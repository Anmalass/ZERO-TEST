extends Node3D
const P = "res://games/zero_test/"
const TOTAL = 10
var score := 0
var elapsed := 0.0
var player
var label: Label
var msg: Label
var decor_added := false
var origin := Vector2.ZERO
var dragging := false

func _ready() -> void:
    var env = WorldEnvironment.new()
    var e = Environment.new()
    e.background_mode = Environment.BG_COLOR
    e.background_color = Color("#050706")
    e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    e.ambient_light_color = Color("#7fbf9f")
    e.ambient_light_energy = 0.6
    env.environment = e
    add_child(env)
    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-50, 30, 0)
    sun.shadow_enabled = true
    add_child(sun)
    var body = StaticBody3D.new()
    body.position = Vector3(0, -0.5, 0)
    var cs = CollisionShape3D.new()
    var bs = BoxShape3D.new()
    bs.size = Vector3(60, 1, 60)
    cs.shape = bs
    body.add_child(cs)
    var mi = MeshInstance3D.new()
    var bm = BoxMesh.new()
    bm.size = bs.size
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color("#0f1512")
    bm.material = mat
    mi.mesh = bm
    body.add_child(mi)
    add_child(body)
    player = CharacterBody3D.new()
    player.set_script(_script("player.gd"))
    player.position = Vector3(0, 1, 0)
    add_child(player)
    for i in TOTAL:
        var c = Area3D.new()
        c.set_script(_script("coin.gd"))
        c.position = Vector3(randf_range(-22, 22), 1, randf_range(-22, 22))
        c.collected.connect(_on_coin)
        add_child(c)
    _hud()

func _script(f: String):
    var s = Assets.get_asset(P + f)
    return s if s != null else load(P + f)

func _hud() -> void:
    var cl = CanvasLayer.new()
    add_child(cl)
    label = Label.new()
    label.position = Vector2(20, 16)
    label.add_theme_font_size_override("font_size", 26)
    cl.add_child(label)
    msg = Label.new()
    msg.position = Vector2(20, 60)
    msg.add_theme_font_size_override("font_size", 22)
    cl.add_child(msg)
    var b = Button.new()
    b.text = "BACK (ESC)"
    b.position = Vector2(1080, 16)
    b.custom_minimum_size = Vector2(170, 56)
    b.pressed.connect(_back)
    cl.add_child(b)

func _process(d: float) -> void:
    elapsed += d
    label.text = "Coins %d/%d   Time %.0fs" % [score, TOTAL, elapsed]
    if not decor_added and Assets.is_ready(P + "decor.gd"):
        decor_added = true
        var n = Node3D.new()
        n.set_script(Assets.get_asset(P + "decor.gd"))
        add_child(n)
        msg.text = "Background assets streamed in."

func _on_coin() -> void:
    score += 1
    if score == TOTAL:
        msg.text = "All coins collected!" + ("  Achievement unlocked!" if Save.unlock("coin_collector") else "")
        Save.write()

func _input(ev: InputEvent) -> void:
    if ev is InputEventKey and ev.pressed and ev.keycode == KEY_ESCAPE:
        _back()
    elif ev is InputEventScreenTouch and ev.position.x < 640:
        dragging = ev.pressed
        origin = ev.position
        if not ev.pressed:
            player.touch_dir = Vector2.ZERO
    elif ev is InputEventScreenDrag and dragging:
        player.touch_dir = ((ev.position - origin) / 80.0).limit_length(1.0)

func _back() -> void:
    Save.end_game()
    get_tree().change_scene_to_file("res://launcher/launcher.tscn")
