extends Node3D
const P = "res://games/zero_test/"
const TOTAL = 10
var score := 0
var elapsed := 0.0
var player
var label: Label
var msg: Label
var decor_added := false
var menu_layer: CanvasLayer
var menu_panel: PanelContainer
var joystick

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
    var cl := CanvasLayer.new()
    cl.layer = 10
    add_child(cl)

    label = Label.new()
    label.position = Vector2(20, 16)
    label.add_theme_font_size_override("font_size", 26)
    cl.add_child(label)

    msg = Label.new()
    msg.position = Vector2(20, 60)
    msg.add_theme_font_size_override("font_size", 18)
    msg.add_theme_color_override("font_color", Color("#9eb0a7"))
    cl.add_child(msg)

    var menu := Button.new()
    menu.text = "MENU"
    menu.anchor_left = 1.0
    menu.anchor_right = 1.0
    menu.offset_left = -150
    menu.offset_right = -20
    menu.offset_top = 18
    menu.offset_bottom = 70
    menu.pressed.connect(_toggle_menu)
    cl.add_child(menu)

    # Virtual analog. It is primarily intended for Android/touch devices.
    joystick = _script("mobile_joystick.gd").new()
    joystick.position = Vector2(24, 0)
    joystick.anchor_top = 1.0
    joystick.anchor_bottom = 1.0
    joystick.offset_top = -190
    joystick.offset_bottom = -20
    joystick.vector_changed.connect(_on_joystick)
    cl.add_child(joystick)

    _build_menu(cl)

func _on_joystick(value: Vector2) -> void:
    if player:
        player.touch_dir = value

func _build_menu(cl: CanvasLayer) -> void:
    var overlay := ColorRect.new()
    overlay.name = "PauseOverlay"
    overlay.color = Color(0.01, 0.02, 0.015, 0.78)
    overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.mouse_filter = Control.MOUSE_FILTER_STOP
    overlay.process_mode = Node.PROCESS_MODE_ALWAYS
    overlay.visible = false
    cl.add_child(overlay)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    overlay.add_child(center)

    menu_panel = PanelContainer.new()
    menu_panel.custom_minimum_size = Vector2(440, 0)
    menu_panel.add_theme_stylebox_override("panel", _panel_style(Color("#0b120f"), Color("#2ee59d"), 20, 1))
    center.add_child(menu_panel)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 28)
    margin.add_theme_constant_override("margin_right", 28)
    margin.add_theme_constant_override("margin_top", 24)
    margin.add_theme_constant_override("margin_bottom", 24)
    menu_panel.add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 10)
    margin.add_child(box)

    var title := Label.new()
    title.text = "GAME MENU"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28)
    title.add_theme_color_override("font_color", Color("#edf5f0"))
    box.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Zero Test"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_color_override("font_color", Color("#82918a"))
    box.add_child(subtitle)

    var cont := Button.new()
    cont.text = "CONTINUE"
    cont.custom_minimum_size = Vector2(0, 52)
    cont.pressed.connect(_close_menu)
    box.add_child(cont)

    var settings := Button.new()
    settings.text = "SETTINGS"
    settings.custom_minimum_size = Vector2(0, 52)
    settings.pressed.connect(_show_settings)
    box.add_child(settings)

    var restart := Button.new()
    restart.text = "RESTART GAME"
    restart.custom_minimum_size = Vector2(0, 52)
    restart.pressed.connect(_restart_game)
    box.add_child(restart)

    var exit := Button.new()
    exit.text = "EXIT TO LAUNCHER"
    exit.custom_minimum_size = Vector2(0, 52)
    exit.pressed.connect(_back)
    box.add_child(exit)

    menu_panel.set_meta("overlay", overlay)

func _panel_style(bg: Color, border: Color, radius := 16, width := 1) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(width)
    s.set_corner_radius_all(radius)
    s.set_content_margin_all(16)
    return s

func _toggle_menu() -> void:
    if menu_panel == null:
        return
    var overlay: ColorRect = menu_panel.get_meta("overlay")
    overlay.visible = not overlay.visible
    get_tree().paused = overlay.visible
    menu_panel.get_parent().process_mode = Node.PROCESS_MODE_ALWAYS

func _close_menu() -> void:
    var overlay: ColorRect = menu_panel.get_meta("overlay")
    overlay.visible = false
    get_tree().paused = false

func _show_settings() -> void:
    var overlay: ColorRect = menu_panel.get_meta("overlay")
    var popup := PanelContainer.new()
    popup.name = "SettingsPopup"
    popup.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
    popup.custom_minimum_size = Vector2(420, 0)
    popup.add_theme_stylebox_override("panel", _panel_style(Color("#0b120f"), Color("#2ee59d"), 18, 1))
    overlay.add_child(popup)

    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 24)
    margin.add_theme_constant_override("margin_right", 24)
    margin.add_theme_constant_override("margin_top", 20)
    margin.add_theme_constant_override("margin_bottom", 20)
    popup.add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 10)
    margin.add_child(box)

    var title := Label.new()
    title.text = "SETTINGS"
    title.add_theme_font_size_override("font_size", 25)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)

    var graphics := OptionButton.new()
    for key in Save.SCALE:
        graphics.add_item(key)
        if key == Save.data.graphics:
            graphics.select(graphics.item_count - 1)
    graphics.item_selected.connect(func(index):
        Save.data.graphics = graphics.get_item_text(index)
        Save.apply_graphics()
        Save.write()
    )
    box.add_child(graphics)

    var close := Button.new()
    close.text = "BACK"
    close.custom_minimum_size = Vector2(0, 48)
    close.pressed.connect(func():
        popup.queue_free()
    )
    box.add_child(close)

func _restart_game() -> void:
    get_tree().paused = false
    Save.end_game()
    get_tree().reload_current_scene()

func _process(d: float) -> void:
    if not get_tree().paused:
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
        _toggle_menu()
    elif ev is InputEventJoypadButton and ev.pressed:
        if ev.button_index == JOY_BUTTON_START or ev.button_index == JOY_BUTTON_BACK:
            _toggle_menu()

func _back() -> void:
    get_tree().paused = false
    Save.end_game()
    get_tree().change_scene_to_file("res://launcher/launcher.tscn")
