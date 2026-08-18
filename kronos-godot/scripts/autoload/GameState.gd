extends Node
## Central GameState Singleton for Kronos.
## Manages pet stats (level, exp, coins, energy, joy), inventory, equipped cosmetics, and active rooms.

# ==============================================================================
# 🐾 CONSTANTS & LIMITS
# ==============================================================================
const MAX_ENERGY: float = 100.0
const MIN_ENERGY: float = 0.0
const MAX_JOY: float = 100.0
const MIN_JOY: float = 0.0
const ENERGY_BUFF_THRESHOLD: float = 70.0
const BASE_EXP_PER_LEVEL: int = 100

# Item Catalog reference for item effects & shop catalog
const ITEM_DEFINITIONS: Dictionary = {
	# Treats & Snacks
	"snack_coffee": {
		"id": "snack_coffee",
		"name": "Pixel Espresso",
		"icon": "☕",
		"category": "snack",
		"price": 40,
		"description": "Quick boost! Restores +25 Energy.",
		"energy_boost": 25.0,
		"joy_boost": 0.0,
		"exp_boost": 0
	},
	"snack_croissant": {
		"id": "snack_croissant",
		"name": "Butter Croissant",
		"icon": "🥐",
		"category": "snack",
		"price": 60,
		"description": "Crispy & warm! +35 Energy & +15 Joy.",
		"energy_boost": 35.0,
		"joy_boost": 15.0,
		"exp_boost": 0
	},
	"snack_matcha": {
		"id": "snack_matcha",
		"name": "Ceremonial Matcha",
		"icon": "🍵",
		"category": "snack",
		"price": 80,
		"description": "Zen state. +45 Energy & +25 Joy.",
		"energy_boost": 45.0,
		"joy_boost": 25.0,
		"exp_boost": 0
	},
	"snack_donut": {
		"id": "snack_donut",
		"name": "Star Donut",
		"icon": "🍩",
		"category": "snack",
		"price": 100,
		"description": "Sugary delight! +60 Joy & +20 Energy.",
		"energy_boost": 20.0,
		"joy_boost": 60.0,
		"exp_boost": 0
	},
	"snack_ramen": {
		"id": "snack_ramen",
		"name": "Midnight Ramen",
		"icon": "🍜",
		"category": "snack",
		"price": 150,
		"description": "Hearty broth! +75 Energy & +40 Joy.",
		"energy_boost": 75.0,
		"joy_boost": 40.0,
		"exp_boost": 0
	},
	"snack_bento": {
		"id": "snack_bento",
		"name": "Deluxe Bento",
		"icon": "🍱",
		"category": "snack",
		"price": 250,
		"description": "Feast of champions! Full restore + 25 bonus XP.",
		"energy_boost": 100.0,
		"joy_boost": 100.0,
		"exp_boost": 25
	},
	# Wearable Cosmetics
	"cosmetic_bow": {
		"id": "cosmetic_bow",
		"name": "Red Bowtie",
		"icon": "🎀",
		"category": "cosmetic",
		"slot": "neck",
		"price": 200,
		"description": "A charming red bow to wear proudly."
	},
	"cosmetic_shades": {
		"id": "cosmetic_shades",
		"name": "Cool Sunglasses",
		"icon": "🕶️",
		"category": "cosmetic",
		"slot": "face",
		"price": 350,
		"description": "Dark pixel shades for max swagger."
	},
	"cosmetic_crown": {
		"id": "cosmetic_crown",
		"name": "Golden Crown",
		"icon": "👑",
		"category": "cosmetic",
		"slot": "head",
		"price": 600,
		"description": "A glittering royal crown with jewels."
	},
	"cosmetic_wizard": {
		"id": "cosmetic_wizard",
		"name": "Wizard Hat",
		"icon": "🧙",
		"category": "cosmetic",
		"slot": "head",
		"price": 900,
		"description": "Pointed starry sorcerer hat of deep focus."
	},
	# Room Decor
	"decor_bonsai": {
		"id": "decor_bonsai",
		"name": "Mini Bonsai",
		"icon": "🪴",
		"category": "decor",
		"price": 300,
		"description": "Tranquil miniature tree for the bedroom."
	},
	"decor_boombox": {
		"id": "decor_boombox",
		"name": "Retro Boombox",
		"icon": "📻",
		"category": "decor",
		"price": 450,
		"description": "Old-school cassette beatbox for the lounge."
	},
	"decor_arcade": {
		"id": "decor_arcade",
		"name": "Arcade Cabinet",
		"icon": "🎮",
		"category": "decor",
		"price": 1200,
		"description": "Vintage pixel arcade machine for the library."
	}
}

