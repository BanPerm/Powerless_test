extends Node3D

@export var start_template: RoomTemplate
@export var normal_templates: Array[RoomTemplate] = []
@export var special_templates: Array[RoomTemplate] = []
@export var room_target: int = 8
@export var room_min: int = 5
@export var player: Node3D
@export var nav_region: NavigationRegion3D
@export var wall_segment_scene: PackedScene

var layout_generator := DungeonLayoutGenerator.new()
var real_door_states: Array = []
var _start_room_instance: RoomInstance

func _ready() -> void:
	generate_dungeon()

func generate_dungeon() -> void:
	var success = layout_generator.generate(start_template, normal_templates, special_templates, room_target, room_min)
	if not success:
		push_warning("Génération échouée après plusieurs tentatives.")
		return

	for room_data in layout_generator.placed_rooms:
		_build_room(room_data)

	_build_walls()
	_spawn_player_in_start_room()

	await get_tree().physics_frame
	nav_region.bake_navigation_mesh(false)
		
# Dans dungeon_manager.gd, après _build_room
func _build_room(room_data: DungeonLayoutGenerator.PlacedRoomData) -> RoomInstance:
	var instance: RoomInstance = room_data.template.scene.instantiate()
	add_child(instance)
	instance.position = Vector3(room_data.position.x, 0, room_data.position.y)
	instance.rotation_degrees.y = -room_data.rotation_degrees
	instance.initialize()

	if room_data.template.category == RoomTemplate.Category.START:
		_start_room_instance = instance

	return instance

func _spawn_altar(room_instance: RoomInstance) -> void:
	var altar: AttackAltar = preload("res://scenes/pickups/altar_attack.tscn").instantiate()
	room_instance.add_child(altar)
	altar.position = Vector3(0, 1, 0)  # centre de la salle, ajuste selon ta scène

func _build_walls() -> void:
	var wall_container := Node3D.new()
	wall_container.name = "GeneratedWalls"
	add_child(wall_container)

	var result: Dictionary = DungeonWallBuilder.generate_walls_and_doors(layout_generator.placed_rooms, GameConstants.WALL_CORNER_EXTENSION)
	real_door_states = result.doors

	for spec in result.walls:
		var wall: WallSegment = wall_segment_scene.instantiate()
		wall_container.add_child(wall)
		wall.position = spec.world_position + Vector3(0, GameConstants.WALL_HEIGHT / 2.0, 0)
		wall.rotation_degrees.y = spec.rotation_y
		wall.size = Vector3(spec.length, GameConstants.WALL_HEIGHT, GameConstants.WALL_THICKNESS)
		wall.add_to_group(GameConstants.GROUP_OCCLUDER)
		wall.add_to_group("nav_source")


func _spawn_player_in_start_room() -> void:
	if not _start_room_instance:
		push_warning("Aucune salle de départ trouvée pour le spawn du joueur !")
		return
	var spawn_point := _find_marker_recursive(_start_room_instance)
	if player and spawn_point:
		player.global_position = spawn_point.global_position
	else:
		push_warning("Marker3D de spawn introuvable dans la salle de départ.")
	
	_spawn_altar(_start_room_instance)
		

func _find_marker_recursive(node: Node) -> Marker3D:
	if node is Marker3D and not (node is DoorMarker):
		return node
	for child in node.get_children():
		var result = _find_marker_recursive(child)
		if result:
			return result
	return null
	
func get_room_positions() -> Array:
	var result: Array = []
	for i in range(layout_generator.placed_rooms.size()):
		var room_data = layout_generator.placed_rooms[i]
		var door_infos: Array = []
		for door_state in real_door_states:
			if door_state.room_index == i:
				# Convertit la coordonnée absolue en offset relatif au centre de la salle (cohérent avec RoomDoorInfo.offset)
				var relative_offset: float
				if door_state.side == Direction.Value.NORTH or door_state.side == Direction.Value.SOUTH:
					relative_offset = door_state.coord - room_data.position.x
				else:
					relative_offset = door_state.coord - room_data.position.y

				door_infos.append({
					"facing": door_state.side,
					"offset": relative_offset,
					"width": door_state.width,
					"connected": true
				})
		result.append({
			"position": room_data.position,
			"footprint": RoomGeometry.effective_footprint(room_data.template, room_data.rotation_degrees),
			"doors": door_infos
		})
	return result

func _rotate_offset(door: RoomDoorInfo, rotation_degrees: int) -> float:
	# L'offset le long du mur, après rotation, reste le même scalaire
	# (seule la direction du mur change, pas la position le long de ce mur)
	return door.offset

func _effective_footprint(room_data: DungeonLayoutGenerator.PlacedRoomData) -> Vector2:
	var fp: Vector2 = room_data.template.footprint
	if room_data.rotation_degrees == 90 or room_data.rotation_degrees == 270:
		return Vector2(fp.y, fp.x)
	return fp
