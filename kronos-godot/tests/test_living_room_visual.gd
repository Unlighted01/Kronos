extends Node2D

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(720, 160))
	get_viewport().size = Vector2i(720, 160)

	# Set up background
	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.05, 0.08)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(720, 160)
	add_child(bg)

	# Load Living Room (Hearth of Hestia)
	var room = load("res://scenes/rooms/LivingRoom.tscn").instantiate()
	add_child(room)

	# 1. Spawn Kitsune Fox by the hoplite shield
	var fox = PetRenderer.new()
	fox.species = "fox"
	fox.current_state = PetRenderer.AnimState.IDLE
	fox.position = Vector2(85.0, 102.0)
	fox.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(fox)

	# 2. Shiba Warming Paws on Hearth Floor Cushion (Option B Action: WARM_PAWS)
	var shiba_hearth = PetRenderer.new()
	shiba_hearth.species = "shiba"
	shiba_hearth.current_state = PetRenderer.AnimState.WARM_PAWS
	shiba_hearth.facing_right = false
	shiba_hearth.position = Vector2(138.0, 102.0)
	shiba_hearth.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_hearth)

	# 3. Shiba Sleeping Loaf tucked inside Couch Cushion (Option B Action: LOAF)
	var shiba_couch = PetRenderer.new()
	shiba_couch.species = "shiba"
	shiba_couch.current_state = PetRenderer.AnimState.NAP
	shiba_couch.position = Vector2(242.0, 88.0)
	shiba_couch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_couch)

	# 4. Shiba Feasting on the Banquet Table (Option B Action: EAT)
	var shiba_table = PetRenderer.new()
	shiba_table.species = "shiba"
	shiba_table.current_state = PetRenderer.AnimState.STUDY
	shiba_table.facing_right = false # Facing left towards the feast platter
	shiba_table.position = Vector2(416.0, 66.0)
	shiba_table.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_table)

	# 5. Shiba Perched on Balustrade Gazing at Olympus Sunset (Option B Action: GAZE)
	var shiba_gaze = PetRenderer.new()
	shiba_gaze.species = "shiba"
	shiba_gaze.current_state = PetRenderer.AnimState.WINDOW_GAZE
	shiba_gaze.facing_right = true
	shiba_gaze.position = Vector2(612.0, 102.0)
	shiba_gaze.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_gaze)

	# 6. Capybara companion on the open terrace by the eternal brazier
	var capy = PetRenderer.new()
	capy.species = "capybara"
	capy.current_state = PetRenderer.AnimState.IDLE
	capy.position = Vector2(675.0, 102.0)
	capy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(capy)

	# Advance 20 frames to let fire embers and sun rays settle
	for i in range(20):
		await get_tree().process_frame
		
	await get_tree().create_timer(0.4).timeout

	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/netne/.gemini/antigravity/brain/c16bf1a4-3954-476f-975d-a5a59e385b63/kronos_living_room_overhaul_preview.png"
	img.save_png(out_path)
	print("LIVING_ROOM_PREVIEW_SAVED:" + out_path)
	get_tree().quit(0)
