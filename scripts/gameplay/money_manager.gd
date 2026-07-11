extends Node2D

signal money_collected(amount: int)
signal money_on_counter(amount: int)

var money_on_counter: int = 0
var money_display_nodes: Array[Node2D] = []
var auto_collect_enabled: bool = false

func _ready() -> void:
	auto_collect_enabled = GameManager.has_upgrade("thief_auto_money")
	GameManager.day_started.connect(_on_day_started)

func _on_day_started(_day: int) -> void:
	money_on_counter = 0
	_clear_displays()

func add_money_to_counter(amount: int) -> void:
	money_on_counter += amount
	money_on_counter.emit(money_on_counter)

func collect_money() -> int:
	var amount: int = money_on_counter
	money_on_counter = 0
	_clear_displays()
	GameManager.collect_money(amount)
	money_collected.emit(amount)
	return amount

func collect_amount(amount: int) -> int:
	var to_collect: int = mini(amount, money_on_counter)
	money_on_counter -= to_collect
	GameManager.collect_money(to_collect)
	money_collected.emit(to_collect)
	return to_collect

func lose_to_thief(amount: int) -> void:
	var actual_loss: int = mini(amount, money_on_counter)
	money_on_counter -= actual_loss
	GameManager.lose_money_to_thief(actual_loss)

func get_counter_money() -> int:
	return money_on_counter

func auto_collect() -> void:
	if auto_collect_enabled and money_on_counter > 0:
		collect_money()

func _clear_displays() -> void:
	for node in money_display_nodes:
		if is_instance_valid(node):
			node.queue_free()
	money_display_nodes.clear()
