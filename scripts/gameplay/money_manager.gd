extends Node2D

signal money_collected(amount: int)
signal counter_money_changed(amount: int)

var counter_money: int = 0
var money_display_nodes: Array[Node2D] = []
var auto_collect_enabled: bool = false

func _ready() -> void:
	auto_collect_enabled = GameManager.has_upgrade("thief_auto_money")
	GameManager.day_started.connect(_on_day_started)

func _on_day_started(_day: int) -> void:
	counter_money = 0
	_clear_displays()

func add_money_to_counter(amount: int) -> void:
	counter_money += amount
	counter_money_changed.emit(counter_money)

func collect_money() -> int:
	var amount: int = counter_money
	counter_money = 0
	_clear_displays()
	GameManager.collect_money(amount)
	money_collected.emit(amount)
	return amount

func collect_amount(amount: int) -> int:
	var to_collect: int = mini(amount, counter_money)
	counter_money -= to_collect
	GameManager.collect_money(to_collect)
	money_collected.emit(to_collect)
	return to_collect

func lose_to_thief(amount: int) -> void:
	var actual_loss: int = mini(amount, counter_money)
	counter_money -= actual_loss
	GameManager.lose_money_to_thief(actual_loss)

func get_counter_money() -> int:
	return counter_money

func auto_collect() -> void:
	if auto_collect_enabled and counter_money > 0:
		collect_money()

func _clear_displays() -> void:
	for node in money_display_nodes:
		if is_instance_valid(node):
			node.queue_free()
	money_display_nodes.clear()
