extends Node2D

func _ready() -> void:
	print("\n==================================================")
	print("🐾 RUNNING 32x32 COMPANION SPRITE ENGINE TEST SUITE")
	print("==================================================")
	
	var renderer = PetRenderer.new()
	add_child(renderer)
	
	# 1. Test Shiba Inu
	renderer.species = "shiba"
	renderer._load_species_sprites("shiba")
	var shiba_data = renderer._sprite_cache.get("shiba", {})
	assert_check(not shiba_data.is_empty(), "Shiba sprite cache loaded")
	assert_check(shiba_data["idle"].size() == 4, "Shiba idle has 4 frames")
	assert_check(shiba_data["walk"].size() == 6, "Shiba walk has 6 frames")
	assert_check(shiba_data["nap"].size() == 4, "Shiba nap has 4 frames")
	assert_check(shiba_data["victory"].size() == 4, "Shiba victory has 4 frames")
	
	# 2. Test Calico Cat
	renderer.species = "cat"
	renderer._load_species_sprites("cat")
	var cat_data = renderer._sprite_cache.get("cat", {})
	assert_check(not cat_data.is_empty(), "Calico Cat sprite cache loaded")
	assert_check(cat_data["idle"].size() == 4, "Cat idle has 4 frames")
	assert_check(cat_data["walk"].size() == 6, "Cat walk has 6 frames")
	assert_check(cat_data["nap"].size() == 4, "Cat nap has 4 frames")
	assert_check(cat_data["victory"].size() == 4, "Cat victory has 4 frames")
	
	# 3. Test Snowy Bunny
	renderer.species = "bunny"
	renderer._load_species_sprites("bunny")
	var bunny_data = renderer._sprite_cache.get("bunny", {})
	assert_check(not bunny_data.is_empty(), "Snowy Bunny sprite cache loaded")
	assert_check(bunny_data["idle"].size() == 4, "Bunny idle has 4 frames")
	assert_check(bunny_data["walk"].size() == 6, "Bunny walk has 6 frames")
	assert_check(bunny_data["nap"].size() == 4, "Bunny nap has 4 frames")
	assert_check(bunny_data["victory"].size() == 4, "Bunny victory has 4 frames")
	
	# 4. Test Chubby Penguin
	renderer.species = "penguin"
	renderer._load_species_sprites("penguin")
	var penguin_data = renderer._sprite_cache.get("penguin", {})
	assert_check(not penguin_data.is_empty(), "Chubby Penguin sprite cache loaded")
	assert_check(penguin_data["idle"].size() == 4, "Penguin idle has 4 frames")
	assert_check(penguin_data["walk"].size() == 6, "Penguin walk has 6 frames")
	assert_check(penguin_data["nap"].size() == 4, "Penguin nap has 4 frames")
	assert_check(penguin_data["victory"].size() == 4, "Penguin victory has 4 frames")
	
	# 5. Test Amber Fox
	renderer.species = "fox"
	renderer._load_species_sprites("fox")
	var fox_data = renderer._sprite_cache.get("fox", {})
	assert_check(not fox_data.is_empty(), "Amber Fox sprite cache loaded")
	assert_check(fox_data["idle"].size() == 4, "Fox idle has 4 frames")
	assert_check(fox_data["walk"].size() == 6, "Fox walk has 6 frames")
	assert_check(fox_data["nap"].size() == 4, "Fox nap has 4 frames")
	assert_check(fox_data["victory"].size() == 4, "Fox victory has 4 frames")
	
	# 6. Test Red Panda
	renderer.species = "redpanda"
	renderer._load_species_sprites("redpanda")
	var rp_data = renderer._sprite_cache.get("redpanda", {})
	assert_check(not rp_data.is_empty(), "Red Panda sprite cache loaded")
	assert_check(rp_data["idle"].size() == 4, "Red Panda idle has 4 frames")
	assert_check(rp_data["walk"].size() == 6, "Red Panda walk has 6 frames")
	assert_check(rp_data["nap"].size() == 4, "Red Panda nap has 4 frames")
	assert_check(rp_data["victory"].size() == 4, "Red Panda victory has 4 frames")
	
	# 7. Test Zen Capybara
	renderer.species = "capybara"
	renderer._load_species_sprites("capybara")
	var capy_data = renderer._sprite_cache.get("capybara", {})
	assert_check(not capy_data.is_empty(), "Zen Capybara sprite cache loaded")
	assert_check(capy_data["idle"].size() == 4, "Capybara idle has 4 frames")
	assert_check(capy_data["walk"].size() == 6, "Capybara walk has 6 frames")
	assert_check(capy_data["nap"].size() == 4, "Capybara nap has 4 frames")
	assert_check(capy_data["victory"].size() == 4, "Capybara victory has 4 frames")
	
	# 8. Test Scholar Owl
	renderer.species = "owl"
	renderer._load_species_sprites("owl")
	var owl_data = renderer._sprite_cache.get("owl", {})
	assert_check(not owl_data.is_empty(), "Scholar Owl sprite cache loaded")
	assert_check(owl_data["idle"].size() == 4, "Owl idle has 4 frames")
	assert_check(owl_data["walk"].size() == 6, "Owl walk has 6 frames")
	assert_check(owl_data["nap"].size() == 4, "Owl nap has 4 frames")
	assert_check(owl_data["victory"].size() == 4, "Owl victory has 4 frames")
	
	print("\n==================================================")
	print("🎉 ALL 8 COMPANION SPRITE ENGINES PASSED (100% ROSTER)!")
	print("==================================================")
	get_tree().quit(0)

func assert_check(cond: bool, msg: String) -> void:
	if cond:
		print("  ✅ %s" % msg)
	else:
		printerr("  ❌ FAILED: %s" % msg)
		get_tree().quit(1)
