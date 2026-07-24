extends CanvasLayer
# Autoload "AttackNotificationUI"

const ICON_COLORS := {
	AttackData.IconType.MELEE: Color(0.85, 0.25, 0.25),
	AttackData.IconType.RANGED: Color(0.25, 0.55, 0.85),
	AttackData.IconType.AREA: Color(0.9, 0.55, 0.15),
	AttackData.IconType.SUMMON: Color(0.6, 0.3, 0.85),
	AttackData.IconType.UTILITY: Color(0.4, 0.7, 0.4),
}

const ICON_SYMBOLS := {
	AttackData.IconType.MELEE: "⚔",
	AttackData.IconType.RANGED: "➹",
	AttackData.IconType.AREA: "◎",
	AttackData.IconType.SUMMON: "☄",
	AttackData.IconType.UTILITY: "✦",
}

@onready var background: ColorRect = $Background
@onready var card_row: HBoxContainer = $CenterContainer/CardRow
@onready var continue_button: Button = $ContinueButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	continue_button.pressed.connect(_on_continue_pressed)

func show_received(attacks: Array[AttackData]) -> void:
	for child in card_row.get_children():
		child.queue_free()

	for attack in attacks:
		card_row.add_child(_build_card(attack))

	visible = true
	get_tree().paused = true

func _build_card(attack: AttackData) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(220, 300)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	panel.add_child(vbox)

	# Icône colorée
	var icon_bg := PanelContainer.new()
	icon_bg.custom_minimum_size = Vector2(64, 64)
	var icon_style := StyleBoxFlat.new()
	icon_style.bg_color = ICON_COLORS.get(attack.icon_type, Color.GRAY)
	icon_style.corner_radius_top_left = 8
	icon_style.corner_radius_top_right = 8
	icon_style.corner_radius_bottom_left = 8
	icon_style.corner_radius_bottom_right = 8
	icon_bg.add_theme_stylebox_override("panel", icon_style)

	var icon_label := Label.new()
	icon_label.text = ICON_SYMBOLS.get(attack.icon_type, "?")
	icon_label.add_theme_font_size_override("font_size", 32)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_bg.add_child(icon_label)

	var icon_center := CenterContainer.new()
	icon_center.add_child(icon_bg)
	vbox.add_child(icon_center)

	# Nom
	var name_label := Label.new()
	name_label.text = attack.attack_name
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)

	vbox.add_child(HSeparator.new())

	# Description
	var desc_label := Label.new()
	desc_label.text = attack.description
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_label)

	vbox.add_child(HSeparator.new())

	# Stats
	for line in attack.get_stat_lines():
		var stat_label := Label.new()
		stat_label.text = line
		stat_label.add_theme_font_size_override("font_size", 14)
		stat_label.modulate = Color(0.8, 0.8, 0.8)
		vbox.add_child(stat_label)

	return panel

func _on_continue_pressed() -> void:
	visible = false
	get_tree().paused = false
