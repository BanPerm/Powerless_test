class_name StatusEffect
extends Resource

enum AIOverride { NONE, FROZEN, FLEE }

@export var status_id: String = "generic_status"  # sert à identifier/rafraîchir le statut
@export var duration: float = 2.0
@export var tick_interval: float = 0.0  # 0 = pas de tick périodique

@export var blocks_movement: bool = false   # stun
@export var speed_multiplier: float = 1.0   # slow (<1.0) / haste (>1.0)
@export var ai_override: AIOverride = AIOverride.NONE

func on_apply(_target: Combatant) -> void:
	pass

func on_remove(_target: Combatant) -> void:
	pass

func on_tick(_target: Combatant) -> void:
	pass
