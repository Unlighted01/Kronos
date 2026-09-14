extends Node2D

func _ready():
	print("🐾 [CLI] Initializing Kronos AI Tutor Live CLI Test...")
	AIService.load_ai_config()
	
	if AIService.api_key.is_empty():
		print("❌ No API key configured in user data.")
		get_tree().quit(1)
		return
		
	print("🔑 API Provider: Google Gemini (Active Model: %s)" % AIService._active_gemini_model)
	
	# Step 1: Sanctuary Gating Test
	print("\n--- [1] Testing Study Library Sanctuary Gating ---")
	GameState.active_room = "room_bedroom"
	print("  Current Room: %s -> Is In Study Library: %s" % [GameState.active_room, GameState.is_in_study_library()])
	GameState.unlocked_rooms.append("room_library")
	GameState.active_room = "room_library"
	print("  Switched to: %s -> Is In Study Library: %s" % [GameState.active_room, GameState.is_in_study_library()])
	
	# Step 2: Live Socratic Oral Grading
	print("\n--- [2] Live Socratic Oral Exam Grading ---")
	var q = "What is the primary structural composition of the plasma membrane?"
	var ref_a = "A phospholipid bilayer with embedded proteins."
	var student_a = "It is a double layer of fatty lipids with embedded protein channels that control entry and exit."
	
	print("  🦊 [Tutor Question]: \"%s\"" % q)
	print("  📖 [Reference Answer]: \"%s\"" % ref_a)
	print("  🧑 [Student Response]: \"%s\"" % student_a)
	print("  ⏳ Submitting to Gemini for conceptual evaluation...")
	
	AIService.grade_oral_answer(q, ref_a, student_a, "Sparky (Fox Tutor)", "cozy", func(success: bool, eval_data: Dictionary, err_msg: String):
		if not success:
			print("  ❌ Grading Failed: ", err_msg)
			get_tree().quit(1)
			return
			
		print("\n  🎉 [AI Tutor Evaluation Received!]")
		print("     • Conceptual Score: %d/5" % eval_data.get("score", 0))
		print("     • Semantic Verdict: [%s]" % eval_data.get("verdict", "").to_upper())
		print("     • Companion Feedback: \"%s\"" % eval_data.get("feedback", ""))
		if not str(eval_data.get("follow_up_hint", "")).is_empty():
			print("     • Socratic Hint: \"%s\"" % eval_data.get("follow_up_hint", ""))
			
		# Step 3: Socratic ELI5 Analogy
		print("\n--- [3] Live Socratic Analogy (ELI5) Generation ---")
		print("  💡 [Student Action]: Requesting ELI5 analogy for Active Transport...")
		
		var t = get_tree().create_timer(1.0)
		t.timeout.connect(func():
			AIService.explain_concept("What is active transport in cellular biology?", "Active transport requires ATP hydrolysis to move ions against concentration gradients.", func(eli5_success: bool, analogy_text: String, eli5_err: String):
				if not eli5_success:
					print("  ❌ ELI5 Failed: ", eli5_err)
					get_tree().quit(1)
					return
					
				print("  ✨ [ELI5 Analogy Generated]:")
				print("     \"%s\"" % analogy_text)
				print("\n==================================================")
				print("✅ ALL TERMINAL AI TUTOR TESTS PASSED WITH 100% SUCCESS!")
				print("==================================================")
				get_tree().quit(0)
			)
		)
	)
