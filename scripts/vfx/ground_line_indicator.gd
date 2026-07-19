class_name GroundLineIndicator
extends MeshInstance3D

@export var color: Color = Color(1, 0, 0, 0.6)
@export var width: float = 0.15

func _init() -> void:
	mesh = BoxMesh.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material_override = mat
	visible = false

func update_line(origin: Vector3, direction: Vector3, length: float, ground_y: float) -> void:
	visible = true
	(mesh as BoxMesh).size = Vector3(width, 0.02, length)
	var flat_origin := Vector3(origin.x, ground_y + 0.03, origin.z)
	global_position = flat_origin + direction * (length / 2.0)
	look_at(flat_origin + direction * length, Vector3.UP)

func hide_line() -> void:
	visible = false
