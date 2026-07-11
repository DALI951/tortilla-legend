extends Node2D

signal side_prepared(side_name: String)

var unlocked_sides: Array[String] = []
var prepared_sides: Array[String] = []

func _ready() -> void:
	_scan_unlocked_sides()

func _scan_unlocked_sides() -> void:
	unlocked_sides.clear()
	if GameManager.has_upgrade("sides_chips"):
		unlocked_sides.append("chips")
	if GameManager.has_upgrade("sides_rice"):
		unlocked_sides.append("rice")
	if GameManager.has_upgrade("sides_guac"):
		unlocked_sides.append("guac")

func prep_side(side_name: String) -> void:
	if side_name in unlocked_sides and side_name not in prepared_sides:
		prepared_sides.append(side_name)
		side_prepared.emit(side_name)

func has_side(side_name: String) -> bool:
	return side_name in prepared_sides

func get_prepared() -> Array[String]:
	return prepared_sides.duplicate()

func reset() -> void:
	prepared_sides.clear()
	_scan_unlocked_sides()

func is_quick_add(side_name: String) -> bool:
	return side_name == "chips"
