extends Node2D

signal tortilla_completed(ingredients: Array[String])

var max_taps: int = 6
var current_taps: int = 0
var ingredients_on_tortilla: Array[String] = []
var required_ingredients: Array[String] = []

func _ready() -> void:
	_apply_upgrades()
	_build_required_list()

func _build_required_list() -> void:
	required_ingredients.clear()
	required_ingredients.append("lettuce")
	required_ingredients.append("tomato")
	if GameManager.has_upgrade("ingredient_salsa"):
		required_ingredients.append("salsa")
	if GameManager.has_upgrade("ingredient_cilantro"):
		required_ingredients.append("cilantro")
	if GameManager.has_upgrade("ingredient_onion"):
		required_ingredients.append("onion")
	if GameManager.has_upgrade("ingredient_cheese"):
		required_ingredients.append("cheese")
	if GameManager.has_upgrade("ingredient_peppers"):
		required_ingredients.append("peppers")

func tap_tortilla() -> void:
	if current_taps >= max_taps:
		return
	current_taps += 1
	if current_taps <= required_ingredients.size():
		ingredients_on_tortilla.append(required_ingredients[current_taps - 1])
	if current_taps >= max_taps:
		tortilla_completed.emit(ingredients_on_tortilla)

func reset() -> void:
	current_taps = 0
	ingredients_on_tortilla.clear()
	_build_required_list()

func is_complete() -> bool:
	return current_taps >= max_taps

func get_fill_ratio() -> float:
	if max_taps <= 0:
		return 1.0
	return float(current_taps) / float(max_taps)

func _apply_upgrades() -> void:
	var base_taps: int = 6
	var reduction: int = 0
	if GameManager.has_upgrade("tortilla_taps_1"):
		reduction += 1
	if GameManager.has_upgrade("tortilla_taps_2"):
		reduction += 1
	if GameManager.has_upgrade("tortilla_taps_3"):
		reduction += 1
	if GameManager.has_upgrade("tortilla_auto"):
		max_taps = 1
	else:
		max_taps = maxi(1, base_taps - reduction)
