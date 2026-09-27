extends Node2D

func _ready() -> void:
	print("\n==================================================")
	print("🥐 RUNNING PHASE 2: ITEMS & MINIGAMES TEST SUITE")
	print("==================================================")
	
	# 1. Verify 16x16 and 32x32 Treat Assets
	var item_names = ["croissant", "boba", "sushi", "coffee", "ramen", "matcha", "donut", "pancake", "bento", "energy_drink", "mystery_box", "star", "alarm"]
	for iname in item_names:
		var p16 = "res://assets/sprites/items/%s.png" % iname
		var p32 = "res://assets/sprites/items/%s_32.png" % iname
		assert_check(ResourceLoader.exists(p16), "16x16 item sprite exists: %s" % iname)
		assert_check(ResourceLoader.exists(p32), "32x32 item sprite exists: %s" % iname)
		var t16 = load(p16) as Texture2D
		var t32 = load(p32) as Texture2D
		assert_check(t16 != null, "16x16 texture loads: %s (%dx%d)" % [iname, t16.get_width(), t16.get_height()])
		assert_check(t32 != null, "32x32 texture loads: %s (%dx%d)" % [iname, t32.get_width(), t32.get_height()])

	# 2. Verify Ornate Card Back
	var card_back_path = "res://assets/sprites/items/card_back.png"
	assert_check(ResourceLoader.exists(card_back_path), "Card back sprite exists")
	var cb_tex = load(card_back_path) as Texture2D
	assert_check(cb_tex != null, "Card back texture loads (%dx%d)" % [cb_tex.get_width(), cb_tex.get_height()])
	
	# 3. Verify Botanical Plant Sprites
	var plant_names = [
		"flower_rose", "flower_sunflower", "flower_bluebell", "flower_orchid",
		"pot_normal", "pot_glow", "pot_sprout", "watering_can"
	]
	for pname in plant_names:
		var ppath = "res://assets/sprites/plants/%s.png" % pname
		assert_check(ResourceLoader.exists(ppath), "Botanical sprite exists: %s" % pname)
		var ptex = load(ppath) as Texture2D
		assert_check(ptex != null, "Botanical texture loads: %s (%dx%d)" % [pname, ptex.get_width(), ptex.get_height()])
		
	# 4. Verify SnackCatchGame item texture integration
	var snack_game = load("res://scenes/minigames/SnackCatchGame.tscn").instantiate()
	add_child(snack_game)
	assert_check(snack_game._item_textures.size() >= 5, "SnackCatchGame loaded all 5 falling treat textures")
	assert_check(snack_game._player_texture != null, "SnackCatchGame loaded Shiba player sprite")
	snack_game.queue_free()
	
	# 5. Verify MemoryMatchGame card texture integration
	var memory_game = load("res://scenes/minigames/MemoryMatchGame.tscn").instantiate()
	add_child(memory_game)
	assert_check(memory_game._card_textures.size() == 4, "MemoryMatchGame loaded all 4 study card textures")
	assert_check(memory_game._card_back_tex != null, "MemoryMatchGame loaded ornate tarot card back")
	memory_game.queue_free()
	
	# 6. Verify PlantBloomGame botanical texture integration
	var plant_game = load("res://scenes/minigames/PlantBloomGame.tscn").instantiate()
	add_child(plant_game)
	assert_check(plant_game._flower_textures.size() == 4, "PlantBloomGame loaded all 4 blooming flower textures")
	assert_check(plant_game._pot_normal_tex != null, "PlantBloomGame loaded pot_normal_tex")
	assert_check(plant_game._pot_glow_tex != null, "PlantBloomGame loaded pot_glow_tex")
	assert_check(plant_game._pot_sprout_tex != null, "PlantBloomGame loaded pot_sprout_tex")
	plant_game.queue_free()

	# 7. Verify LeftPanel (Shop) Pixel Art UI Rendering
	var left_panel = load("res://scenes/panels/LeftPanel.tscn").instantiate()
	add_child(left_panel)
	var croissant_card = left_panel._create_shop_card(GameState.ITEM_DEFINITIONS["snack_croissant"])
	var card_icon = left_panel._create_item_icon_control(GameState.ITEM_DEFINITIONS["snack_croissant"], Vector2(32, 32))
	assert_check(card_icon is TextureRect, "LeftPanel shop card uses TextureRect for snacks")
	assert_check((card_icon as TextureRect).texture != null, "LeftPanel snack TextureRect has valid texture")
	var pet_icon = left_panel._create_item_icon_control(GameState.ITEM_DEFINITIONS["pet_shiba"], Vector2(32, 32))
	assert_check(pet_icon is TextureRect, "LeftPanel shop card uses TextureRect for pets")
	assert_check((pet_icon as TextureRect).texture != null, "LeftPanel pet TextureRect has valid texture")
	left_panel.queue_free()

	# 8. Verify RightPanel (Inventory Bag & Pet Picker) Pixel Art UI Rendering
	var right_panel = load("res://scenes/panels/RightPanel.tscn").instantiate()
	add_child(right_panel)
	var bag_icon = right_panel._create_item_icon_control("snack_croissant", GameState.ITEM_DEFINITIONS["snack_croissant"], Vector2(20, 20))
	assert_check(bag_icon is TextureRect, "RightPanel inventory card uses TextureRect for treats")
	assert_check((bag_icon as TextureRect).texture != null, "RightPanel treat TextureRect has valid texture")
	var modal_pet_icon = right_panel._create_pet_icon_control("cat", Vector2(24, 24))
	assert_check(modal_pet_icon is TextureRect, "RightPanel pet picker modal uses TextureRect for pets")
	assert_check((modal_pet_icon as TextureRect).texture != null, "RightPanel pet TextureRect has valid texture")
	right_panel.queue_free()
	
	print("\n==================================================")
	print("🎉 ALL PHASE 2 ITEMS, MINIGAMES & UI TESTS PASSED!")
	print("==================================================")
	get_tree().quit(0)

func assert_check(cond: bool, msg: String) -> void:
	if cond:
		print("  ✅ %s" % msg)
	else:
		printerr("  ❌ FAILED: %s" % msg)
		get_tree().quit(1)
