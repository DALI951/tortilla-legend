extends Node

signal day_started(day_number: int)
signal day_ended(day_number: int)
signal money_changed(new_amount: int)
signal upgrade_purchased(upgrade_id: String)
signal customer_served(correct: bool)
signal customer_lost()
signal thief_defeated()
signal thief_escaped(stolen_amount: int)
signal game_state_changed()

enum GameState { MENU, PLAYING, PAUSED, SUMMARY, SHOP, ENDLESS }

var current_state: GameState = GameState.MENU
var current_day: int = 1
var money: int = 0
var total_earned: int = 0
var customers_served_today: int = 0
var customers_lost_today: int = 0
var money_earned_today: int = 0
var money_lost_to_thief_today: int = 0
var wrong_orders_today: int = 0
var customers_served_total: int = 0
var customers_lost_total: int = 0
var thief_losses_total: int = 0

var day_timer_max: float = 30.0
var day_timer_current: float = 0.0

var purchased_upgrades: Array[String] = []
var ingredient_unlocked: bool = true

const MAX_DAY: int = 60

func _ready() -> void:
	pass

func start_new_game() -> void:
	current_day = 1
	money = 0
	total_earned = 0
	customers_served_total = 0
	customers_lost_total = 0
	thief_losses_total = 0
	purchased_upgrades = []
	recalculate_day_timer()
	SaveManager.save_game()
	start_day()

func continue_game() -> void:
	recalculate_day_timer()
	start_day()

func start_day() -> void:
	current_state = GameState.PLAYING
	customers_served_today = 0
	customers_lost_today = 0
	money_earned_today = 0
	money_lost_to_thief_today = 0
	wrong_orders_today = 0
	day_timer_current = day_timer_max
	day_started.emit(current_day)

func end_day() -> void:
	current_state = GameState.SUMMARY
	customers_served_total += customers_served_today
	customers_lost_total += customers_lost_today
	day_ended.emit(current_day)
	SaveManager.save_game()

func advance_day() -> void:
	current_day += 1
	if current_day > MAX_DAY:
		current_state = GameState.MENU
		SaveManager.save_game()
	else:
		recalculate_day_timer()
		SaveManager.save_game()
		current_state = GameState.SHOP

func enter_shop() -> void:
	current_state = GameState.SHOP

func enter_menu() -> void:
	current_state = GameState.MENU

func enter_endless() -> void:
	current_state = GameState.PLAYING
	customers_served_today = 0
	customers_lost_today = 0
	money_earned_today = 0
	money_lost_to_thief_today = 0
	wrong_orders_today = 0
	day_timer_current = day_timer_max
	day_started.emit(current_day)

func add_money(amount: int) -> void:
	money += amount
	total_earned += amount
	money_earned_today += amount
	money_changed.emit(money)
	game_state_changed.emit()

func spend_money(amount: int) -> bool:
	if money >= amount:
		money -= amount
		money_changed.emit(money)
		game_state_changed.emit()
		return true
	return false

func collect_money(amount: int) -> void:
	add_money(amount)

func lose_money_to_thief(amount: int) -> void:
	money_lost_to_thief_today += amount
	thief_losses_total += amount
	money = maxi(0, money - amount)
	money_changed.emit(money)
	game_state_changed.emit()

func serve_customer(correct: bool, payment: int) -> void:
	customers_served_today += 1
	if correct:
		add_money(payment)
	else:
		add_money(payment)
		wrong_orders_today += 1
	customer_served.emit(correct)

func customer_leaves() -> void:
	customers_lost_today += 1
	customer_lost.emit()

func purchase_upgrade(upgrade_id: String, cost: int) -> bool:
	if spend_money(cost):
		purchased_upgrades.append(upgrade_id)
		upgrade_purchased.emit(upgrade_id)
		game_state_changed.emit()
		return true
	return false

func has_upgrade(upgrade_id: String) -> bool:
	return upgrade_id in purchased_upgrades

func recalculate_day_timer() -> void:
	day_timer_max = 30.0 + float(current_day - 1)
	day_timer_max = clampf(day_timer_max, 30.0, 300.0)

func get_customer_count_for_day() -> int:
	return 5 + int(current_day * 0.8)

func get_patience_for_day() -> float:
	return 30.0 + float(current_day) * 0.5

func get_taco_price() -> int:
	var base_price: int = 10
	for upgrade_id in purchased_upgrades:
		if upgrade_id.begins_with("ingredient_"):
			base_price += 3
	return base_price

func is_endless_mode() -> bool:
	return current_day > MAX_DAY

func reset() -> void:
	current_day = 1
	money = 0
	total_earned = 0
	customers_served_total = 0
	customers_lost_total = 0
	thief_losses_total = 0
	purchased_upgrades.clear()
	current_state = GameState.MENU
	game_state_changed.emit()
