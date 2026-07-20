class_name DungeonGenerator
extends RefCounted

const CELL_SIZE := 16.0  # >= à la plus grande dimension de salle utilisée, marge incluse

var occupied: Dictionary = {}          # Vector2i -> RoomTemplate (layout logique, avant instanciation)
var placed_rooms: Array[RoomInstance] = []

func generate(templates: Array[RoomTemplate], room_count: int, parent: Node3D) -> void:
	occupied.clear()
	placed_rooms.clear()

	var start_templates = templates.filter(func(t): return t.category == RoomTemplate.Category.START)
	var normal_templates = templates.filter(func(t): return t.category == RoomTemplate.Category.NORMAL)
	var rest_templates = templates.filter(func(t): return t.category == RoomTemplate.Category.REST)
	var boss_templates = templates.filter(func(t): return t.category == RoomTemplate.Category.BOSS)

	# --- Étape 1 : construire le layout logique (juste des données, rien d'instancié) ---
	var layout: Dictionary = {}  # Vector2i -> RoomTemplate
	var start_pos := Vector2i.ZERO
	layout[start_pos] = _pick_weighted(start_templates)

	var frontier: Array[Vector2i] = [start_pos]
	var attempts := 0
	var max_attempts := room_count * 20

	while layout.size() < room_count - 1 and attempts < max_attempts and frontier.size() > 0:
		attempts += 1
		var from_pos: Vector2i = frontier[randi() % frontier.size()]
		var dir = Direction.all().pick_random()
		var next_pos: Vector2i = from_pos + Direction.VECTOR[dir]

		if layout.has(next_pos):
			continue

		if not frontier.has(next_pos):
			frontier.append(next_pos)
		if not _has_free_neighbor(from_pos, layout):
			frontier.erase(from_pos)

	if boss_templates.size() > 0:
		for from_pos in frontier:
			var placed := false
			for dir in Direction.all():
				var next_pos: Vector2i = from_pos + Direction.VECTOR[dir]
				if not layout.has(next_pos):
					layout[next_pos] = _pick_weighted(boss_templates)
					placed = true
					break
			if placed:
				break

	# --- Étape 2 : instancier le layout validé ---
	for grid_pos in layout:
		var instance = _place_room(layout[grid_pos], grid_pos, parent)
		occupied[grid_pos] = instance
		placed_rooms.append(instance)

	# --- Étape 3 : marquer les sockets connectés ---
	for grid_pos in occupied:
		for dir in Direction.all():
			var neighbor_pos = grid_pos + Direction.VECTOR[dir]
			if occupied.has(neighbor_pos):
				var room: RoomInstance = occupied[grid_pos]
				var neighbor: RoomInstance = occupied[neighbor_pos]
				var socket = room.get_socket(dir)
				var neighbor_socket = neighbor.get_socket(Direction.OPPOSITE[dir])
				if socket:
					socket.is_used = true
				if neighbor_socket:
					neighbor_socket.is_used = true

	for room in placed_rooms:
		room.finalize_walls()

func _has_free_neighbor(pos: Vector2i, layout: Dictionary) -> bool:
	for dir in Direction.all():
		if not layout.has(pos + Direction.VECTOR[dir]):
			return true
	return false

func _pick_weighted(pool: Array) -> RoomTemplate:
	var total_weight := 0.0
	for t in pool:
		total_weight += t.weight
	var roll := randf() * total_weight
	for t in pool:
		roll -= t.weight
		if roll <= 0:
			return t
	return pool[0]

func _place_room(template: RoomTemplate, grid_pos: Vector2i, parent: Node3D) -> RoomInstance:
	var instance: RoomInstance = template.scene.instantiate()
	parent.add_child(instance)
	instance.global_position = Vector3(grid_pos.x * CELL_SIZE, 0, grid_pos.y * CELL_SIZE)
	instance.initialize()
	return instance
