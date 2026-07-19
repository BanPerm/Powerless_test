extends Node

var _cooldown_timers: Dictionary = {}

func try_attack_data(attack: AttackData, caster: Node3D, aim_direction: Vector3, aim_point: Vector3) -> bool:
	if not attack:
		return false
	if _cooldown_timers.get(attack, 0.0) > 0:
		return false
	attack.execute(caster, aim_direction, aim_point)
	_cooldown_timers[attack] = attack.cooldown
	return true

func _process(delta: float) -> void:
	for attack in _cooldown_timers.keys():
		_cooldown_timers[attack] = max(0.0, _cooldown_timers[attack] - delta)
