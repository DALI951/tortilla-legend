extends Node

signal event_triggered(event: Dictionary)
signal event_ended()

var events_data: Array = []
var last_event_day: int = 0
var min_days_between_events: int = 7
var max_days_between_events: int = 10
var current_event: Dictionary = {}

func _ready() -> void:
	load_events()

func load_events() -> void:
	var file: FileAccess = FileAccess.open("res://data/events.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load events.json")
		return
	var json: JSON = JSON.new()
	var error: Error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		push_error("Failed to parse events.json: " + json.get_error_message())
		return
	var data: Dictionary = json.data
	events_data = data.get("events", [])

func check_for_event(day: int) -> bool:
	var days_since_last: int = day - last_event_day
	if days_since_last < min_days_between_events:
		return false
	if days_since_last >= min_days_between_events:
		var chance: float = float(days_since_last - min_days_between_events) / float(max_days_between_events - min_days_between_events)
		if randf() < chance + 0.3:
			_trigger_event(day)
			return true
	return false

func check_midday_event(day: int) -> bool:
	if not current_event.is_empty():
		return false
	if randf() < 0.15:
		_trigger_event(day)
		return true
	return false

func _trigger_event(day: int) -> void:
	if events_data.is_empty():
		return
	current_event = events_data[randi() % events_data.size()]
	last_event_day = day
	event_triggered.emit(current_event)

func end_event() -> void:
	current_event.clear()
	event_ended.emit()

func get_current_event() -> Dictionary:
	return current_event

func get_customer_multiplier() -> float:
	if current_event.is_empty():
		return 1.0
	var effect: Dictionary = current_event.get("effect", {})
	if effect.get("type", "") == "more_customers":
		return effect.get("customer_multiplier", 1.0)
	if effect.get("type", "") == "high_value_orders":
		return effect.get("customer_multiplier", 1.0)
	return 1.0

func get_patience_multiplier() -> float:
	if current_event.is_empty():
		return 1.0
	var effect: Dictionary = current_event.get("effect", {})
	if effect.get("type", "") == "more_customers":
		return effect.get("patience_multiplier", 1.0)
	return 1.0

func get_price_multiplier() -> float:
	if current_event.is_empty():
		return 1.0
	var effect: Dictionary = current_event.get("effect", {})
	if effect.get("type", "") == "bonus_payment":
		return effect.get("multiplier", 1.0)
	if effect.get("type", "") == "high_value_orders":
		return effect.get("price_multiplier", 1.0)
	return 1.0

func is_previewed() -> bool:
	return not current_event.is_empty()
