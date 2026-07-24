class_name SummonAttackData
extends AttackData

@export var lifetime: float = 8.0
@export var pull_radius: float = 5.0
@export var pulse_interval: float = 2.0
@export var target_group: String = GameConstants.GROUP_ENEMY
@export var is_ranged: bool = true

func _init() -> void:
	input_mode = InputMode.CHARGE_AND_RELEASE
	indicator_type = IndicatorType.CIRCLE
	icon_type = IconType.SUMMON

func execute(caster: Node3D, _aim_direction: Vector3, aim_point: Vector3) -> void:
	var orb := PulsingOrb.new()
	caster.get_tree().current_scene.add_child.call_deferred(orb)
	orb.call_deferred("setup", aim_point, lifetime, effects, caster, pull_radius, pulse_interval, target_group)
	
func get_stat_lines() -> Array[String]:
	var lines := super.get_stat_lines()
	lines.append("Durée: %.1fs" % lifetime)
	lines.append("Rayon d'attraction: %.1fm" % pull_radius)
	return lines
