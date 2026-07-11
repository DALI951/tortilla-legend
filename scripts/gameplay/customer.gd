extends Node2D

signal order_completed(correct: bool, payment: int)
signal customer_impatient()

var order: Array[String] = []
var patience_max: float = 45.0
var patience_current: float = 45.0
var is_served: bool = false
var is_angry: bool = false
var base_payment: int = 10
var color_variant: int = 0

func _ready() -> void:
	patience_max = GameManager.get_patience_for_day()
	patience_current = patience_max
	base_payment = GameManager.get_taco_price()
	generate_order()

func _process(delta: float) -> void:
	if is_served or is_angry:
		return
	patience_current -= delta
	if patience_current <= 0:
		patience_current = 0
		is_angry = true
		GameManager.customer_leaves()
		customer_impatient.emit()
		queue_free()

func generate_order() -> void:
	order.clear()
	order.append("lettuce")
	order.append("tomato")
	
	if GameManager.has_upgrade("ingredient_salsa"):
		order.append("salsa")
	if GameManager.has_upgrade("ingredient_cilantro"):
		order.append("cilantro")
	if GameManager.has_upgrade("ingredient_onion"):
		order.append("onion")
	if GameManager.has_upgrade("ingredient_cheese"):
		order.append("cheese")
	if GameManager.has_upgrade("ingredient_peppers"):
		order.append("peppers")
	
	if GameManager.has_upgrade("customer_choice_1") or GameManager.has_upgrade("customer_choice_2"):
		_apply_customer_removals()
	
	if GameManager.has_upgrade("sides_chips") and randf() > 0.6:
		order.append("side_chips")
	if GameManager.has_upgrade("sides_rice") and randf() > 0.7:
		order.append("side_rice")
	if GameManager.has_upgrade("sides_guac") and randf() > 0.8:
		order.append("side_guac")
	if randf() > 0.3:
		order.append("drink_soda")

func _apply_customer_removals() -> void:
	var max_removals: int = 0
	if GameManager.has_upgrade("customer_choice_2"):
		max_removals = 2
	elif GameManager.has_upgrade("customer_choice_1"):
		max_removals = 1
	
	var removable: Array[String] = []
	for ingredient in order:
		if ingredient in ["lettuce", "tomato", "salsa", "cilantro", "onion", "cheese", "peppers"]:
			removable.append(ingredient)
	
	var removals: int = mini(max_removals, removable.size())
	for i in range(removals):
		var idx: int = randi() % removable.size()
		var to_remove: String = removable[idx]
		order.erase(to_remove)
		removable.remove_at(idx)

func serve(taco_ingredients: Array[String], sides: Array[String], has_drink: bool) -> void:
	if is_served or is_angry:
		return
	
	var is_correct: bool = true
	for ingredient in order:
		if ingredient.begins_with("side_"):
			if not ingredient in sides:
				is_correct = false
		elif ingredient.begins_with("drink_"):
			if not has_drink:
				is_correct = false
		else:
			if not ingredient in taco_ingredients:
				is_correct = false
	
	for taco_ingredient in taco_ingredients:
		if taco_ingredient in order:
			pass
		else:
			for req in order:
				if req.begins_with("no_"):
					var no_ingredient: String = req.substr(3)
					if taco_ingredient == no_ingredient:
						is_correct = false
	
	var payment: int = base_payment
	if not is_correct:
		payment = int(base_payment * 0.5)
	
	is_served = true
	GameManager.serve_customer(is_correct, payment)
	order_completed.emit(is_correct, payment)
	queue_free()

func get_order_display() -> String:
	var parts: PackedStringArray = []
	for item in order:
		if item.begins_with("side_"):
			parts.append(item.substr(5).capitalize())
		elif item.begins_with("drink_"):
			parts.append(item.substr(6).capitalize())
		else:
			parts.append(item.capitalize())
	return ", ".join(parts)

func get_patience_ratio() -> float:
	return patience_current / patience_max
