extends Node2D

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(720, 160))
	get_viewport().size = Vector2i(720, 160)

	# 1. Dark Background Canvas
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.07)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(720, 160)
	add_child(bg)

	# 2. Load Tower of Urania Room
	var room = load("res://scenes/rooms/Library.tscn").instantiate()
	add_child(room)

	# 3. Spawn Kitsune Fox by the Grand Rolling Bookshelf & Ladder
	var fox = PetRenderer.new()
	fox.species = "fox"
	fox.current_state = PetRenderer.AnimState.IDLE
	fox.position = Vector2(80.0, 102.0)
	fox.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(fox)

	# 4. Spawn Calico Cat curled in sleeping loaf in Reading Armchair (Option B: NAP / LOAF)
	var cat_chair = PetRenderer.new()
	cat_chair.species = "cat"
	cat_chair.current_state = PetRenderer.AnimState.NAP
	cat_chair.position = Vector2(220.0, 88.0)
	cat_chair.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_chair)

	# 5. Spawn Shiba drinking hot tea at the bronze Samovar (AnimState: DRINK)
	var shiba_tea = PetRenderer.new()
	shiba_tea.species = "shiba"
	shiba_tea.current_state = PetRenderer.AnimState.DRINK
	shiba_tea.facing_right = false
	shiba_tea.position = Vector2(326.0, 102.0)
	shiba_tea.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_tea)

	# 6. Spawn Calico Cat examining / batting at the Celestial Globe (Option B: WARM_PAWS)
	var cat_globe = PetRenderer.new()
	cat_globe.species = "cat"
	cat_globe.current_state = PetRenderer.AnimState.WARM_PAWS
	cat_globe.facing_right = false
	cat_globe.position = Vector2(378.0, 102.0)
	cat_globe.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_globe)

	# 7. Spawn Shiba studying / snacking at the Scholar Desk (Option B: STUDY / EAT)
	var shiba_desk = PetRenderer.new()
	shiba_desk.species = "shiba"
	shiba_desk.current_state = PetRenderer.AnimState.STUDY
	shiba_desk.facing_right = true
	shiba_desk.position = Vector2(415.0, 70.0)
	shiba_desk.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_desk)

	# 8. Spawn Calico Cat perched on balustrade terrace looking at galaxy (Option B: WINDOW_GAZE)
	var cat_gaze = PetRenderer.new()
	cat_gaze.species = "cat"
	cat_gaze.current_state = PetRenderer.AnimState.WINDOW_GAZE
	cat_gaze.facing_right = true
	cat_gaze.position = Vector2(638.0, 102.0)
	cat_gaze.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_gaze)

	# 9. Spawn Capybara on open celestial terrace
	var capy = PetRenderer.new()
	capy.species = "capybara"
	capy.current_state = PetRenderer.AnimState.IDLE
	capy.position = Vector2(685.0, 102.0)
	capy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(capy)

	# Advance 25 frames to let starlight motes, tea steam, and shooting stars animate
	for i in range(25):
		await get_tree().process_frame
		
	await get_tree().create_timer(0.4).timeout

	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/netne/.gemini/antigravity/brain/c16bf1a4-3954-476f-975d-a5a59e385b63/kronos_library_overhaul_preview.png"
	img.save_png(out_path)
	print("LIBRARY_PREVIEW_SAVED:" + out_path)
	get_tree().quit(0)
