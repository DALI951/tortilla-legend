extends Node2D

signal drink_filled()

var mode: String = "hold"
var fill_speed: float = 1.0
var auto_fill: bool = false
var fill_progress: float = 0.0
var fill_target: float = 2.0
var is_filling: bool = false
var is_filled: bool = false

func _ready() -> void:
	_apply_upgrades()

func _process(delta: float) -> void:
	if auto_fill and is_filling:
		fill_progress += delta * fill_speed
		if fill_progress >= fill_target:
			_complete_fill()

func start_fill() -> void:
	if is_filled:
		return
	is_filling = true
	fill_progress = 0.0
	if auto_fill:
		pass

func stop_fill() -> void:
	if not is_filling:
		return
	if fill_progress >= fill_target:
		_complete_fill()
	else:
		is_filling = false
		fill_progress = 0.0

func tap_fill() -> void:
	if is_filled:
		return
	fill_progress += fill_target * 0.3
	if fill_progress >= fill_target:
		_complete_fill()

func _complete_fill() -> void:
	is_filling = false
	is_filled = true
	fill_progress = fill_target
	drink_filled.emit()

func is_ready() -> bool:
	return is_filled

func get_fill_ratio() -> float:
	if fill_target <= 0:
		return 1.0
	return clampf(fill_progress / fill_target, 0.0, 1.0)

func reset() -> void:
	fill_progress = 0.0
	is_filling = false
	is_filled = false

func _apply_upgrades() -> void:
	if GameManager.has_upgrade("soda_auto"):
		auto_fill = true
		fill_speed = 2.0
	elif GameManager.has_upgrade("soda_fast"):
		mode = "tap"
		fill_speed = 2.0
	elif GameManager.has_upgrade("soda_tap"):
		mode = "tap"
		fill_speed = 1.0
	else:
		mode = "hold"
		fill_speed = 1.0
