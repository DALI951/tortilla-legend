extends Control

@onready var money_label: Label = $TopBar/MoneyLabel
@onready var back_button: Button = $BottomBar/BackButton
@onready var next_day_button: Button = $BottomBar/NextDayButton
@onready var upgrade_container: VBoxContainer = $ScrollContainer/UpgradeContainer

var upgrades_data: Array = []

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	next_day_button.pressed.connect(_on_next_day_pressed)
	_apply_fonts()
	load_upgrades()
	display_upgrades()
	update_money()

func _apply_fonts() -> void:
	var dark: Color = Color(0.15, 0.1, 0.05)
	$TopBar/Title.add_theme_font_size_override("font_size", 52)
	$TopBar/Title.add_theme_color_override("font_color", dark)
	money_label.add_theme_font_size_override("font_size", 48)
	money_label.add_theme_color_override("font_color", Color(0.1, 0.45, 0.1))
	back_button.add_theme_font_size_override("font_size", 36)
	back_button.add_theme_color_override("font_color", Color.WHITE)
	next_day_button.add_theme_font_size_override("font_size", 36)
	next_day_button.add_theme_color_override("font_color", Color.WHITE)

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

	for upgrade in upgrades_data:
		var upgrade_id: String = upgrade.get("id", "")
		var is_purchased: bool = GameManager.has_upgrade(upgrade_id)
		var prereqs_met: bool = _check_prerequisites(upgrade.get("prerequisites", []))
		var can_afford: bool = GameManager.money >= upgrade.get("cost", 0)
		var is_available: bool = not is_purchased and prereqs_met and can_afford
		var card: PanelContainer = _create_upgrade_card(upgrade, is_purchased, is_available)
		upgrade_container.add_child(card)

func _create_upgrade_card(upgrade: Dictionary, is_purchased: bool, is_available: bool) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 140)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style: StyleBoxFlat = StyleBoxFlat.new()
	if is_purchased:
		style.bg_color = Color(0.6, 0.85, 0.6, 1)
	elif is_available:
		style.bg_color = Color(1.0, 0.95, 0.85, 1)
	else:
		style.bg_color = Color(0.85, 0.85, 0.85, 1)
	style.border_color = Color(0.3, 0.2, 0.1, 1)
	style.set_border_width_all(3)
	style.set_corner_radius_all(12)
	style.set_content_margin_all(16)
	card.add_theme_stylebox_override("panel", style)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	card.add_child(hbox)

	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(info_vbox)

	var dark: Color = Color(0.15, 0.1, 0.05)
	var name_label: Label = Label.new()
	name_label.text = upgrade.get("name", "Upgrade")
	name_label.add_theme_font_size_override("font_size", 30)
	name_label.add_theme_color_override("font_color", dark)
	info_vbox.add_child(name_label)

	var desc_label: Label = Label.new()
	desc_label.text = upgrade.get("description", "")
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.add_theme_font_size_override("font_size", 22)
	desc_label.add_theme_color_override("font_color", Color(0.3, 0.22, 0.12))
	info_vbox.add_child(desc_label)

	var right_vbox: VBoxContainer = VBoxContainer.new()
	right_vbox.custom_minimum_size = Vector2(160, 0)
	right_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_child(right_vbox)

	if is_purchased:
		var owned_label: Label = Label.new()
		owned_label.text = "OWNED"
		owned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		owned_label.add_theme_font_size_override("font_size", 30)
		owned_label.add_theme_color_override("font_color", Color(0.1, 0.4, 0.1))
		right_vbox.add_child(owned_label)
	else:
		var cost_label: Label = Label.new()
		cost_label.text = "$%d" % upgrade.get("cost", 0)
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cost_label.add_theme_font_size_override("font_size", 34)
		cost_label.add_theme_color_override("font_color", Color(0.1, 0.45, 0.1))
		right_vbox.add_child(cost_label)

		if is_available:
			var buy_button: Button = Button.new()
			buy_button.text = "BUY"
			buy_button.custom_minimum_size = Vector2(0, 60)
			buy_button.add_theme_font_size_override("font_size", 30)
			buy_button.add_theme_color_override("font_color", Color.WHITE)
			buy_button.pressed.connect(_on_buy_pressed.bind(upgrade))
			right_vbox.add_child(buy_button)

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
		FeedbackManager.vibrate_medium()
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
