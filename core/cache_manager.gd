extends Node
# Tracks local asset cache per game. Never touches profile/achievements/library.
const FILE = "user://cache.json"
var limit_mb := 500
var data := {}  # game_id -> {"files": {path: bytes}, "last_used": unix}

func _ready() -> void:
    if FileAccess.file_exists(FILE):
        var d = JSON.parse_string(FileAccess.get_file_as_string(FILE))
        if d is Dictionary:
            data = d

func _write() -> void:
    var f = FileAccess.open(FILE, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))

func record(game: String, path: String, bytes: int) -> void:
    if not data.has(game):
        data[game] = {"files": {}, "last_used": 0}
    data[game].files[path] = bytes
    data[game].last_used = Time.get_unix_time_from_system()
    _evict()
    _write()

func game_bytes(game: String) -> int:
    var t := 0
    if data.has(game):
        for p in data[game].files:
            t += int(data[game].files[p])
    return t

func total_bytes() -> int:
    var t := 0
    for g in data:
        t += game_bytes(g)
    return t

func _evict() -> void:
    while total_bytes() > limit_mb * 1048576 and data.size() > 1:
        var oldest := ""
        for g in data:
            if oldest == "" or data[g].last_used < data[oldest].last_used:
                oldest = g
        data.erase(oldest)

func clear() -> void:
    data.clear()
    _write()
