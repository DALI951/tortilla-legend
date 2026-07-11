extends Control

@onready var back_button: Button = $Panel/VBox/BackButton
@onready var lang_button: Button = $Panel/VBox/LanguageButton
@onready var sfx_slider: HSlider = $Panel/VBox/SFXSlider
@onready var sfx_label: Label = $Panel/VBox/SFXBox/SFXValue
@onready var choice_toggle: CheckButton = $Panel/VBox/ChoiceToggle

func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	lang_button.pressed.connect(_on_lang_pressed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	choice_toggle.toggled.connect(_on_choice_toggled)
	_update_display()

func _update_display() -> void:
	lang_button.text = LocalizationManager.tr_key("language") + ": " + LocalizationManager.current_language.upper()
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1)) * 100.0 if AudioServer.bus_count > 1 else 100.0
	sfx_label.text = "%d%%" % int(sfx_slider.value)
	choice_toggle.button_pressed = GameManager.has_upgrade("customer_choice_1") or GameManager.has_upgrade("customer_choice_2")
	choice_toggle.text = LocalizationManager.tr_key("customer_choice")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_lang_pressed() -> void:
	var langs: Array[String] = LocalizationManager.SUPPORTED_LANGUAGES
	var idx: int = langs.find(LocalizationManager.current_language)
	idx = (idx + 1) % langs.size()
	LocalizationManager.set_language(langs[idx])
	_update_display()

func _on_sfx_changed(value: float) -> void:
	if AudioServer.bus_count > 1:
		AudioServer.set_bus_volume_db(1, linear_to_db(value / 100.0))
	sfx_label.text = "%d%%" % int(value)

func _on_choice_toggled(pressed: bool) -> void:
	if pressed:
		if not GameManager.has_upgrade("customer_choice_1"):
			GameManager.purchased_upgrades.append("customer_choice_1")
	else:
		GameManager.purchased_upgrades.erase("customer_choice_1")
		GameManager.purchased_upgrades.erase("customer_choice_2")
	SaveManager.save_game()
