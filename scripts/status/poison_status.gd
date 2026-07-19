class_name PoisonStatus
extends StatusEffect

@export var damage_per_tick: int = 5

func on_tick(target: Combatant) -> void:
	target.apply_status_damage(damage_per_tick)
