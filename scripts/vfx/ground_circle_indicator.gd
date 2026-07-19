class_name GroundAreaIndicator
extends MeshInstance3D

@export var color: Color = Color(1, 0.4, 0, 0.35)

func _init() -> void:
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.0
	cyl.bottom_radius = 1.0
	cyl.height = 0.02
	mesh = cyl
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_override = mat
	visible = false

func update_circle(center: Vector3, radius: float, ground_y: float) -> void:
	visible = true
	var cyl := mesh as CylinderMesh
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	global_position = Vector3(center.x, ground_y + 0.03, center.z)

func hide_circle() -> void:
	visible = false
