class_name RangedAttackData
extends AttackData

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 15.0
@export var max_range: float = 15.0

func _init() -> void:
	input_mode = InputMode.CHARGE_AND_RELEASE
	indicator_type = IndicatorType.LINE

func execute(caster: Node3D, aim_direction: Vector3, _aim_point: Vector3) -> void:
	var projectile = ObjectPool.get_object(projectile_scene)
	var pos := caster.global_position + aim_direction * 0.6 + Vector3(0, 1, 0)
	caster.get_tree().current_scene.add_child.call_deferred(projectile)
	projectile.call_deferred("look_at_from_position", pos, pos + aim_direction, Vector3.UP)
	projectile.call_deferred("setup", aim_direction, projectile_speed, damage, effects, caster, projectile_scene)
