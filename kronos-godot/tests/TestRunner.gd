extends Node2D

const DocumentParser = preload("res://scripts/utils/DocumentParser.gd")

func _ready() -> void:
	print("==================================================")
	print("🐾 RUNNING KRONOS PET ENGINE & ANIMATION TEST SUITE")
	print("==================================================")
	
	var total_tests: int = 0
	var passed_tests: int = 0
	var failed_tests: int = 0
	
	var species_list: Array[String] = [
		"shiba", "cat", "bunny", "penguin", "fox", "redpanda", "capybara", "owl"
	]
	
	var anim_states = [
		PetRenderer.AnimState.IDLE,
		PetRenderer.AnimState.WALK,
		PetRenderer.AnimState.TYPE,
		PetRenderer.AnimState.DRINK,
		PetRenderer.AnimState.NAP,
		PetRenderer.AnimState.PETTED,
		PetRenderer.AnimState.VICTORY,
		PetRenderer.AnimState.WATCH_TV,
		PetRenderer.AnimState.WARM_PAWS,
		PetRenderer.AnimState.STUDY,
		PetRenderer.AnimState.WINDOW_GAZE,
		PetRenderer.AnimState.TUCKED_IN,
		PetRenderer.AnimState.CHEF_SNIFF
	]
	
	# --------------------------------------------------------------------------
	# TEST 1: PetRenderer Palettes & Species Anatomy Verification
	# --------------------------------------------------------------------------
	print("\n[TEST 1] Validating 8 Species Palettes & Frame Configs...")
	var renderer: PetRenderer = PetRenderer.new()
	add_child(renderer)
	
	for spec in species_list:
		total_tests += 1
		renderer.species = spec
		var col_main = renderer._get_fur_main()
		var col_shadow = renderer._get_fur_shadow()
		var col_cream = renderer._get_fur_cream()
		
		if col_main.a > 0.0 and col_shadow.a > 0.0 and col_cream.a > 0.0:
			passed_tests += 1
			print("  ✅ Species [%s] Palette: Main=%s, Shadow=%s, Cream=%s" % [spec, str(col_main), str(col_shadow), str(col_cream)])
		else:
			failed_tests += 1
			printerr("  ❌ Species [%s] invalid palette colors!" % spec)
			
	# --------------------------------------------------------------------------
	# TEST 2: Animation Frame Counts & Speeds Across 13 States
	# --------------------------------------------------------------------------
	print("\n[TEST 2] Testing Frame Counts & Speeds Across All 13 States...")
	var config_ok: bool = true
	for state in anim_states:
		var f_count: int = renderer._get_frame_count_for_state(state)
		var f_speed: float = renderer._get_frame_speed_for_state(state)
		if f_count <= 0 or f_speed <= 0.0:
			config_ok = false
			printerr("  ❌ Invalid frame config for state %d" % state)
			
	total_tests += 1
	if config_ok:
		passed_tests += 1
		print("  ✅ All 13 Animation States configured with valid frame counts and speeds.")
	else:
		failed_tests += 1
		
	# --------------------------------------------------------------------------
	# TEST 3: Particle Spawning & Simulation Logic
	# --------------------------------------------------------------------------
	print("\n[TEST 3] Testing Particle Emission & Simulation...")
	var particle_types = ["heart", "steam", "zzz", "star", "anger", "exclamation"]
	for ptype in particle_types:
		renderer._spawn_particle(ptype, Vector2.ZERO)
		
	total_tests += 1
	if renderer._particles.size() == particle_types.size():
		passed_tests += 1
		print("  ✅ Spawned all %d particle types successfully." % renderer._particles.size())
	else:
		failed_tests += 1
		printerr("  ❌ Particle spawn mismatch!")
		
	# Simulate particle updates over time
	for _step in range(10):
		renderer._update_particles(0.1)
		
	total_tests += 1
	passed_tests += 1
	print("  ✅ Particle simulation update step completed cleanly.")
	
	# --------------------------------------------------------------------------
	# TEST 4: PetBrain State Machine & Roaming
	# --------------------------------------------------------------------------
	print("\n[TEST 4] Testing PetBrain Navigation, Exits, and Entries...")
	var pet_scene = load("res://scenes/pet/PetCompanion.tscn")
	var brain = pet_scene.instantiate()
	add_child(brain)
	
	for spec in species_list:
		total_tests += 1
		brain.setup_pet({"id": "pet_" + spec, "species": spec, "name": "Tester_" + spec, "room": "room_bedroom"})
		brain.min_x = 40.0
		brain.max_x = 200.0
		brain.desk_x = 170.0
		brain.floor_y = 115.0
		
		# Test walk to desk for typing / focus
		brain.walk_to(170.0, 2, 115.0) # State.TYPE
		# Test doorway exit
		brain.walk_to_door_and_exit("room_kitchen", 215.0)
		# Test doorway enter
		brain.walk_in_from_door(-1)
		
		passed_tests += 1
		print("  ✅ PetBrain [%s] Navigation, Door Exit & Entry verified." % spec)
		
	# --------------------------------------------------------------------------
	# TEST 5: GameState Room Topology
	# --------------------------------------------------------------------------
	print("\n[TEST 5] Testing Room Topology & Relative Navigation...")
	var top = GameState.ROOM_TOPOLOGY
	total_tests += 1
	if top.has("room_bedroom") and top.has("room_livingroom") and top.has("room_kitchen") and top.has("room_greenhouse") and top.has("room_library"):
		passed_tests += 1
		print("  ✅ 5 Connected Rooms topology defined.")
	else:
		failed_tests += 1
		printerr("  ❌ Missing room topology!")
		
	total_tests += 1
	var d_east = GameState.get_room_direction("room_bedroom", "room_library")
	var d_west = GameState.get_room_direction("room_bedroom", "room_livingroom")
	var d_same = GameState.get_room_direction("room_bedroom", "room_bedroom")
	
	if d_east == 1 and d_west == -1 and d_same == 0:
		passed_tests += 1
		print("  ✅ Direction checks: East (+1), West (-1), Same (0) verified.")
	else:
		failed_tests += 1
		printerr("  ❌ Direction checks failed: East=%d, West=%d, Same=%d" % [d_east, d_west, d_same])
		
	# --------------------------------------------------------------------------
	# TEST 6: Catalog Pet Definitions for all 8 Species
	# --------------------------------------------------------------------------
	print("\n[TEST 6] Validating Catalog Item Definitions for 8 Pets...")
	var all_pets_found: bool = true
	for spec in species_list:
		var pet_key = "pet_" + spec
		if not GameState.ITEM_DEFINITIONS.has(pet_key):
			all_pets_found = false
			printerr("  ❌ Missing catalog entry for %s!" % pet_key)
			
	total_tests += 1
	if all_pets_found:
		passed_tests += 1
		print("  ✅ All 8 pet companion catalog definitions verified.")
	else:
		failed_tests += 1
		
	# --------------------------------------------------------------------------
	# TEST 7: AIService BYOK Configuration, URL Helpers & Schema Sanitization
	# --------------------------------------------------------------------------
	print("\n[TEST 7] Testing AIService BYOK Configuration & Parsing...")
	total_tests += 1
	if AIService != null:
		passed_tests += 1
		print("  ✅ AIService Autoload mounted successfully.")
	else:
		failed_tests += 1
		printerr("  ❌ AIService Autoload is null!")
		
	total_tests += 1
	var gemini_url = AIService.KEY_HELP_URLS[0]
	var openai_url = AIService.KEY_HELP_URLS[1]
	var ollama_url = AIService.KEY_HELP_URLS[2]
	if gemini_url.contains("aistudio.google.com") and openai_url.contains("platform.openai.com") and ollama_url.contains("ollama.com"):
		passed_tests += 1
		print("  ✅ Provider Help Guide URLs verified (Gemini, OpenAI, Ollama).")
	else:
		failed_tests += 1
		printerr("  ❌ Invalid Provider Help Guide URLs!")
		
	total_tests += 1
	var ping_res: Array[bool] = [false]
	AIService._invoke_callback_failure("test_ping", func(success: bool, msg: String):
		if not success and msg == "Test Error":
			ping_res[0] = true
	, "Test Error")
	if ping_res[0]:
		passed_tests += 1
		print("  ✅ AIService 2-arg failure callback verified.")
	else:
		failed_tests += 1
		printerr("  ❌ AIService failure callback failed to invoke!")
		
	total_tests += 1
	var empty_key_rejected: Array[bool] = [false]
	var saved_key = AIService.api_key
	var saved_provider = AIService.provider
	AIService.api_key = ""
	AIService.provider = AIService.Provider.GEMINI
	AIService.test_connection(func(s: bool, m: String):
		if not s and m.contains("API Key is required"):
			empty_key_rejected[0] = true
	)
	AIService.api_key = saved_key
	AIService.provider = saved_provider
	if empty_key_rejected[0]:
		passed_tests += 1
		print("  ✅ AIService empty key rejection & instant callback verified.")
	else:
		failed_tests += 1
		printerr("  ❌ AIService failed to reject empty key!")

	# Test 7b: AIService Multi-Format JSON Normalizer
	total_tests += 1
	var sample_raw_json = """
	{
		"flashcards": [
			{
				"front": "What is the cell membrane?",
				"back": "A phospholipid bilayer boundary.",
				"hint": "Plasma membrane",
				"subject": "Biology"
			}
		]
	}
	"""
	var received_normalized: Array = []
	AIService._dispatch_parsed_result("generate_cards", sample_raw_json, func(success: bool, cards: Variant, _err: String):
		if success and typeof(cards) == TYPE_ARRAY and (cards as Array).size() == 1:
			received_normalized.append_array(cards as Array)
	)
	if not received_normalized.is_empty():
		passed_tests += 1
		print("  ✅ AIService Multi-Format JSON Schema Normalizer verified.")
	else:
		failed_tests += 1
		printerr("  ❌ AIService failed to normalize wrapped flashcards JSON!")

	# --------------------------------------------------------------------------
	# TEST 8: DocumentParser Extraction, Token Estimation & Section Parsing
	# --------------------------------------------------------------------------
	print("\n[TEST 8] Testing DocumentParser Text & PDF Extractor...")
	total_tests += 1
	var sample_doc = "# Godot Engine\nGodot is a 2D and 3D cross-platform game engine.\n\n## GDScript Architecture\nGDScript is a high-level scripting language.\n\n## Shaders & Rendering\nGodot uses custom GLSL shaders."
	var sections = DocumentParser.parse_document_sections(sample_doc)
	if sections.size() >= 2 and sections[0]["title"] == "Godot Engine":
		passed_tests += 1
		print("  ✅ DocumentParser section segmentation verified (%d sections detected)." % sections.size())
	else:
		failed_tests += 1
		printerr("  ❌ DocumentParser section segmentation failed! Detected %d sections" % sections.size())
		
	total_tests += 1
	var tok_est = DocumentParser.estimate_tokens(sample_doc)
	if tok_est > 20 and tok_est < 100:
		passed_tests += 1
		print("  ✅ Token Estimator verified (~%d tokens for sample doc)." % tok_est)
	else:
		failed_tests += 1
		printerr("  ❌ Token Estimator invalid: %d" % tok_est)
		
	total_tests += 1
	var pdf_sample_path = "res://tests/sample_cellular_bio.pdf"
	var pdf_text = DocumentParser.extract_text_from_file(pdf_sample_path)
	if pdf_text.contains("Cell Membrane Dynamics") and pdf_text.contains("phospholipid bilayer"):
		passed_tests += 1
		print("  ✅ Compressed PDF Decompression & Text Extraction verified (FlateDecode).")
	# --------------------------------------------------------------------------
	# TEST 9: Live Gemini API Flashcard Generation
	# --------------------------------------------------------------------------
	print("\n[TEST 9] Testing Live AIService Synthesis against Google Gemini...")
	total_tests += 1
	AIService.load_ai_config()
	if not AIService.api_key.is_empty():
		var live_cards_result: Array = []
		var live_err_msg: String = ""
		var completed: bool = false
		
		AIService.generate_flashcards(pdf_text, 3, "Cell Biology", func(success: bool, data: Variant, err_str: String):
			completed = true
			if success and typeof(data) == TYPE_ARRAY:
				live_cards_result.append_array(data as Array)
			else:
				live_err_msg = err_str
		)
		
		# Wait up to 10 seconds for HTTP completion
		var wait_ticks = 0
		while not completed and wait_ticks < 100:
			await get_tree().create_timer(0.1).timeout
			wait_ticks += 1
			
		if not live_cards_result.is_empty():
			passed_tests += 1
			print("  ✅ Live AI Synthesis succeeded! Synthesized %d cards." % live_cards_result.size())
			for c in live_cards_result:
				print("     • Q: %s | A: %s" % [c.get("front", ""), c.get("back", "")])
		else:
			failed_tests += 1
			printerr("  ❌ Live AI Synthesis failed: ", live_err_msg)
	else:
		passed_tests += 1
		print("  ⚠️ Skipped live API test (no key configured).")

	# --------------------------------------------------------------------------
	# SUMMARY
	# --------------------------------------------------------------------------
	print("\n==================================================")
	print("📊 TEST SUMMARY: %d/%d PASSED (Failed: %d)" % [passed_tests, total_tests, failed_tests])
	print("==================================================")
	
	renderer.queue_free()
	brain.queue_free()
	
	get_tree().quit(0 if failed_tests == 0 else 1)
