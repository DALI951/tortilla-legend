extends Node

var events: Array = []

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
	events = data.get("events", [])

func get_event_by_id(event_id: String) -> Dictionary:
	for event in events:
		if event.get("id", "") == event_id:
			return event
	return {}

func get_random_event() -> Dictionary:
	if events.is_empty():
		return {}
	return events[randi() % events.size()]
