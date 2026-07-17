extends CharacterBody3D

@export var speed: float = 6.0
@export var dash_speed: float = 20.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.6
@export var max_health: int = 100

var gravity = 9.8
var is_dashing: bool = false
var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO

var health: int = max_health
var is_invincible: bool = false
var invincibility_duration: float = 0.5
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_friction: float = 8.0

var bodies_in_hurtbox: Array = []
		
func take_damage(amount: int, from_position: Vector3):
	health -= amount
	is_invincible = true
	
	# Knockback : direction opposée à l'attaquant
	var knockback_dir = (global_position - from_position).normalized()
	knockback_velocity = knockback_dir * 8.0
	
	# Flash visuel
	flash_hit()
	
	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

func flash_hit():
	var mat = $MeshInstance3D.get_surface_override_material(0)
	if mat:
		var original_color = mat.albedo_color
		mat.albedo_color = Color.RED
		await get_tree().create_timer(0.1).timeout
		mat.albedo_color = original_color

func _physics_process(delta):
	var input_dir = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	# Rotation de 45° pour aligner avec la vue isométrique
	var iso_angle = deg_to_rad(45)
	var direction = Vector3(
		input_dir.x * cos(iso_angle) - input_dir.y * sin(iso_angle),
		0,
		input_dir.x * sin(iso_angle) + input_dir.y * cos(iso_angle)
	)
	
	if cooldown_timer > 0:
		cooldown_timer -= delta

	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		if dash_timer <= 0:
			is_dashing = false
	else:
		# Déclenchement du dash
		if Input.is_action_just_pressed("dash") and cooldown_timer <= 0 and direction.length() > 0:
			is_dashing = true
			dash_timer = dash_duration
			cooldown_timer = dash_cooldown
			dash_direction = direction.normalized()
		else:
			# Mouvement normal
			if direction.length() > 0:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
				
	if not is_invincible and bodies_in_hurtbox.size() > 0:
		take_damage(10, bodies_in_hurtbox[0].global_position)

	if knockback_velocity.length() > 0.1:
		velocity.x += knockback_velocity.x
		velocity.z += knockback_velocity.z
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_friction * delta)

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()

func _on_hurt_box_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		bodies_in_hurtbox.append(body)
		
func _on_hurt_box_body_exited(body: Node3D) -> void:
	if body in bodies_in_hurtbox:
		bodies_in_hurtbox.erase(body)
