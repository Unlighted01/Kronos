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
	"snack_pancake": {
		"id": "snack_pancake",
		"name": "Souffle Pancakes",
		"icon": "🥞",
		"category": "snack",
		"price": 110,
		"description": "Fluffy stacks with maple syrup! +50 Energy & +50 Joy.",
		"energy_boost": 50.0,
		"joy_boost": 50.0,
		"exp_boost": 5
	},
	"snack_boba": {
		"id": "snack_boba",
		"name": "Brown Sugar Boba",
		"icon": "🧋",
		"category": "snack",
		"price": 120,
		"description": "Sweet iced milk tea! +40 Energy & +45 Joy.",
		"energy_boost": 40.0,
		"joy_boost": 45.0,
		"exp_boost": 5
	},
	"snack_onigiri": {
		"id": "snack_onigiri",
		"name": "Salmon Onigiri",
		"icon": "🍙",
		"category": "snack",
		"price": 130,
		"description": "Nori-wrapped rice ball! +55 Energy & +30 Joy.",
		"energy_boost": 55.0,
		"joy_boost": 30.0,
		"exp_boost": 8
	},
	"snack_ramen": {
		"id": "snack_ramen",
		"name": "Midnight Ramen",
		"icon": "🍜",
		"category": "snack",
		"price": 150,
		"description": "Hearty rich broth! +75 Energy & +40 Joy.",
		"energy_boost": 75.0,
		"joy_boost": 40.0,
		"exp_boost": 10
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
	# Head
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
	"cosmetic_beanie": {
		"id": "cosmetic_beanie",
		"name": "Slouch Beanie",
		"icon": "🧶",
		"category": "cosmetic",
		"slot": "head",
		"price": 280,
		"description": "Cozy knitted winter beanie for chilly focus sessions."
	},
	"cosmetic_chef": {
		"id": "cosmetic_chef",
		"name": "Toque Chef Hat",
		"icon": "👨‍🍳",
		"category": "cosmetic",
		"slot": "head",
		"price": 320,
		"description": "Crisp white baker hat for kitchen connoisseurs."
	},
	"cosmetic_cap": {
		"id": "cosmetic_cap",
		"name": "Baseball Cap",
		"icon": "🧢",
		"category": "cosmetic",
		"slot": "head",
		"price": 240,
		"description": "Retro backwards cap with vintage sporty flair."
	},
	# Face
	"cosmetic_shades": {
		"id": "cosmetic_shades",
		"name": "Cool Sunglasses",
		"icon": "🕶️",
		"category": "cosmetic",
		"slot": "face",
		"price": 350,
		"description": "Dark pixel shades for max swagger."
	},
	"cosmetic_glasses": {
		"id": "cosmetic_glasses",
		"name": "Round Glasses",
		"icon": "👓",
		"category": "cosmetic",
		"slot": "face",
		"price": 220,
		"description": "Cute circular wireframe spectacles for deep study."
	},
	"cosmetic_monocle": {
		"id": "cosmetic_monocle",
		"name": "Brass Monocle",
		"icon": "🧐",
		"category": "cosmetic",
		"slot": "face",
		"price": 400,
		"description": "Distinguished single lens with golden chain."
	},
	# Neck
	"cosmetic_bow": {
		"id": "cosmetic_bow",
		"name": "Red Bowtie",
		"icon": "🎀",
		"category": "cosmetic",
		"slot": "neck",
		"price": 200,
		"description": "A charming red bow to wear proudly."
	},
	"cosmetic_scarf": {
		"id": "cosmetic_scarf",
		"name": "Plaid Scarf",
		"icon": "🧣",
		"category": "cosmetic",
		"slot": "neck",
		"price": 300,
		"description": "Warm flannel tartan scarf wrapped cozily."
	},
	"cosmetic_bell": {
		"id": "cosmetic_bell",
		"name": "Bell Collar",
		"icon": "🔔",
		"category": "cosmetic",
		"slot": "neck",
		"price": 250,
		"description": "Silken red collar with jingling golden bell."
	},
	# Room Decor
	# Bedroom Decor
	"decor_bonsai": {
		"id": "decor_bonsai",
		"name": "Mini Bonsai",
		"icon": "🪴",
		"category": "decor",
		"target_room": "room_bedroom",
		"target_room_name": "Temple of Morpheus",
		"price": 300,
		"description": "Tranquil miniature pine bonsai on the desk shelf."
	},
	"decor_lava_lamp": {
		"id": "decor_lava_lamp",
		"name": "Lava Lamp",
		"icon": "🏮",
		"category": "decor",
		"target_room": "room_bedroom",
		"target_room_name": "Temple of Morpheus",
		"price": 400,
		"description": "Mesmerizing glowing lava lamp on the nightstand."
	},
	# Living Room Decor
	"decor_boombox": {
		"id": "decor_boombox",
		"name": "Retro Boombox",
		"icon": "📻",
		"category": "decor",
		"target_room": "room_livingroom",
		"target_room_name": "Hearth of Hestia",
		"price": 450,
		"description": "Old-school cassette beatbox on the lounge credenza."
	},
	"decor_record_stack": {
		"id": "decor_record_stack",
		"name": "Vinyl Stack",
		"icon": "🎶",
		"category": "decor",
		"target_room": "room_livingroom",
		"target_room_name": "Hearth of Hestia",
		"price": 350,
		"description": "Color-coded vintage vinyl albums stacked beside turntable."
	},
	# Library Decor
	"decor_arcade": {
		"id": "decor_arcade",
		"name": "Arcade Cabinet",
		"icon": "🎮",
		"category": "decor",
		"target_room": "room_library",
		"target_room_name": "Tower of Urania",
		"price": 1200,
		"description": "Vintage tabletop pixel arcade cabinet with glowing demo screen."
	},
	"decor_telescope": {
		"id": "decor_telescope",
		"name": "Brass Telescope",
		"icon": "🔭",
		"category": "decor",
		"target_room": "room_library",
		"target_room_name": "Tower of Urania",
		"price": 500,
		"description": "Antique brass stargazing telescope pointed out the rafter window."
	},
	# Kitchen Decor
	"decor_spice_rack": {
		"id": "decor_spice_rack",
		"name": "Artisan Spice Rack",
		"icon": "🧂",
		"category": "decor",
		"target_room": "room_kitchen",
		"target_room_name": "Banks of the Styx",
		"price": 380,
		"description": "Handcrafted wooden spice rack with glass herb jars."
	},
	"decor_pastry_dome": {
		"id": "decor_pastry_dome",
		"name": "Glass Pastry Cloche",
		"icon": "🧁",
		"category": "decor",
		"target_room": "room_kitchen",
		"target_room_name": "Banks of the Styx",
		"price": 420,
		"description": "Elegant glass display cloche with blueberry muffins."
	},
	# Greenhouse Decor
	"decor_terrarium": {
		"id": "decor_terrarium",
		"name": "Glass Terrarium",
		"icon": "🌿",
		"category": "decor",
		"target_room": "room_greenhouse",
		"target_room_name": "Elysian Fields",
		"price": 450,
		"description": "Geometric brass & crystal terrarium housing rare moss."
	},
	"decor_fairy_lantern": {
		"id": "decor_fairy_lantern",
		"name": "Solar Fairy Lamp",
		"icon": "💡",
		"category": "decor",
		"target_room": "room_greenhouse",
		"target_room_name": "Conservatory",
		"price": 360,
		"description": "Hanging blown-glass lantern casting fairy light motes."
	},
	# Rooms / Real Estate
	"room_bedroom": {
		"id": "room_bedroom",
		"name": "Temple of Morpheus",
		"icon": "🌙",
		"category": "room",
		"price": 0,
		"unlock_level": 1,
		"description": "The sanctuary of sleep, featuring the Font of Lethe and the Hourglass Altar."
	},
	"room_livingroom": {
		"id": "room_livingroom",
		"name": "Hearth of Hestia",
		"icon": "🔥",
		"category": "room",
		"price": 250,
		"unlock_level": 2,
		"description": "A sacred marble hearth with a roaring fire pit and ancient study desk."
	},
	"room_library": {
		"id": "room_library",
		"name": "Tower of Urania",
		"icon": "🔭",
		"category": "room",
		"price": 500,
		"unlock_level": 4,
		"description": "An astronomical observatory overlooking the endless cosmos."
	},
	"room_kitchen": {
		"id": "room_kitchen",
		"name": "Banks of the Styx",
		"icon": "🛶",
		"category": "room",
		"price": 750,
		"unlock_level": 6,
		"description": "The gloomy underworld dock featuring Asphodel meadows and a spectral forge."
	},
	"room_greenhouse": {
		"id": "room_greenhouse",
		"name": "Elysian Fields",
		"icon": "🌾",
		"category": "room",
		"price": 1000,
		"unlock_level": 8,
		"description": "Endless golden wheat fields under a sunset sky of the Golden Age."
	},
	# Adoptable Pets
	"pet_shiba": {
		"id": "pet_shiba",
		"name": "Loyal Shiba",
		"default_name": "Kronos",
		"icon": "🐕",
		"category": "pet",
		"species": "shiba",
		"price": 0,
		"unlock_level": 1,
		"description": "The original loyal companion! Fluffy curled tail, energetic typing, and warm smiles."
	},
	"pet_cat": {
		"id": "pet_cat",
		"name": "Calico Cat",
		"default_name": "Mochi",
		"icon": "🐱",
		"category": "pet",
		"species": "cat",
		"price": 300,
		"unlock_level": 2,
		"description": "Cozy sleepy kitty with cute twitchy ears, box naps, and coffee sips."
	},
	"pet_bunny": {
		"id": "pet_bunny",
		"name": "Fluffy Bunny",
		"default_name": "Boba",
		"icon": "🐰",
		"category": "pet",
		"species": "bunny",
		"price": 600,
		"unlock_level": 4,
		"description": "Snowy white rabbit with floppy ears, hopping walk, and carrot snacks."
	},
	"pet_penguin": {
		"id": "pet_penguin",
		"name": "Chubby Penguin",
		"default_name": "Pippin",
		"icon": "🐧",
		"category": "pet",
		"species": "penguin",
		"price": 900,
		"unlock_level": 6,
		"description": "Adorably round tuxedo penguin in a red scarf with a cute waddle."
	},
	"pet_fox": {
		"id": "pet_fox",
		"name": "Red Fox",
		"default_name": "Kitsune",
		"icon": "🦊",
		"category": "pet",
		"species": "fox",
		"price": 1200,
		"unlock_level": 8,
		"description": "Vibrant amber fox with a huge fluffy brush tail and curious leaps."
	}
}

