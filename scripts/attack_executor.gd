class_name AttackExecutor
extends Node

@export var equipped_attacks: Array[AttackData] = []
var _cooldown_timers: Dictionary = {}

func try_attack_data(attack: AttackData, caster: Node3D, aim_direction: Vector3, aim_point: Vector3) -> bool:
	if not attack:
		return false
	if _cooldown_timers.get(attack, 0.0) > 0:
		return false
	attack.execute(caster, aim_direction, aim_point)
	_cooldown_timers[attack] = attack.cooldown
	return true

func get_cooldown_fraction(attack: AttackData) -> float:
	if not attack or attack.cooldown <= 0:
		return 0.0
	var remaining: float = _cooldown_timers.get(attack, 0.0)
	return clamp(remaining / attack.cooldown, 0.0, 1.0)

func _process(delta: float) -> void:
	for attack in _cooldown_timers.keys():
		_cooldown_timers[attack] = max(0.0, _cooldown_timers[attack] - delta)
