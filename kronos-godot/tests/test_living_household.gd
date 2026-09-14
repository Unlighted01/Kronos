extends Node2D

var total_tests: int = 0
var passed_tests: int = 0
var failed_tests: int = 0

func _ready() -> void:
	print("\n==================================================")
	print("🐾 RUNNING LIVING HOUSEHOLD & EXPEDITIONS TEST SUITE")
	print("==================================================")
	
	_test_expedition_grace_period()
	_test_start_and_complete_expedition()
	_test_recall_pet_from_outside()
	_test_focus_mode_study_buddy()
	_test_fetch_companion()
	_test_multi_pet_social_interaction()
	_test_buddy_invite_and_coordinated_travel()
	_test_save_load_persistence()
	
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

func _test_expedition_grace_period() -> void:
	print("\n[TEST 1] Testing Expedition Grace Period for Newcomers...")
	GameState.active_pets = [
		{
			"id": "pet_shiba",
			"name": "Kronos",
			"species": "shiba",
			"room": "room_bedroom",
			"energy": 80.0,
			"joy": 80.0,
			"equipped_cosmetics": {},
			"is_outside": false,
			"expedition_end_unix": 0,
			"expedition_destination": "",
			"adopted_at_unix": 0
		},
		{
			"id": "pet_cat",
			"name": "Luna",
			"species": "cat",
			"room": "room_bedroom",
			"energy": 80.0,
			"joy": 80.0,
			"equipped_cosmetics": {},
			"is_outside": false,
			"expedition_end_unix": 0,
			"expedition_destination": "",
			"adopted_at_unix": int(Time.get_unix_time_from_system())
		}
	]
	
	assert_test(GameState.is_pet_newcomer(0) == false, "Established pet is NOT a newcomer")
	assert_test(GameState.is_pet_newcomer(1) == true, "Newly adopted pet is flagged as newcomer (grace period active)")
	
	var newcomer_depart = GameState.start_pet_expedition(1, 180.0, "garden")
	assert_test(newcomer_depart == false, "Newcomer is prevented from embarking on outdoor expedition")
	assert_test(GameState.is_pet_outside(1) == false, "Newcomer pet remains inside the house")

func _test_start_and_complete_expedition() -> void:
	print("\n[TEST 2] Testing Expedition Departure, Timing & Souvenir Rewards...")
	var initial_coins = GameState.coins
	var initial_joy = GameState.get_pet_joy(0)
	
	var started = GameState.start_pet_expedition(0, 240.0, "secret garden")
	assert_test(started == true, "Mature pet successfully embarked on expedition")
	assert_test(GameState.is_pet_outside(0) == true, "Pet is marked as currently outside")
	
	var remaining = GameState.get_pet_expedition_remaining(0)
	assert_test(remaining > 230.0 and remaining <= 240.0, "Expedition remaining countdown is accurately ~240s")
	
	var souvenir = GameState.complete_pet_expedition(0)
	assert_test(GameState.is_pet_outside(0) == false, "Pet is no longer outside after completing expedition")
	assert_test(GameState.get_pet_expedition_remaining(0) == 0.0, "Expedition remaining time resets to 0")
	assert_test(GameState.get_pet_joy(0) > initial_joy or GameState.get_pet_joy(0) == 100.0, "Pet gained Joy from outdoor stroll")
	assert_test(souvenir.has("name") and souvenir.has("desc"), "Souvenir reward contains name and description")
	assert_test(GameState.coins > initial_coins or souvenir.get("type", "") == "item", "Souvenir awarded coins or an inventory item")

func _test_recall_pet_from_outside() -> void:
	print("\n[TEST 3] Testing Whistling/Recalling Pet Inside Early...")
	GameState.start_pet_expedition(0, 300.0, "patio")
	assert_test(GameState.is_pet_outside(0) == true, "Pet went outside to patio")
	
	var recalled = GameState.recall_pet_from_outside(0)
	assert_test(recalled == true, "Recall signal succeeded")
	assert_test(GameState.is_pet_outside(0) == false, "Pet is safely back inside after whistle")
	assert_test(GameState.get_pet_expedition_remaining(0) == 0.0, "Expedition timer cancelled")

func _test_focus_mode_study_buddy() -> void:
	print("\n[TEST 4] Testing Focus Mode Solo Study Buddy Dynamic...")
	GameState.clear_study_buddy()
	assert_test(GameState.study_buddy_idx == -1, "Initial study buddy index is cleared (-1)")
	
	var picked_buddy = GameState.assign_study_buddy("room_bedroom")
	assert_test(picked_buddy == 0 or picked_buddy == 1, "Exactly one pet chosen as study buddy")
	assert_test(GameState.get_study_buddy_idx() == picked_buddy, "get_study_buddy_idx() matches assignment")
	
	GameState.clear_study_buddy()
	assert_test(GameState.study_buddy_idx == -1, "Study buddy cleared after focus session ends")

