extends Node2D

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(720, 160))
	get_viewport().size = Vector2i(720, 160)

	# 1. Dark Background Canvas
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.03, 0.06)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(720, 160)
	add_child(bg)

	# 2. Load Temple of Morpheus Room
	var room = load("res://scenes/rooms/Bedroom.tscn").instantiate()
	add_child(room)

	# 3. Spawn Kitsune Fox by the Astrolabe & Grimoire Stand
	var fox = PetRenderer.new()
	fox.species = "fox"
	fox.current_state = PetRenderer.AnimState.IDLE
	fox.position = Vector2(55.0, 102.0)
	fox.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(fox)

	# 4. Spawn Shiba studying / snacking at the Altar of Somnus (Option B: STUDY / EAT)
	var shiba_altar = PetRenderer.new()
	shiba_altar.species = "shiba"
	shiba_altar.current_state = PetRenderer.AnimState.STUDY
	shiba_altar.facing_right = true
	shiba_altar.position = Vector2(110.0, 66.0)
	shiba_altar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_altar)

	# 5. Spawn Calico Cat curled in sleeping loaf in Royal Canopy Bed (Option B: NAP / LOAF)
	var cat_bed = PetRenderer.new()
	cat_bed.species = "cat"
	cat_bed.current_state = PetRenderer.AnimState.NAP
	cat_bed.position = Vector2(230.0, 86.0)
	cat_bed.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_bed)

	# 6. Spawn Calico Cat playfully batting at the Starlight Luna Moth (Option B: WARM_PAWS / PLAY)
	var cat_play = PetRenderer.new()
	cat_play.species = "cat"
	cat_play.current_state = PetRenderer.AnimState.WARM_PAWS
	cat_play.facing_right = false
	cat_play.position = Vector2(320.0, 102.0)
	cat_play.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_play)

	# 7. Spawn Calico Cat drinking at the Font of Lethe (AnimState: DRINK)
	var cat_drink = PetRenderer.new()
	cat_drink.species = "cat"
	cat_drink.current_state = PetRenderer.AnimState.DRINK
	cat_drink.facing_right = false
	cat_drink.position = Vector2(490.0, 102.0)
	cat_drink.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat_drink)

	# 8. Spawn Shiba perched on terrace balustrade gazing at crescent moon (Option B: WINDOW_GAZE)
	var shiba_gaze = PetRenderer.new()
	shiba_gaze.species = "shiba"
	shiba_gaze.current_state = PetRenderer.AnimState.WINDOW_GAZE
	shiba_gaze.facing_right = true
	shiba_gaze.position = Vector2(615.0, 102.0)
	shiba_gaze.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba_gaze)

	# 8. Spawn Capybara on open terrace overlooking Mount Olympus
	var capy = PetRenderer.new()
	capy.species = "capybara"
	capy.current_state = PetRenderer.AnimState.IDLE
	capy.position = Vector2(665.0, 102.0)
	capy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(capy)

	# Advance 25 frames to let fireflies, dream sand, and celestial particles settle
	for i in range(25):
		await get_tree().process_frame
		
	await get_tree().create_timer(0.4).timeout

	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/netne/.gemini/antigravity/brain/c16bf1a4-3954-476f-975d-a5a59e385b63/kronos_bedroom_overhaul_preview.png"
	img.save_png(out_path)
	print("BEDROOM_PREVIEW_SAVED:" + out_path)
	get_tree().quit(0)
