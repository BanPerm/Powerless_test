class_name DungeonWallBuilder
extends RefCounted

class WallSpec:
	var world_position: Vector3
	var length: float
	var rotation_y: float
	func _init(pos: Vector3, len: float, rot: float) -> void:
		world_position = pos
		length = len
		rotation_y = rot

class _Edge:
	var room_index: int
	var side: Direction.Value
	var fixed_coord: float
	var range: Vector2
	var door_gaps: Array
	
class DoorState:
	var room_index: int
	var side: Direction.Value
	var is_open: bool
	var coord: float   # position le long du mur (même repère que range.x/range.y)
	var width: float
	func _init(idx: int, s: Direction.Value, open: bool, c: float, w: float) -> void:
		room_index = idx
		side = s
		is_open = open
		coord = c
		width = w

const COORD_TOLERANCE := 0.05
const MIN_OVERLAP := 0.05

static func generate_walls_and_doors(placed_rooms: Array, corner_extension: float = 0.15) -> Dictionary:
	var edges := _collect_edges(placed_rooms)
	var horizontal: Array = edges.filter(func(e): return e.side == Direction.Value.NORTH or e.side == Direction.Value.SOUTH)
	var vertical: Array = edges.filter(func(e): return e.side == Direction.Value.EAST or e.side == Direction.Value.WEST)

	var specs: Array = []
	var door_states: Array = []

	var result_h = _process_axis_full(horizontal, Direction.Value.NORTH, Direction.Value.SOUTH, true, corner_extension)
	var result_v = _process_axis_full(vertical, Direction.Value.EAST, Direction.Value.WEST, false, corner_extension)

	specs += result_h.specs + result_v.specs
	door_states += result_h.doors + result_v.doors

	return {"walls": specs, "doors": door_states}

static func _collect_edges(placed_rooms: Array) -> Array:
	var edges: Array = []
	for i in range(placed_rooms.size()):
		var room_data = placed_rooms[i]
		var fp := RoomGeometry.effective_footprint(room_data.template, room_data.rotation_degrees)
		var pos: Vector2 = room_data.position

		var side_defs := {
			Direction.Value.NORTH: {"fixed": pos.y - fp.y / 2.0, "range": Vector2(pos.x - fp.x / 2.0, pos.x + fp.x / 2.0)},
			Direction.Value.SOUTH: {"fixed": pos.y + fp.y / 2.0, "range": Vector2(pos.x - fp.x / 2.0, pos.x + fp.x / 2.0)},
			Direction.Value.EAST:  {"fixed": pos.x + fp.x / 2.0, "range": Vector2(pos.y - fp.y / 2.0, pos.y + fp.y / 2.0)},
			Direction.Value.WEST:  {"fixed": pos.x - fp.x / 2.0, "range": Vector2(pos.y - fp.y / 2.0, pos.y + fp.y / 2.0)},
		}

		for world_side in side_defs.keys():
			var e := _Edge.new()
			e.room_index = i
			e.side = world_side
			e.fixed_coord = side_defs[world_side].fixed
			e.range = side_defs[world_side].range
			e.door_gaps = _doors_for_side(room_data, world_side)
			edges.append(e)
	return edges

static func _doors_for_side(room_data, world_side: Direction.Value) -> Array:
	var gaps: Array = []
	for door in room_data.doors:
		var facing = Direction.rotate(door.side, room_data.rotation_degrees)
		if facing != world_side:
			continue
		var world_pt := RoomGeometry.world_door_point(room_data.position, room_data.rotation_degrees, room_data.template, door)
		var coord: float = world_pt.x if (world_side == Direction.Value.NORTH or world_side == Direction.Value.SOUTH) else world_pt.y
		gaps.append(Vector2(coord - door.width / 2.0, coord + door.width / 2.0))
	return gaps

static func _process_axis_full(edges: Array, side_a: Direction.Value, side_b: Direction.Value, horizontal: bool, corner_extension: float) -> Dictionary:
	var groups: Dictionary = {}
	for e in edges:
		var key := str(round(e.fixed_coord / COORD_TOLERANCE))
		if not groups.has(key):
			groups[key] = []
		groups[key].append(e)

	var specs: Array = []
	var door_states: Array = []

	for key in groups.keys():
		var group: Array = groups[key]
		var group_a: Array = group.filter(func(e): return e.side == side_a)
		var group_b: Array = group.filter(func(e): return e.side == side_b)
		var covered: Dictionary = {}

		for a in group_a:
			for b in group_b:
				var overlap := _intersect(a.range, b.range)
				if overlap.y - overlap.x <= MIN_OVERLAP:
					continue

				var gaps: Array = []
				for g in a.door_gaps + b.door_gaps:
					var clipped := _intersect(g, overlap)
					if clipped.y - clipped.x > 0.01:
						gaps.append(clipped)
						var gap_center := (clipped.x + clipped.y) / 2.0
						var gap_width := clipped.y - clipped.x
						door_states.append(DoorState.new(a.room_index, a.side, true, gap_center, gap_width))
						door_states.append(DoorState.new(b.room_index, b.side, true, gap_center, gap_width))

				var solids := _subtract_ranges(overlap, gaps)
				for s in solids:
					specs.append(_make_spec(a.fixed_coord, s, horizontal, corner_extension))

				_add_covered(covered, a, overlap)
				_add_covered(covered, b, overlap)

		for e in group:
			var covered_ranges: Array = covered.get(e, [])
			var leftovers := _subtract_ranges(e.range, covered_ranges)
			for l in leftovers:
				specs.append(_make_spec(e.fixed_coord, l, horizontal, corner_extension))

	return {"specs": specs, "doors": door_states}

static func _add_covered(covered: Dictionary, edge, r: Vector2) -> void:
	if not covered.has(edge):
		covered[edge] = []
	covered[edge].append(r)

static func _intersect(a: Vector2, b: Vector2) -> Vector2:
	var lo = max(a.x, b.x)
	var hi = min(a.y, b.y)
	if hi <= lo:
		return Vector2(0, 0)
	return Vector2(lo, hi)

static func _subtract_ranges(base: Vector2, cuts: Array) -> Array:
	var sorted_cuts: Array = cuts.filter(func(c): return c.y > c.x)
	sorted_cuts.sort_custom(func(a, b): return a.x < b.x)

	var result: Array = []
	var cursor := base.x
	for c in sorted_cuts:
		var start = max(c.x, base.x)
		var end = min(c.y, base.y)
		if start > cursor:
			result.append(Vector2(cursor, start))
		cursor = max(cursor, end)
	if cursor < base.y:
		result.append(Vector2(cursor, base.y))
	return result

static func _make_spec(fixed_coord: float, r: Vector2, horizontal: bool, extension: float) -> WallSpec:
	var min_c = r.x - extension
	var max_c = r.y + extension
	var length = max_c - min_c
	var center = (min_c + max_c) / 2.0

	if horizontal:
		return WallSpec.new(Vector3(center, 0, fixed_coord), length, 0.0)
	return WallSpec.new(Vector3(fixed_coord, 0, center), length, 90.0)