# ==============================================================================
# 📊 STATE VARIABLES
# ==============================================================================
var pet_name: String = "Kronos"
var pet_species: String = "shiba"
var level: int = 1
var exp: int = 0
var coins: int = 0
var knowledge_points: int = 0
var energy: float = 80.0
var joy: float = 80.0
var streak: int = 0
var equipped_cosmetic: String = "" # Active head/neck accessory
var equipped_cosmetics: Dictionary = {} # Multi-slot support: {"head": "cosmetic_crown", "face": "cosmetic_shades", "neck": "cosmetic_bow"}
var active_view_room: String = "room_bedroom" # Default bedroom environment
var pet_room: String = "room_bedroom" # Where the main pet is located
var active_room: String = "room_bedroom" # Backwards compatibility alias for active_view_room
var inventory: Array[Dictionary] = [] # Array of {"item_id": String, "quantity": int, "metadata": Dictionary}
var placed_decor: Dictionary = {} # {"decor_bonsai": true, "decor_boombox": true}

# Unlocked Progression Real Estate & Household Pets
var unlocked_rooms: Array[String] = ["room_bedroom"]
var unlocked_pets: Array[String] = ["pet_shiba"]
var active_pets: Array[Dictionary] = [
	{"id": "pet_shiba", "name": "Kronos", "species": "shiba", "room": "room_bedroom"}
]

