extends Control

@onready var title_label: Label = $Panel/VBox/Title
@onready var money_earned: Label = $Panel/VBox/MoneyEarned
@onready var customers_served: Label = $Panel/VBox/CustomersServed
@onready var customers_lost: Label = $Panel/VBox/CustomersLost
@onready var wrong_orders: Label = $Panel/VBox/WrongOrders
@onready var thief_losses: Label = $Panel/VBox/ThiefLosses
@onready var continue_button: Button = $Panel/VBox/ContinueButton

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	display_summary()

func display_summary() -> void:
	title_label.text = LocalizationManager.tr_key("day_complete") % GameManager.current_day
	money_earned.text = "%s: $%d" % [LocalizationManager.tr_key("money_earned"), GameManager.money_earned_today]
	customers_served.text = "%s: %d" % [LocalizationManager.tr_key("customers_served"), GameManager.customers_served_today]
	customers_lost.text = "%s: %d" % [LocalizationManager.tr_key("customers_lost"), GameManager.customers_lost_today]
	wrong_orders.text = "%s: %d" % [LocalizationManager.tr_key("wrong_orders"), GameManager.wrong_orders_today]
	thief_losses.text = "%s: $%d" % [LocalizationManager.tr_key("thief_losses"), GameManager.money_lost_to_thief_today]
	
	if GameManager.current_day >= GameManager.MAX_DAY:
		title_label.text = LocalizationManager.tr_key("congratulations")
		continue_button.text = LocalizationManager.tr_key("play_endless")
	else:
		continue_button.text = LocalizationManager.tr_key("continue")

func _on_continue_pressed() -> void:
	if GameManager.current_day >= GameManager.MAX_DAY:
		GameManager.enter_endless()
		get_tree().change_scene_to_file("res://scenes/gameplay.tscn")
	else:
		GameManager.advance_day()
		GameManager.enter_shop()
		get_tree().change_scene_to_file("res://scenes/kitchen_shop.tscn")
