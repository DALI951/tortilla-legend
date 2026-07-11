extends Control

@onready var resume_button: Button = $Panel/VBox/ResumeButton if has_node("Panel/VBox/ResumeButton") else null
@onready var quit_button: Button = $Panel/VBox/QuitButton if has_node("Panel/VBox/QuitButton") else null

func _ready() -> void:
	visible = false
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func show_pause() -> void:
	visible = true
	get_tree().paused = true

func hide_pause() -> void:
	visible = false
	get_tree().paused = false

func _on_resume_pressed() -> void:
	hide_pause()

func _on_quit_pressed() -> void:
	get_tree().paused = false
	GameManager.enter_menu()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
