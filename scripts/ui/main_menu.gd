extends Control

@onready var day_label: Label = $DayCounter
@onready var play_button: Button = $PlayButton
@onready var kitchen_button: Button = $KitchenButton
@onready var settings_button: Button = $SettingsButton

func _ready() -> void:
	if SaveManager.has_save():
		SaveManager.load_game()
	_apply_font_sizes()
	update_display()
	play_button.pressed.connect(_on_play_pressed)
	kitchen_button.pressed.connect(_on_kitchen_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func _apply_font_sizes() -> void:
	$TitleLabel.add_theme_font_size_override("font_size", 64)
	day_label.add_theme_font_size_override("font_size", 40)
	play_button.add_theme_font_size_override("font_size", 36)
	kitchen_button.add_theme_font_size_override("font_size", 36)
	settings_button.add_theme_font_size_override("font_size", 36)

func update_display() -> void:
	day_label.text = LocalizationManager.tr_key("day_label") % GameManager.current_day
	if GameManager.current_day > GameManager.MAX_DAY:
		play_button.text = LocalizationManager.tr_key("play_endless")
	else:
		play_button.text = LocalizationManager.tr_key("play")

func _on_play_pressed() -> void:
	GameManager.start_new_game() if not SaveManager.has_save() else GameManager.continue_game()
	get_tree().change_scene_to_file("res://scenes/gameplay.tscn")

func _on_kitchen_pressed() -> void:
	GameManager.enter_shop()
	get_tree().change_scene_to_file("res://scenes/kitchen_shop.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings_scene.tscn")
