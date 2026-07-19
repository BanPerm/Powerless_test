class_name PullEffect
extends AttackEffect

@export var force: float = 10.0

func apply(target: Node3D, source: Node3D) -> void:
	if target.has_method("apply_knockback"):
		var direction = (source.global_position - target.global_position).normalized()
		target.apply_knockback(direction * force)
