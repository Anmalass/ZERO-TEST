extends Control

# PROJECT ZERO — modern responsive launcher UI
const BG := Color("#060908")
const PANEL := Color("#0c1210")
const PANEL_2 := Color("#101815")
const PANEL_HOVER := Color("#14211b")
const BORDER := Color("#1c2b24")
const BORDER_HI := Color("#2ee59d")
const ACC := Color("#2ee59d")
const ACC_DARK := Color("#123c2d")
const TEXT := Color("#edf5f0")
const DIM := Color("#82918a")
const MUTED := Color("#53615b")

const TABS := ["HOME", "LIBRARY", "STORE", "FRIENDS", "PROFILE", "SETTINGS"]

var games := {}
var page: VBoxContainer
var nav_buttons: Dictionary = {}
var scroll: ScrollContainer

func _ready() -> void:
    theme = _make_theme()
    Save.end_game()
    _scan()
    # The launcher is usable as a guest. Authentication is only required when
    # the user actually tries to launch a playable game.
    _build_ui()
    if bool(Save.data.get("authenticated", false)):
        Save.unlock("first_launch")
        Save.write()
    show_tab("HOME")

func _build_auth() -> void:
    # First-launch authentication screen. Credentials are stored locally for this prototype.
    var bg := ColorRect.new()
    bg.color = BG
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var carbon := TextureRect.new()
    carbon.texture = load("res://platform/carbon.png")
    carbon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    carbon.stretch_mode = TextureRect.STRETCH_TILE
    carbon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    carbon.modulate = Color(1, 1, 1, 0.08)
    carbon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    carbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(carbon)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)

    var shell := PanelContainer.new()
    shell.custom_minimum_size = Vector2(430, 0)
    shell.add_theme_stylebox_override("panel", _panel_style(PANEL, BORDER_HI, 22, 1))
    center.add_child(shell)

    var margin := MarginContainer.new()
    _set_margins(margin, 34, 34, 30, 30)
    shell.add_child(margin)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 13)
    margin.add_child(box)

    var brand := _lbl("ZERO", 34, ACC)
    brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(brand)
    var title := _lbl("PROJECT ZERO", 22, TEXT)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)
    var subtitle := _lbl("Sign in to continue", 13, DIM)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(subtitle)

    var email := LineEdit.new()
    email.name = "Email"
    email.placeholder_text = "Email"
    email.custom_minimum_size = Vector2(0, 48)
    box.add_child(email)

    var password := LineEdit.new()
    password.name = "Password"
    password.placeholder_text = "Password"
    password.secret = true
    password.custom_minimum_size = Vector2(0, 48)
    box.add_child(password)

    var status := _lbl("", 12, Color("#ff8b8b"))
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(status)

    var signin := _btn("SIGN IN", func():
        if Save.sign_in(email.text, password.text):
            _reload_launcher()
        else:
            status.text = "Email atau password salah."
    , true)
    signin.custom_minimum_size = Vector2(0, 52)
    box.add_child(signin)

    var divider := HSeparator.new()
    box.add_child(divider)

    var signup_title := _lbl("New to Project Zero?", 12, DIM)
    signup_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(signup_title)

    var signup := _btn("CREATE ACCOUNT", func():
        _show_signup()
    )
    signup.custom_minimum_size = Vector2(0, 48)
    box.add_child(signup)

    var back := _btn("BACK TO PROFILE", func():
        for c in get_children():
            c.queue_free()
        await get_tree().process_frame
        _build_ui()
        show_tab("PROFILE")
    )
    box.add_child(back)

