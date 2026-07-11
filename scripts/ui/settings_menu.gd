extends Control

@onready var language_option: OptionButton = $VBox/LanguageOption if has_node("VBox/LanguageOption") else null
@onready var sfx_slider: HSlider = $VBox/SFXSlider if has_node("VBox/SFXSlider") else null
@onready var customer_choice_toggle: CheckButton = $VBox/Toggles/CustomerChoiceToggle if has_node("VBox/Toggles/CustomerChoiceToggle") else null
@onready var back_button: Button = $VBox/BackButton if has_node("VBox/BackButton") else null

func _ready() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	if language_option:
		_populate_languages()
		language_option.item_selected.connect(_on_language_changed)
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	if customer_choice_toggle:
		customer_choice_toggle.button_pressed = GameManager.has_upgrade("customer_choice_1")
		customer_choice_toggle.toggled.connect(_on_customer_choice_toggled)

func _populate_languages() -> void:
	if language_option == null:
		return
	language_option.clear()
	language_option.add_item("English", 0)
	language_option.add_item("Arabic", 1)
	match LocalizationManager.current_language:
		"en":
			language_option.selected = 0
		"ar":
			language_option.add_item("Arabic", 1)
			language_option.selected = 1

func _on_language_changed(index: int) -> void:
	match index:
		0:
			LocalizationManager.set_language("en")
		1:
			LocalizationManager.set_language("ar")

func _on_sfx_volume_changed(value: float) -> void:
	if AudioServer.bus_count > 1:
		AudioServer.set_bus_volume_db(1, linear_to_db(value / 100.0))

func _on_customer_choice_toggled(pressed: bool) -> void:
	if pressed:
		if not GameManager.has_upgrade("customer_choice_1"):
			GameManager.purchased_upgrades.append("customer_choice_1")
	else:
		GameManager.purchased_upgrades.erase("customer_choice_1")
		GameManager.purchased_upgrades.erase("customer_choice_2")
	SaveManager.save_game()

func _on_back_pressed() -> void:
	queue_free()
