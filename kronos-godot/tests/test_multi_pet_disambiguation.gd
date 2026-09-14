extends Node2D

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _ready() -> void:
	print("\n==================================================")
	print("🐾 RUNNING MULTI-PET FEEDING & EQUIPPING TEST SUITE")
	print("==================================================")
	
	_test_multi_pet_data_setup()
	_test_targeted_feeding()
	_test_targeted_equipping()
	_test_targeted_unequipping()
	_test_pet_selection_and_stats()
	_test_room_manager_index_mapping()
	
	print("\n==================================================")
	print("📊 TEST SUMMARY: %d/%d PASSED (Failed: %d)" % [passed_tests, total_tests, failed_tests])
	print("==================================================")
	
	get_tree().quit(0 if failed_tests == 0 else 1)

func assert_test(condition: bool, test_name: String) -> void:
	total_tests += 1
	if condition:
		passed_tests += 1
		print("  ✅ %s" % test_name)
	else:
		failed_tests += 1
		printerr("  ❌ FAILED: %s" % test_name)

func _test_multi_pet_data_setup() -> void:
	print("\n[TEST 1] Setting Up Multi-Pet Household State...")
	GameState.active_pets = [
		{
			"id": "pet_shiba",
			"name": "Kronos",
			"species": "shiba",
			"room": "room_bedroom",
			"energy": 50.0,
			"joy": 50.0,
			"equipped_cosmetics": {}
		},
		{
			"id": "pet_fox",
			"name": "Kitsune",
			"species": "fox",
			"room": "room_livingroom",
			"energy": 40.0,
			"joy": 40.0,
			"equipped_cosmetics": {}
		}
	]
	GameState.selected_pet_index = 0
	GameState.energy = 50.0
	GameState.joy = 50.0
	GameState.equipped_cosmetics.clear()
	GameState.equipped_cosmetic = ""
	
	assert_test(GameState.active_pets.size() == 2, "Household has 2 active pets")
	assert_test(GameState.get_pet_energy(0) == 50.0, "Pet 0 starting energy is 50%")
	assert_test(GameState.get_pet_energy(1) == 40.0, "Pet 1 starting energy is 40%")

func _test_targeted_feeding() -> void:
	print("\n[TEST 2] Testing Targeted Feeding on Specific Pet...")
	GameState.add_item("snack_croissant", 3)
	
	var res: Dictionary = {
		"received": false,
		"idx": -1,
		"item_id": ""
	}
	
	var conn = func(p_idx: int, i_id: String, _data: Dictionary):
		res["received"] = true
		res["idx"] = p_idx
		res["item_id"] = i_id
	
	EventBus.pet_fed.connect(conn)
	
	# Feed Pet 1 (Kitsune) specifically
	# snack_croissant gives +35 energy, +15 joy
	var success = GameState.use_item("snack_croissant", 1)
	
	EventBus.pet_fed.disconnect(conn)
	
	assert_test(success, "use_item succeeded for Pet 1")
	assert_test(res["received"], "EventBus.pet_fed signal was emitted")
	assert_test(res["idx"] == 1, "pet_fed emitted with correct target pet_index (1)")
	assert_test(res["item_id"] == "snack_croissant", "pet_fed emitted with correct item_id")
	
	# Verify Pet 1 gained stats (40 + 35 = 75 energy, 40 + 15 = 55 joy)
	assert_test(GameState.get_pet_energy(1) == 75.0, "Pet 1 energy boosted from 40% -> 75%")
	assert_test(GameState.get_pet_joy(1) == 55.0, "Pet 1 joy boosted from 40% -> 55%")
	
	# Verify Pet 0 remained untouched (50 energy, 50 joy)
	assert_test(GameState.get_pet_energy(0) == 50.0, "Pet 0 energy remained at 50%")
	assert_test(GameState.get_pet_joy(0) == 50.0, "Pet 0 joy remained at 50%")