# House Lighting & Interactive Object States
var room_lights: Dictionary = {
	"room_bedroom": false,
	"room_livingroom": false,
	"room_library": false,
	"room_kitchen": false,
	"room_greenhouse": false
}

var object_states: Dictionary = {
	"bedroom_bed_open": false,
	"bedroom_window_open": false
}

# Audio & Notification Preferences
var audio_settings: Dictionary = {
	"master_volume": 0.8,
	"ambience_volume": 0.5,
	"sfx_volume": 0.7,
	"is_muted": false,
	"ambience_enabled": true,
	"timer_notifs_enabled": true,
	"pet_nudges_enabled": true
}

# Passive presence accumulator
var _passive_presence_accumulator: float = 0.0

# Micro-Tasks & Daily Quests State
var tasks: Array[Dictionary] = []
var active_task_id: String = ""
var daily_quests: Array[Dictionary] = []
var quest_generation_date: String = ""

const QUEST_TEMPLATES: Array[Dictionary] = [
	{
		"id": "quest_focus",
		"title": "Focus Master",
		"description": "Complete 2 Focus Sprints",
		"icon": "⏱️",
		"target_type": "focus_session",
		"target_count": 2,
		"reward_coins": 150,
		"reward_exp": 50
	},
	{
		"id": "quest_snack",
		"title": "Pet Nutritionist",
		"description": "Feed Shiba 1 snack treat",
		"icon": "🥐",
		"target_type": "feed_snack",
		"target_count": 1,
		"reward_coins": 100,
		"reward_exp": 40
	},
	{
		"id": "quest_explore",
		"title": "House Explorer",
		"description": "Visit 3 different rooms",
		"icon": "🚪",
		"target_type": "room_change",
		"target_count": 3,
		"reward_coins": 80,
		"reward_exp": 30
	},
	{
		"id": "quest_cuddle",
		"title": "Affectionate Bond",
		"description": "Pet your companion 5 times",
		"icon": "💖",
		"target_type": "pet_cuddle",
		"target_count": 5,
		"reward_coins": 120,
		"reward_exp": 45
	}
]

