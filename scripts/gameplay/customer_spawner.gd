extends Node2D

signal customer_spawned(customer: Node2D)
signal all_customers_served()

var max_customers: int = 5
var customers_spawned: int = 0
var customers_active: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 3.0
var is_spawning: bool = false

var customer_slots: Array[Vector2] = []
var occupied_slots: Dictionary = {}

var customer_colors: Array[Color] = [
	Color(0.85, 0.35, 0.3),
	Color(0.3, 0.5, 0.85),
	Color(0.3, 0.75, 0.4),
	Color(0.75, 0.4, 0.75),
	Color(0.85, 0.6, 0.2),
	Color(0.4, 0.7, 0.8),
]

func _ready() -> void:
	GameManager.day_started.connect(_on_day_started)
	_calculate_slots()

func _on_day_started(_day: int) -> void:
	max_customers = GameManager.get_customer_count_for_day()
	customers_spawned = 0
	customers_active = 0
	occupied_slots.clear()
	spawn_timer = 1.5
	is_spawning = true

func _process(delta: float) -> void:
	if not is_spawning:
		return
	spawn_timer -= delta
	if spawn_timer <= 0:
		if customers_spawned < max_customers:
			_spawn_customer()
			spawn_timer = spawn_interval
		else:
			is_spawning = false

func _calculate_slots() -> void:
	customer_slots.clear()
	var cols: int = 4
	var start_x: float = 120.0
	var gap_x: float = 240.0
	var row_y: float = 130.0
	for i in range(cols):
		customer_slots.append(Vector2(start_x + i * gap_x, row_y))

func _spawn_customer() -> void:
	var slot_idx: int = _find_free_slot()
	if slot_idx == -1:
		return

	var customer: Node2D = Node2D.new()
	customer.set_script(load("res://scripts/gameplay/customer.gd"))
	customer.position = customer_slots[slot_idx]

	var color: Color = customer_colors[customers_spawned % customer_colors.size()]

	var body: ColorRect = ColorRect.new()
	body.size = Vector2(100, 110)
	body.position = Vector2(-50, -15)
	body.color = color
	var body_style: StyleBoxFlat = StyleBoxFlat.new()
	body_style.set_corner_radius_all(14)
	body_style.set_content_margin_all(0)
	body.add_theme_stylebox_override("panel", body_style)
	customer.add_child(body)

	var head: ColorRect = ColorRect.new()
	head.size = Vector2(60, 60)
	head.position = Vector2(-30, -75)
	head.color = Color(0.92, 0.78, 0.65)
	var head_style: StyleBoxFlat = StyleBoxFlat.new()
	head_style.set_corner_radius_all(30)
	head_style.set_content_margin_all(0)
	head.add_theme_stylebox_override("panel", head_style)
	customer.add_child(head)

	var name_label: Label = Label.new()
	name_label.position = Vector2(-70, 110)
	name_label.custom_minimum_size = Vector2(140, 30)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 22)
	name_label.text = _get_customer_name()
	customer.add_child(name_label)

	add_child(customer)
	customer.customer_impatient.connect(_on_customer_impatient.bind(customer))
	customer.order_completed.connect(_on_customer_served.bind(customer))
	occupied_slots[slot_idx] = customer
	customers_spawned += 1
	customers_active += 1
	customer_spawned.emit(customer)

func _get_customer_name() -> String:
	var names: Array[String] = [
		"Alex", "Sam", "Jo", "Pat", "Max",
		"Lee", "Kim", "Rio", "Sky", "Finn",
	]
	return names[randi() % names.size()]

func _find_free_slot() -> int:
	for i in range(customer_slots.size()):
		if not occupied_slots.has(i):
			return i
	return -1

func _on_customer_served(_correct: bool, _payment: int, customer: Node2D) -> void:
	for key in occupied_slots:
		if occupied_slots[key] == customer:
			occupied_slots.erase(key)
			break
	customers_active -= 1
	_check_all_served()

func _on_customer_impatient(customer: Node2D) -> void:
	for key in occupied_slots:
		if occupied_slots[key] == customer:
			occupied_slots.erase(key)
			break
	customers_active -= 1
	_check_all_served()

func _check_all_served() -> void:
	if customers_spawned >= max_customers and customers_active <= 0:
		all_customers_served.emit()
