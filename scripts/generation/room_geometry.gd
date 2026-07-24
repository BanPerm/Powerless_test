class_name RoomGeometry
extends RefCounted

static func effective_footprint(template: RoomTemplate, rotation_degrees: int) -> Vector2:
	var fp := template.footprint
	if rotation_degrees == 90 or rotation_degrees == 270:
		return Vector2(fp.y, fp.x)
	return fp

static func rotate_point(p: Vector2, degrees: int) -> Vector2:
	var steps: int = int(degrees / 90) % 4
	var r := p
	for i in range(steps):
		r = Vector2(-r.y, r.x)
	return r

static func local_door_point(door: RoomDoorInfo, footprint: Vector2) -> Vector2:
	match door.side:
		Direction.Value.NORTH: return Vector2(door.offset, -footprint.y / 2.0)
		Direction.Value.SOUTH: return Vector2(door.offset, footprint.y / 2.0)
		Direction.Value.EAST: return Vector2(footprint.x / 2.0, door.offset)
		Direction.Value.WEST: return Vector2(-footprint.x / 2.0, door.offset)
	return Vector2.ZERO

static func world_door_point(position: Vector2, rotation_degrees: int, template: RoomTemplate, door: RoomDoorInfo) -> Vector2:
	var local_pt := local_door_point(door, template.footprint)
	return position + rotate_point(local_pt, rotation_degrees)
