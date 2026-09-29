extends Node
# Local profile + achievements. Swap file IO for server calls later.
const FILE = "user://profile.json"
const ACCOUNTS_FILE = "user://accounts.json"
const SCALE = {"LOW": 0.5, "MEDIUM": 0.75, "HIGH": 1.0, "SUPER": 1.0, "ULTRA": 1.0, "CUSTOM": 0.85}
var data := {"username": "", "email": "", "authenticated": false, "level": 1, "xp": 0, "games_played": 0, "play_time": 0.0,
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


func _accounts() -> Dictionary:
    if not FileAccess.file_exists(ACCOUNTS_FILE):
        return {}
    var parsed = JSON.parse_string(FileAccess.get_file_as_string(ACCOUNTS_FILE))
    return parsed if parsed is Dictionary else {}

func _write_accounts(accounts: Dictionary) -> void:
    var f = FileAccess.open(ACCOUNTS_FILE, FileAccess.WRITE)
    if f:
        f.store_string(JSON.stringify(accounts))

func _hash_password(password: String) -> String:
    var ctx := HashingContext.new()
    ctx.start(HashingContext.HASH_SHA256)
    ctx.update(password.to_utf8_buffer())
    return ctx.finish().hex_encode()

func has_account(email: String) -> bool:
    return _accounts().has(email.strip_edges().to_lower())

func sign_up(username: String, email: String, password: String) -> bool:
    username = username.strip_edges()
    email = email.strip_edges().to_lower()
    if username.length() < 2 or email.length() < 4 or password.length() < 6:
        return false
    var accounts := _accounts()
    if accounts.has(email):
        return false
    accounts[email] = {"username": username, "password": _hash_password(password)}
    _write_accounts(accounts)
    data.username = username
    data.email = email
    data.authenticated = true
    write()
    return true

func sign_in(email: String, password: String) -> bool:
    email = email.strip_edges().to_lower()
    var accounts := _accounts()
    if not accounts.has(email):
        return false
    var account: Dictionary = accounts[email]
    if str(account.get("password", "")) != _hash_password(password):
        return false
    data.username = str(account.get("username", "ANMA"))
    data.email = email
    data.authenticated = true
    write()
    return true

func sign_out() -> void:
    data.authenticated = false
    write()

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
