class_name LaunchEffect
extends AttackEffect

@export var strength: float = 12.0

func apply(target: Node3D, _source: Node3D) -> void:
	if target.has_method("launch_upward"):
		target.launch_upward(strength)