func _show_signup() -> void:
    for c in get_children():
        c.queue_free()
    await get_tree().process_frame

    var bg := ColorRect.new()
    bg.color = BG
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)
    var shell := PanelContainer.new()
    shell.custom_minimum_size = Vector2(430, 0)
    shell.add_theme_stylebox_override("panel", _panel_style(PANEL, BORDER_HI, 22, 1))
    center.add_child(shell)
    var margin := MarginContainer.new()
    _set_margins(margin, 34, 34, 30, 30)
    shell.add_child(margin)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 13)
    margin.add_child(box)

    var title := _lbl("CREATE ACCOUNT", 28, TEXT)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)
    var sub := _lbl("Create your local Project Zero account", 13, DIM)
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(sub)

    var username := LineEdit.new()
    username.placeholder_text = "Username"
    username.custom_minimum_size = Vector2(0, 48)
    box.add_child(username)
    var email := LineEdit.new()
    email.placeholder_text = "Email"
    email.custom_minimum_size = Vector2(0, 48)
    box.add_child(email)
    var password := LineEdit.new()
    password.placeholder_text = "Password (min. 6 characters)"
    password.secret = true
    password.custom_minimum_size = Vector2(0, 48)
    box.add_child(password)
    var confirm := LineEdit.new()
    confirm.placeholder_text = "Confirm password"
    confirm.secret = true
    confirm.custom_minimum_size = Vector2(0, 48)
    box.add_child(confirm)
    var status := _lbl("", 12, Color("#ff8b8b"))
    status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(status)

    var create := _btn("CREATE ACCOUNT", func():
        if password.text != confirm.text:
            status.text = "Password tidak sama."
        elif Save.sign_up(username.text, email.text, password.text):
            _reload_launcher()
        else:
            status.text = "Isi data dengan benar atau email sudah digunakan."
    , true)
    create.custom_minimum_size = Vector2(0, 52)
    box.add_child(create)
    var back := _btn("BACK TO SIGN IN", func(): _reload_auth())
    box.add_child(back)

func _reload_auth() -> void:
    for c in get_children():
        c.queue_free()
    await get_tree().process_frame
    _build_auth()

func _reload_launcher() -> void:
    get_tree().reload_current_scene()

func _build_ui() -> void:
    # Full-screen dark background.
    var bg := ColorRect.new()
    bg.color = BG
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    var carbon := TextureRect.new()
    carbon.texture = load("res://platform/carbon.png")
    carbon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    carbon.stretch_mode = TextureRect.STRETCH_TILE
    carbon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    carbon.modulate = Color(1, 1, 1, 0.10)
    carbon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    carbon.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(carbon)

    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 0)
    add_child(root)

    # Header.
    var header := PanelContainer.new()
    header.custom_minimum_size = Vector2(0, 72)
    header.add_theme_stylebox_override("panel", _panel_style(PANEL, BORDER, 0, 0))
    root.add_child(header)

    var header_margin := MarginContainer.new()
    _set_margins(header_margin, 22, 22, 10, 10)
    header.add_child(header_margin)

    var header_row := HBoxContainer.new()
    header_row.add_theme_constant_override("separation", 14)
    header_margin.add_child(header_row)

    var logo := Label.new()
    logo.text = "ZERO"
    logo.add_theme_font_size_override("font_size", 25)
    logo.add_theme_color_override("font_color", ACC)
    logo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    header_row.add_child(logo)

    var title := Label.new()
    title.text = "PROJECT"
    title.add_theme_font_size_override("font_size", 16)
    title.add_theme_color_override("font_color", TEXT)
    title.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    header_row.add_child(title)

    var spacer := Control.new()
    spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    header_row.add_child(spacer)

    var user := Label.new()
    user.text = "%s  •  ONLINE" % str(Save.data.username)
    user.add_theme_font_size_override("font_size", 13)
    user.add_theme_color_override("font_color", DIM)
    user.size_flags_vertical = Control.SIZE_SHRINK_CENTER
    header_row.add_child(user)

    # Navigation.
    var nav_panel := PanelContainer.new()
    nav_panel.custom_minimum_size = Vector2(0, 66)
    nav_panel.add_theme_stylebox_override("panel", _panel_style(Color("#090d0b"), BORDER, 0, 0))
    root.add_child(nav_panel)

    var nav_margin := MarginContainer.new()
    _set_margins(nav_margin, 14, 14, 8, 8)
    nav_panel.add_child(nav_margin)

    var nav := HBoxContainer.new()
    nav.add_theme_constant_override("separation", 8)
    nav_margin.add_child(nav)

    for tab in TABS:
        var b := Button.new()
        b.text = tab
        b.custom_minimum_size = Vector2(108, 46)
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(show_tab.bind(tab))
        nav.add_child(b)
        nav_buttons[tab] = b

    # Main scrolling area.
    scroll = ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    root.add_child(scroll)

    var content_margin := MarginContainer.new()
    content_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _set_margins(content_margin, 22, 22, 20, 30)
    scroll.add_child(content_margin)

    page = VBoxContainer.new()
    page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page.add_theme_constant_override("separation", 14)
    content_margin.add_child(page)

