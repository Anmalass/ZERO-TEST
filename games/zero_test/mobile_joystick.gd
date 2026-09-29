extends Control
class_name MobileJoystick

signal vector_changed(value: Vector2)

const OUTER_RADIUS := 78.0
const INNER_RADIUS := 30.0
const DEADZONE := 0.10

var _finger_id := -1
var _value := Vector2.ZERO
var _knob := Vector2.ZERO

func _ready() -> void:
    custom_minimum_size = Vector2(170, 170)
    mouse_filter = Control.MOUSE_FILTER_STOP
    process_mode = Node.PROCESS_MODE_ALWAYS
    queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed and _finger_id == -1:
            _finger_id = event.index
            _set_from_position(event.position)
            accept_event()
        elif not event.pressed and event.index == _finger_id:
            _finger_id = -1
            _set_value(Vector2.ZERO)
            accept_event()

    elif event is InputEventScreenDrag and event.index == _finger_id:
        _set_from_position(event.position)
        accept_event()

    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed and _finger_id == -1:
            _finger_id = -2
            _set_from_position(event.position)
            accept_event()
        elif not event.pressed and _finger_id == -2:
            _finger_id = -1
            _set_value(Vector2.ZERO)
            accept_event()

    elif event is InputEventMouseMotion and _finger_id == -2:
        _set_from_position(event.position)
        accept_event()

func _set_from_position(pos: Vector2) -> void:
    var center := size * 0.5
    var delta := pos - center
    var radius := min(center.x, center.y) - 6.0

    if radius <= 0.0:
        return

    _set_value(delta / radius)

func _set_value(value: Vector2) -> void:
    var v := value.limit_length(1.0)
    if v.length() < DEADZONE:
        v = Vector2.ZERO
    _value = v
    _knob = v * max(0.0, min(size.x, size.y) * 0.5 - INNER_RADIUS - 6.0)
    vector_changed.emit(_value)
    queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    var radius := min(center.x, center.y) - 6.0

    if radius <= 0.0:
        return

    draw_circle(center, radius, Color(0.02, 0.04, 0.03, 0.68))
    draw_arc(center, radius, 0.0, TAU, 64, Color(0.18, 0.90, 0.62, 0.72), 2.0)

    var knob_pos := center + _knob
    draw_circle(knob_pos, INNER_RADIUS, Color(0.18, 0.90, 0.62, 0.92))
    draw_circle(knob_pos, INNER_RADIUS - 7.0, Color(0.04, 0.10, 0.08, 0.85))
