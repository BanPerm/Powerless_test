extends Node3D

@export var room_scene: PackedScene
@export var room_count: int = 8
@export var player: Node3D

var generator := DungeonGenerator.new()
var room_instances: Dictionary = {}  # Vector2i -> RoomInstance

func _ready() -> void:
	generate_dungeon()

func generate_dungeon() -> void:
	var rooms = generator.generate(room_count)

	for grid_pos in rooms:
		var room_data: RoomData = rooms[grid_pos]
		var instance: RoomInstance = room_scene.instantiate()
		add_child(instance)
		instance.setup(room_data)
		room_instances[grid_pos] = instance

	_spawn_player_in_start_room()

func _spawn_player_in_start_room() -> void:
	var start_room: RoomInstance = room_instances[Vector2i.ZERO]
	var spawn_point = start_room.get_node_or_null("SpawnPoints/PlayerSpawn")
	if player and spawn_point:
		player.global_position = spawn_point.global_position
