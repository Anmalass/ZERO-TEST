extends CharacterBody3D
const SPEED = 7.0
var touch_dir := Vector2.ZERO
var mesh: MeshInstance3D

func _ready() -> void:
    var cs = CollisionShape3D.new()
    cs.shape = CapsuleShape3D.new()
    add_child(cs)
    mesh = MeshInstance3D.new()
    var cm = CapsuleMesh.new()
    var m = StandardMaterial3D.new()
    m.albedo_color = Color("#cfd8d3")
    m.metallic = 0.8
    m.roughness = 0.3
    m.emission_enabled = true
    m.emission = Color("#0b5a3a")
    cm.material = m
    mesh.mesh = cm
    add_child(mesh)
    var cam = Camera3D.new()
    cam.position = Vector3(0, 6, 9)
    cam.rotation_degrees = Vector3(-32, 0, 0)
    add_child(cam)

func _physics_process(d: float) -> void:
    var x = int(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
    var y = int(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - int(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
    var v = Vector2(x, y)
    if v == Vector2.ZERO:
        v = touch_dir
    v = v.limit_length(1.0)
    velocity.x = v.x * SPEED
    velocity.z = v.y * SPEED
    if not is_on_floor():
        velocity.y -= 20.0 * d
    move_and_slide()
    position.x = clampf(position.x, -29, 29)
    position.z = clampf(position.z, -29, 29)
    if v.length() > 0.1:
        mesh.rotation.y = atan2(-v.x, -v.y)
