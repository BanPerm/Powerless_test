extends Area3D

var direction: Vector3
var speed: float
var damage: int
var effects: Array[AttackEffect] = []
var caster: Node3D
var max_lifetime: float = 3.0
var _timer: float = 0.0
var _scene_ref: PackedScene

func setup(dir: Vector3, spd: float, dmg: int, fx: Array[AttackEffect], cstr: Node3D, scene_ref: PackedScene) -> void:
	direction = dir
	speed = spd
	damage = dmg
	effects = fx
	caster = cstr
	_scene_ref = scene_ref
	_timer = 0.0
	visible = true
	set_process(true)
	set_physics_process(true)

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

	scale = Vector3.ZERO
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.08)

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	_timer += delta
	if _timer >= max_lifetime:
		_return_to_pool()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group(GameConstants.GROUP_ENEMY):
		if body.has_method("take_damage"):
			body.take_damage(damage, global_position)
		for effect in effects:
			effect.apply(body, caster)
		_return_to_pool()
	elif body.is_in_group(GameConstants.GROUP_OCCLUDER):
		_return_to_pool()

func _return_to_pool() -> void:
	ObjectPool.return_object(self)
