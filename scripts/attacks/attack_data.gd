class_name AttackData
extends Resource

enum InputMode { INSTANT, CHARGE_AND_RELEASE }
enum IndicatorType { NONE, LINE, CIRCLE }

@export var attack_name: String = "Attaque"
@export var damage: int = 10
@export var cooldown: float = 0.5
@export var effects: Array[AttackEffect] = []

@export_group("Comportement")
@export var input_mode: InputMode = InputMode.INSTANT
@export var indicator_type: IndicatorType = IndicatorType.NONE

func execute(caster: Node3D, aim_direction: Vector3, aim_point: Vector3) -> void:
	push_error("execute() doit être surchargée")

func _apply_effects(target: Node3D, caster: Node3D) -> void:
	for effect in effects:
		effect.apply(target, caster)
