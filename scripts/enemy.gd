extends CharacterBody3D

@export var target: Node3D  # le joueur
@export var speed: float = 3.5
@export var stop_distance: float = 0.5  # distance à laquelle il arrête d'avancer

var gravity = 9.8

func _physics_process(delta):
	if target:
		var to_target = target.global_position - global_position
		to_target.y = 0  # on ignore la hauteur pour la direction horizontale
		var distance = to_target.length()

		if distance > stop_distance:
			var direction = to_target.normalized()
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
