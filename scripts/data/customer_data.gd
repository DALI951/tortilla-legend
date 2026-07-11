extends Node

var customer_colors: Array[Color] = [
	Color(0.9, 0.3, 0.3),
	Color(0.3, 0.5, 0.9),
	Color(0.3, 0.8, 0.4),
	Color(0.8, 0.4, 0.8),
	Color(0.9, 0.6, 0.2),
	Color(0.4, 0.7, 0.9),
	Color(0.9, 0.8, 0.3),
	Color(0.6, 0.3, 0.7)
]

func get_random_color() -> Color:
	return customer_colors[randi() % customer_colors.size()]

func create_customer_data(day: int) -> Dictionary:
	return {
		"patience_max": GameManager.get_patience_for_day(),
		"color": get_random_color(),
		"complexity_level": _get_complexity(day)
	}

func _get_complexity(day: int) -> int:
	if day <= 10:
		return 1
	elif day <= 25:
		return 2
	elif day <= 40:
		return 3
	else:
		return 4
