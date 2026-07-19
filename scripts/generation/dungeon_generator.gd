class_name DungeonGenerator
extends RefCounted

var placed_rooms: Array[Node3D] = []

func generate(templates: Array[RoomTemplate], room_count: int, parent: Node3D) -> void:
	var current_template = templates.pick_random()
	var current_room = current_template.scene.instantiate()
	parent.add_child(current_room)
	placed_rooms.append(current_room)

	for i in range(room_count - 1):
		var open_socket = _find_open_socket(current_room)
		if not open_socket:
			break

		var next_template = templates.pick_random()
		var next_room = next_template.scene.instantiate()
		parent.add_child(next_room)

		_align_room_to_socket(next_room, open_socket)
		open_socket.is_used = true
		placed_rooms.append(next_room)
		current_room = next_room

func _find_open_socket(room: Node3D) -> RoomSocket:
	for child in room.get_children():
		if child is RoomSocket and not child.is_used:
			return child
	return null

func _align_room_to_socket(new_room: Node3D, target_socket: RoomSocket) -> void:
	# Trouve le socket d'entrée de la nouvelle salle (le premier disponible, par convention)
	var entry_socket: RoomSocket = null
	for child in new_room.get_children():
		if child is RoomSocket:
			entry_socket = child
			break

	if not entry_socket:
		return

	# Aligne position et rotation pour que les deux sockets coïncident, dos à dos
	var target_transform = target_socket.global_transform
	var offset = new_room.global_transform.affine_inverse() * entry_socket.global_transform
	new_room.global_transform = target_transform * offset.affine_inverse()
	entry_socket.is_used = true
