extends PanelContainer

@onready var name_label: Label = $VBox/NameLabel if has_node("VBox/NameLabel") else null
@onready var desc_label: Label = $VBox/DescLabel if has_node("VBox/DescLabel") else null
@onready var cost_label: Label = $VBox/CostLabel if has_node("VBox/CostLabel") else null
@onready var action_button: Button = $VBox/ActionButton if has_node("VBox/ActionButton") else null

var upgrade_data: Dictionary = {}
var is_purchased: bool = false

signal upgrade_requested(upgrade: Dictionary)

func setup(data: Dictionary, purchased: bool, available: bool) -> void:
	upgrade_data = data
	is_purchased = purchased
	
	if name_label:
		name_label.text = data.get("name", "Upgrade")
	if desc_label:
		desc_label.text = data.get("description", "")
	
	if is_purchased:
		if cost_label:
			cost_label.text = "OWNED"
		if action_button:
			action_button.visible = false
	else:
		if cost_label:
			cost_label.text = "$%d" % data.get("cost", 0)
		if action_button:
			action_button.visible = available
			action_button.pressed.connect(_on_action_pressed)
	
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if is_purchased:
		style.bg_color = Color(0.6, 0.85, 0.6, 1)
	elif available:
		style.bg_color = Color(1.0, 0.95, 0.85, 1)
	else:
		style.bg_color = Color(0.75, 0.75, 0.75, 1)
	style.border_color = Color(0.3, 0.2, 0.1, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10)
	add_theme_stylebox_override("panel", style)

func _on_action_pressed() -> void:
	upgrade_requested.emit(upgrade_data)