# ==============================================================================
# 📊 STATE VARIABLES
# ==============================================================================
var pet_name: String = "Kronos"
var level: int = 1
var exp: int = 0
var coins: int = 100 # Starting wallet balance
var energy: float = 80.0
var joy: float = 80.0
var streak: int = 0
var equipped_cosmetic: String = "" # Active head/neck accessory
var equipped_cosmetics: Dictionary = {} # Multi-slot support: {"head": "cosmetic_crown", "neck": "cosmetic_bow"}
var active_view_room: String = "room_bedroom" # Default bedroom environment
var pet_room: String = "room_bedroom" # Where the pet companion is currently located
var active_room: String = "room_bedroom" # Backwards compatibility alias for active_view_room
var inventory: Array[Dictionary] = [] # Array of {"item_id": String, "quantity": int, "metadata": Dictionary}

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	# Initial notification
	_emit_all_stats()

# ==============================================================================
# ⚡ STAT MODIFIERS & HELPERS
# ==============================================================================
## Returns whether the pet has enough energy to qualify for the focus speed buff (+50% coin earning speed)
func is_energy_buffed() -> bool:
	return energy >= ENERGY_BUFF_THRESHOLD

## Returns the EXP required to reach the next level
func get_exp_required_for_level(target_level: int) -> int:
	return target_level * BASE_EXP_PER_LEVEL

## Adds coins with tracking and event emission
func add_coins(amount: int, reason: String = "") -> void:
	if amount <= 0:
		return
	coins += amount
	EventBus.coins_changed.emit(coins, amount, reason)

## Spends coins if balance is sufficient, returning true if successful
func spend_coins(amount: int, reason: String = "") -> bool:
	if amount <= 0:
		return true
	if coins < amount:
		return false
	coins -= amount
	EventBus.coins_changed.emit(coins, -amount, reason)
	return true

## Adds EXP and handles cascading level ups
func add_exp(amount: int) -> void:
	if amount <= 0:
		return
	exp += amount
	
	while true:
		var req_exp: int = get_exp_required_for_level(level)
		if exp >= req_exp:
			exp -= req_exp
			level += 1
			EventBus.level_up.emit(level)
		else:
			break
			
	var current_req: int = get_exp_required_for_level(level)
	EventBus.exp_changed.emit(exp, current_req, level)

## Sets pet energy clamped between 0 and 100
func set_energy(value: float) -> void:
	var old_buffed: bool = is_energy_buffed()
	energy = clampf(value, MIN_ENERGY, MAX_ENERGY)
	var new_buffed: bool = is_energy_buffed()
	EventBus.energy_changed.emit(energy, MAX_ENERGY, new_buffed)

## Adds energy (or removes if negative)
func add_energy(amount: float) -> void:
	set_energy(energy + amount)

## Sets pet joy clamped between 0 and 100
func set_joy(value: float) -> void:
	joy = clampf(value, MIN_JOY, MAX_JOY)
	EventBus.joy_changed.emit(joy, MAX_JOY)

## Adds joy (or removes if negative)
func add_joy(amount: float) -> void:
	set_joy(joy + amount)

