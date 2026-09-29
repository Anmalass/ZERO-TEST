extends Control
const BG = Color("#07090a")
const CARD = Color("#101412")
const ACC = Color("#2ee59d")
const DIM = Color("#7f8c86")
const TABS = ["HOME", "LIBRARY", "STORE", "FRIENDS", "PROFILE", "SETTINGS"]
var games := {}
var page: VBoxContainer

func _ready() -> void:
    theme = _make_theme()
    Save.end_game()
    _scan()
    var bg = ColorRect.new()
    bg.color = BG
    bg.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var tex = TextureRect.new()
    tex.texture = load("res://platform/carbon.png")
    tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    tex.stretch_mode = TextureRect.STRETCH_TILE
    tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    tex.set_anchors_preset(Control.PRESET_FULL_RECT)
    tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(tex)
    var root = VBoxContainer.new()
    root.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(root)
    var bar = HBoxContainer.new()
    root.add_child(bar)
    for t in TABS:
        var b = Button.new()
        b.text = t
        b.custom_minimum_size = Vector2(0, 56)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(show_tab.bind(t))
        bar.add_child(b)
    var sc = ScrollContainer.new()
    sc.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(sc)
    var mc = MarginContainer.new()
    mc.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for m in ["left", "right", "top", "bottom"]:
        mc.add_theme_constant_override("margin_" + m, 16)
    sc.add_child(mc)
    page = VBoxContainer.new()
    page.add_theme_constant_override("separation", 12)
    mc.add_child(page)
    Save.unlock("first_launch")
    Save.write()
    show_tab("HOME")

func _scan() -> void:
    var d = DirAccess.open("res://games")
    if d == null:
        return
    for n in d.get_directories():
        var p = "res://games/%s/manifest.json" % n
        if FileAccess.file_exists(p):
            var j = JSON.parse_string(FileAccess.get_file_as_string(p))
            if j is Dictionary and j.has("id"):
                games[j.id] = j

func _lbl(t: String, s := 18, c := Color.WHITE) -> Label:
    var l = Label.new()
    l.text = t
    l.add_theme_font_size_override("font_size", s)
    l.add_theme_color_override("font_color", c)
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return l

func _card() -> VBoxContainer:
    var p = PanelContainer.new()
    var sb = StyleBoxFlat.new()
    sb.bg_color = CARD
    sb.set_corner_radius_all(6)
    sb.set_border_width_all(1)
    sb.border_color = Color("#22302a")
    sb.set_content_margin_all(16)
    p.add_theme_stylebox_override("panel", sb)
    p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    var v = VBoxContainer.new()
    p.add_child(v)
    page.add_child(p)
    return v

func _btn(t: String, cb: Callable) -> Button:
    var b = Button.new()
    b.text = t
    b.custom_minimum_size = Vector2(0, 56)
    b.pressed.connect(cb)
    return b

func show_tab(t: String) -> void:
    for c in page.get_children():
        c.queue_free()
    match t:
        "HOME": _home()
        "LIBRARY": _library()
        "PROFILE": _profile()
        "SETTINGS": _settings()
        _:
            var v = _card()
            v.add_child(_lbl(t, 28))
            v.add_child(_lbl("Planned for a later phase. See README roadmap.", 16, DIM))

func _home() -> void:
    var v = _card()
    v.add_child(_lbl("PROJECT ZERO", 34, ACC))
    v.add_child(_lbl("%s  |  Lv %d  |  XP %d/%d" % [Save.data.username, int(Save.data.level), int(Save.data.xp), int(Save.data.level) * 100], 16, DIM))
    var last = str(Save.data.last_game)
    if last != "" and games.has(last):
        var c = _card()
        c.add_child(_lbl("Continue Playing", 14, DIM))
        c.add_child(_lbl(games[last].name, 24))
        c.add_child(_btn("PLAY", play.bind(last)))
    page.add_child(_lbl("Discover", 22))
    for id in games:
        _game_card(id)

func _library() -> void:
    page.add_child(_lbl("Library", 28))
    for id in games:
        _game_card(id)

func _game_card(id: String) -> void:
    var g = games[id]
    var v = _card()
    v.add_child(_lbl(g.name.to_upper(), 24))
    v.add_child(_lbl("%s  |  %s" % [", ".join(g.genre), ", ".join(g.modes)], 14, DIM))
    v.add_child(_lbl("PLAYABLE" if g.status == "playable" else "COMING SOON", 14, ACC))
    v.add_child(_btn("OPEN", open_game.bind(id)))

