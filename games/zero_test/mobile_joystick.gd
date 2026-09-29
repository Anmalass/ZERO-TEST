extends Control
## Simple touch joystick for Android / touchscreen devices.
signal vector_changed(value: Vector2)

@export var radius := 82.0
@export var knob_radius := 32.0
var center := Vector2.ZERO
var knob := Vector2.ZERO
var active_touch := -1

func _ready() -> void:
    custom_minimum_size = Vector2(radius * 2.0, radius * 2.0)
    mouse_filter = Control.MOUSE_FILTER_STOP
    center = Vector2(radius, radius)
    knob = center
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_RESIZED:
        center = size * 0.5
        if center == Vector2.ZERO:
            center = Vector2(radius, radius)
        knob = center
        queue_redraw()

func _gui_input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            active_touch = event.index
            _update_from_position(event.position)
        elif event.index == active_touch:
            active_touch = -1
            _reset()
    elif event is InputEventScreenDrag and event.index == active_touch:
        _update_from_position(event.position)

func _update_from_position(pos: Vector2) -> void:
    var delta := pos - center
    var value := delta / radius
    value = value.limit_length(1.0)
    knob = center + value * radius
    vector_changed.emit(value)
    queue_redraw()

func _reset() -> void:
    knob = center
    vector_changed.emit(Vector2.ZERO)
    queue_redraw()

func _draw() -> void:
    draw_circle(center, radius, Color(0.03, 0.08, 0.06, 0.72))
    draw_arc(center, radius, 0.0, TAU, 48, Color(0.18, 0.90, 0.62, 0.65), 3.0)
    draw_circle(knob, knob_radius, Color(0.18, 0.90, 0.62, 0.90))
    draw_circle(knob, knob_radius - 7.0, Color(0.03, 0.16, 0.11, 0.85))
