extends Node2D

signal topping_applied(ingredient: String)

var mode: String = "drag"
var applied_toppings: Array[String] = []

func _ready() -> void:
	_apply_upgrades()

func apply_topping(ingredient: String) -> void:
	if ingredient in applied_toppings:
		return
	applied_toppings.append(ingredient)
	topping_applied.emit(ingredient)

func reset() -> void:
	applied_toppings.clear()

func get_available_toppings() -> Array[String]:
	var toppings: Array[String] = []
	toppings.append("lettuce")
	toppings.append("tomato")
	if GameManager.has_upgrade("ingredient_salsa"):
		toppings.append("salsa")
	if GameManager.has_upgrade("ingredient_cilantro"):
		toppings.append("cilantro")
	if GameManager.has_upgrade("ingredient_onion"):
		toppings.append("onion")
	if GameManager.has_upgrade("ingredient_cheese"):
		toppings.append("cheese")
	if GameManager.has_upgrade("ingredient_peppers"):
		toppings.append("peppers")
	return toppings

func is_drag_mode() -> bool:
	return mode == "drag"

func is_tap_mode() -> bool:
	return mode == "tap" or mode == "auto"

func _apply_upgrades() -> void:
	if GameManager.has_upgrade("topping_auto_2"):
		mode = "auto"
	elif GameManager.has_upgrade("topping_auto_1"):
		mode = "tap"
	else:
		mode = "drag"
