class_name MeleeAttackData
extends AttackData

@export var range: float = 2.0
@export var angle_degrees: float = 60.0
@export var single_target: bool = false

func _init() -> void:
	input_mode = InputMode.INSTANT
	indicator_type = IndicatorType.NONE

func execute(caster: Node3D, aim_direction: Vector3, _aim_point: Vector3) -> void:
	_spawn_slash_vfx(caster, aim_direction)

	var hit_targets: Array = []
	for enemy:CharacterBody3D in caster.get_tree().get_nodes_in_group(GameConstants.GROUP_ENEMY):
		var to_enemy := enemy.global_position - caster.global_position
		to_enemy.y = 0
		if to_enemy.length() > range:
			continue
		var angle := rad_to_deg(aim_direction.angle_to(to_enemy.normalized()))
		if angle <= angle_degrees / 2.0:
			hit_targets.append(enemy)

	if single_target and hit_targets.size() > 1:
		hit_targets.sort_custom(func(a, b): return caster.global_position.distance_to(a.global_position) < caster.global_position.distance_to(b.global_position))
		hit_targets = [hit_targets[0]]

	for enemy in hit_targets:
		_apply_hit(enemy, caster)

func _apply_hit(target: Node3D, caster: Node3D) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage, caster.global_position)
	_apply_effects(target, caster)

func _spawn_slash_vfx(caster: Node3D, aim_direction: Vector3) -> void:
	var slash := SlashEffect.new()
	var pos := caster.global_position + Vector3(0, 0.05, 0)
	caster.get_tree().current_scene.add_child(slash)
	slash.look_at_from_position(pos, pos + aim_direction, Vector3.UP)
	slash.setup(range, angle_degrees)
	
func get_stat_lines() -> Array[String]:
	var lines := super.get_stat_lines()
	lines.append("Portée: %.1fm" % range)
	lines.append("Angle: %d°" % angle_degrees)
	return lines