func _scan() -> void:
    var d := DirAccess.open("res://games")
    if d == null:
        return
    for n in d.get_directories():
        var p := "res://games/%s/manifest.json" % n
        if FileAccess.file_exists(p):
            var j = JSON.parse_string(FileAccess.get_file_as_string(p))
            if j is Dictionary and j.has("id"):
                games[j.id] = j

func _set_margins(c: MarginContainer, left: int, right: int, top: int, bottom: int) -> void:
    c.add_theme_constant_override("margin_left", left)
    c.add_theme_constant_override("margin_right", right)
    c.add_theme_constant_override("margin_top", top)
    c.add_theme_constant_override("margin_bottom", bottom)

func _lbl(t: String, s := 18, c := TEXT) -> Label:
    var l := Label.new()
    l.text = t
    l.add_theme_font_size_override("font_size", s)
    l.add_theme_color_override("font_color", c)
    l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    return l

func _panel_style(bg: Color, border: Color, radius := 14, width := 1) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(width)
    s.set_corner_radius_all(radius)
    s.set_content_margin_all(18)
    return s

func _card(title := "", accent := false) -> VBoxContainer:
    var p := PanelContainer.new()
    p.add_theme_stylebox_override(
        "panel",
        _panel_style(PANEL_2, BORDER_HI if accent else BORDER, 16, 1)
    )
    p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page.add_child(p)

    var v := VBoxContainer.new()
    v.add_theme_constant_override("separation", 8)
    p.add_child(v)

    if title != "":
        v.add_child(_lbl(title, 13, ACC if accent else DIM))
    return v

func _btn(t: String, cb: Callable, accent := false) -> Button:
    var b := Button.new()
    b.text = t
    b.custom_minimum_size = Vector2(0, 48)
    b.pressed.connect(cb)
    if accent:
        b.add_theme_stylebox_override("normal", _sb(ACC, ACC, 12))
        b.add_theme_color_override("font_color", Color("#04110b"))
        b.add_theme_color_override("font_hover_color", Color("#04110b"))
    return b

func _section_title(title: String, subtitle: String = "") -> void:
    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 10)
    page.add_child(row)
    var left := VBoxContainer.new()
    left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    left.add_child(_lbl(title, 24, TEXT))
    if subtitle != "":
        left.add_child(_lbl(subtitle, 13, DIM))
    row.add_child(left)

func _update_nav(active: String) -> void:
    for tab in nav_buttons:
        var b: Button = nav_buttons[tab]
        b.add_theme_stylebox_override("normal", _sb(ACC_DARK if tab == active else Color("#0d1310"), ACC if tab == active else BORDER, 12))
        b.add_theme_color_override("font_color", ACC if tab == active else DIM)
        b.add_theme_color_override("font_hover_color", TEXT)

func show_tab(t: String) -> void:
    _update_nav(t)
    for c in page.get_children():
        c.queue_free()
    scroll.scroll_vertical = 0

    match t:
        "HOME":
            _home()
        "LIBRARY":
            _library()
        "PROFILE":
            _profile()
        "SETTINGS":
            _settings()
        "STORE":
            _coming_soon("STORE", "Digital store, game updates and future content will live here.")
        "FRIENDS":
            _coming_soon("FRIENDS", "Friends, online status and multiplayer sessions are planned.")

