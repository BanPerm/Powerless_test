class_name AreaAttackData
extends AttackData

@export var radius: float = 4.0
@export var is_ranged: bool = false
@export var max_cast_range: float = 10.0

func _init() -> void:
	input_mode = InputMode.CHARGE_AND_RELEASE
	indicator_type = IndicatorType.CIRCLE
	icon_type = IconType.AREA

func execute(caster: Node3D, _aim_direction: Vector3, aim_point: Vector3) -> void:
	var center := caster.global_position
	if is_ranged:
		var to_point := aim_point - caster.global_position
		to_point.y = 0
		if to_point.length() > max_cast_range:
			to_point = to_point.normalized() * max_cast_range
		center = caster.global_position + to_point

	for enemy in caster.get_tree().get_nodes_in_group(GameConstants.GROUP_ENEMY):
		if center.distance_to(enemy.global_position) <= radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(damage, center)
			_apply_effects(enemy, caster)
			
func get_stat_lines() -> Array[String]:
	var lines := super.get_stat_lines()
	lines.append("Rayon: %.1fm" % radius)
	return lines
