class_name ApplyStatusEffect
extends AttackEffect

@export var status: StatusEffect

func apply(target: Node3D, _source: Node3D) -> void:
	if target is Combatant and status:
		target.apply_status(status)
