class_name TeleportEffect
extends AttackEffect

enum Mode { CASTER_TO_TARGET, TARGET_TO_CASTER, SWAP }

@export var mode: Mode = Mode.CASTER_TO_TARGET
@export var offset_distance: float = 1.5

func apply(target: Node3D, source: Node3D) -> void:
	match mode:
		Mode.CASTER_TO_TARGET:
			var dir = (source.global_position - target.global_position).normalized()
			source.global_position = target.global_position + dir * offset_distance
		Mode.TARGET_TO_CASTER:
			var dir = (target.global_position - source.global_position).normalized()
			target.global_position = source.global_position + dir * offset_distance
		Mode.SWAP:
			var tmp = source.global_position
			source.global_position = target.global_position
			target.global_position = tmp
