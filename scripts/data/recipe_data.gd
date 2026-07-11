extends Node

var base_recipe: Dictionary = {}
var sides: Dictionary = {}
var drinks: Dictionary = {}

func _ready() -> void:
	load_recipes()

func load_recipes() -> void:
	var file: FileAccess = FileAccess.open("res://data/recipes.json", FileAccess.READ)
	if file == null:
		push_error("Failed to load recipes.json")
		return
	var json: JSON = JSON.new()
	var error: Error = json.parse(file.get_as_text())
	file.close()
	if error != OK:
		push_error("Failed to parse recipes.json: " + json.get_error_message())
		return
	var data: Dictionary = json.data
	base_recipe = data.get("base_recipe", {})
	sides = data.get("sides", {})
	drinks = data.get("drinks", {})

func get_base_ingredients() -> Array:
	return base_recipe.get("base_ingredients", [])

func get_optional_ingredients() -> Array:
	return base_recipe.get("optional_ingredients", [])

func get_side_data(side_name: String) -> Dictionary:
	return sides.get(side_name, {})

func get_drink_data(drink_name: String) -> Dictionary:
	return drinks.get(drink_name, {})

func get_unlocked_sides() -> Array[String]:
	var result: Array[String] = []
	for side_name in sides.keys():
		var side: Dictionary = sides[side_name]
		var upgrade_id: String = side.get("unlock_upgrade", "")
		if upgrade_id != "" and GameManager.has_upgrade(upgrade_id):
			result.append(side_name)
	return result
