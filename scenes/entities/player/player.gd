class_name Player
extends Combatant

@export var speed: float = 6.0
@export var dash_speed: float = 20.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.6

@onready var attack_executor: Node = $AttackExecutor
@onready var hurtbox: Area3D = $HurtBox

var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var dash_direction: Vector3 = Vector3.ZERO
var last_move_direction: Vector3 = Vector3.FORWARD
var bodies_in_hurtbox: Array = []

var aim_line_indicator: GroundLineIndicator
var area_indicator: GroundAreaIndicator

class AttackSlot:
	var action_name: String
	var attack: AttackData
	var is_charging: bool = false

	func _init(action: String):
		action_name = action

var attack_slots: Array[AttackSlot] = []

func _ready() -> void:
	super._ready()
	add_to_group(GameConstants.GROUP_PLAYER)
	hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	hurtbox.body_exited.connect(_on_hurtbox_body_exited)

	aim_line_indicator = GroundLineIndicator.new()
	area_indicator = GroundAreaIndicator.new()
	get_tree().current_scene.add_child.call_deferred(aim_line_indicator)
	get_tree().current_scene.add_child.call_deferred(area_indicator)
	
	attack_slots = [
		AttackSlot.new("attack_primary"),
		AttackSlot.new("attack_secondary"),
		AttackSlot.new("attack_area"),
		AttackSlot.new("attack_orb"),
		AttackSlot.new("kick_attack"),
		AttackSlot.new("fear_attack"),
	]

	# Setup temporaire pour tester — plus tard, remplacé par un tirage aléatoire
	equip_attack(0, preload("res://resources/attacks/basic_melee.tres"))
	equip_attack(1, preload("res://resources/attacks/basic_ranged.tres"))
	equip_attack(2, preload("res://resources/attacks/basic_area.tres"))
	equip_attack(3, preload("res://resources/attacks/orb.tres"))
	equip_attack(4, preload("res://resources/attacks/kick_attack.tres"))
	equip_attack(5, preload("res://resources/attacks/fear_area.tres"))

func equip_attack(slot_index: int, attack: AttackData) -> void:
	if slot_index < attack_slots.size():
		attack_slots[slot_index].attack = attack

func _on_hurtbox_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		bodies_in_hurtbox.append(body)

func _on_hurtbox_body_exited(body: Node) -> void:
	bodies_in_hurtbox.erase(body)

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_instant_attacks()
	apply_knockback_physics(delta)
	apply_gravity(delta)
	_handle_contact_damage()
	_process_statuses(delta)
	move_and_slide()
	
func _handle_instant_attacks() -> void:
	if is_stunned():
		return
	for slot in attack_slots:
		if not slot.attack:
			continue
		if slot.attack.input_mode == AttackData.InputMode.INSTANT:
			if Input.is_action_just_pressed(slot.action_name):
				attack_executor.try_attack_data(slot.attack, self, get_aim_direction(), get_aim_ground_point())

func _handle_movement(delta: float) -> void:
	if is_stunned():
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		return

	var current_speed := speed * get_speed_multiplier()
	var input_dir := Input.get_vector("move_up", "move_down", "move_right", "move_left")
	var iso_angle := deg_to_rad(45)
	var direction := Vector3(
		input_dir.x * cos(iso_angle) - input_dir.y * sin(iso_angle),
		0,
		input_dir.x * sin(iso_angle) + input_dir.y * cos(iso_angle)
	)

	if direction.length() > 0:
		last_move_direction = direction.normalized()

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction.x * dash_speed
		velocity.z = dash_direction.z * dash_speed
		if dash_timer <= 0:
			is_dashing = false
	elif Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and direction.length() > 0:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown
		dash_direction = direction.normalized()
	else:
		if direction.length() > 0:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)

func _handle_contact_damage() -> void:
	if not is_invincible and bodies_in_hurtbox.size() > 0:
		take_damage(10, bodies_in_hurtbox[0].global_position)

func _process(_delta: float) -> void:
	_handle_charge_attacks()

func _handle_charge_attacks() -> void:
	var aim_dir := get_aim_direction()
	var aim_point := get_aim_ground_point()
	var any_line := false
	var any_circle := false

	for slot in attack_slots:
		if not slot.attack or slot.attack.input_mode != AttackData.InputMode.CHARGE_AND_RELEASE:
			continue

		if Input.is_action_pressed(slot.action_name):
			_show_indicator_for(slot.attack, aim_dir, aim_point)
			if slot.attack.indicator_type == AttackData.IndicatorType.LINE:
				any_line = true
			elif slot.attack.indicator_type == AttackData.IndicatorType.CIRCLE:
				any_circle = true

		if Input.is_action_just_released(slot.action_name):
			attack_executor.try_attack_data(slot.attack, self, aim_dir, aim_point)

	if not any_line:
		aim_line_indicator.hide_line()
	if not any_circle:
		area_indicator.hide_circle()

func _show_indicator_for(attack: AttackData, aim_dir: Vector3, aim_point: Vector3) -> void:
	match attack.indicator_type:
		AttackData.IndicatorType.LINE:
			var range_value = attack.max_range if "max_range" in attack else 10.0
			aim_line_indicator.update_line(global_position, aim_dir, range_value, get_ground_height(global_position))
		AttackData.IndicatorType.CIRCLE:
			var center := global_position
			if "is_ranged" in attack and attack.is_ranged:
				var to_point := aim_point - global_position
				to_point.y = 0
				var max_range = attack.max_cast_range if "max_cast_range" in attack else 10.0
				if to_point.length() > max_range:
					to_point = to_point.normalized() * max_range
				center = global_position + to_point
			var radius_value = attack.radius if "radius" in attack else 3.0
			area_indicator.update_circle(center, radius_value, get_ground_height(center))

func get_aim_ground_point() -> Vector3:
	var camera := get_viewport().get_camera_3d()
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)
	var plane := Plane(Vector3.UP, global_position.y)
	var intersection = plane.intersects_ray(ray_origin, ray_direction)
	return intersection if intersection else global_position + last_move_direction * 3.0

func get_aim_direction() -> Vector3:
	var dir := get_aim_ground_point() - global_position
	dir.y = 0
	return dir.normalized() if dir.length() > 0.01 else last_move_direction

func get_ground_height(pos: Vector3) -> float:
	var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(pos + Vector3(0, 5, 0), pos + Vector3(0, -5, 0))
	query.exclude = [self]
	var result := space_state.intersect_ray(query)
	return result.position.y if result else global_position.y
