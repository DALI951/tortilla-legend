extends Node2D

signal customer_spawned(customer: Node2D)
signal all_customers_served()

var customer_scene: PackedScene = null
var max_customers: int = 5
var customers_spawned: int = 0
var customers_active: int = 0
var spawn_timer: float = 0.0
var spawn_interval: float = 3.0
var is_spawning: bool = false

var customer_slots: Array[Vector2] = []
var occupied_slots: Dictionary = {}

func _ready() -> void:
	customer_scene = preload("res://scenes/gameplay.tscn")
	GameManager.day_started.connect(_on_day_started)
	_calculate_slots()

func _on_day_started(day: int) -> void:
	max_customers = GameManager.get_customer_count_for_day()
	customers_spawned = 0
	customers_active = 0
	occupied_slots.clear()
	spawn_timer = 1.0
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
	var slot_width: float = 200.0
	var start_x: float = 200.0
	var y: float = 200.0
	for i in range(8):
		customer_slots.append(Vector2(start_x + i * slot_width, y))

func _spawn_customer() -> void:
	var slot_idx: int = _find_free_slot()
	if slot_idx == -1:
		return
	
	var customer: CharacterBody2D = CharacterBody2D.new()
	customer.set_script(load("res://scripts/gameplay/customer.gd"))
	customer.position = customer_slots[slot_idx]
	
	var sprite: ColorRect = ColorRect.new()
	sprite.custom_minimum_size = Vector2(120, 150)
	var colors: Array[Color] = [
		Color(0.9, 0.3, 0.3),
		Color(0.3, 0.5, 0.9),
		Color(0.3, 0.8, 0.4),
		Color(0.8, 0.4, 0.8),
		Color(0.9, 0.6, 0.2)
	]
	sprite.color = colors[customers_spawned % colors.size()]
	sprite.position = Vector2(-60, -75)
	customer.add_child(sprite)
	
	add_child(customer)
	customer.customer_impaired.connect(_on_customer_impatient.bind(customer))
	customer.order_completed.connect(_on_customer_served.bind(customer))
	occupied_slots[slot_idx] = customer
	customers_spawned += 1
	customers_active += 1
	customer_spawned.emit(customer)

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
