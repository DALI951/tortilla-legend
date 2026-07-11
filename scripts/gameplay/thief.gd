extends Node2D

signal thief_defeated(stolen_amount: int)
signal thief_escaped(stolen_amount: int)

var is_active: bool = false
var is_defeated: bool = false
var taps_needed: int = 2
var taps_received: int = 0
var stolen_amount: int = 0
var move_speed: float = 100.0
var direction: int = 1
var has_reached_end: bool = false

func _ready() -> void:
	_apply_upgrades()
	visible = false

func _process(delta: float) -> void:
	if not is_active or is_defeated:
		return
	position.x += direction * move_speed * delta
	if direction > 0 and position.x >= 980:
		_reach_end()
	elif direction < 0 and position.x <= 100:
		_reach_end()

func activate(counter_money: int) -> void:
	is_active = true
	is_defeated = false
	taps_received = 0
	stolen_amount = mini(counter_money, 50)
	visible = true
	direction = 1
	position.x = -50
	position.y = 400

func tap_thief() -> void:
	if not is_active or is_defeated:
		return
	taps_received += 1
	FeedbackManager.vibrate_light()
	if taps_received >= taps_needed:
		_defeat()

func _defeat() -> void:
	is_defeated = true
	is_active = false
	visible = false
	FeedbackManager.vibrate_heavy()
	thief_defeated.emit(stolen_amount)

func _reach_end() -> void:
	has_reached_end = true
	is_active = false
	visible = false
	thief_escaped.emit(stolen_amount)

func is_thief_active() -> bool:
	return is_active and not is_defeated

func _apply_upgrades() -> void:
	if GameManager.has_upgrade("thief_beat_fast"):
		taps_needed = 1
	else:
		taps_needed = 2