func open_game(id: String) -> void:
    for c in page.get_children():
        c.queue_free()
    var g = games[id]
    var v = _card()
    v.add_child(_lbl(g.name.to_upper(), 30))
    v.add_child(_lbl("v%s  |  min launcher %s" % [g.version, g.minimum_version], 14, DIM))
    v.add_child(_lbl(g.about, 18))
    var b = _btn("PLAY" if g.status == "playable" else "COMING SOON", play.bind(id))
    b.disabled = g.status != "playable"
    v.add_child(b)
    v.add_child(_btn("BACK", show_tab.bind("LIBRARY")))

func _profile() -> void:
    var v = _card()
    v.add_child(_lbl(str(Save.data.username), 30))
    v.add_child(_lbl("Level %d  |  XP %d/%d" % [int(Save.data.level), int(Save.data.xp), int(Save.data.level) * 100], 16, DIM))
    v.add_child(_lbl("Games played: %d\nPlay time: %d min\nMultiplayer sessions: %d" % [int(Save.data.games_played), int(float(Save.data.play_time) / 60.0), int(Save.data.multiplayer_sessions)], 18))
    page.add_child(_lbl("Achievements", 22))
    for id in Save.defs:
        var a = Save.defs[id]
        var c = _card()
        c.add_child(_lbl(("[x] " if Save.data.achievements.has(id) else "[ ] ") + a.name + "  (" + a.rarity + ")", 18))
        c.add_child(_lbl(a.description, 14, DIM))

func _settings() -> void:
    var v = _card()
    v.add_child(_lbl("Graphics", 24))
    var ob = OptionButton.new()
    ob.custom_minimum_size = Vector2(0, 56)
    var i := 0
    for k in Save.SCALE:
        ob.add_item(k)
        if k == Save.data.graphics:
            ob.select(i)
        i += 1
    ob.item_selected.connect(_on_graphics.bind(ob))
    v.add_child(ob)
    var c = _card()
    c.add_child(_lbl("Cache", 24))
    var info = _lbl("", 16, DIM)
    c.add_child(info)
    _cache_info(info)
    c.add_child(_btn("CLEAR CACHE", _clear_cache.bind(info)))

func _on_graphics(idx: int, ob: OptionButton) -> void:
    Save.data.graphics = ob.get_item_text(idx)
    Save.apply_graphics()
    Save.write()

func _cache_info(info: Label) -> void:
    info.text = "Total: %.2f KB (limit %d MB)\nZero Test: %.2f KB" % [Cache.total_bytes() / 1024.0, Cache.limit_mb, Cache.game_bytes("zero_test") / 1024.0]

func _clear_cache(info: Label) -> void:
    Cache.clear()
    _cache_info(info)

func play(id: String) -> void:
    var m = games[id]
    if m.status != "playable" or m.entry == "":
        return
    var ov = ColorRect.new()
    ov.color = BG
    ov.set_anchors_preset(Control.PRESET_FULL_RECT)
    add_child(ov)
    var v = VBoxContainer.new()
    v.set_anchors_preset(Control.PRESET_CENTER)
    ov.add_child(v)
    var l = _lbl("CONNECTING...", 28)
    v.add_child(l)
    var pb = ProgressBar.new()
    pb.custom_minimum_size = Vector2(420, 24)
    v.add_child(pb)
    Assets.load_manifest(id, m.assets)
    while not Assets.tier_done(1):
        l.text = "LOADING " + m.name.to_upper()
        pb.value = Assets.percent(1) * 100.0
        await get_tree().process_frame
    pb.value = 100
    l.text = "PLAYABLE"
    await get_tree().create_timer(0.3).timeout
    Save.start_game(id)
    get_tree().change_scene_to_file(m.entry)

func _sb(bg: Color, border: Color, bw := 1) -> StyleBoxFlat:
    var s = StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(bw)
    s.set_corner_radius_all(6)
    s.set_content_margin_all(10)
    return s

func _make_theme() -> Theme:
    var t = Theme.new()
    for cls in ["Button", "OptionButton"]:
        t.set_stylebox("normal", cls, _sb(Color("#111714"), Color("#26332d")))
        t.set_stylebox("hover", cls, _sb(Color("#16201b"), ACC))
        t.set_stylebox("pressed", cls, _sb(ACC, ACC))
        t.set_stylebox("disabled", cls, _sb(Color("#0d100e"), Color("#1a211d")))
        t.set_stylebox("focus", cls, _sb(Color(0, 0, 0, 0), ACC))
        t.set_color("font_color", cls, Color("#e8efe9"))
        t.set_color("font_hover_color", cls, ACC)
        t.set_color("font_pressed_color", cls, Color("#04110b"))
        t.set_color("font_disabled_color", cls, Color("#4a5750"))
    t.set_stylebox("fill", "ProgressBar", _sb(ACC, ACC, 0))
    t.set_stylebox("background", "ProgressBar", _sb(Color("#111714"), Color("#26332d")))
    return t
