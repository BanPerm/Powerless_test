class_name AttackAltar
extends Area3D

@export var choice_count: int = 3
var _triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if _triggered or not body is Player:
		return
	_triggered = true

	var already_equipped: Array[AttackData] = []
	for slot in body.attack_slots:
		if slot.attack:
			already_equipped.append(slot.attack)

	var drawn := AttackDatabase.get_random_choices(choice_count, already_equipped)
	if drawn.is_empty():
		_triggered = false
		return

	for attack in drawn:
		var slot_index = body.get_empty_slot_index()
		if slot_index == -1:
			break  # plus de slot disponible, on garde le reste pour un futur système de reroll/remplacement
		body.equip_attack(slot_index, attack)

	AttackNotificationUI.show_received(drawn)
	queue_free()