var _last_checked_hour: int = -1
var _midnight_check_accumulator: float = 0.0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	randomize()
	_last_checked_hour = Time.get_time_dict_from_system().get("hour", 12)
	check_and_generate_daily_quests()
	_connect_quest_listeners()
	_emit_all_stats()

func _process(delta: float) -> void:
	_check_morning_light_shutoff()
	_check_midnight_rollover(delta)
	
	# Generous Passive Presence EXP (+1 EXP / 15s) and Coins (+1 Coin / 30s)
	_passive_presence_accumulator += delta
	if _passive_presence_accumulator >= 15.0:
		_passive_presence_accumulator = 0.0
		add_exp(1)
		# Add 1 passive coin every 30s
		if int(Time.get_unix_time_from_system()) % 30 == 0:
			add_coins(1, "passive_presence")

## Automatically checks at midnight if the calendar day rolled over
func _check_midnight_rollover(delta: float) -> void:
	_midnight_check_accumulator += delta
	if _midnight_check_accumulator >= 15.0:
		_midnight_check_accumulator = 0.0
		var today_str: String = Time.get_date_string_from_system()
		if quest_generation_date != "" and quest_generation_date != today_str:
			check_and_generate_daily_quests()

## Automatically shuts off all house lights when real-world time crosses into morning (06:00)
func _check_morning_light_shutoff() -> void:
	var cur_hour: int = Time.get_time_dict_from_system().get("hour", 12)
	if cur_hour == 6 and _last_checked_hour != 6:
		for r_id in room_lights.keys():
			if room_lights[r_id]:
				room_lights[r_id] = false
				EventBus.room_light_toggled.emit(r_id, false)
	_last_checked_hour = cur_hour

# ==============================================================================
# 🏠 ROOM REAL ESTATE & MULTI-PET HOUSEHOLD API
# ==============================================================================
## Maximum allowed pets roaming in the household based on player Level
func get_max_pet_slots() -> int:
	if level >= 10: return 5
	if level >= 7: return 4
	if level >= 5: return 3
	if level >= 3: return 2
	return 1

func is_room_unlocked(r_id: String) -> bool:
	if r_id == "room_bedroom":
		return true
	return unlocked_rooms.has(r_id)

func buy_room(r_id: String) -> bool:
	if is_room_unlocked(r_id):
		return false
	var def = ITEM_DEFINITIONS.get(r_id, null)
	if not def:
		return false
	var price: int = int(def.get("price", 0))
	var req_lvl: int = int(def.get("unlock_level", 1))
	if level < req_lvl or coins < price:
		return false
		
	coins -= price
	unlocked_rooms.append(r_id)
	EventBus.coins_changed.emit(coins, -price, "room_unlock")
	EventBus.room_unlocked.emit(r_id)
	if AudioManager:
		AudioManager.play_sfx("chime")
	if DatabaseManager:
		DatabaseManager.save_game()
	return true

func is_pet_unlocked(p_id: String) -> bool:
	if p_id == "pet_shiba":
		return true
	return unlocked_pets.has(p_id)

func adopt_pet(p_id: String, as_household: bool, custom_name: String = "") -> bool:
	var def = ITEM_DEFINITIONS.get(p_id, null)
	if not def:
		return false
	var price: int = int(def.get("price", 0))
	# If already unlocked, it's free to switch or add!
	if unlocked_pets.has(p_id):
		price = 0
		
	var req_lvl: int = int(def.get("unlock_level", 1))
	if level < req_lvl or coins < price:
		return false
		
	coins -= price
	if not unlocked_pets.has(p_id):
		unlocked_pets.append(p_id)
		
	var final_name: String = custom_name if custom_name != "" else def.get("default_name", "Companion")
	var spec: String = def.get("species", "shiba")
	var p_data: Dictionary = {
		"id": p_id,
		"name": final_name,
		"species": spec,
		"room": active_view_room
	}
	
	if as_household and active_pets.size() < get_max_pet_slots():
		active_pets.append(p_data)
	else:
		# Replace main companion
		pet_species = spec
		pet_name = final_name
		if not active_pets.is_empty():
			active_pets[0] = p_data
		else:
			active_pets.append(p_data)
			
	EventBus.coins_changed.emit(coins, -price, "pet_adoption")
	EventBus.pet_adopted.emit(p_data, as_household)
	EventBus.pet_list_changed.emit(active_pets)
	
	# Trigger celebratory delivery box in room!
	EventBus.pet_delivery_box_spawned.emit(p_data, Vector2(120.0, 115.0))
	
	if DatabaseManager:
		DatabaseManager.save_game()
	return true

