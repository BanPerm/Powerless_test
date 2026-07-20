class_name DungeonLayoutGenerator
extends RefCounted

class PlacedRoomData:
	var template: RoomTemplate
	var position: Vector2
	var rotation_degrees: int
	var doors: Array
	var connected_door_indices: Array[int] = []

class OpenDoor:
	var room: PlacedRoomData
	var door_index: int
	func _init(r: PlacedRoomData, idx: int) -> void:
		room = r
		door_index = idx

var placed_rooms: Array[PlacedRoomData] = []

func generate(start_template: RoomTemplate, normal_templates: Array[RoomTemplate],
		special_templates: Array[RoomTemplate], room_target: int, room_min: int,
		max_global_retries: int = 15) -> bool:
	for retry in range(max_global_retries):
		if _generate_once(start_template, normal_templates, special_templates, room_target, room_min):
			return true
	return false

func _generate_once(start_template: RoomTemplate, normal_templates: Array[RoomTemplate],
		special_templates: Array[RoomTemplate], room_target: int, room_min: int) -> bool:
	placed_rooms = []
	var open_doors: Array[OpenDoor] = []

	var start_doors := RoomDoorExtractor.get_doors(start_template)
	var start_room := PlacedRoomData.new()
	start_room.template = start_template
	start_room.position = Vector2.ZERO
	start_room.rotation_degrees = 0
	start_room.doors = start_doors
	placed_rooms.append(start_room)

	for i in range(start_doors.size()):
		open_doors.append(OpenDoor.new(start_room, i))

	var attempts := 0
	var max_attempts := room_target * 25

	while placed_rooms.size() < room_target and open_doors.size() > 0 and attempts < max_attempts:
		attempts += 1
		var pick_index := randi() % open_doors.size()
		var anchor: OpenDoor = open_doors[pick_index]

		var loop_index := _find_loop_closure(anchor, open_doors, pick_index)
		if loop_index != -1:
			var other: OpenDoor = open_doors[loop_index]
			anchor.room.connected_door_indices.append(anchor.door_index)
			other.room.connected_door_indices.append(other.door_index)
			var hi = max(pick_index, loop_index)
			var lo = min(pick_index, loop_index)
			open_doors.remove_at(hi)
			open_doors.remove_at(lo)
			continue

		var success := _try_connect(anchor, normal_templates, special_templates)
		open_doors.remove_at(pick_index)
		if success:
			var new_room: PlacedRoomData = placed_rooms[placed_rooms.size() - 1]
			for i in range(new_room.doors.size()):
				if not new_room.connected_door_indices.has(i):
					open_doors.append(OpenDoor.new(new_room, i))

	return placed_rooms.size() >= room_min

func _find_loop_closure(anchor: OpenDoor, open_doors: Array[OpenDoor], exclude_index: int) -> int:
	var anchor_door: RoomDoorInfo = anchor.room.doors[anchor.door_index]
	var anchor_point := _world_door_point(anchor.room, anchor_door)
	var anchor_facing := Direction.rotate(anchor_door.side, anchor.room.rotation_degrees)
	var needed_dir = Direction.OPPOSITE[anchor_facing]

	for i in range(open_doors.size()):
		if i == exclude_index:
			continue
		var other: OpenDoor = open_doors[i]
		if other.room == anchor.room:
			continue
		var other_door: RoomDoorInfo = other.room.doors[other.door_index]
		if abs(other_door.width - anchor_door.width) > 0.05:
			continue
		var other_facing := Direction.rotate(other_door.side, other.room.rotation_degrees)
		if other_facing != needed_dir:
			continue
		var other_point := _world_door_point(other.room, other_door)
		if other_point.distance_to(anchor_point) < 0.1:
			return i
	return -1

func _try_connect(anchor: OpenDoor, normal_templates: Array[RoomTemplate], special_templates: Array[RoomTemplate]) -> bool:
	var anchor_door: RoomDoorInfo = anchor.room.doors[anchor.door_index]
	var anchor_point := _world_door_point(anchor.room, anchor_door)
	var anchor_facing := Direction.rotate(anchor_door.side, anchor.room.rotation_degrees)
	var needed_dir = Direction.OPPOSITE[anchor_facing]

	var pool: Array[RoomTemplate] = normal_templates.duplicate()
	if placed_rooms.size() >= 5:
		pool.append_array(special_templates)
	pool.shuffle()

	for template in pool:
		var doors: Array = RoomDoorExtractor.get_doors(template)
		var door_order := range(doors.size())
		door_order.shuffle()

		for door_index in door_order:
			var door: RoomDoorInfo = doors[door_index]
			if abs(door.width - anchor_door.width) > 0.05:
				continue

			var rotations: Array = [0, 90, 180, 270] if template.allow_rotation else [0]
			rotations.shuffle()

			for rot in rotations:
				var facing = Direction.rotate(door.side, rot)
				if facing != needed_dir:
					continue

				var local_pt := _local_door_point(door, template.footprint)
				var rotated_pt := _rotate_point(local_pt, rot)
				var candidate_position: Vector2 = anchor_point - rotated_pt
				var candidate_rect := _room_rect(template.footprint, candidate_position, rot)

				var overlap := false
				for existing in placed_rooms:
					var existing_rect := _room_rect(existing.template.footprint, existing.position, existing.rotation_degrees)
					if _rects_overlap(candidate_rect, existing_rect):
						overlap = true
						break
				if overlap:
					continue

				var new_room := PlacedRoomData.new()
				new_room.template = template
				new_room.position = candidate_position
				new_room.rotation_degrees = rot
				new_room.doors = doors
				new_room.connected_door_indices.append(door_index)
				anchor.room.connected_door_indices.append(anchor.door_index)
				placed_rooms.append(new_room)
				return true

	return false

func _local_door_point(door: RoomDoorInfo, footprint: Vector2) -> Vector2:
	match door.side:
		Direction.Value.NORTH: return Vector2(door.offset, -footprint.y / 2.0)
		Direction.Value.SOUTH: return Vector2(door.offset, footprint.y / 2.0)
		Direction.Value.EAST: return Vector2(footprint.x / 2.0, door.offset)
		Direction.Value.WEST: return Vector2(-footprint.x / 2.0, door.offset)
	return Vector2.ZERO

func _world_door_point(room: PlacedRoomData, door: RoomDoorInfo) -> Vector2:
	var local_pt := _local_door_point(door, room.template.footprint)
	return room.position + _rotate_point(local_pt, room.rotation_degrees)

func _rotate_point(p: Vector2, degrees: int) -> Vector2:
	var steps: int = int(degrees / 90) % 4
	var r := p
	for i in range(steps):
		r = Vector2(-r.y, r.x)
	return r

func _room_rect(footprint: Vector2, position: Vector2, rotation_degrees: int) -> Rect2:
	var fp := footprint
	if rotation_degrees == 90 or rotation_degrees == 270:
		fp = Vector2(fp.y, fp.x)
	return Rect2(position - fp / 2.0, fp)

func _rects_overlap(a: Rect2, b: Rect2) -> bool:
	return a.grow(-0.05).intersects(b.grow(-0.05))
