class_name RoomDoorExtractor
extends RefCounted

static var _cache: Dictionary = {}  # PackedScene -> Array[RoomDoorInfo]

static func get_doors(template: RoomTemplate) -> Array:
	if _cache.has(template.scene):
		return _cache[template.scene]

	var doors: Array = []
	var temp_root: Node3D = template.scene.instantiate()
	_scan(temp_root, temp_root, doors)
	temp_root.free()

	_cache[template.scene] = doors
	return doors

static func _scan(root: Node3D, node: Node, doors: Array) -> void:
	for child in node.get_children():
		if child is DoorMarker:
			var rel_transform := _relative_transform(root, child)
			var side := _direction_from_forward(rel_transform)
			var offset := _offset_from_side(side, rel_transform.origin)
			doors.append(RoomDoorInfo.new(side, offset, child.width, root.get_path_to(child)))
		_scan(root, child, doors)

static func _relative_transform(root: Node3D, node: Node3D) -> Transform3D:
	var t := node.transform
	var current := node.get_parent()
	while current and current != root:
		if current is Node3D:
			t = current.transform * t
		current = current.get_parent()
	return t

static func _direction_from_forward(t: Transform3D) -> Direction.Value:
	var forward: Vector3 = -t.basis.z
	forward.y = 0
	forward = forward.normalized()
	if abs(forward.x) > abs(forward.z):
		return Direction.Value.EAST if forward.x > 0 else Direction.Value.WEST
	return Direction.Value.SOUTH if forward.z > 0 else Direction.Value.NORTH

static func _offset_from_side(side: Direction.Value, origin: Vector3) -> float:
	if side == Direction.Value.NORTH or side == Direction.Value.SOUTH:
		return origin.x
	return origin.z
