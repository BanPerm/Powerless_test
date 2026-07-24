class_name PulsingOrb
extends Node3D

var radius: float = 5.0
var pulse_interval: float = 2.0
var target_group: String = GameConstants.GROUP_ENEMY

var effects: Array[AttackEffect] = []
var caster: Node3D
var _lifetime: float = 8.0
var _life_timer: float = 0.0
var _pulse_timer: float = 0.0
var _visual: MeshInstance3D
var _range_indicator: GroundAreaIndicator

func _init() -> void:
	_visual = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.3
	sphere.height = 0.6
	_visual.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.4, 0.7, 1.0, 0.9)
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = Color(0.4, 0.7, 1.0)
	_visual.material_override = mat
	add_child(_visual)

func setup(spawn_position: Vector3, lifetime: float, fx: Array[AttackEffect], cstr: Node3D, r: float, interval: float, group: String) -> void:
	global_position = spawn_position
	_lifetime = lifetime
	effects = fx
	caster = cstr
	radius = r
	pulse_interval = interval
	target_group = group
	_pulse_timer = pulse_interval

	_range_indicator = GroundAreaIndicator.new()
	_range_indicator.color = Color(0.4, 0.7, 1.0, 0.2)
	get_tree().current_scene.add_child.call_deferred(_range_indicator)

func _process(delta: float) -> void:
	if _range_indicator and is_instance_valid(_range_indicator):
		_range_indicator.update_circle(global_position, radius, global_position.y)

	_life_timer += delta
	if _life_timer >= _lifetime:
		if _range_indicator:
			_range_indicator.queue_free()
		queue_free()
		return

	_pulse_timer -= delta
	if _pulse_timer <= 0:
		_pulse_timer = pulse_interval
		_pulse()
		_flash_pulse()

func _pulse() -> void:
	for entity in get_tree().get_nodes_in_group(target_group):
		if entity == caster:
			continue
		if global_position.distance_to(entity.global_position) <= radius:
			for effect in effects:
				effect.apply(entity, self)  # "self" = l'orbe est la source du pull

func _flash_pulse() -> void:
	var tween := create_tween()
	tween.tween_property(_visual, "scale", Vector3.ONE * 1.5, 0.1)
	tween.tween_property(_visual, "scale", Vector3.ONE, 0.15)
