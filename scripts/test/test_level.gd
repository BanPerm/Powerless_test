extends Node3D

var placed_rooms: Array[Node3D] = []
func _ready():
	pass
	"""
	var room_a = preload("res://scenes/rooms/basic_room_a.tscn").instantiate()
	add_child(room_a)
	room_a.initialize()

	var room_b = preload("res://scenes/rooms/basic_room_a.tscn").instantiate()
	add_child(room_b)
	room_b.initialize()

	var socket_out = room_a.get_open_sockets()[0]
	print("Socket A pos: ", socket_out.global_position, " forward: ", -socket_out.global_transform.basis.z)

	_align_room_to_socket(room_b, socket_out)

	var entry = room_b.sockets[0]  # celui qui vient d'être utilisé
	print("Socket B (après alignement) pos: ", entry.global_position, " forward: ", -entry.global_transform.basis.z)
	"""
