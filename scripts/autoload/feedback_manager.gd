extends Node

func vibrate(duration_ms: int = 50) -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(duration_ms)

func screen_shake(intensity: float = 5.0, duration: float = 0.2) -> void:
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return
	var camera: Camera2D = viewport.get_camera_2d()
	if camera == null:
		return
	var original_offset: Vector2 = camera.offset
	var tween: Tween = create_tween()
	var shake_count: int = int(duration / 0.05)
	for i in range(shake_count):
		var random_offset: Vector2 = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		tween.tween_property(camera, "offset", original_offset + random_offset, 0.025)
	tween.tween_property(camera, "offset", original_offset, 0.025)

func vibrate_light() -> void:
	vibrate(30)

func vibrate_medium() -> void:
	vibrate(80)

func vibrate_heavy() -> void:
	vibrate(150)

func shake_light() -> void:
	screen_shake(3.0, 0.15)

func shake_medium() -> void:
	screen_shake(6.0, 0.25)

func shake_heavy() -> void:
	screen_shake(10.0, 0.4)
