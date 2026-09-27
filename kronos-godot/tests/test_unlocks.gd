extends Node

func _ready() -> void:
	print("=== VERIFYING KRONOS UNLOCKS ===")
	
	if DatabaseManager:
		DatabaseManager.load_game()
		
	if GameState:
		print("UNLOCKED_ROOMS:", GameState.unlocked_rooms)
		print("UNLOCKED_PETS:", GameState.unlocked_pets)
		print("COINS:", GameState.coins)
		print("LEVEL:", GameState.level)
		print("ACTIVE_PETS_COUNT:", GameState.active_pets.size())
		for i in range(GameState.active_pets.size()):
			var p = GameState.active_pets[i]
			print("  Pet #%d: %s (%s) in %s" % [i, p.get("name"), p.get("species"), p.get("room")])
			
		assert(GameState.unlocked_rooms.size() >= 5, "All 5 rooms should be unlocked!")
		assert(GameState.unlocked_pets.size() >= 8, "All 8 pets should be unlocked!")
		print(">>> ALL ASSERTIONS PASSED! ALL ROOMS & PETS UNLOCKED SUCCESSFUL! <<<")
		
	get_tree().quit(0)
