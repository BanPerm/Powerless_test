extends Control

var player: Player
var dungeon_manager: Node3D
@export var world_scale: float = 0.5
@export var wall_color: Color = Color(0.6, 0.6, 0.65, 1.0)
@export var wall_width: float = 2.0
@export var player_color: Color = Color(0.9, 0.85, 0.2, 1.0)
@export var background_color: Color = Color(0, 0, 0, 0.5)

var room_positions: Array = []
var _initialized := false

func _ready() -> void:
	clip_contents = true

func _process(_delta: float) -> void:
	if not _initialized and dungeon_manager:
		room_positions = dungeon_manager.get_room_positions()
		_initialized = true
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), background_color, true)

	if not player or room_positions.is_empty():
		return

	var center := size / 2.0
	var player_pos_2d := Vector2(player.global_position.x, player.global_position.z)

	for room in room_positions:
		_draw_room_outline(room, player_pos_2d, center)

	draw_circle(center, 4.0, player_color)

func _draw_room_outline(room: Dictionary, player_pos_2d: Vector2, center: Vector2) -> void:
	var room_pos: Vector2 = room.position
	var footprint: Vector2 = room.footprint
	var relative := (room_pos - player_pos_2d) / world_scale
	var half_size := (footprint / world_scale) / 2.0
	var top_left := center + relative - half_size

	# Les 4 coins du rectangle, en pixels écran
	var corners := {
		Direction.Value.NORTH: [top_left, top_left + Vector2(half_size.x * 2, 0)],
		Direction.Value.SOUTH: [top_left + Vector2(0, half_size.y * 2), top_left + Vector2(half_size.x * 2, half_size.y * 2)],
		Direction.Value.WEST: [top_left, top_left + Vector2(0, half_size.y * 2)],
		Direction.Value.EAST: [top_left + Vector2(half_size.x * 2, 0), top_left + Vector2(half_size.x * 2, half_size.y * 2)],
	}

	for side in corners.keys():
		var segment_points: Array = _split_segment_for_doors(side, corners[side], room.doors, footprint)
		for pair in segment_points:
			draw_line(pair[0], pair[1], wall_color, wall_width)

func _split_segment_for_doors(side: Direction.Value, segment: Array, doors: Array, footprint: Vector2) -> Array:
	var start: Vector2 = segment[0]
	var end: Vector2 = segment[1]
	var wall_length: float = footprint.x if (side == Direction.Value.NORTH or side == Direction.Value.SOUTH) else footprint.y

	var gaps: Array = []
	for door in doors:
		if door.facing == side and door.connected:
			var t: float = (door.offset + wall_length / 2.0) / wall_length  # 0..1 le long du mur
			var half_gap_t: float = (door.width / 2.0) / wall_length
			gaps.append([clamp(t - half_gap_t, 0.0, 1.0), clamp(t + half_gap_t, 0.0, 1.0)])

	gaps.sort_custom(func(a, b): return a[0] < b[0])

	var segments: Array = []
	var cursor := 0.0
	for gap in gaps:
		if gap[0] > cursor:
			segments.append([start.lerp(end, cursor), start.lerp(end, gap[0])])
		cursor = gap[1]
	if cursor < 1.0:
		segments.append([start.lerp(end, cursor), start.lerp(end, 1.0)])

	return segments