func _test_fetch_companion() -> void:
	print("\n[TEST 5] Testing Companion Fetching Across Rooms...")
	GameState.active_view_room = "room_bedroom"
	GameState.active_pets[0]["room"] = "room_bedroom"
	GameState.active_pets[1]["room"] = "room_kitchen"
	
	var fetch_res = {"received": false, "fetcher": -1, "target": -1}
	var fetch_callable = func(f_idx, t_idx):
		fetch_res["received"] = true
		fetch_res["fetcher"] = f_idx
		fetch_res["target"] = t_idx
		
	EventBus.pet_fetch_started.connect(fetch_callable)
	
	var sent = GameState.send_pet_to_fetch(0, 1)
	assert_test(sent == true, "send_pet_to_fetch returned true")
	assert_test(fetch_res["received"] == true, "pet_fetch_started signal emitted")
	assert_test(fetch_res["fetcher"] == 0 and fetch_res["target"] == 1, "Correct fetcher (0) and target (1) IDs")
	assert_test(GameState.active_pets[1]["room"] == "room_bedroom", "Target pet room updated to active room (room_bedroom)")
	
	EventBus.pet_fetch_started.disconnect(fetch_callable)

func _test_multi_pet_social_interaction() -> void:
	print("\n[TEST 6] Testing Multi-Pet Social Chatter & Mutual Reactions...")
	var pet_scene = preload("res://scenes/pet/PetCompanion.tscn")
	var pet1 = pet_scene.instantiate() as PetBrain
	var pet2 = pet_scene.instantiate() as PetBrain
	add_child(pet1)
	add_child(pet2)
	
	pet1.pet_index = 0
	pet1.setup_pet(GameState.active_pets[0])
	pet1.position = Vector2(80.0, 115.0)
	
	pet2.pet_index = 1
	pet2.setup_pet(GameState.active_pets[1])
	pet2.position = Vector2(160.0, 115.0)
	
	var social_res = {"received": false}
	var social_callable = func(_i, _p, _t):
		social_res["received"] = true
	EventBus.pet_social_started.connect(social_callable)
	
	var social_triggered = pet1._try_multi_pet_social()
	assert_test(social_triggered == true, "pet1 successfully initiated social interaction with roommate pet2")
	assert_test(pet1._is_social_partner == true and pet2._is_social_partner == true, "Both pets marked as active social partners")
	assert_test(pet1.post_target_state == PetBrain.State.SOCIALIZING, "Pet1 target state set to SOCIALIZING")
	
	EventBus.pet_social_started.disconnect(social_callable)
	pet1.queue_free()
	pet2.queue_free()

func _test_buddy_invite_and_coordinated_travel() -> void:
	print("\n[TEST 7] Testing Buddy Invite & Coordinated Room Travel...")
	var pet_scene = preload("res://scenes/pet/PetCompanion.tscn")
	var leader = pet_scene.instantiate() as PetBrain
	var follower = pet_scene.instantiate() as PetBrain
	add_child(leader)
	add_child(follower)
	
	leader.pet_index = 0
	leader.setup_pet(GameState.active_pets[0])
	follower.pet_index = 1
	follower.setup_pet(GameState.active_pets[1])
	
	follower.accept_buddy_invite(leader, "room_kitchen", 220.0)
	assert_test(follower._buddy_leader_node == leader, "Follower recognized leader node")
	
	leader.queue_free()
	follower.queue_free()

func _test_save_load_persistence() -> void:
	print("\n[TEST 8] Testing Save & Deserialization Persistence for Expeditions...")
	GameState.start_pet_expedition(0, 250.0, "mystic garden")
	var save_dict = GameState.serialize()
	
	assert_test(save_dict.has("active_pets"), "Serialized save contains active_pets")
	var p0 = save_dict["active_pets"][0]
	assert_test(p0.get("is_outside", false) == true, "Saved pet is_outside is true")
	assert_test(p0.get("expedition_destination", "") == "mystic garden", "Saved destination is preserved")
	assert_test(p0.get("expedition_end_unix", 0) > 0, "Saved expedition end timestamp is positive integer")
	
	GameState.active_pets[0]["is_outside"] = false
	GameState.deserialize(save_dict)
	assert_test(GameState.is_pet_outside(0) == true, "Deserialized state restored is_outside to true")
	assert_test(GameState.get_pet_expedition_remaining(0) > 0.0, "Deserialized expedition remaining time restored correctly")
	
	GameState.recall_pet_from_outside(0)
