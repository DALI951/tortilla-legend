extends Timer

@onready var timer_label: Label = get_node("/root/Gameplay/DayTimer")
@onready var money_label: Label = get_node("/root/Gameplay/MoneyCounter")

var is_running: bool = false

func _ready() -> void:
	wait_time = 1.0
	timeout.connect(_on_timeout)
	GameManager.day_started.connect(_on_day_started)

func _on_day_started(_day: int) -> void:
	start_timer()

func start_timer() -> void:
	is_running = true
	start()

func stop_timer() -> void:
	is_running = false
	stop()

func _on_timeout() -> void:
	if not is_running:
		return
	GameManager.day_timer_current -= 1.0
	if GameManager.day_timer_current <= 0:
		GameManager.day_timer_current = 0
		GameManager.end_day()
		get_tree().change_scene_to_file("res://scenes/day_summary.tscn")
	update_display()

func _process(_delta: float) -> void:
	if is_running:
		update_display()

func update_display() -> void:
	if timer_label:
		timer_label.text = "%ds" % int(GameManager.day_timer_current)
	if money_label:
		money_label.text = "$%d" % GameManager.money
