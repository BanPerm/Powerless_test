class_name Enemy
extends Combatant

@export var speed: float = 3.5
@export var stop_distance: float = 0.5
@export var path_update_interval: float = 0.3

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

var target: Node3D
var _path_update_timer: float = 0.0
var _debug_timer := 0.0
var _debug_start_pos: Vector3

func _ready() -> void:
	super._ready()
	invincibility_duration = GameConstants.DEFAULT_INVINCIBILITY_ENEMY
	add_to_group(GameConstants.GROUP_ENEMY)
	target = get_tree().get_first_node_in_group(GameConstants.GROUP_PLAYER)

	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = stop_distance
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	
	_setup_navigation.call_deferred()
	_debug_start_pos = global_position

func _setup_navigation() -> void:
	# Attendre que la carte physique et le serveur soient 100% prêts
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	if target:
		nav_agent.target_position = target.global_position

func _physics_process(delta: float) -> void:
	_handle_chase(delta)
	apply_knockback_physics(delta)
	apply_gravity(delta)
	_process_statuses(delta)
	move_and_slide()
	
func _handle_chase(delta: float) -> void:
	if is_stunned() or not target:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		return

	var current_speed := speed * get_speed_multiplier()

	_path_update_timer -= delta
	if _path_update_timer <= 0:
		_path_update_timer = path_update_interval
		nav_agent.target_position = target.global_position

	if nav_agent.is_navigation_finished():
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
		return

	var next_path_pos := nav_agent.get_next_path_position()
	var direction := Vector3(next_path_pos.x - global_position.x, 0, next_path_pos.z - global_position.z)
	if direction.length() > 0.01:
		direction = direction.normalized()
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	var desired_velocity := Vector3(direction.x * current_speed, 0, direction.z * current_speed)
	nav_agent.set_velocity(desired_velocity)  # passe par le nav agent, pas assignation directe

func _on_velocity_computed(safe_velocity: Vector3) -> void:
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z

func _apply_deceleration() -> void:
	var current_speed := speed * get_speed_multiplier()
	velocity.x = move_toward(velocity.x, 0, current_speed)
	velocity.z = move_toward(velocity.z, 0, current_speed)