func _home() -> void:
    var hero := _card("", true)
    var top := HBoxContainer.new()
    top.add_theme_constant_override("separation", 18)
    hero.add_child(top)

    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.add_child(_lbl("WELCOME BACK", 13, ACC))
    info.add_child(_lbl("PROJECT ZERO", 31, TEXT))
    info.add_child(_lbl("%s  •  LEVEL %d" % [str(Save.data.username), int(Save.data.level)], 15, DIM))
    top.add_child(info)

    var badge := _lbl("ZERO", 16, ACC)
    badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    badge.custom_minimum_size = Vector2(76, 76)
    badge.add_theme_stylebox_override("normal", _sb(ACC_DARK, BORDER_HI, 38))
    top.add_child(badge)

    var xp := int(Save.data.xp)
    var need := max(1, int(Save.data.level) * 100)
    var xp_row := HBoxContainer.new()
    xp_row.add_child(_lbl("XP", 12, DIM))
    var xp_spacer := Control.new()
    xp_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    xp_row.add_child(xp_spacer)
    xp_row.add_child(_lbl("%d / %d" % [xp, need], 12, DIM))
    hero.add_child(xp_row)

    var bar := ProgressBar.new()
    bar.custom_minimum_size = Vector2(0, 8)
    bar.max_value = need
    bar.value = xp
    bar.show_percentage = false
    hero.add_child(bar)

    var last := str(Save.data.last_game)
    if last != "" and games.has(last):
        _section_title("CONTINUE PLAYING", "Jump back into your latest game.")
        _continue_card(last)

    _section_title("DISCOVER", "Your games and upcoming projects.")
    for id in games:
        _game_card(id)

func _continue_card(id: String) -> void:
    var g: Dictionary = games[id]
    var p := PanelContainer.new()
    p.add_theme_stylebox_override("panel", _panel_style(PANEL_2, BORDER, 16, 1))
    p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page.add_child(p)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 16)
    p.add_child(row)

    var icon := TextureRect.new()
    icon.texture = load("res://icon.png")
    icon.custom_minimum_size = Vector2(76, 76)
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    row.add_child(icon)

    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.add_child(_lbl(g.name, 22, TEXT))
    info.add_child(_lbl("%s  •  %s" % [", ".join(g.genre), ", ".join(g.modes)], 13, DIM))
    var play_button := _btn("PLAY", play.bind(id), true)
play_button.custom_minimum_size = Vector2(150, 48)
row.add_child(info)
row.add_child(play_button)

func _library() -> void:
    _section_title("LIBRARY", "%d project%s available." % [games.size(), "" if games.size() == 1 else "s"])
    for id in games:
        _game_card(id)

func _game_card(id: String) -> void:
    var g: Dictionary = games[id]
    var p := PanelContainer.new()
    p.add_theme_stylebox_override("panel", _panel_style(PANEL_2, BORDER, 16, 1))
    p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page.add_child(p)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 16)
    p.add_child(row)

    var icon := TextureRect.new()
    icon.texture = load("res://icon.png")
    icon.custom_minimum_size = Vector2(64, 64)
    icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    row.add_child(icon)

    var info := VBoxContainer.new()
    info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    info.add_child(_lbl(g.name.to_upper(), 21, TEXT))
    info.add_child(_lbl("%s  •  %s" % [", ".join(g.genre), ", ".join(g.modes)], 13, DIM))
    info.add_child(_lbl("PLAYABLE" if g.status == "playable" else "COMING SOON", 12, ACC if g.status == "playable" else DIM))
    row.add_child(info)

    var open := _btn("OPEN", open_game.bind(id), g.status == "playable")
    open.custom_minimum_size = Vector2(130, 48)
    row.add_child(open)

func open_game(id: String) -> void:
    for c in page.get_children():
        c.queue_free()
    var g: Dictionary = games[id]

    var back := _btn("‹  LIBRARY", show_tab.bind("LIBRARY"))
    back.custom_minimum_size = Vector2(140, 44)
    page.add_child(back)

    var v := _card("", g.status == "playable")
    v.add_child(_lbl(g.name.to_upper(), 30, TEXT))
    v.add_child(_lbl("v%s  •  minimum launcher %s" % [g.version, g.minimum_version], 13, DIM))
    v.add_child(_lbl(g.about, 17, TEXT))

    var play_button := _btn("PLAY" if g.status == "playable" else "COMING SOON", play.bind(id), true)
    play_button.disabled = g.status != "playable"
    v.add_child(play_button)

func _open_auth_from_profile() -> void:
    for c in get_children():
        c.queue_free()
    await get_tree().process_frame
    _build_auth()

