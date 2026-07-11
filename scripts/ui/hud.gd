extends CanvasLayer

@onready var money_label: Label = $MoneyCounter
@onready var timer_label: Label = $DayTimer
@onready var pause_button: Button = $PauseButton
@onready var event_label: Label = $EventLabel if has_node("EventLabel") else null

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_pressed)
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.day_started.connect(_on_day_started)
	update_display()

func _process(_delta: float) -> void:
	timer_label.text = "%ds" % int(GameManager.day_timer_current)

func update_display() -> void:
	money_label.text = "$%d" % GameManager.money
	timer_label.text = "%ds" % int(GameManager.day_timer_current)

func _on_money_changed(_new_amount: int) -> void:
	money_label.text = "$%d" % GameManager.money

func _on_day_started(_day: int) -> void:
	update_display()

func _on_pause_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		pause_button.text = "||"
	else:
		get_tree().paused = true
		pause_button.text = "▶"

func show_event_notification(event_name: String) -> void:
	if event_label:
		event_label.text = event_name
		event_label.visible = true
		var tween: Tween = create_tween()
		tween.tween_interval(3.0)
		tween.tween_property(event_label, "modulate:a", 0.0, 0.5)
		tween.tween_callback(func(): event_label.visible = false; event_label.modulate.a = 1.0)
