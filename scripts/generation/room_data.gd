class_name RoomData
extends RefCounted

var grid_position: Vector2i
var world_position: Vector3
var connections: Dictionary = {
	"north": false,
	"south": false,
	"east": false,
	"west": false
}
var room_node: Node3D = null
var is_cleared: bool = false