func remove_pet(p_id: String) -> bool:
	if active_pets.size() <= 1:
		return false # Cannot remove last pet
		
	var removed = false
	for i in range(active_pets.size()):
		if active_pets[i].get("id", "") == p_id:
			active_pets.remove_at(i)
			removed = true
			break
			
	if removed:
		# Update legacy main companion reference if we removed the first pet
		pet_species = active_pets[0].get("species", "shiba")
		pet_name = active_pets[0].get("name", "Companion")
		
		EventBus.pet_list_changed.emit(active_pets)
		if DatabaseManager:
			DatabaseManager.save_game()
			
	return removed

func reset_to_clean_slate() -> void:
	coins = 0
	level = 1
	exp = 0
	energy = 80.0
	joy = 80.0
	streak = 0
	pet_name = "Kronos"
	pet_species = "shiba"
	active_view_room = "room_bedroom"
	pet_room = "room_bedroom"
	unlocked_rooms = ["room_bedroom"]
	unlocked_pets = ["pet_shiba"]
	active_pets = [
		{"id": "pet_shiba", "name": "Kronos", "species": "shiba", "room": "room_bedroom"}
	]
	inventory.clear()
	placed_decor.clear()
	check_and_generate_daily_quests()
	_emit_all_stats()
	EventBus.pet_list_changed.emit(active_pets)
	EventBus.room_changed.emit(active_view_room)
	if DatabaseManager:
		DatabaseManager.save_game()

# ==============================================================================
# 💡 HOUSE LIGHTING & OBJECT INTERACTION API
# ==============================================================================
## Toggles the light state of a specific room, emitting room_light_toggled
func toggle_room_light(room_id: String) -> bool:
	var next_state: bool = not room_lights.get(room_id, false)
	room_lights[room_id] = next_state
	EventBus.room_light_toggled.emit(room_id, next_state)
	return next_state

## Returns whether the light switch in a room is currently ON
func is_room_light_on(room_id: String) -> bool:
	return room_lights.get(room_id, false)

## Sets the state of an interactive room object
func set_object_state(object_id: String, state_value: Variant) -> void:
	object_states[object_id] = state_value
	EventBus.object_state_changed.emit(object_id, state_value)

## Returns the current state of an interactive room object
func get_object_state(object_id: String, default_value: Variant = false) -> Variant:
	return object_states.get(object_id, default_value)

# ==============================================================================
# 📈 PROGRESSION, STATS & EXPERIENCE
# ==============================================================================
## Calculates the required EXP to reach the next level
func get_exp_required_for_level(lvl: int) -> int:
	return BASE_EXP_PER_LEVEL * lvl

## Adds coins to balance
func add_coins(amount: int, reason: String = "generic") -> void:
	if amount == 0:
		return
	coins = maxi(0, coins + amount)
	EventBus.coins_changed.emit(coins, amount, reason)

## Adds Knowledge Points (KP) from flashcards / active recall
func add_knowledge_points(amount: int, reason: String = "active_recall") -> void:
	if amount == 0:
		return
	knowledge_points = maxi(0, knowledge_points + amount)
	EventBus.knowledge_points_changed.emit(knowledge_points, amount, reason)

## Spends coins if sufficient balance exists
func spend_coins(amount: int, reason: String = "generic") -> bool:
	if amount <= 0:
		return true
	if coins < amount:
		return false
	coins -= amount
	EventBus.coins_changed.emit(coins, -amount, reason)
	return true

## Adds EXP and handles cascading level ups and pet slot unlocks
func add_exp(amount: int) -> void:
	if amount <= 0:
		return
	exp += amount
	
	var old_slots: int = get_max_pet_slots()
	while true:
		var req_exp: int = get_exp_required_for_level(level)
		if exp >= req_exp:
			exp -= req_exp
			level += 1
			EventBus.level_up.emit(level)
			var new_slots: int = get_max_pet_slots()
			if new_slots > old_slots:
				old_slots = new_slots
				EventBus.max_pets_changed.emit(new_slots)
		else:
			break
			
	var current_req: int = get_exp_required_for_level(level)
	EventBus.exp_changed.emit(exp, current_req, level)

