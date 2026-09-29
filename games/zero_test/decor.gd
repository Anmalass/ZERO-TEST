extends Node3D
# Priority-3 asset: scenery streamed in after the game is already playable.

func _ready() -> void:
    for i in 30:
        var pos = Vector3(randf_range(-28, 28), 0, randf_range(-28, 28))
        if pos.length() < 5.0:
            continue
        var t = MeshInstance3D.new()
        var c = CylinderMesh.new()
        c.top_radius = 0.0
        c.bottom_radius = 1.0
        c.height = randf_range(2.0, 4.0)
        var m = StandardMaterial3D.new()
        m.albedo_color = Color("#1a2b23")
        c.material = m
        t.mesh = c
        t.position = pos + Vector3(0, c.height / 2.0, 0)
        add_child(t)
