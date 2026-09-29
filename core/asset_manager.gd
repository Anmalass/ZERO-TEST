extends Node
# Prototype streaming: manifest -> priority queue -> threaded background loading -> retry -> cache record.
# Later: swap ResourceLoader for CDN download (HTTPRequest) with same states/API.
const MAX_ACTIVE = 2
const MAX_RETRY = 3
var items := {}   # path -> {state, priority, retries, game, res}
var active := []

func load_manifest(game: String, list: Array) -> void:
    for a in list:
        if not items.has(a.path):
            items[a.path] = {"state": "queued", "priority": int(a.priority), "retries": 0, "game": game, "res": null}

func is_ready(path: String) -> bool:
    return items.has(path) and items[path].state == "ready"

func get_asset(path: String):
    return items[path].res if is_ready(path) else null

func percent(tier: int) -> float:
    var total := 0
    var done := 0
    for k in items:
        if items[k].priority <= tier:
            total += 1
            if items[k].state in ["ready", "failed"]:
                done += 1
    return 1.0 if total == 0 else float(done) / total

func tier_done(tier: int) -> bool:
    return percent(tier) >= 1.0

func _process(_d: float) -> void:
    for p in active.duplicate():
        var st = ResourceLoader.load_threaded_get_status(p)
        if st == ResourceLoader.THREAD_LOAD_LOADED:
            items[p].res = ResourceLoader.load_threaded_get(p)
            items[p].state = "ready"
            active.erase(p)
            var f = FileAccess.open(p, FileAccess.READ)
            Cache.record(items[p].game, p, f.get_length() if f else 0)
        elif st == ResourceLoader.THREAD_LOAD_FAILED or st == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
            active.erase(p)
            items[p].retries += 1
            items[p].state = "queued" if items[p].retries < MAX_RETRY else "failed"
    if active.size() < MAX_ACTIVE:
        var q := []
        for k in items:
            if items[k].state == "queued":
                q.append(k)
        q.sort_custom(func(a, b): return items[a].priority < items[b].priority)
        for k in q:
            if active.size() >= MAX_ACTIVE:
                break
            if ResourceLoader.load_threaded_request(k) == OK:
                items[k].state = "loading"
                active.append(k)
            else:
                items[k].retries += 1
                if items[k].retries >= MAX_RETRY:
                    items[k].state = "failed"
