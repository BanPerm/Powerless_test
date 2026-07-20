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

@onready var plug: WallSegment = $Plug

func _ready() -> void:
	_sync_plug_size()

func _sync_plug_size() -> void:
	if plug:
		plug.size = Vector3(width, wall_height, wall_thickness)