func _test_targeted_equipping() -> void:
	print("\n[TEST 3] Testing Targeted Cosmetic Equipping on Specific Pet...")
	
	var res: Dictionary = {
		"received": false,
		"idx": -1,
		"slot": "",
		"cid": ""
	}
	
	var conn = func(p_idx: int, slot: String, c_id: String):
		res["received"] = true
		res["idx"] = p_idx
		res["slot"] = slot
		res["cid"] = c_id
		
	EventBus.cosmetic_equipped.connect(conn)
	
	# Equip Wizard Hat on Pet 1
	GameState.equip_cosmetic("head", "cosmetic_wizard", 1)
	
	EventBus.cosmetic_equipped.disconnect(conn)
	
	assert_test(res["received"], "EventBus.cosmetic_equipped signal emitted")
	assert_test(res["idx"] == 1, "cosmetic_equipped targeted Pet 1")
	assert_test(res["slot"] == "head", "cosmetic_equipped slot is head")
	assert_test(res["cid"] == "cosmetic_wizard", "cosmetic_equipped id is cosmetic_wizard")
	
	# Assert Pet 1 has it equipped
	assert_test(GameState.is_pet_cosmetic_equipped(1, "cosmetic_wizard"), "is_pet_cosmetic_equipped(1, wizard) is true")
	# Assert Pet 0 does NOT have it equipped
	assert_test(not GameState.is_pet_cosmetic_equipped(0, "cosmetic_wizard"), "is_pet_cosmetic_equipped(0, wizard) is false")
	
	# Assert global queries
	assert_test(GameState.is_cosmetic_equipped("cosmetic_wizard"), "is_cosmetic_equipped(wizard) is true")
	assert_test(GameState.get_pet_wearing_cosmetic("cosmetic_wizard") == 1, "get_pet_wearing_cosmetic identifies Pet 1")
	assert_test(GameState.get_total_equipped_cosmetics_count() == 1, "Total equipped cosmetics count is 1")

func _test_targeted_unequipping() -> void:
	print("\n[TEST 4] Testing Targeted Cosmetic Unequipping...")
	
	var res: Dictionary = {
		"received": false,
		"idx": -1,
		"slot": ""
	}
	
	var conn = func(p_idx: int, slot: String):
		res["received"] = true
		res["idx"] = p_idx
		res["slot"] = slot
		
	EventBus.cosmetic_unequipped.connect(conn)
	
	# Unequip head from Pet 1
	GameState.unequip_cosmetic("head", 1)
	
	EventBus.cosmetic_unequipped.disconnect(conn)
	
	assert_test(res["received"], "EventBus.cosmetic_unequipped signal emitted")
	assert_test(res["idx"] == 1, "cosmetic_unequipped targeted Pet 1")
	assert_test(res["slot"] == "head", "cosmetic_unequipped slot is head")
	
	assert_test(not GameState.is_pet_cosmetic_equipped(1, "cosmetic_wizard"), "Pet 1 no longer has wizard hat")
	assert_test(not GameState.is_cosmetic_equipped("cosmetic_wizard"), "No pet is wearing wizard hat")
	assert_test(GameState.get_pet_wearing_cosmetic("cosmetic_wizard") == -1, "get_pet_wearing_cosmetic returns -1")

func _test_pet_selection_and_stats() -> void:
	print("\n[TEST 5] Testing Pet Selection & Stats Synchronization...")
	
	var res: Dictionary = {
		"received": false,
		"idx": -1
	}
	
	var conn = func(idx: int, _data: Dictionary):
		res["received"] = true
		res["idx"] = idx
		
	EventBus.active_pet_selected.connect(conn)
	
	GameState.select_pet(1)
	
	EventBus.active_pet_selected.disconnect(conn)
	
	assert_test(res["received"], "EventBus.active_pet_selected signal emitted")
	assert_test(res["idx"] == 1, "active_pet_selected index is 1")
	assert_test(GameState.selected_pet_index == 1, "GameState.selected_pet_index updated to 1")
	assert_test(GameState.get_active_energy() == 75.0, "get_active_energy reflects Pet 1's energy (75%)")
	assert_test(GameState.get_active_joy() == 55.0, "get_active_joy reflects Pet 1's joy (55%)")
	assert_test(GameState.pet_name == "Kitsune", "GameState.pet_name synced to Kitsune")
	assert_test(GameState.pet_species == "fox", "GameState.pet_species synced to fox")

func _test_room_manager_index_mapping() -> void:
	print("\n[TEST 6] Testing RoomManager Global Pet Index Mapping...")
	# Pet 0 is in room_bedroom, Pet 1 is in room_livingroom
	var room_pets: Array[Dictionary] = []
	for p in GameState.active_pets:
		if p.get("room", "") == "room_livingroom":
			room_pets.append(p)
			
	assert_test(room_pets.size() == 1, "room_livingroom only has 1 companion")
	assert_test(room_pets[0].get("name", "") == "Kitsune", "Companion in room is Kitsune")
	
	# Verify global index resolution
	var global_idx: int = GameState.active_pets.find(room_pets[0])
	assert_test(global_idx == 1, "Kitsune's global index correctly resolves to 1 (not local index 0)")