## Sets focus streak
func set_streak(new_streak: int) -> void:
	streak = maxi(0, new_streak)
	EventBus.streak_changed.emit(streak)

## Increments focus streak
func increment_streak() -> void:
	set_streak(streak + 1)

## Resets focus streak (e.g. on manual skip)
func reset_streak() -> void:
	set_streak(0)

# ==============================================================================
# 🎒 INVENTORY MANAGEMENT
# ==============================================================================
## Adds an item to inventory or increases existing quantity
func add_item(item_id: String, quantity: int = 1, metadata: Dictionary = {}) -> void:
	if quantity <= 0:
		return
	
	var found: bool = false
	for item in inventory:
		if item.get("item_id", "") == item_id:
			var current_qty: int = item.get("quantity", 0)
			item["quantity"] = current_qty + quantity
			found = true
			break
			
	if not found:
		inventory.append({
			"item_id": item_id,
			"quantity": quantity,
			"metadata": metadata
		})
		
	EventBus.item_acquired.emit(item_id, quantity)
	EventBus.inventory_changed.emit(inventory)

## Removes an item from inventory
func remove_item(item_id: String, quantity: int = 1) -> bool:
	if quantity <= 0:
		return true
		
	for i in range(inventory.size() - 1, -1, -1):
		var item: Dictionary = inventory[i]
		if item.get("item_id", "") == item_id:
			var current_qty: int = item.get("quantity", 0)
			if current_qty > quantity:
				item["quantity"] = current_qty - quantity
				EventBus.item_removed.emit(item_id, quantity)
				EventBus.inventory_changed.emit(inventory)
				return true
			elif current_qty == quantity:
				inventory.remove_at(i)
				EventBus.item_removed.emit(item_id, quantity)
				EventBus.inventory_changed.emit(inventory)
				return true
			else:
				return false
	return false

## Checks if inventory has at least `quantity` of `item_id`
func has_item(item_id: String, quantity: int = 1) -> bool:
	for item in inventory:
		if item.get("item_id", "") == item_id:
			return item.get("quantity", 0) >= quantity
	return false

## Gets quantity of specific item
func get_item_count(item_id: String) -> int:
	for item in inventory:
		if item.get("item_id", "") == item_id:
			return item.get("quantity", 0)
	return 0

## Uses an item from inventory and applies stat bonuses
func use_item(item_id: String) -> bool:
	if not has_item(item_id, 1):
		return false
		
	var item_def: Dictionary = ITEM_DEFINITIONS.get(item_id, {})
	var energy_boost: float = item_def.get("energy_boost", 0.0)
	var joy_boost: float = item_def.get("joy_boost", 0.0)
	var exp_boost: int = item_def.get("exp_boost", 0)
	
	if remove_item(item_id, 1):
		if energy_boost > 0.0:
			add_energy(energy_boost)
		if joy_boost > 0.0:
			add_joy(joy_boost)
		if exp_boost > 0:
			add_exp(exp_boost)
			
		EventBus.item_used.emit(item_id, item_def)
		return true
		
	return false

# ==============================================================================
# 👗 COSMETICS & ROOMS
# ==============================================================================
## Equips a cosmetic item into a slot ("head", "neck", etc.)
func equip_cosmetic(slot: String, cosmetic_id: String) -> void:
	equipped_cosmetics[slot] = cosmetic_id
	equipped_cosmetic = cosmetic_id # For backward compatibility with single slot
	EventBus.cosmetic_equipped.emit(slot, cosmetic_id)

## Unequips cosmetic from slot
func unequip_cosmetic(slot: String) -> void:
	if equipped_cosmetics.has(slot):
		equipped_cosmetics.erase(slot)
	if equipped_cosmetic != "" and not equipped_cosmetics.values().has(equipped_cosmetic):
		equipped_cosmetic = ""
	EventBus.cosmetic_unequipped.emit(slot)