## Returns the current real-world season ("spring", "summer", "autumn", "winter")
func get_current_season() -> String:
	var month: int = Time.get_date_dict_from_system().get("month", 8)
	if month >= 3 and month <= 5:
		return "spring"
	elif month >= 6 and month <= 8:
		return "summer"
	elif month >= 9 and month <= 11:
		return "autumn"
	else:
		return "winter"

## Returns whether the pet has enough energy to qualify for the focus speed buff (+50% coin earning speed)
func is_energy_buffed() -> bool:
	return energy >= ENERGY_BUFF_THRESHOLD

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
	if DatabaseManager:
		DatabaseManager.save_game()
	EventBus.room_changed.emit(active_view_room)

## Sets the room where the pet is currently located
func set_pet_room(room_id: String) -> void:
	if pet_room == room_id:
		return
	pet_room = room_id
	EventBus.pet_room_changed.emit(pet_room)

## Summons ALL pets to the user's current view room
func call_pet_to_view() -> void:
	pet_room = active_view_room
	# Bring every companion back to the current view room
	for p in active_pets:
		p["room"] = active_view_room
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
# 🪴 ROOM DECORATION MANAGEMENT
# ==============================================================================
## Places a decor item in its designated room
func place_decor(item_id: String) -> bool:
	if not has_item(item_id, 1):
		return false
	var def: Dictionary = ITEM_DEFINITIONS.get(item_id, {})
	var target_r: String = def.get("target_room", "")
	placed_decor[item_id] = true
	EventBus.decor_placed.emit(item_id, target_r, true)
	return true

## Removes/stows a placed decor item
func remove_decor(item_id: String) -> bool:
	if placed_decor.has(item_id):
		placed_decor.erase(item_id)
		var def: Dictionary = ITEM_DEFINITIONS.get(item_id, {})
		var target_r: String = def.get("target_room", "")
		EventBus.decor_placed.emit(item_id, target_r, false)
		return true
	return false

## Toggles placed state of decor item
func toggle_decor(item_id: String) -> bool:
	if is_decor_placed(item_id):
		remove_decor(item_id)
		return false
	else:
		place_decor(item_id)
		return true

## Checks if a decor item is currently placed in its room
func is_decor_placed(item_id: String) -> bool:
	return placed_decor.get(item_id, false)

## Returns array of placed decor item IDs for a specific room
func get_placed_decor_for_room(room_id: String) -> Array[String]:
	var result: Array[String] = []
	for item_id in placed_decor.keys():
		if placed_decor.get(item_id, false):
			var def: Dictionary = ITEM_DEFINITIONS.get(item_id, {})
			if def.get("target_room", "") == room_id:
				result.append(item_id)
	return result

# ==============================================================================
# 📋 MICRO-TASKS API
# ==============================================================================
## Adds a new micro-task
func add_task(title: String) -> Dictionary:
	var clean_t: String = title.strip_edges()
	if clean_t.is_empty():
		return {}
		
	var task: Dictionary = {
		"id": "task_%d_%d" % [int(Time.get_unix_time_from_system()), randi() % 1000],
		"title": clean_t,
		"completed": false,
		"created_at": Time.get_unix_time_from_system(),
		"completed_at": 0
	}
	
	tasks.append(task)
	if active_task_id.is_empty():
		set_active_task(task["id"])
		
	EventBus.task_added.emit(task)
	if DatabaseManager:
		DatabaseManager.save_game()
	return task

## Toggles a task completion state
func toggle_task(task_id: String) -> bool:
	for t in tasks:
		if t.get("id", "") == task_id:
			var next_state: bool = not t.get("completed", false)
			t["completed"] = next_state
			t["completed_at"] = Time.get_unix_time_from_system() if next_state else 0
			EventBus.task_toggled.emit(task_id, next_state)
			if DatabaseManager:
				DatabaseManager.save_game()
			return next_state
	return false

## Deletes a task
func delete_task(task_id: String) -> bool:
	for i in range(tasks.size()):
		if tasks[i].get("id", "") == task_id:
			tasks.remove_at(i)
			if active_task_id == task_id:
				active_task_id = tasks[0]["id"] if tasks.size() > 0 else ""
				var new_title = get_active_task_title()
				EventBus.active_task_selected.emit(active_task_id, new_title)
			EventBus.task_deleted.emit(task_id)
			if DatabaseManager:
				DatabaseManager.save_game()
			return true
	return false

## Sets the active focus task
func set_active_task(task_id: String) -> void:
	active_task_id = task_id
	var title: String = get_active_task_title()
	EventBus.active_task_selected.emit(active_task_id, title)
	if TimerEngine:
		TimerEngine.active_task_name = title
	if DatabaseManager:
		DatabaseManager.save_game()

