extends Node

@export var all_attacks: Array[AttackData] = []

func _ready() -> void:
	if all_attacks.is_empty():
		all_attacks = [
			preload("res://resources/attacks/basic_melee.tres"),
			preload("res://resources/attacks/basic_ranged.tres"),
			preload("res://resources/attacks/basic_area.tres"),
			preload("res://resources/attacks/orb.tres"),
			preload("res://resources/attacks/kick_attack.tres"),
			preload("res://resources/attacks/fear_area.tres"),
		]

func get_random_choices(count: int, exclude: Array[AttackData] = []) -> Array[AttackData]:
	var pool: Array[AttackData] = all_attacks.filter(func(a): return not exclude.has(a))
	pool.shuffle()
	return pool.slice(0, min(count, pool.size()))