func _profile() -> void:
    _section_title("PROFILE", "Your Project Zero account and local progress.")

    if not bool(Save.data.get("authenticated", false)):
        var guest := _card("", true)
        guest.add_child(_lbl("GUEST MODE", 30, TEXT))
        guest.add_child(_lbl("You can browse Home and Library without an account. Sign in or create an account when you want to play.", 15, DIM))
        var row := HBoxContainer.new()
        row.add_theme_constant_override("separation", 10)
        var signin := _btn("SIGN IN", _open_auth_from_profile, true)
        signin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(signin)
        var signup := _btn("CREATE ACCOUNT", func():
            _open_auth_from_profile()
            await get_tree().process_frame
            _show_signup()
        )
        signup.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(signup)
        guest.add_child(row)

        var info := _card("WHY ACCOUNT?")
        info.add_child(_lbl("Your account unlocks game launching and keeps your local profile, XP and achievements together on this device.", 14, DIM))
        return

    var v := _card("", true)
    v.add_child(_lbl(str(Save.data.username), 30, TEXT))
    v.add_child(_lbl(str(Save.data.email), 13, DIM))
    v.add_child(_lbl("LEVEL %d" % int(Save.data.level), 14, ACC))

    var xp := int(Save.data.xp)
    var need := max(1, int(Save.data.level) * 100)
    var bar := ProgressBar.new()
    bar.max_value = need
    bar.value = xp
    bar.show_percentage = false
    bar.custom_minimum_size = Vector2(0, 8)
    v.add_child(bar)
    v.add_child(_lbl("%d / %d XP" % [xp, need], 13, DIM))

    var stats := _card("ACTIVITY")
    stats.add_child(_lbl(
        "Games played     %d\nPlay time          %d min\nMultiplayer        %d sessions" %
        [int(Save.data.games_played), int(float(Save.data.play_time) / 60.0), int(Save.data.multiplayer_sessions)],
        17, TEXT
    ))

    _section_title("ACHIEVEMENTS")
    for id in Save.defs:
        var a: Dictionary = Save.defs[id]
        var unlocked := Save.data.achievements.has(id)
        var c := _card()
        c.add_child(_lbl(
            ("✓  " if unlocked else "○  ") + a.name,
            17, ACC if unlocked else DIM
        ))
        c.add_child(_lbl(a.description, 13, DIM))

    var account := _card("ACCOUNT")
    account.add_child(_btn("SIGN OUT", func():
        Save.sign_out()
        show_tab("PROFILE")
    ))

func _settings() -> void:
    _section_title("SETTINGS", "Tune Project Zero for your device.")

    var v := _card("GRAPHICS", true)
    var ob := OptionButton.new()
    ob.custom_minimum_size = Vector2(0, 48)
    var i := 0
    for k in Save.SCALE:
        ob.add_item(k)
        if k == Save.data.graphics:
            ob.select(i)
        i += 1
    ob.item_selected.connect(_on_graphics.bind(ob))
    v.add_child(ob)
    v.add_child(_lbl("Lower scale can improve FPS on weaker phones.", 13, DIM))

    var c := _card("CACHE")
    var info := _lbl("", 15, DIM)
    c.add_child(info)
    _cache_info(info)
    c.add_child(_btn("CLEAR CACHE", _clear_cache.bind(info)))

    var account := _card("ACCOUNT", true)
    account.add_child(_lbl("Signed in as %s" % str(Save.data.email), 13, DIM))
    account.add_child(_btn("SIGN OUT", func():
        Save.sign_out()
        get_tree().reload_current_scene()
    ))

    var about := _card("ABOUT")
    about.add_child(_lbl("PROJECT ZERO  •  v0.1.0", 16, TEXT))
    about.add_child(_lbl("Modern launcher prototype by ANMA.", 13, DIM))

func _coming_soon(title: String, description: String) -> void:
    _section_title(title)
    var v := _card("", true)
    v.add_child(_lbl(title, 30, ACC))
    v.add_child(_lbl("COMING SOON", 13, DIM))
    v.add_child(_lbl(description, 17, TEXT))

func _on_graphics(idx: int, ob: OptionButton) -> void:
    Save.data.graphics = ob.get_item_text(idx)
    Save.apply_graphics()
    Save.write()