## Gets the active task Dictionary
func get_active_task() -> Dictionary:
	for t in tasks:
		if t.get("id", "") == active_task_id:
			return t
	return {}

## Gets the active task title string
func get_active_task_title() -> String:
	var t = get_active_task()
	return t.get("title", "General Deep Work") if not t.is_empty() else "General Deep Work"

# ==============================================================================
# 📜 DAILY PET QUESTS API
# ==============================================================================
## Checks date and generates fresh daily quests ONLY when crossing midnight (00:00) into a new calendar day
func check_and_generate_daily_quests() -> void:
	var today_str: String = Time.get_date_string_from_system()
	
	# If quests already exist for today's date, do NOT reset them!
	if quest_generation_date == today_str and not daily_quests.is_empty():
		return
		
	quest_generation_date = today_str
	daily_quests.clear()
	
	for tpl in QUEST_TEMPLATES:
		var q: Dictionary = {
			"id": tpl["id"],
			"title": tpl["title"],
			"description": tpl["description"],
			"icon": tpl["icon"],
			"target_type": tpl["target_type"],
			"target_count": tpl["target_count"],
			"current_count": 0,
			"reward_coins": tpl["reward_coins"],
			"reward_exp": tpl["reward_exp"],
			"claimed": false
		}
		daily_quests.append(q)
		
	EventBus.quests_updated.emit()
	if DatabaseManager:
		DatabaseManager.save_game()

## Advances progress for any active quest matching the target_type
func progress_quest(target_type: String, amount: int = 1) -> void:
	var changed: bool = false
	for q in daily_quests:
		if q.get("target_type", "") == target_type and not q.get("claimed", false):
			var cur: int = int(q.get("current_count", 0))
			var target: int = int(q.get("target_count", 1))
			if cur < target:
				q["current_count"] = mini(target, cur + amount)
				changed = true
				
	if changed:
		EventBus.quests_updated.emit()
		if DatabaseManager:
			DatabaseManager.save_game()

## Claims a completed quest reward
func claim_quest(quest_id: String) -> bool:
	for q in daily_quests:
		if q.get("id", "") == quest_id:
			var cur: int = int(q.get("current_count", 0))
			var target: int = int(q.get("target_count", 1))
			var claimed: bool = q.get("claimed", false)
			if cur >= target and not claimed:
				q["claimed"] = true
				var reward_coins: int = int(q.get("reward_coins", 100))
				var reward_exp: int = int(q.get("reward_exp", 50))
				add_coins(reward_coins, "quest_reward")
				add_exp(reward_exp)
				EventBus.quest_claimed.emit(quest_id, reward_coins, reward_exp)
				EventBus.quests_updated.emit()
				if AudioManager:
					AudioManager.play_sfx("coin")
				if DatabaseManager:
					DatabaseManager.save_game()
				return true
	return false

func _connect_quest_listeners() -> void:
	EventBus.session_completed.connect(func(type, _c, _x, _s): 
		if type == "work": 
			progress_quest("focus_session")
	)
	EventBus.item_used.connect(func(_id, data): 
		if data.get("category", "") == "snack": 
			progress_quest("feed_snack")
	)
	EventBus.room_changed.connect(func(_r): 
		progress_quest("room_change")
	)
	EventBus.pet_interacted.connect(func(t): 
		if t == "pet" or t == "cuddle": 
			progress_quest("pet_cuddle")
	)

# ==============================================================================
# 💾 SERIALIZATION / DATA EXPORT
# ==============================================================================
## Exports complete game state to a Dictionary
func serialize() -> Dictionary:
	return {
		"pet_name": pet_name,
		"pet_species": pet_species,
		"level": level,
		"exp": exp,
		"coins": coins,
		"knowledge_points": knowledge_points,
		"energy": energy,
		"joy": joy,
		"streak": streak,
		"unlocked_rooms": unlocked_rooms,
		"unlocked_pets": unlocked_pets,
		"active_pets": active_pets,
		"equipped_cosmetic": equipped_cosmetic,
		"equipped_cosmetics": equipped_cosmetics,
		"active_room": active_view_room,
		"active_view_room": active_view_room,
		"pet_room": pet_room,
		"inventory": inventory,
		"placed_decor": placed_decor,
		"room_lights": room_lights,
		"object_states": object_states,
		"audio_settings": audio_settings,
		"tasks": tasks,
		"active_task_id": active_task_id,
		"daily_quests": daily_quests,
		"quest_generation_date": quest_generation_date,
		"last_saved_unix": Time.get_unix_time_from_system()
	}

