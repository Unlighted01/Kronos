extends Node2D

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(720, 160))
	get_viewport().size = Vector2i(720, 160)

	# 1. Dark Abyssal Canvas
	var bg = ColorRect.new()
	bg.color = Color(0.03, 0.04, 0.06)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(720, 160)
	add_child(bg)

	# 2. Load Banks of the Styx Room
	var room = load("res://scenes/rooms/Kitchen.tscn").instantiate()
	add_child(room)

	# 3. Spawn Calico Cat curled in sleeping loaf in the Obsidian Sarcophagus (Option B: NAP / LOAF)
	var cat_sarc = PetRenderer.new()
	cat_sarc.species = "cat"
	cat_sarc.current_state = PetRenderer.AnimState.NAP
	cat_sarc.position = Vector2(110.0, 88.0)
	cat_sarc.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_sarc)

	# 4. Spawn Shiba studying the Ledger of Souls at the Altar of Obols (Option B: STUDY / EAT)
	var shiba_altar = PetRenderer.new()
	shiba_altar.species = "shiba"
	shiba_altar.current_state = PetRenderer.AnimState.STUDY
	shiba_altar.facing_right = true
	shiba_altar.position = Vector2(215.0, 70.0)
	shiba_altar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_altar)

	# 5. Spawn Shiba warming paws by the cyan Soulfire Brazier (Option B: WARM_PAWS)
	var shiba_warm = PetRenderer.new()
	shiba_warm.species = "shiba"
	shiba_warm.current_state = PetRenderer.AnimState.WARM_PAWS
	shiba_warm.facing_right = false
	shiba_warm.position = Vector2(356.0, 102.0)
	shiba_warm.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_warm)

	# 6. Spawn Kitsune Fox by the Iron Mooring Bollard
	var fox = PetRenderer.new()
	fox.species = "fox"
	fox.current_state = PetRenderer.AnimState.IDLE
	fox.facing_right = true
	fox.position = Vector2(385.0, 102.0)
	fox.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(fox)

	# 7. Spawn Capybara standing stoic on Charon's ferry skiff deck
	var capy = PetRenderer.new()
	capy.species = "capybara"
	capy.current_state = PetRenderer.AnimState.IDLE
	capy.facing_right = true
	capy.position = Vector2(495.0, 98.0)
	capy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(capy)

	# 8. Spawn Calico Cat perched on Charon's skiff gazing across the River Styx (Option B: WINDOW_GAZE)
	var cat_gaze = PetRenderer.new()
	cat_gaze.species = "cat"
	cat_gaze.current_state = PetRenderer.AnimState.WINDOW_GAZE
	cat_gaze.facing_right = true
	cat_gaze.position = Vector2(565.0, 98.0)
	cat_gaze.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_gaze)

	# Advance 25 frames to let fog banks, soul motes, brazier flames, and boat bobbing settle
	for i in range(25):
		await get_tree().process_frame
		
	await get_tree().create_timer(0.4).timeout

	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/netne/.gemini/antigravity/brain/c16bf1a4-3954-476f-975d-a5a59e385b63/kronos_kitchen_overhaul_preview.png"
	img.save_png(out_path)
	print("KITCHEN_PREVIEW_SAVED:" + out_path)
	get_tree().quit(0)
