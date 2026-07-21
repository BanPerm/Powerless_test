@tool
class_name DoorMarker
extends Node3D

@export var width: float = 4.0:
	set(value):
		width = value
		_sync_plug_size()

@export var wall_height: float = 3.0:
	set(value):
		wall_height = value
		_sync_plug_size()

@export var wall_thickness: float = 0.3:
	set(value):
		wall_thickness = value
		_sync_plug_size()

@export var threshold_depth: float = 1.0:  # profondeur du seuil de sol, de chaque côté du mur
	set(value):
		threshold_depth = value
		_sync_plug_size()

@onready var plug: WallSegment = $Plug
@onready var threshold: StaticBody3D = $Threshold
@onready var threshold_mesh: MeshInstance3D = $Threshold/MeshInstance3D
@onready var threshold_collision: CollisionShape3D = $Threshold/CollisionShape3D

func _ready() -> void:
	if threshold_mesh and threshold_mesh.mesh:
		threshold_mesh.mesh = threshold_mesh.mesh.duplicate()
	if threshold_collision and threshold_collision.shape:
		threshold_collision.shape = threshold_collision.shape.duplicate()
	_sync_plug_size()

func _sync_plug_size() -> void:
	if plug:
		plug.size = Vector3(width, wall_height, wall_thickness)

	if threshold_mesh and threshold_mesh.mesh is BoxMesh:
		threshold_mesh.mesh.size = Vector3(width, 0.1, threshold_depth * 2.0)

	if threshold_collision and threshold_collision.shape is BoxShape3D:
		threshold_collision.shape.size = Vector3(width, 0.1, threshold_depth * 2.0)
