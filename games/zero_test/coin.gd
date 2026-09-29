extends Area3D
signal collected

func _ready() -> void:
    var cs = CollisionShape3D.new()
    var s = SphereShape3D.new()
    s.radius = 0.9
    cs.shape = s
    add_child(cs)
    var mi = MeshInstance3D.new()
    var m = CylinderMesh.new()
    m.top_radius = 0.5
    m.bottom_radius = 0.5
    m.height = 0.12
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color("#2ee59d")
    mat.emission_enabled = true
    mat.emission = Color("#00b36b")
    m.material = mat
    mi.mesh = m
    mi.rotation_degrees.x = 90
    add_child(mi)
    body_entered.connect(_on_body)

func _process(d: float) -> void:
    rotate_y(d * 2.0)

func _on_body(_b: Node3D) -> void:
    collected.emit()
    queue_free()
