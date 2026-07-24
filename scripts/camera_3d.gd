extends Camera3D

# --- Follow ---
@export var target: Node3D
@export var offset: Vector3 = Vector3(10, 12, 10)
@export var follow_smoothness: float = 5.0

# --- Occlusion ---
@export var fade_speed: float = 8.0
@export var target_alpha: float = 0.25

var faded_objects: Dictionary = {}

func _ready():
	look_at(global_position - offset, Vector3.UP)

func _physics_process(delta):
	if not target:
		return
	
	# Follow
	var target_pos = target.global_position + offset
	global_position = global_position.lerp(target_pos, follow_smoothness * delta)
	
	# Occlusion
	var space_state = get_world_3d().direct_space_state
	var from = global_position
	var to = target.global_position + Vector3(0, 1, 0)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = false
	var currently_hit: Array = []
	
	var offsets = [Vector3.ZERO, Vector3(0.3, 0, 0), Vector3(-0.3, 0, 0)]
	for off in offsets:
		query.to = to + off
		var result = space_state.intersect_ray(query)
		if result and result.collider.is_in_group(GameConstants.GROUP_OCCLUDER):
			currently_hit.append(result.collider)
	
	for obj in currently_hit:
		if not faded_objects.has(obj):
			var mat = get_material_for_node(obj)
			if mat:
				faded_objects[obj] = mat
		if faded_objects.has(obj):
			faded_objects[obj].set_shader_parameter("alpha", 
				lerp(faded_objects[obj].get_shader_parameter("alpha"), target_alpha, fade_speed * delta))
	
	for obj in faded_objects.keys():
		if obj not in currently_hit:
			var mat = faded_objects[obj]
			mat.set_shader_parameter("alpha", 
				lerp(mat.get_shader_parameter("alpha"), 1.0, fade_speed * delta))
				
func get_material_for_node(node):
	# Si c'est un nœud CSG (CSGBox, CSGSphere, etc.)
	if node is CSGPrimitive3D:
		return node.material
	
	# Si c'est une MeshInstance3D (ou une enfant d'un StaticBody3D)
	# Vérifiez s'il s'agit d'une MeshInstance ou s'il en contient une
	var mesh_instance = node.get_node_or_null("MeshInstance3D") if not node is MeshInstance3D else node
	if mesh_instance:
		var mat = mesh_instance.get_surface_override_material(0)
		if not mat:
			var active_mat = mesh_instance.get_active_material(0)
			if active_mat:
				mat = active_mat.duplicate()
				mesh_instance.set_surface_override_material(0, mat)
		return mat
	return null
	
func find_mesh_instance(node: Node) -> MeshInstance3D:
	for child in node.get_children():
		if child is MeshInstance3D:
			return child
	return null
