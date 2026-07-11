extends Node2D

signal helper_activated()

var is_awake: bool = false
var is_auto: bool = false
var sleep_timer: float = 0.0

func _ready() -> void:
	_apply_upgrades()

func _process(delta: float) -> void:
	if is_auto and not is_awake:
		is_awake = true
		helper_activated.emit()

func tap_helper() -> void:
	if is_auto:
		return
	if not is_awake:
		is_awake = true
		helper_activated.emit()

func deactivate() -> void:
	if not is_auto:
		is_awake = false

func is_helper_active() -> bool:
	return is_awake

func _apply_upgrades() -> void:
	if GameManager.has_upgrade("helper_auto"):
		is_auto = true
		is_awake = true
	elif GameManager.has_upgrade("helper_wake"):
		is_auto = false
		is_awake = false
	else:
		is_auto = false
		is_awake = false
