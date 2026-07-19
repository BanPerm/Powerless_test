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

	obj.visible = false
	obj.set_physics_process(false)
	obj.set_process(false)
	if obj.get_parent():
		obj.get_parent().remove_child.call_deferred(obj)

	_pools[key].append(obj)
