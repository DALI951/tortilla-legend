extends Node2D

signal meat_cooked(slot_index: int)
signal meat_burned(slot_index: int)

var slots: Array[Dictionary] = []
var max_slots: int = 4
var cook_speed_multiplier: float = 1.0
var noburn_enabled: bool = false
var auto_remove_enabled: bool = false

func _ready() -> void:
	_apply_upgrades()
	for i in range(max_slots):
		slots.append({
			"state": "empty",
			"cook_progress": 0.0,
			"burn_progress": 0.0,
			"cook_time": 5.0,
			"burn_time": 3.0
		})

func _process(delta: float) -> void:
	for i in range(slots.size()):
		var slot: Dictionary = slots[i]
		if slot["state"] == "cooking":
			slot["cook_progress"] += delta * cook_speed_multiplier
			if slot["cook_progress"] >= slot["cook_time"]:
				slot["state"] = "cooked"
				slot["cook_progress"] = slot["cook_time"]
				meat_cooked.emit(i)
				if auto_remove_enabled:
					_remove_meat(i)
		elif slot["state"] == "cooked" and not noburn_enabled:
			slot["burn_progress"] += delta
			if slot["burn_progress"] >= slot["burn_time"]:
				slot["state"] = "burned"
				slot["burn_progress"] = slot["burn_time"]
				meat_burned.emit(i)

func place_meat(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= slots.size():
		return false
	if slots[slot_index]["state"] != "empty":
		return false
	slots[slot_index]["state"] = "cooking"
	slots[slot_index]["cook_progress"] = 0.0
	slots[slot_index]["burn_progress"] = 0.0
	return true

func remove_meat(slot_index: int) -> String:
	if slot_index < 0 or slot_index >= slots.size():
		return ""
	var state: String = slots[slot_index]["state"]
	slots[slot_index]["state"] = "empty"
	slots[slot_index]["cook_progress"] = 0.0
	slots[slot_index]["burn_progress"] = 0.0
	return state

func _remove_meat(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < slots.size():
		if slots[slot_index]["state"] == "cooked":
			slots[slot_index]["state"] = "empty"
			slots[slot_index]["cook_progress"] = 0.0
			slots[slot_index]["burn_progress"] = 0.0

func click_slot(slot_index: int) -> String:
	if slot_index < 0 or slot_index >= slots.size():
		return ""
	var state: String = slots[slot_index]["state"]
	if state == "burned":
		remove_meat(slot_index)
		return "removed_burned"
	return state

func get_slot_state(slot_index: int) -> String:
	if slot_index < 0 or slot_index >= slots.size():
		return ""
	return slots[slot_index]["state"]

func get_cook_ratio(slot_index: int) -> float:
	if slot_index < 0 or slot_index >= slots.size():
		return 0.0
	var slot: Dictionary = slots[slot_index]
	if slot["state"] == "cooking":
		return slot["cook_progress"] / slot["cook_time"]
	elif slot["state"] == "cooked":
		if noburn_enabled:
			return 1.0
		return 1.0 + (slot["burn_progress"] / slot["burn_time"])
	return 0.0

func _apply_upgrades() -> void:
	if GameManager.has_upgrade("grill_speed_2"):
		cook_speed_multiplier = 0.6
	elif GameManager.has_upgrade("grill_speed_1"):
		cook_speed_multiplier = 0.8
	else:
		cook_speed_multiplier = 1.0
	
	noburn_enabled = GameManager.has_upgrade("grill_noburn")
	auto_remove_enabled = GameManager.has_upgrade("grill_auto_remove")
