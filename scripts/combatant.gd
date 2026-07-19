class_name Combatant
extends CharacterBody3D

signal health_changed(new_health: int, max_health: int)
signal died
signal status_applied(status: StatusEffect)
signal status_removed(status: StatusEffect)
signal damaged(amount: int, from_position: Vector3)

@export var max_health: int = 100
@export var invincibility_duration: float = 0.5

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var health: int
var gravity: float = 9.8
var is_invincible: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_friction: float = 8.0
var active_statuses: Dictionary = {}

func _ready() -> void:
	health = max_health
	_duplicate_material()

func _duplicate_material() -> void:
	var mat = mesh_instance.get_surface_override_material(0)
	if mat:
		mesh_instance.set_surface_override_material(0, mat.duplicate())
	else:
		var active_mat = mesh_instance.get_active_material(0)
		if active_mat:
			mesh_instance.set_surface_override_material(0, active_mat.duplicate())

func apply_knockback(velocity_impulse: Vector3) -> void:
	knockback_velocity = velocity_impulse

func apply_knockback_physics(delta: float) -> void:
	if knockback_velocity.length() > 0.1:
		velocity.x += knockback_velocity.x
		velocity.z += knockback_velocity.z
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_friction * delta)

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

func launch_upward(strength: float) -> void:
	velocity.y = strength

# --- Statuts ---

func apply_status(effect: StatusEffect) -> void:
	if active_statuses.has(effect.status_id):
		active_statuses[effect.status_id].time_remaining = effect.duration
	else:
		active_statuses[effect.status_id] = {
			"effect": effect,
			"time_remaining": effect.duration,
			"tick_timer": effect.tick_interval
		}
		effect.on_apply(self)
		status_applied.emit(effect)

func _process_statuses(delta: float) -> void:
	for status_id in active_statuses.keys().duplicate():
		var entry = active_statuses[status_id]
		var effect: StatusEffect = entry.effect

		entry.time_remaining -= delta

		if effect.tick_interval > 0:
			entry.tick_timer -= delta
			if entry.tick_timer <= 0:
				effect.on_tick(self)
				entry.tick_timer += effect.tick_interval

		if entry.time_remaining <= 0:
			effect.on_remove(self)
			active_statuses.erase(status_id)
			status_removed.emit(effect)

func is_stunned() -> bool:
	for entry in active_statuses.values():
		if entry.effect.blocks_movement:
			return true
	return false

func get_speed_multiplier() -> float:
	var mult := 1.0
	for entry in active_statuses.values():
		mult *= entry.effect.speed_multiplier
	return mult

func get_ai_override() -> int:
	for entry in active_statuses.values():
		if entry.effect.ai_override != StatusEffect.AIOverride.NONE:
			return entry.effect.ai_override
	return StatusEffect.AIOverride.NONE

func apply_status_damage(amount: int) -> void:
	health = max(0, health - amount)
	health_changed.emit(health, max_health)
	flash_hit()
	if health <= 0:
		die()

func take_damage(amount: int, from_position: Vector3) -> void:
	if is_invincible:
		return
	health = max(0, health - amount)
	is_invincible = true

	damaged.emit(amount, from_position)
	health_changed.emit(health, max_health)
	flash_hit()

	await get_tree().create_timer(invincibility_duration).timeout
	is_invincible = false

	if health <= 0:
		die()

func die() -> void:
	died.emit()
	queue_free()

func flash_hit() -> void:
	var mat = mesh_instance.get_surface_override_material(0)
	if mat:
		var original_color = mat.albedo_color
		mat.albedo_color = Color.RED
		await get_tree().create_timer(0.1).timeout
		if mat:
			mat.albedo_color = original_color
