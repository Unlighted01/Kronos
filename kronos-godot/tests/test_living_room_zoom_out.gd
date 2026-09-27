extends Node2D

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(720, 240))
	get_viewport().size = Vector2i(720, 240)

	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.05, 0.08)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(720, 240)
	add_child(bg)

	var cam = Camera2D.new()
	cam.position = Vector2(360, 80)
	cam.zoom = Vector2(0.68, 0.68)
	add_child(cam)

	var room = load("res://scenes/rooms/LivingRoom.tscn").instantiate()
	add_child(room)

	# Spawn companions
	var shiba = PetRenderer.new()
	shiba.species = "shiba"
	shiba.current_state = PetRenderer.AnimState.NAP
	shiba.position = Vector2(242.0, 88.0)
	shiba.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba)

	var capy = PetRenderer.new()
	capy.species = "capybara"
	capy.current_state = PetRenderer.AnimState.IDLE
	capy.position = Vector2(615.0, 102.0)
	capy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(capy)

	for i in range(20):
		await get_tree().process_frame
		
	await get_tree().create_timer(0.4).timeout

	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/netne/.gemini/antigravity/brain/c16bf1a4-3954-476f-975d-a5a59e385b63/kronos_living_room_zoomout_preview.png"
	img.save_png(out_path)
	print("LIVING_ROOM_ZOOMOUT_SAVED:" + out_path)
	get_tree().quit(0)