## Loads state from a Dictionary
func deserialize(data: Dictionary) -> void:
	pet_name = data.get("pet_name", "Kronos")
	pet_species = data.get("pet_species", "shiba")
	level = data.get("level", 10)
	exp = data.get("exp", 0)
	coins = data.get("coins", 9999)
	knowledge_points = data.get("knowledge_points", 0)
	energy = data.get("energy", 80.0)
	joy = data.get("joy", 80.0)
	streak = data.get("streak", 0)
	
	var raw_rooms = data.get("unlocked_rooms", ["room_bedroom"])
	unlocked_rooms.clear()
	if raw_rooms is Array:
		for r in raw_rooms:
			unlocked_rooms.append(str(r))
	if not unlocked_rooms.has("room_bedroom"):
		unlocked_rooms.append("room_bedroom")
		
	var raw_pets = data.get("unlocked_pets", ["pet_shiba"])
	unlocked_pets.clear()
	if raw_pets is Array:
		for p in raw_pets:
			unlocked_pets.append(str(p))
	if not unlocked_pets.has("pet_shiba"):
		unlocked_pets.append("pet_shiba")
		
	var raw_active_pets = data.get("active_pets", [])
	active_pets.clear()
	if raw_active_pets is Array and raw_active_pets.size() > 0:
		for ap in raw_active_pets:
			if ap is Dictionary:
				active_pets.append(ap)
	else:
		active_pets.append({"id": "pet_shiba", "name": pet_name, "species": pet_species, "room": "room_bedroom"})
		
	equipped_cosmetic = data.get("equipped_cosmetic", "")
	equipped_cosmetics = data.get("equipped_cosmetics", {})
	active_view_room = data.get("active_view_room", data.get("active_room", "room_bedroom"))
	active_room = active_view_room
	pet_room = data.get("pet_room", "room_bedroom")
	
	var raw_decor = data.get("placed_decor", {})
	placed_decor.clear()
	if raw_decor is Dictionary:
		for k in raw_decor.keys():
			placed_decor[k] = raw_decor[k]
	
	var raw_lights = data.get("room_lights", {})
	if raw_lights is Dictionary:
		for k in raw_lights.keys():
			room_lights[k] = raw_lights[k]
			
	var raw_objs = data.get("object_states", {})
	if raw_objs is Dictionary:
		for k in raw_objs.keys():
			object_states[k] = raw_objs[k]
			
	var raw_audio = data.get("audio_settings", {})
	if raw_audio is Dictionary:
		for k in raw_audio.keys():
			audio_settings[k] = raw_audio[k]
	
	var raw_inv = data.get("inventory", [])
	inventory.clear()
	if raw_inv is Array:
		for item in raw_inv:
			if item is Dictionary:
				inventory.append(item)
				
	var raw_tasks = data.get("tasks", [])
	tasks.clear()
	if raw_tasks is Array:
		for t in raw_tasks:
			if t is Dictionary:
				tasks.append(t)
	active_task_id = data.get("active_task_id", "")
	if active_task_id.is_empty() and tasks.size() > 0:
		active_task_id = tasks[0].get("id", "")
		
	var raw_quests = data.get("daily_quests", [])
	daily_quests.clear()
	if raw_quests is Array:
		for q in raw_quests:
			if q is Dictionary:
				daily_quests.append(q)
	quest_generation_date = data.get("quest_generation_date", "")
	check_and_generate_daily_quests()
				
	_emit_all_stats()
	EventBus.pet_list_changed.emit(active_pets)

## Sets an individual audio setting and applies volume changes
func set_audio_setting(key: String, val: Variant) -> void:
	audio_settings[key] = val
	EventBus.audio_settings_changed.emit()
	if has_node("/root/AudioManager"):
		var am = get_node("/root/AudioManager")
		if am and am.has_method("update_volumes"):
			am.update_volumes()
	if DatabaseManager:
		DatabaseManager.save_game()

func _emit_all_stats() -> void:
	EventBus.coins_changed.emit(coins, 0, "init")
	EventBus.exp_changed.emit(exp, get_exp_required_for_level(level), level)
	EventBus.energy_changed.emit(energy, MAX_ENERGY, is_energy_buffed())
	EventBus.joy_changed.emit(joy, MAX_JOY)
	EventBus.streak_changed.emit(streak)
	EventBus.inventory_changed.emit(inventory)
	EventBus.room_changed.emit(active_view_room)
	EventBus.pet_room_changed.emit(pet_room)
	EventBus.quests_updated.emit()
	EventBus.stats_updated.emit(serialize())
