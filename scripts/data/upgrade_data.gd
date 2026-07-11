extends Node

var upgrades: Array = []

func _ready() -> void:
	load_upgrades()

func load_upgrades() -> void:
	var file: FileAccess = FileAccess.open("res://data/upgrades.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load upgrades.json")
		return
	var json: JSON = JSON.new()
	var error: Error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		push_error("Failed to parse upgrades.json: " + json.get_error_message())
		return
	var data: Dictionary = json.data
	upgrades = data.get("upgrades", [])

func get_upgrade_by_id(upgrade_id: String) -> Dictionary:
	for upgrade in upgrades:
		if upgrade.get("id", "") == upgrade_id:
			return upgrade
	return {}

func get_upgrades_by_category(category: String) -> Array:
	var result: Array = []
	for upgrade in upgrades:
		if upgrade.get("category", "") == category:
			result.append(upgrade)
	return result

func get_all_categories() -> Array[String]:
	var categories: Array[String] = []
	for upgrade in upgrades:
		var cat: String = upgrade.get("category", "")
		if cat not in categories:
			categories.append(cat)
	return categories

func is_toggleable(upgrade_id: String) -> bool:
	var upgrade: Dictionary = get_upgrade_by_id(upgrade_id)
	return upgrade.get("toggleable", false)

func get_toggleable_upgrades() -> Array:
	var result: Array = []
	for upgrade in upgrades:
		if upgrade.get("toggleable", false):
			result.append(upgrade)
	return result