func _cache_info(info: Label) -> void:
    info.text = "Total: %.2f KB  •  limit %d MB\nZero Test: %.2f KB" % [
        Cache.total_bytes() / 1024.0,
        Cache.limit_mb,
        Cache.game_bytes("zero_test") / 1024.0
    ]

func _clear_cache(info: Label) -> void:
    Cache.clear()
    _cache_info(info)

func _show_login_required(id: String) -> void:
    var ov := ColorRect.new()
    ov.name = "LoginRequiredOverlay"
    ov.color = Color(0.02, 0.04, 0.03, 0.92)
    ov.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ov.z_index = 50
    add_child(ov)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ov.add_child(center)

    var card := PanelContainer.new()
    card.custom_minimum_size = Vector2(480, 0)
    card.add_theme_stylebox_override("panel", _panel_style(PANEL, ACC, 20, 1))
    center.add_child(card)

    var margin := MarginContainer.new()
    _set_margins(margin, 30, 30, 26, 26)
    card.add_child(margin)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 12)
    margin.add_child(box)

    var title := _lbl("SIGN IN REQUIRED", 27, TEXT)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(title)
    var text := _lbl("You need a Project Zero account before you can play a game.", 15, DIM)
    text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(text)

    var profile := _btn("GO TO PROFILE", func():
        ov.queue_free()
        show_tab("PROFILE")
    , true)
    profile.custom_minimum_size = Vector2(0, 50)
    box.add_child(profile)

    var cancel := _btn("CANCEL", func(): ov.queue_free())
    box.add_child(cancel)

func play(id: String) -> void:
    if not bool(Save.data.get("authenticated", false)):
        _show_login_required(id)
        return

    var m: Dictionary = games[id]
    if m.status != "playable" or m.entry == "":
        return

    var ov := ColorRect.new()
    ov.color = BG
    ov.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(ov)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ov.add_child(center)

    var v := VBoxContainer.new()
    v.custom_minimum_size = Vector2(420, 0)
    v.add_theme_constant_override("separation", 12)
    center.add_child(v)

    var l := _lbl("CONNECTING...", 25, TEXT)
    l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    v.add_child(l)

    var pb := ProgressBar.new()
    pb.custom_minimum_size = Vector2(0, 8)
    v.add_child(pb)

    Assets.load_manifest(id, m.assets)
    while not Assets.tier_done(1):
        l.text = "LOADING  " + m.name.to_upper()
        pb.value = Assets.percent(1) * 100.0
        await get_tree().process_frame

    pb.value = 100
    l.text = "READY"
    await get_tree().create_timer(0.3).timeout
    Save.start_game(id)
    get_tree().change_scene_to_file(m.entry)

func _sb(bg: Color, border: Color, radius := 12, bw := 1) -> StyleBoxFlat:
    var s := StyleBoxFlat.new()
    s.bg_color = bg
    s.border_color = border
    s.set_border_width_all(bw)
    s.set_corner_radius_all(radius)
    s.set_content_margin_all(10)
    return s

func _make_theme() -> Theme:
    var t := Theme.new()

    for cls in ["Button", "OptionButton"]:
        t.set_stylebox("normal", cls, _sb(Color("#0d1310"), BORDER, 12))
        t.set_stylebox("hover", cls, _sb(PANEL_HOVER, ACC, 12))
        t.set_stylebox("pressed", cls, _sb(ACC, ACC, 12))
        t.set_stylebox("disabled", cls, _sb(Color("#0a0e0c"), Color("#15201a"), 12))
        t.set_stylebox("focus", cls, _sb(Color(0, 0, 0, 0), ACC, 12))
        t.set_color("font_color", cls, TEXT)
        t.set_color("font_hover_color", cls, ACC)
        t.set_color("font_pressed_color", cls, Color("#04110b"))
        t.set_color("font_disabled_color", cls, MUTED)
        t.set_font_size("font_size", cls, 13)

    t.set_stylebox("fill", "ProgressBar", _sb(ACC, ACC, 6, 0))
    t.set_stylebox("background", "ProgressBar", _sb(Color("#111914"), BORDER, 6, 1))
    t.set_color("font_color", "ProgressBar", Color.TRANSPARENT)

    return t
