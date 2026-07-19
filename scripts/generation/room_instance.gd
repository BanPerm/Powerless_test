class_name RoomInstance
extends Node3D

@onready var wall_north: Node3D = $Walls/WallNorth
@onready var wall_south: Node3D = $Walls/WallSouth
@onready var wall_east: Node3D = $Walls/WallEast
@onready var wall_west: Node3D = $Walls/WallWest

@onready var door_north: Node3D = $DoorNorth
@onready var door_south: Node3D = $DoorSouth
@onready var door_east: Node3D = $DoorEast
@onready var door_west: Node3D = $DoorWest

var room_data: RoomData

func setup(data: RoomData) -> void:
	room_data = data
	global_position = data.world_position
	_apply_connections()

func _apply_connections() -> void:
	wall_north.visible = not room_data.connections["north"]
	wall_south.visible = not room_data.connections["south"]
	wall_east.visible = not room_data.connections["east"]
	wall_west.visible = not room_data.connections["west"]

	door_north.visible = room_data.connections["north"]
	door_south.visible = room_data.connections["south"]
	door_east.visible = room_data.connections["east"]
	door_west.visible = room_data.connections["west"]

	# Désactive la collision des murs remplacés par une porte
	wall_north.get_node("CollisionShape3D").disabled = room_data.connections["north"]
	wall_south.get_node("CollisionShape3D").disabled = room_data.connections["south"]
	wall_east.get_node("CollisionShape3D").disabled = room_data.connections["east"]
	wall_west.get_node("CollisionShape3D").disabled = room_data.connections["west"]
