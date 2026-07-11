extends Control

enum PrepState { WAITING, TORTILLA, GRILL, TOPPINGS, PREP_DONE, SERVING }

var state: PrepState = PrepState.WAITING
var current_customer: Node2D = null
var taco_ingredients: Array[String] = []
var grill_timer: float = 0.0
var grill_cook_time: float = 5.0
var grill_placed: bool = false
var grill_done: bool = false
var tortilla_taps: int = 0
var tortilla_max: int = 6
var required_ingredients: Array[String] = []
var serving_sides: Array[String] = []
var has_drink: bool = false
var is_paused: bool = false
var day_started_received: bool = false

var customer_spawner_instance: Node2D = null

@onready var timer_label: Label = $HUD/TimerLabel
@onready var money_label: Label = $HUD/MoneyLabel
@onready var pause_button: Button = $HUD/PauseButton
@onready var station_label: Label = $KitchenArea/StationLabel
@onready var order_label: Label = $CustomerArea/OrderLabel
@onready var action_button: Button = $KitchenArea/ActionButton
@onready var serve_button: Button = $KitchenArea/ServeButton
@onready var customer_container: Control = $CustomerArea/CustomerContainer
@onready var day_timer_node: Timer = $DayTimerNode
@onready var kitchen_area: Control = $KitchenArea
@onready var customer_area: Control = $CustomerArea
@onready var progress_label: Label = $KitchenArea/ProgressLabel
@onready var event_label: Label = $HUD/EventLabel

func _ready() -> void:
	pause_button.pressed.connect(_on_pause_pressed)
	action_button.pressed.connect(_on_action_pressed)
	serve_button.pressed.connect(_on_serve_pressed)
	day_timer_node.wait_time = 1.0
	day_timer_node.timeout.connect(_on_day_tick)
	GameManager.day_started.connect(_on_day_started)
	GameManager.day_ended.connect(_on_day_ended)
	_build_required_list()
	tortilla_max = _get_tortilla_max()
	serve_button.visible = false
	event_label.visible = false
	action_button.disabled = false
	_update_ui()
	if GameManager.current_state == GameManager.GameState.PLAYING:
		_start_day_logic(GameManager.current_day)

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

func _get_tortilla_max() -> int:
	var base: int = 6
	if GameManager.has_upgrade("tortilla_taps_1"):
		base -= 1
	if GameManager.has_upgrade("tortilla_taps_2"):
		base -= 1
	if GameManager.has_upgrade("tortilla_taps_3"):
		base -= 1
	if GameManager.has_upgrade("tortilla_auto"):
		base = 1
	return maxi(1, base)

func _on_day_started(day: int) -> void:
	day_started_received = true
	_start_day_logic(day)

func _start_day_logic(day: int) -> void:
	if day_started_received and customer_spawner_instance != null:
		return
	day_started_received = true
	state = PrepState.WAITING
	current_customer = null
	taco_ingredients.clear()
	tortilla_taps = 0
	grill_timer = 0.0
	grill_placed = false
	grill_done = false
	serving_sides.clear()
	has_drink = false
	is_paused = false
	action_button.disabled = false
	_build_required_list()
	tortilla_max = _get_tortilla_max()
	serve_button.visible = false
	event_label.visible = false
	_spawn_customers(day)
	day_timer_node.start()
	_update_ui()

func _spawn_customers(day: int) -> void:
	customer_spawner_instance = Node2D.new()
	customer_spawner_instance.set_script(load("res://scripts/gameplay/customer_spawner.gd"))
	customer_container.add_child(customer_spawner_instance)
	customer_spawner_instance.all_customers_served.connect(_on_all_customers_served)
	customer_spawner_instance._on_day_started(day)
	for slot_pos in customer_spawner_instance.customer_slots:
		var marker: ColorRect = ColorRect.new()
		marker.size = Vector2(100, 130)
		marker.position = slot_pos + Vector2(-50, -65)
		marker.color = Color(0.85, 0.78, 0.68, 0.3)
		marker.name = "Slot" + str(customer_spawner_instance.customer_slots.find(slot_pos))
		customer_container.add_child(marker)

func _on_day_ended(_day: int) -> void:
	day_timer_node.stop()
	if customer_spawner_instance:
		customer_spawner_instance.is_spawning = false
	state = PrepState.WAITING
	get_tree().change_scene_to_file("res://scenes/day_summary.tscn")

func _on_day_tick() -> void:
	if is_paused:
		return
	GameManager.day_timer_current -= 1.0
	if GameManager.day_timer_current <= 0:
		GameManager.day_timer_current = 0
		GameManager.end_day()
	_update_ui()

func _process(delta: float) -> void:
	if is_paused:
		return
	if state == PrepState.GRILL and grill_placed and not grill_done:
		var speed: float = 1.0
		if GameManager.has_upgrade("grill_speed_2"):
			speed = 1.67
		elif GameManager.has_upgrade("grill_speed_1"):
			speed = 1.25
		grill_timer += delta * speed
		if grill_timer >= grill_cook_time:
			grill_done = true
			grill_timer = grill_cook_time
	_update_ui()

