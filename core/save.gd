extends Node
# Local profile + achievements. Swap file IO for server calls later.
const FILE = "user://profile.json"
const SCALE = {"LOW": 0.5, "MEDIUM": 0.75, "HIGH": 1.0, "SUPER": 1.0, "ULTRA": 1.0, "CUSTOM": 0.85}
var data := {"username": "ANMA", "level": 1, "xp": 0, "games_played": 0, "play_time": 0.0,
    "multiplayer_sessions": 0, "achievements": [], "last_game": "", "graphics": "MEDIUM"}
var defs := {}
var session_start := 0.0

func _ready() -> void:
    var arr = JSON.parse_string(FileAccess.get_file_as_string("res://platform/achievements.json"))
    if arr is Array:
        for a in arr:
            defs[a.id] = a
    if FileAccess.file_exists(FILE):
        var d = JSON.parse_string(FileAccess.get_file_as_string(FILE))
        if d is Dictionary:
            for k in d:
                data[k] = d[k]
    apply_graphics()

func write() -> void:
    var f = FileAccess.open(FILE, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(data))

func add_xp(n: int) -> void:
    data.xp = int(data.xp) + n
    data.level = int(data.level)
    while data.xp >= data.level * 100:
        data.xp -= data.level * 100
        data.level += 1
    write()

func unlock(id: String) -> bool:
    if data.achievements.has(id) or not defs.has(id):
        return false
    data.achievements.append(id)
    add_xp(int(defs[id].xp))
    return true

func start_game(id: String) -> void:
    data.games_played = int(data.games_played) + 1
    data.last_game = id
    session_start = Time.get_unix_time_from_system()
    unlock("first_game")
    write()

func end_game() -> void:
    if session_start > 0.0:
        data.play_time = float(data.play_time) + Time.get_unix_time_from_system() - session_start
        session_start = 0.0
        write()

func apply_graphics() -> void:
    get_viewport().scaling_3d_scale = SCALE.get(data.graphics, 0.75)
