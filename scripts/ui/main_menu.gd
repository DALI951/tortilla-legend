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
	var dark: Color = Color(0.15, 0.1, 0.05)
	$TitleLabel.add_theme_font_size_override("font_size", 72)
	$TitleLabel.add_theme_color_override("font_color", dark)
	day_label.add_theme_font_size_override("font_size", 48)
	day_label.add_theme_color_override("font_color", dark)
	play_button.add_theme_font_size_override("font_size", 48)
	play_button.add_theme_color_override("font_color", Color.WHITE)
	kitchen_button.add_theme_font_size_override("font_size", 48)
	kitchen_button.add_theme_color_override("font_color", Color.WHITE)
	settings_button.add_theme_font_size_override("font_size", 48)
	settings_button.add_theme_color_override("font_color", Color.WHITE)

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
