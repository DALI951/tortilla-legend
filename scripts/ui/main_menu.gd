extends Control

@onready var day_label: Label = $DayCounter
@onready var play_button: Button = $PlayButton
@onready var kitchen_button: Button = $KitchenButton
@onready var settings_button: Button = $SettingsButton

func _ready() -> void:
	update_display()
	play_button.pressed.connect(_on_play_pressed)
	kitchen_button.pressed.connect(_on_kitchen_pressed)
	settings_button.pressed.connect(_on_settings_pressed)

func update_display() -> void:
	day_label.text = tr("day_label") % GameManager.current_day
	if GameManager.current_day > GameManager.MAX_DAY:
		play_button.text = tr("play_endless")
	else:
		play_button.text = tr("play")

func _on_play_pressed() -> void:
	if SaveManager.has_save():
		GameManager.continue_game()
	else:
		GameManager.start_new_game()
	get_tree().change_scene_to_file("res://scenes/gameplay.tscn")

func _on_kitchen_pressed() -> void:
	GameManager.enter_shop()
	get_tree().change_scene_to_file("res://scenes/kitchen_shop.tscn")

func _on_settings_pressed() -> void:
	pass
