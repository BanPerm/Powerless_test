class_name KnockbackEffect
extends AttackEffect

@export var force: float = 10.0

func apply(target: Node3D, caster: Node3D) -> void:
	if target.has_method("apply_knockback"):
		var direction = (target.global_position - caster.global_position).normalized()
		target.apply_knockback(direction * force)
