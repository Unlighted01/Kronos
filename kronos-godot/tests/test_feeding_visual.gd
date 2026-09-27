extends Node2D

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(800, 600))
	get_viewport().size = Vector2i(800, 600)
	
	var bg = ColorRect.new()
	bg.color = Color(0.12, 0.14, 0.18, 1.0)
	bg.size = Vector2(800, 600)
	add_child(bg)
	
	var items = [
		"snack_croissant", "snack_sushi", "snack_ramen",
		"snack_coffee", "snack_boba", "snack_pancake"
	]
	
	for col in range(items.size()):
		var item_id = items[col]
		for stage in range(3):
			# Row 0: Shiba
			var shiba = PetRenderer.new()
			shiba.species = "shiba"
			shiba.current_state = PetRenderer.AnimState.FEEDING
			shiba.feeding_item_id = item_id
			shiba.feeding_stage = stage
			shiba.position = Vector2(70 + col * 120, 80 + stage * 70)
			shiba.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			add_child(shiba)
			
			# Row 1: Cat
			var cat = PetRenderer.new()
			cat.species = "cat"
			cat.current_state = PetRenderer.AnimState.FEEDING
			cat.feeding_item_id = item_id
			cat.feeding_stage = stage
			cat.position = Vector2(70 + col * 120, 80 + stage * 70 + 130)
			cat.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			add_child(cat)
			
			# Row 2: Fox
			var fox = PetRenderer.new()
			fox.species = "fox"
			fox.current_state = PetRenderer.AnimState.FEEDING
			fox.feeding_item_id = item_id
			fox.feeding_stage = stage
			fox.position = Vector2(70 + col * 120, 80 + stage * 70 + 260)
			fox.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			add_child(fox)

	for i in range(25):
		await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout
	
	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/netne/.gemini/antigravity/brain/c16bf1a4-3954-476f-975d-a5a59e385b63/godot_actual_feeding_render.png"
	img.save_png(out_path)
	print("FEEDING_RENDER_SAVED:" + out_path)
	get_tree().quit()
