extends Node2D

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(620, 480))
	get_viewport().size = Vector2i(620, 480)

	# Add items to GameState inventory for display
	GameState.coins = 9999
	GameState.inventory.clear()
	GameState.add_item("snack_croissant", 3)
	GameState.add_item("snack_coffee", 2)
	GameState.add_item("snack_donut", 1)
	GameState.add_item("snack_boba", 4)
	GameState.add_item("snack_onigiri", 2)
	GameState.add_item("snack_ramen", 1)
	GameState.add_item("snack_pancake", 2)
	GameState.add_item("snack_bento", 1)
	GameState.add_item("snack_energy_drink", 5)
	GameState.add_item("snack_mystery_box", 2)

	# Set up background
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.07, 0.10)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(620, 480)
	add_child(bg)

	# Title Banner
	var title = Label.new()
	title.text = "KRONOS — PIXEL ART SHOP & INVENTORY PREVIEW"
	title.position = Vector2(16, 8)
	title.add_theme_font_size_override("font_size", 11)
	title.modulate = Color(1.0, 0.84, 0.0)
	add_child(title)

	var hbox = HBoxContainer.new()
	hbox.position = Vector2(16, 32)
	hbox.custom_minimum_size = Vector2(588, 436)
	hbox.add_theme_constant_override("separation", 16)
	add_child(hbox)

	# Left Panel (Shop)
	var left_panel = load("res://scenes/panels/LeftPanel.tscn").instantiate()
	left_panel.custom_minimum_size = Vector2(286, 436)
	hbox.add_child(left_panel)

	# Right Panel (Inventory Bag)
	var right_panel = load("res://scenes/panels/RightPanel.tscn").instantiate()
	right_panel.custom_minimum_size = Vector2(286, 436)
	hbox.add_child(right_panel)

	# Wait for layout to render
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout

	# Set LeftPanel to Treats category
	left_panel._set_shop_category("snack")

	# Switch RightPanel to Bag tab (tab 1)
	if right_panel.tab_container:
		right_panel.tab_container.current_tab = 1
		right_panel._refresh_bag_tab()

	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(0.3).timeout

	var img = get_viewport().get_texture().get_image()
	var out_path = "C:/Users/netne/.gemini/antigravity/brain/c16bf1a4-3954-476f-975d-a5a59e385b63/kronos_shop_inventory_fix_preview.png"
	img.save_png(out_path)
	print("PREVIEW_SAVED:" + out_path)
	get_tree().quit(0)

