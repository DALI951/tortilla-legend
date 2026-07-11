extends Node

const SAVE_PATH: String = "user://save_game.json"
const SAVE_VERSION: int = 1

func save_game() -> void:
	var save_data: Dictionary = {
		"version": SAVE_VERSION,
		"current_day": GameManager.current_day,
		"money": GameManager.money,
		"total_earned": GameManager.total_earned,
		"customers_served_total": GameManager.customers_served_total,
		"customers_lost_total": GameManager.customers_lost_total,
		"thief_losses_total": GameManager.thief_losses_total,
		"upgrades": GameManager.purchased_upgrades.duplicate(),
		"settings": {
			"language": LocalizationManager.current_language,
			"sfx_volume": AudioServer.get_bus_volume_db(1) if AudioServer.bus_count > 1 else 0.0
		}
	}
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to save game: " + SAVE_PATH)
		return
	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return false
	
	var json: JSON = JSON.new()
	var error: Error = json.parse(file.get_as_text())
	file.close()
	
	if error != OK:
		push_error("Failed to parse save file: " + json.get_error_message())
		return false
	
	var data: Dictionary = json.data
	if not data is Dictionary:
		return false
	
	if data.get("version", 0) < SAVE_VERSION:
		# Handle future migration if needed
		pass
	
	GameManager.current_day = data.get("current_day", 1)
	GameManager.money = data.get("money", 0)
	GameManager.total_earned = data.get("total_earned", 0)
	GameManager.customers_served_total = data.get("customers_served_total", 0)
	GameManager.customers_lost_total = data.get("customers_lost_total", 0)
	GameManager.thief_losses_total = data.get("thief_losses_total", 0)
	GameManager.purchased_upgrades.clear()
	var upgrades: Array = data.get("upgrades", [])
	for u in upgrades:
		GameManager.purchased_upgrades.append(String(u))
	
	var settings: Dictionary = data.get("settings", {})
	if settings.has("language"):
		LocalizationManager.set_language(settings["language"])
	
	return true

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	GameManager.reset()

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
