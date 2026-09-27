extends Node2D

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(720, 160))
	get_viewport().size = Vector2i(720, 160)

	# 1. Warm Pastoral Canvas
	var bg = ColorRect.new()
	bg.color = Color(0.42, 0.65, 0.88)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(720, 160)
	add_child(bg)

	# 2. Load Elysian Fields Room
	var room = load("res://scenes/rooms/Greenhouse.tscn").instantiate()
	add_child(room)

	# 3. Spawn Kitsune Fox by the Scarecrow & Straw Hat
	var fox = PetRenderer.new()
	fox.species = "fox"
	fox.current_state = PetRenderer.AnimState.IDLE
	fox.facing_right = true
	fox.position = Vector2(55.0, 102.0)
	fox.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(fox)

	# 4. Spawn Calico Cat curled in sleeping loaf on the Marble Sunbench (Option B: NAP / LOAF)
	var cat_bench = PetRenderer.new()
	cat_bench.species = "cat"
	cat_bench.current_state = PetRenderer.AnimState.NAP
	cat_bench.position = Vector2(210.0, 88.0)
	cat_bench.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_bench)

	# 5. Spawn Shiba drinking fresh spring water at the Birdbath Fountain (AnimState: DRINK)
	var shiba_fountain = PetRenderer.new()
	shiba_fountain.species = "shiba"
	shiba_fountain.current_state = PetRenderer.AnimState.DRINK
	shiba_fountain.facing_right = false
	shiba_fountain.position = Vector2(330.0, 102.0)
	shiba_fountain.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_fountain)

	# 6. Spawn Calico Cat batting at fluttering golden butterflies (Option B: WARM_PAWS)
	var cat_play = PetRenderer.new()
	cat_play.species = "cat"
	cat_play.current_state = PetRenderer.AnimState.WARM_PAWS
	cat_play.facing_right = false
	cat_play.position = Vector2(375.0, 102.0)
	cat_play.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_play)

	# 7. Spawn Shiba potting herbs / snacking at the Rustic Potting Bench (Option B: STUDY / EAT)
	var shiba_pot = PetRenderer.new()
	shiba_pot.species = "shiba"
	shiba_pot.current_state = PetRenderer.AnimState.STUDY
	shiba_pot.facing_right = true
	shiba_pot.position = Vector2(425.0, 70.0)
	shiba_pot.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_pot)

	# 8. Spawn Calico Cat gazing across the golden wheat fields and sunlit hills (Option B: WINDOW_GAZE)
	var cat_gaze = PetRenderer.new()
	cat_gaze.species = "cat"
	cat_gaze.current_state = PetRenderer.AnimState.WINDOW_GAZE
	cat_gaze.facing_right = true
	cat_gaze.position = Vector2(620.0, 102.0)
	cat_gaze.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_gaze)

	# 9. Spawn Capybara enjoying the peaceful breeze in the wheat meadow
	var capy = PetRenderer.new()
	capy.species = "capybara"
	capy.current_state = PetRenderer.AnimState.IDLE
	capy.position = Vector2(675.0, 102.0)
	capy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(capy)

	# Advance 25 frames to let butterflies, falling petals, sun motes, and fountain drips animate
	for i in range(25):
		await get_tree().process_frame
		
	await get_tree().create_timer(0.4).timeout

	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/netne/.gemini/antigravity/brain/c16bf1a4-3954-476f-975d-a5a59e385b63/kronos_greenhouse_overhaul_preview.png"
	img.save_png(out_path)
	print("GREENHOUSE_PREVIEW_SAVED:" + out_path)
	get_tree().quit(0)
