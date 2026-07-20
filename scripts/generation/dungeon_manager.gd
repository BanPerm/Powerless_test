extends Node3D

@export var start_template: RoomTemplate
@export var normal_templates: Array[RoomTemplate] = []
@export var special_templates: Array[RoomTemplate] = []
@export var room_target: int = 8
@export var room_min: int = 5
@export var player: Node3D

var layout_generator := DungeonLayoutGenerator.new()

func _ready() -> void:
	generate_dungeon()

func generate_dungeon() -> void:
	var success = layout_generator.generate(start_template, normal_templates, special_templates, room_target, room_min)
	if not success:
		push_warning("Génération échouée après plusieurs tentatives.")
		return

	for room_data in layout_generator.placed_rooms:
		_build_room(room_data)

	_spawn_player_in_start_room()

func _build_room(room_data: DungeonLayoutGenerator.PlacedRoomData) -> void:
	var instance: RoomInstance = room_data.template.scene.instantiate()
	add_child(instance)
	instance.position = Vector3(room_data.position.x, 0, room_data.position.y)
	instance.rotation_degrees.y = -room_data.rotation_degrees
	instance.initialize()
	_cap_unused_doors(instance, room_data)

func _cap_unused_doors(instance: Node3D, room_data: DungeonLayoutGenerator.PlacedRoomData) -> void:
	for i in range(room_data.doors.size()):
		if room_data.connected_door_indices.has(i):
			continue
		var door_info: RoomDoorInfo = room_data.doors[i]
		var marker = instance.get_node_or_null(door_info.marker_path)
		if marker and marker.plug:
			var mesh = marker.plug.get_node_or_null("MeshInstance3D")
			var collision = marker.plug.get_node_or_null("CollisionShape3D")
			if collision:
				collision.disabled = false
			if mesh:
				mesh.visible = true

func _spawn_player_in_start_room() -> void:
	if get_child_count() == 0:
		return
	var spawn_point := _find_marker_recursive(get_child(0))
	if player and spawn_point:
		player.global_position = spawn_point.global_position

func _find_marker_recursive(node: Node) -> Marker3D:
	if node is Marker3D and not (node is DoorMarker):
		return node
	for child in node.get_children():
		var result = _find_marker_recursive(child)
		if result:
			return result
	return null
