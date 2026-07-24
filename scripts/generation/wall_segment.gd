@tool
class_name WallSegment
extends StaticBody3D

@export var size: Vector3 = Vector3(3, 3, 0.3):
	set(value):
		size = value
		_apply_size()

@onready var collision_shape: CollisionShape3D = $CollisionShape3D
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	add_to_group(GameConstants.GROUP_OCCLUDER)
	add_to_group(GameConstants.GROUP_NAV)
	_ensure_unique_resources()
	_apply_size()

func _ensure_unique_resources() -> void:
	if collision_shape and collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
	if mesh_instance and mesh_instance.mesh:
		mesh_instance.mesh = mesh_instance.mesh.duplicate()

	var mat = mesh_instance.get_surface_override_material(0)
	if mat:
		mesh_instance.set_surface_override_material(0, mat.duplicate())
	else:
		var active_mat = mesh_instance.get_active_material(0)
		if active_mat:
			mesh_instance.set_surface_override_material(0, active_mat.duplicate())

func _apply_size() -> void:
	if not collision_shape or not mesh_instance:
		return
	if collision_shape.shape is BoxShape3D:
		collision_shape.shape.size = size
	if mesh_instance.mesh is BoxMesh:
		mesh_instance.mesh.size = size