## Checks if a specific cosmetic item is equipped
func is_cosmetic_equipped(cosmetic_id: String) -> bool:
	if equipped_cosmetic == cosmetic_id:
		return true
	for s in equipped_cosmetics.keys():
		if equipped_cosmetics[s] == cosmetic_id:
			return true
	return false

## Returns item definition dict
func get_item_def(item_id: String) -> Dictionary:
	return ITEM_DEFINITIONS.get(item_id, {})

## Returns array of item definitions for category ("snack", "cosmetic", "decor")
func get_items_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for k in ITEM_DEFINITIONS.keys():
		var def: Dictionary = ITEM_DEFINITIONS[k]
		if def.get("category", "") == category:
			result.append(def)
	return result

## Sets active room / environment currently viewed by the user
func set_view_room(room_id: String) -> void:
	if active_view_room == room_id:
		return
	active_view_room = room_id
	active_room = room_id
	EventBus.room_changed.emit(active_view_room)

## Sets the room where the pet is currently located
func set_pet_room(room_id: String) -> void:
	if pet_room == room_id:
		return
	pet_room = room_id
	EventBus.pet_room_changed.emit(pet_room)

## Summons the pet to the user's current view room
func call_pet_to_view() -> void:
	pet_room = active_view_room
	EventBus.pet_room_changed.emit(pet_room)
	EventBus.pet_called.emit(active_view_room)

## Returns whether the pet is in the user's current view room
func is_pet_in_current_view() -> bool:
	return pet_room == active_view_room

## Returns whether the pet is in the current room (alias for is_pet_in_current_view)
func is_pet_in_current_room() -> bool:
	return is_pet_in_current_view()

## Backwards-compatibility alias for set_view_room
func set_room(room_id: String) -> void:
	set_view_room(room_id)

# ==============================================================================
# 💾 SERIALIZATION / DATA EXPORT
# ==============================================================================
## Exports complete game state to a Dictionary
func serialize() -> Dictionary:
	return {
		"pet_name": pet_name,
		"level": level,
		"exp": exp,
		"coins": coins,
		"energy": energy,
		"joy": joy,
		"streak": streak,
		"equipped_cosmetic": equipped_cosmetic,
		"equipped_cosmetics": equipped_cosmetics,
		"active_room": active_view_room,
		"active_view_room": active_view_room,
		"pet_room": pet_room,
		"inventory": inventory,
		"last_saved_unix": Time.get_unix_time_from_system()
	}

## Loads state from a Dictionary
func deserialize(data: Dictionary) -> void:
	pet_name = data.get("pet_name", "Kronos")
	level = data.get("level", 1)
	exp = data.get("exp", 0)
	coins = data.get("coins", 100)
	energy = data.get("energy", 80.0)
	joy = data.get("joy", 80.0)
	streak = data.get("streak", 0)
	equipped_cosmetic = data.get("equipped_cosmetic", "")
	equipped_cosmetics = data.get("equipped_cosmetics", {})
	active_view_room = data.get("active_view_room", data.get("active_room", "room_bedroom"))
	active_room = active_view_room
	pet_room = data.get("pet_room", "room_bedroom")
	
	var raw_inv = data.get("inventory", [])
	inventory.clear()
	if raw_inv is Array:
		for item in raw_inv:
			if item is Dictionary:
				inventory.append(item)
				
	_emit_all_stats()

func _emit_all_stats() -> void:
	EventBus.coins_changed.emit(coins, 0, "init")
	EventBus.exp_changed.emit(exp, get_exp_required_for_level(level), level)
	EventBus.energy_changed.emit(energy, MAX_ENERGY, is_energy_buffed())
	EventBus.joy_changed.emit(joy, MAX_JOY)
	EventBus.streak_changed.emit(streak)
	EventBus.inventory_changed.emit(inventory)
	EventBus.room_changed.emit(active_view_room)
	EventBus.pet_room_changed.emit(pet_room)
	EventBus.stats_updated.emit(serialize())
