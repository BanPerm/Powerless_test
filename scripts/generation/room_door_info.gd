class_name RoomDoorInfo
extends RefCounted

var side: Direction.Value
var offset: float
var width: float
var marker_path: NodePath

func _init(s: Direction.Value, o: float, w: float, path: NodePath) -> void:
	side = s
	offset = o
	width = w
	marker_path = path