func _update_ui() -> void:
	timer_label.text = "%ds" % int(GameManager.day_timer_current)
	money_label.text = "$%d" % GameManager.money

	match state:
		PrepState.WAITING:
			station_label.text = "Waiting for customer..."
			action_button.visible = false
			order_label.text = ""
			progress_label.text = ""
		PrepState.TORTILLA:
			station_label.text = "TORTILLA STATION"
			action_button.visible = true
			action_button.disabled = false
			action_button.text = "TAP TO FILL"
			progress_label.text = "%d/%d taps" % [tortilla_taps, tortilla_max]
			_show_order()
		PrepState.GRILL:
			station_label.text = "GRILL STATION"
			action_button.visible = true
			if not grill_placed:
				action_button.text = "PLACE MEAT"
				action_button.disabled = false
				progress_label.text = ""
			elif not grill_done:
				var pct: int = int((grill_timer / grill_cook_time) * 100)
				action_button.text = "COOKING..."
				action_button.disabled = true
				progress_label.text = "%d%% cooked" % pct
			else:
				action_button.text = "TAKE MEAT"
				action_button.disabled = false
				progress_label.text = "DONE!"
		PrepState.TOPPINGS:
			station_label.text = "TOPPING STATION"
			action_button.visible = true
			action_button.disabled = false
			action_button.text = "ADD TOPPINGS"
			progress_label.text = "Tap to add each ingredient"
			_show_order()
		PrepState.PREP_DONE:
			station_label.text = "TACO READY!"
			action_button.visible = false
			serve_button.visible = true
			progress_label.text = "Tap SERVE, then tap a customer"
			_show_order()
		PrepState.SERVING:
			station_label.text = "SELECT A CUSTOMER"
			action_button.visible = false
			serve_button.visible = false
			progress_label.text = "Tap on a customer to serve"
			_show_order()

func _show_order() -> void:
	if current_customer and is_instance_valid(current_customer) and current_customer.has_method("get_order_display"):
		order_label.text = "ORDER: " + current_customer.get_order_display()
	else:
		order_label.text = ""

func _on_action_pressed() -> void:
	if is_paused:
		return
	match state:
		PrepState.TORTILLA:
			_do_tortilla_tap()
		PrepState.GRILL:
			_do_grill_action()
		PrepState.TOPPINGS:
			_do_topping_tap()

func _do_tortilla_tap() -> void:
	if tortilla_taps >= tortilla_max:
		state = PrepState.GRILL
		_update_ui()
		return
	tortilla_taps += 1
	if tortilla_taps <= required_ingredients.size():
		taco_ingredients.append(required_ingredients[tortilla_taps - 1])
	if tortilla_taps >= tortilla_max:
		state = PrepState.GRILL
	FeedbackManager.vibrate_light()
	_update_ui()

func _do_grill_action() -> void:
	if not grill_placed:
		grill_placed = true
		grill_timer = 0.0
		FeedbackManager.vibrate_light()
	elif grill_done:
		state = PrepState.TOPPINGS
		FeedbackManager.vibrate_light()
	_update_ui()

func _do_topping_tap() -> void:
	var available: Array[String] = _get_available_toppings()
	var added: bool = false
	for topping in available:
		if topping not in taco_ingredients:
			taco_ingredients.append(topping)
			added = true
			break
	if not added:
		state = PrepState.PREP_DONE
		serve_button.visible = true
		FeedbackManager.vibrate_light()
	_update_ui()

func _get_available_toppings() -> Array[String]:
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

func _on_serve_pressed() -> void:
	if state != PrepState.PREP_DONE:
		return
	state = PrepState.SERVING
	serve_button.visible = false
	_update_ui()

func serve_customer_at_slot(customer: Node2D) -> void:
	if state != PrepState.SERVING:
		return
	if customer == null or not is_instance_valid(customer):
		return
	current_customer = customer
	_perform_serve()

func _perform_serve() -> void:
	if current_customer == null or not is_instance_valid(current_customer):
		state = PrepState.WAITING
		serve_button.visible = false
		_update_ui()
		return

	var is_correct: bool = true
	for ingredient in current_customer.order:
		if ingredient.begins_with("side_"):
			if not ingredient in serving_sides:
				is_correct = false
		elif ingredient.begins_with("drink_"):
			if not has_drink:
				is_correct = false
		else:
			if not ingredient in taco_ingredients:
				is_correct = false

	var payment: int = GameManager.get_taco_price()
	if not is_correct:
		payment = int(payment * 0.5)

	GameManager.serve_customer(is_correct, payment)

	FeedbackManager.vibrate_medium()

	current_customer.is_served = true
	current_customer.order_completed.emit(is_correct, payment)
	current_customer.queue_free()

	state = PrepState.WAITING
	current_customer = null
	taco_ingredients.clear()
	tortilla_taps = 0
	grill_timer = 0.0
	grill_placed = false
	grill_done = false
	serving_sides.clear()
	has_drink = false
	serve_button.visible = false
	action_button.disabled = false
	_update_ui()

func _on_all_customers_served() -> void:
	if state == PrepState.WAITING:
		GameManager.end_day()

func _on_pause_pressed() -> void:
	is_paused = not is_paused
	if is_paused:
		pause_button.text = "RESUME"
		day_timer_node.paused = true
	else:
		pause_button.text = "||"
		day_timer_node.paused = false

func _unhandled_input(event: InputEvent) -> void:
	if state != PrepState.SERVING:
		return
	if event is InputEventScreenTouch and event.pressed:
		for child in customer_container.get_children():
			if child is Node2D and child != customer_spawner_instance:
				var global_pos: Vector2 = child.global_position
				var mouse_pos: Vector2 = get_global_mouse_position()
				if global_pos.distance_to(mouse_pos) < 100:
					serve_customer_at_slot(child)
					return

func _exit_tree() -> void:
	if customer_spawner_instance and is_instance_valid(customer_spawner_instance):
		customer_spawner_instance.queue_free()
		customer_spawner_instance = null
