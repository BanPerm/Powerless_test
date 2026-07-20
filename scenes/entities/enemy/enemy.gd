class_name Enemy
extends Combatant

@export var speed: float = 3.5
@export var stop_distance: float = 0.5

var target: Node3D

func _ready() -> void:
	super._ready()
	invincibility_duration = GameConstants.DEFAULT_INVINCIBILITY_ENEMY
	add_to_group(GameConstants.GROUP_ENEMY)
	target = get_tree().get_first_node_in_group(GameConstants.GROUP_PLAYER)

func _physics_process(delta: float) -> void:
	_handle_chase()
	apply_knockback_physics(delta)
	apply_gravity(delta)
	_process_statuses(delta)
	move_and_slide()

func _handle_chase() -> void:
	if is_stunned():
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		return

	var override := get_ai_override()
	var current_speed := speed * get_speed_multiplier()

	if override == StatusEffect.AIOverride.FROZEN or not target:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		return

	if override == StatusEffect.AIOverride.FLEE:
		var away_dir := (global_position - target.global_position).normalized()
		velocity.x = away_dir.x * current_speed
		velocity.z = away_dir.z * current_speed
		return

	var to_target := target.global_position - global_position
	to_target.y = 0
	var distance := to_target.length()

	if distance > stop_distance:
		var direction := to_target.normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
