extends Control

@onready var money_label: Label = $MoneyLabel
@onready var back_button: Button = $BackButton
@onready var next_day_button: Button = $NextDayButton
@onready var upgrade_container: Control = $UpgradeContainer

var upgrade_card_scene: PackedScene = null
var upgrades_data: Array = []

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	next_day_button.pressed.connect(_on_next_day_pressed)
	load_upgrades()
	display_upgrades()
	update_money()

func load_upgrades() -> void:
	var file: FileAccess = FileAccess.open("res://data/upgrades.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load upgrades.json")
		return
	var json: JSON = JSON.new()
	var error: Error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		push_error("Failed to parse upgrades.json: " + json.get_error_message())
		return
	var data: Dictionary = json.data
	upgrades_data = data.get("upgrades", [])

func display_upgrades() -> void:
	for child in upgrade_container.get_children():
		child.queue_free()
	
	var x_offset: float = 50.0
	var y_offset: float = 10.0
	var card_width: float = 160.0
	var card_height: float = 200.0
	var spacing: float = 15.0
	
	for upgrade in upgrades_data:
		var upgrade_id: String = upgrade.get("id", "")
		var is_purchased: bool = GameManager.has_upgrade(upgrade_id)
		var prereqs_met: bool = _check_prerequisites(upgrade.get("prerequisites", []))
		var can_afford: bool = GameManager.money >= upgrade.get("cost", 0)
		var is_available: bool = not is_purchased and prereqs_met and can_afford
		
		var card: PanelContainer = _create_upgrade_card(upgrade, is_purchased, is_available)
		card.position = Vector2(x_offset, y_offset)
		upgrade_container.add_child(card)
		
		x_offset += card_width + spacing
		if x_offset > 1700.0:
			x_offset = 50.0
			y_offset += card_height + spacing

func _create_upgrade_card(upgrade: Dictionary, is_purchased: bool, is_available: bool) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(150, 190)
	
	var style: StyleBoxFlat = StyleBoxFlat.new()
	if is_purchased:
		style.bg_color = Color(0.6, 0.85, 0.6, 1)
	elif is_available:
		style.bg_color = Color(1.0, 0.95, 0.85, 1)
	else:
		style.bg_color = Color(0.75, 0.75, 0.75, 1)
	style.border_color = Color(0.3, 0.2, 0.1, 1)
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", style)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	card.add_child(vbox)
	
	var name_label: Label = Label.new()
	name_label.text = upgrade.get("name", "Upgrade")
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_label)
	
	var desc_label: Label = Label.new()
	desc_label.text = upgrade.get("description", "")
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(desc_label)
	
	var spacer: Control = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	if is_purchased:
		var owned_label: Label = Label.new()
		owned_label.text = "OWNED"
		owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(owned_label)
	else:
		var cost_label: Label = Label.new()
		cost_label.text = "$%d" % upgrade.get("cost", 0)
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(cost_label)
		
		if is_available:
			var buy_button: Button = Button.new()
			buy_button.text = "BUY"
			buy_button.pressed.connect(_on_buy_pressed.bind(upgrade))
			vbox.add_child(buy_button)
	
	return card

func _check_prerequisites(prereqs: Array) -> bool:
	for prereq in prereqs:
		if not GameManager.has_upgrade(String(prereq)):
			return false
	return true

func _on_buy_pressed(upgrade: Dictionary) -> void:
	var upgrade_id: String = upgrade.get("id", "")
	var cost: int = upgrade.get("cost", 0)
	if GameManager.purchase_upgrade(upgrade_id, cost):
		display_upgrades()
		update_money()

func update_money() -> void:
	money_label.text = "$%d" % GameManager.money

func _on_back_pressed() -> void:
	GameManager.enter_menu()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_next_day_pressed() -> void:
	GameManager.advance_day()
	if GameManager.current_day > GameManager.MAX_DAY:
		get_tree().change_scene_to_file("res://scenes/day_summary.tscn")
	else:
		GameManager.start_day()
		get_tree().change_scene_to_file("res://scenes/gameplay.tscn")
