extends Node2D

signal assembly_completed(ingredients: Array[String])

var assembled_ingredients: Array[String] = []
var target_ingredients: Array[String] = []
var is_complete: bool = false

func start_assembly(ingredients: Array[String]) -> void:
	target_ingredients = ingredients.duplicate()
	assembled_ingredients.clear()
	is_complete = false

func add_ingredient(ingredient: String) -> void:
	if is_complete:
		return
	if ingredient in target_ingredients and ingredient not in assembled_ingredients:
		assembled_ingredients.append(ingredient)
		_check_complete()

func _check_complete() -> void:
	if assembled_ingredients.size() >= target_ingredients.size():
		is_complete = true
		assembly_completed.emit(assembled_ingredients)

func get_progress() -> float:
	if target_ingredients.is_empty():
		return 1.0
	return float(assembled_ingredients.size()) / float(target_ingredients.size())

func get_remaining() -> Array[String]:
	var remaining: Array[String] = []
	for ingredient in target_ingredients:
		if ingredient not in assembled_ingredients:
			remaining.append(ingredient)
	return remaining

func reset() -> void:
	assembled_ingredients.clear()
	target_ingredients.clear()
	is_complete = false
