extends Node

var _pools: Dictionary = {}  # scene_path -> Array[Node] (nodes disponibles)

func get_object(scene: PackedScene) -> Node:
	var key = scene.resource_path
	if not _pools.has(key):
		_pools[key] = []

	var pool: Array = _pools[key]
	while pool.size() > 0:
		var obj = pool.pop_back()
		if is_instance_valid(obj):
			return obj

	var new_obj = scene.instantiate()
	new_obj.set_meta("pool_scene_path", key)
	return new_obj

func return_object(obj: Node) -> void:
	if not obj.has_meta("pool_scene_path"):
		obj.queue_free()
		return

	var key = obj.get_meta("pool_scene_path")
	if not _pools.has(key):
		_pools[key] = []

	if _pools[key].has(obj):
		return

	obj.visible = false
	obj.set_physics_process(false)
	obj.set_process(false)

	var parent = obj.get_parent()
	if parent:
		_deferred_remove.call_deferred(parent, obj)

	_pools[key].append(obj)

func _deferred_remove(parent: Node, obj: Node) -> void:
	if is_instance_valid(parent) and is_instance_valid(obj) and obj.get_parent() == parent:
		parent.remove_child(obj)
