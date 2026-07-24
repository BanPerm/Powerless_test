extends CanvasLayer

@export var player: Player
@export var dungeon_manager: Node3D

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/HealthLabel
@onready var cooldown_row: HBoxContainer = $CooldownRow
@onready var minimap: Control = $MiniMap/MiniMapDraw

var cooldown_overlays: Array[ColorRect] = []

func _ready() -> void:
	if not player:
		push_warning("HUD: aucun player assigné")
		return

	player.health_changed.connect(_on_health_changed)
	_on_health_changed(player.health, player.max_health)

	for slot_control in cooldown_row.get_children():
		var overlay := slot_control.get_node_or_null("CooldownOverlay")
		if overlay:
			cooldown_overlays.append(overlay)

	if minimap:
		minimap.player = player
		minimap.dungeon_manager = dungeon_manager

func _on_health_changed(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current
	health_label.text = "%d / %d" % [current, max_health]

func _process(_delta: float) -> void:
	if not player:
		return
	for i in range(min(player.attack_slots.size(), cooldown_overlays.size())):
		var slot := player.attack_slots[i]
		var overlay := cooldown_overlays[i]
		if slot.attack:
			var fraction := player.attack_executor.get_cooldown_fraction(slot.attack)
			overlay.visible = fraction > 0.0
			overlay.custom_minimum_size.y = 40.0 * fraction
		else:
			overlay.visible = false
