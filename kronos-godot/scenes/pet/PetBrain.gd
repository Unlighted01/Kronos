extends CharacterBody2D
class_name PetBrain

## Autonomous Pet AI & State Machine for Kronos.
## Controls the Shiba Inu companion physics, elevation hopping onto furniture (Beds, Sofas, Chairs),
## autonomous room wandering, context-aware prop interactions, and instant response to user clicks.

enum State {
	IDLE,
	WANDER,
	WALK_TO_TARGET,
	TYPE,
	DRINK,
	NAP,
	PETTED,
	VICTORY,
	WATCH_TV,
	WARM_PAWS,
	STUDY,
	WINDOW_GAZE,
	TUCKED_IN,
	CHEF_SNIFF,
	EXITING_ROOM,
	PLAY,
	SPECIAL_INTERACTION,
	SOCIALIZING,
	FOLLOWING,
	FETCHING,
	DEPARTING_OUTSIDE,
	EATING,
	ASK_FOOD,
	HANGRY
}

# ==============================================================================
# 🏠 HOUSE TOPOLOGY — DISABLED (Domains don't use doors)
# ==============================================================================
# const HOUSE_TOPOLOGY: Dictionary = {
# 	"room_bedroom": ["room_livingroom"],
# 	"room_livingroom": ["room_bedroom", "room_library", "room_kitchen"],
# 	"room_library": ["room_livingroom"],
# 	"room_kitchen": ["room_livingroom", "room_greenhouse"],
# 	"room_greenhouse": ["room_kitchen"]
# }
# const ROOM_EXITS: Dictionary = {
# 	"room_bedroom": { "room_livingroom": 224.0 },
# 	"room_livingroom": { "room_bedroom": 16.0, "room_library": 92.0, "room_kitchen": 226.0 },
# 	"room_library": { "room_livingroom": 118.0 },
# 	"room_kitchen": { "room_livingroom": 16.0, "room_greenhouse": 224.0 },
# 	"room_greenhouse": { "room_kitchen": 16.0 }
# }
# const ROOM_ENTRIES: Dictionary = {
# 	"room_bedroom": { "room_livingroom": 210.0 },
# 	"room_livingroom": { "room_bedroom": 28.0, "room_library": 92.0, "room_kitchen": 212.0 },
# 	"room_library": { "room_livingroom": 118.0 },
# 	"room_kitchen": { "room_livingroom": 28.0, "room_greenhouse": 210.0 },
# 	"room_greenhouse": { "room_kitchen": 28.0 }
# }

# ==============================================================================
# 🐾 EXPORT CONFIGURATION & ROOM BOUNDS
# ==============================================================================
@export_group("Room Bounds & Anchors")
@export var min_x: float = 40.0
@export var max_x: float = 200.0
@export var floor_y: float = 115.0
@export var desk_x: float = 75.0
@export var nap_x: float = 175.0
@export var drink_x: float = 120.0

@export_group("Movement Physics")
@export var walk_speed: float = 42.0
@export var arrival_tolerance: float = 3.0

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var renderer: PetRenderer = $PetRenderer
@onready var cosmetic_layer: CosmeticLayer = $CosmeticLayer
@onready var thought_bubble: ThoughtBubble = $ThoughtBubble
@onready var click_area: Area2D = $ClickArea

# ==============================================================================
# 📊 INTERNAL STATE MACHINE & PATIENCE
# ==============================================================================
var pet_id: String = "pet_shiba"
var pet_name: String = "Kronos"
var species: String = "shiba"
var assigned_room: String = "room_bedroom"
var pet_index: int = 0

var current_state: State = State.IDLE
var target_x: float = 120.0
var current_target_y: float = 115.0
var post_target_y: float = 115.0
var state_timer: float = 0.0
var post_target_state: State = State.IDLE

func get_slot_offset_x() -> float:
	return (float(pet_index) - 1.0) * 16.0

func setup_pet(data: Dictionary) -> void:
	pet_id = data.get("id", "pet_shiba")
	pet_name = data.get("name", "Kronos")
	species = data.get("species", "shiba")
	assigned_room = data.get("room", "room_bedroom")
	if not renderer:
		renderer = get_node_or_null("PetRenderer")
	if renderer:
		renderer.species = species
		renderer.queue_redraw()
	if not thought_bubble:
		thought_bubble = get_node_or_null("ThoughtBubble")
	if thought_bubble:
		thought_bubble.species = species
	if not cosmetic_layer:
		cosmetic_layer = get_node_or_null("CosmeticLayer")
	if cosmetic_layer and cosmetic_layer.has_method("sync_from_data"):
		cosmetic_layer.sync_from_data(pet_index, data)
	# Re-evaluate visibility now that assigned_room is correctly set
	_update_visibility_from_room_state()

# Previous state cache for interruptions (like petting)
var _previous_state: State = State.IDLE
var _petted_duration: float = 2.5
var _victory_duration: float = 3.0
var _periodic_thought_timer: float = 0.0

# Focus Work Patience (2-4 minutes attention span before naturally taking a break)
var _work_patience_timer: float = 0.0
var _work_patience_duration: float = 180.0

# Petting Spam & Annoyance State
var _pet_click_count: int = 0
var _pet_spam_timer: float = 0.0

# Autonomous Room Roaming State
var _roam_timer: float = 0.0
var _next_roam_interval: float = 50.0
var _pending_target_room: String = ""

# Dynamic room floor height offset (e.g. Charon's Skiff bobbing)
var _floor_bob_y: float = 0.0

# Living Household Social & Multi-Pet State
var _social_cooldown: float = 15.0
var _is_social_partner: bool = false
var _social_partner_node: PetBrain = null
var _buddy_leader_node: PetBrain = null

# Companion Fetch State
var _fetch_check_timer: float = 0.0
var _next_fetch_check: float = 60.0
var _fetching_target_pet_id: String = ""

# Autonomous Outdoor Stroll / Expedition State
var _expedition_check_timer: float = 0.0
var _next_expedition_check: float = 90.0

# 🍴 Hunger & Feeding State
var _hunger_prompt_cooldown: float = 0.0
const HUNGER_PROMPT_COOLDOWN_TIME: float = 300.0 # 5 minutes between food prompts
var _hunger_check_timer: float = 0.0
const HUNGER_CHECK_INTERVAL: float = 5.0 # Check hunger level every 5 seconds
var _eating_timer: float = 0.0
const EATING_DURATION: float = 2.4
var _fed_item_id: String = ""

# ==============================================================================
# 🎲 WEIGHTED-RANDOM IDLE INTERACTION SYSTEM
# ==============================================================================
const RARITY_WEIGHTS: Dictionary = {
	"common": 60.0,
	"uncommon": 30.0,
	"rare": 10.0
}

const UNIVERSAL_BEHAVIORS: Array[Dictionary] = [
	{
		"id": "universal_yawn",
		"rarity": "common",
		"target": "in_place",
		"primary": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 3.0,
			"thought": "*big sleepy yawn* 🥱",
			"particle": "zzz"
		},
		"reaction": null
	},
	{
		"id": "universal_groom",
		"rarity": "common",
		"target": "in_place",
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 3.2,
			"thought": "*grooming paws* 🐾✨",
			"particle": "heart"
		},
		"reaction": null
	},
	{
		"id": "universal_cam_gaze",
		"rarity": "uncommon",
		"target": "in_place",
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 3.5,
			"thought": "Looking right at you! 👀✨",
			"particle": "heart"
		},
		"reaction": null
	},
	{
		"id": "universal_timer_watch",
		"rarity": "uncommon",
		"target": "desk",
		"condition": "timer_running",
		"primary": {
			"anim": PetRenderer.AnimState.STUDY,
			"duration": 4.0,
			"thought": "Focus sprint in progress! ⏳✨",
			"particle": "star"
		},
		"reaction": null
	}
]

const BEDROOM_BEHAVIORS: Array[Dictionary] = [
	# Common
	{
		"id": "bedroom_stargaze",
		"rarity": "common",
		"target": "drink", # 490.0, Lethe waterfall & starry sky
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 3.5,
			"thought": "Gazing at the moon & stars... 🌙✨",
			"particle": "heart"
		},
		"reaction": null
	},
	{
		"id": "bedroom_bed_nap",
		"rarity": "common",
		"target": "nap", # 220.0, Daybed
		"primary": {
			"anim": PetRenderer.AnimState.NAP,
			"duration": 5.0,
			"thought": "Curled up on the soft quilt~ 🛏️💤",
			"particle": "zzz"
		},
		"reaction": null
	},
	# Uncommon
	{
		"id": "bedroom_wind_clock",
		"rarity": "uncommon",
		"target": "desk", # 100.0, Altar
		"primary": {
			"anim": PetRenderer.AnimState.STUDY,
			"duration": 3.2,
			"thought": "Inspecting the swinging pendulum 🕰️",
			"particle": "star"
		},
		"reaction": null
	},
	{
		"id": "bedroom_chase_firefly",
		"rarity": "uncommon",
		"target": "random_floor",
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.5,
			"thought": "Chasing a stray dream moth! 💡🐾",
			"particle": "star"
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Almost caught it! ✨🐾",
			"particle": "heart",
			"tween": "happy_hop"
		}
	},
	{
		"id": "bedroom_meditate",
		"rarity": "uncommon",
		"target": "desk",
		"primary": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 4.0,
			"thought": "Quiet meditation under the marble pillar 🏛️",
			"particle": "heart"
		},
		"reaction": null
	},
	# Rare
	{
		"id": "bedroom_shadow_startle",
		"rarity": "rare",
		"target": "random_floor",
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 2.0,
			"thought": "Wait... did that shadow move? 👀",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Yikes! Just my own shadow! 💨",
			"particle": "exclamation",
			"tween": "startle_hop"
		}
	},
	{
		"id": "bedroom_sleepy_wobble",
		"rarity": "rare",
		"target": "in_place",
		"primary": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 3.0,
			"thought": "Nodding off while standing... 🥱",
			"particle": "zzz"
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Whoa! Caught myself! 😳",
			"particle": "exclamation",
			"tween": "wobble"
		}
	}
]

const LIVINGROOM_BEHAVIORS: Array[Dictionary] = [
	# Common
	{
		"id": "livingroom_hearth_nap",
		"rarity": "common",
		"target": "nap", # 200.0, Hearth fire
		"primary": {
			"anim": PetRenderer.AnimState.WARM_PAWS,
			"duration": 5.0,
			"thought": "Toasting paws by Hestia's eternal flame 🔥🐾",
			"particle": "zzz"
		},
		"reaction": null
	},
	{
		"id": "livingroom_couch_stretch",
		"rarity": "common",
		"target": "desk", # 450.0, Feasting table / couch
		"primary": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 3.5,
			"thought": "Big luxurious stretch across the plush couch~ 🛋️✨",
			"particle": "heart"
		},
		"reaction": null
	},
	# Uncommon
	{
		"id": "livingroom_bat_embers",
		"rarity": "uncommon",
		"target": "nap", # 200.0, Near hearth
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.5,
			"thought": "Batting at the floating golden sparks! ✨🐾",
			"particle": "star"
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Caught a warm spark! ⭐",
			"particle": "star",
			"tween": "happy_hop"
		}
	},
	{
		"id": "livingroom_curl_cushion",
		"rarity": "uncommon",
		"target": "desk",
		"primary": {
			"anim": PetRenderer.AnimState.NAP,
			"duration": 4.5,
			"thought": "Burrowing into the soft velvet cushions... 🛋️💤",
			"particle": "zzz"
		},
		"reaction": null
	},
	{
		"id": "livingroom_mesmerized_flames",
		"rarity": "uncommon",
		"target": "nap",
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 4.0,
			"thought": "Staring into the sacred flames, mesmerized... 🔥✨",
			"particle": "heart"
		},
		"reaction": null
	},
	# Rare
	{
		"id": "livingroom_fire_yelp",
		"rarity": "rare",
		"target": "nap",
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.0,
			"thought": "Getting a little too close to the embers... 🔥",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Yip! Too toasty! Jumped back! 💨🔥",
			"particle": "exclamation",
			"tween": "startle_hop"
		}
	},
	{
		"id": "livingroom_cushion_rearrange",
		"rarity": "rare",
		"target": "desk",
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.5,
			"thought": "Determinedly fluffing and rearranging the cushion 🐾🛋️",
			"particle": "star"
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Aha! The perfect comfy nest! ✨🛋️",
			"particle": "heart",
			"tween": "happy_hop"
		}
	}
]

const LIBRARY_BEHAVIORS: Array[Dictionary] = [
	# Common
	{
		"id": "library_read_grimoire",
		"rarity": "common",
		"target": "desk", # 400.0, Celestial desk
		"primary": {
			"anim": PetRenderer.AnimState.STUDY,
			"duration": 4.0,
			"thought": "Studying the ancient astrological grimoire... 📖✨",
			"particle": "star"
		},
		"reaction": null
	},
	{
		"id": "library_peer_telescope",
		"rarity": "common",
		"target": "max_x", # 650.0, Observation terrace / telescope
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 4.0,
			"thought": "Gazing deep into distant galaxies! 🔭🌌",
			"particle": "heart"
		},
		"reaction": null
	},
	# Uncommon
	{
		"id": "library_knock_book",
		"rarity": "uncommon",
		"target": "nap", # 200.0, Book stacks
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.0,
			"thought": "Paw gently nudging a heavy tome... 📚",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Thud! Oops, I didn't mean to! 🐾😳",
			"particle": "exclamation",
			"tween": "startle_hop"
		}
	},
	{
		"id": "library_spin_globe",
		"rarity": "uncommon",
		"target": "drink", # 360.0, Globe
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.5,
			"thought": "Spinning the celestial globe! 🌍✨",
			"particle": "star"
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Wheee, round and round! ⭐",
			"particle": "star",
			"tween": "happy_hop"
		}
	},
	{
		"id": "library_nap_scrolls",
		"rarity": "uncommon",
		"target": "nap",
		"primary": {
			"anim": PetRenderer.AnimState.NAP,
			"duration": 5.0,
			"thought": "Curled up on a warm stack of scrolls~ 📚💤",
			"particle": "zzz"
		},
		"reaction": null
	},
	# Rare
	{
		"id": "library_shadow_spook",
		"rarity": "rare",
		"target": "min_x", # 80.0, Deep between bookshelves
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 2.0,
			"thought": "A shadowy figure between the tall shelves?! 👻",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Puffed up with shock! 💨🙀",
			"particle": "exclamation",
			"tween": "startle_hop"
		}
	},
	{
		"id": "library_secret_page",
		"rarity": "rare",
		"target": "desk",
		"primary": {
			"anim": PetRenderer.AnimState.STUDY,
			"duration": 2.5,
			"thought": "Wait, this page reveals a secret constellation! 📜✨",
			"particle": "star"
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "A celestial breakthrough! 🌟🏆",
			"particle": "heart",
			"tween": "happy_hop"
		}
	}
]

const GREENHOUSE_BEHAVIORS: Array[Dictionary] = [
	# Common
	{
		"id": "greenhouse_chew_wheat",
		"rarity": "common",
		"target": "nap", # 600.0, Golden wheat field
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.5,
			"thought": "Nibbling on a golden wheat stalk... 🌾",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Bleh! Bitter! Spits it out and shakes head! 😝💢",
			"particle": "anger",
			"tween": "head_shake"
		}
	},
	{
		"id": "greenhouse_plant_seed",
		"rarity": "common",
		"target": "drink", # 350.0, Soil patch
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 3.0,
			"thought": "Carefully burying a tiny seed in the rich soil 🌱🐾",
			"particle": "star"
		},
		"reaction": null
	},
	# Uncommon
	{
		"id": "greenhouse_chase_butterfly",
		"rarity": "uncommon",
		"target": "random_floor",
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.5,
			"thought": "Chasing a golden butterfly through the crops! 🦋✨",
			"particle": "star"
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Fluttered over my head! 🌟",
			"particle": "star",
			"tween": "happy_hop"
		}
	},
	{
		"id": "greenhouse_scarecrow_sit",
		"rarity": "uncommon",
		"target": "desk", # 100.0, Scarecrow
		"primary": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 4.0,
			"thought": "Sitting peacefully at the scarecrow's feet 🌾🐦",
			"particle": "heart"
		},
		"reaction": null
	},
	{
		"id": "greenhouse_sneeze",
		"rarity": "uncommon",
		"target": "random_floor",
		"primary": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Sniffling flower pollen... 🌸",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Achoo!! Big pollen sneeze! 🤧💨",
			"particle": "exclamation",
			"tween": "startle_hop"
		}
	},
	# Rare
	{
		"id": "greenhouse_scarecrow_spook",
		"rarity": "rare",
		"target": "desk",
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 2.0,
			"thought": "Wait... did the scarecrow just blink?! 🌾👀",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.5,
			"thought": "Frozen in pure disbelief! 😳",
			"particle": "exclamation",
			"tween": "startle_hop"
		}
	},
	{
		"id": "greenhouse_eat_berry",
		"rarity": "rare",
		"target": "nap",
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.0,
			"thought": "Finding a sweet ripe sunberry! 🍓✨",
			"particle": "star"
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.5,
			"thought": "Delicious! So sweet and juicy! 🥰🍓",
			"particle": "heart",
			"tween": "happy_hop"
		}
	}
]

const KITCHEN_BEHAVIORS: Array[Dictionary] = [
	# Common
	{
		"id": "kitchen_sniff_oven",
		"rarity": "common",
		"target": "min_x",
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 3.5,
			"thought": "Mmm... smells like warm cinnamon rolls! 🥐✨",
			"particle": "heart"
		},
		"reaction": null
	},
	{
		"id": "kitchen_watch_coffee",
		"rarity": "common",
		"target": "desk",
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 3.0,
			"thought": "Watching warm espresso steam curls rise ☕☁️",
			"particle": "heart"
		},
		"reaction": null
	},
	{
		"id": "kitchen_floor_nap",
		"rarity": "common",
		"target": "nap",
		"primary": {
			"anim": PetRenderer.AnimState.NAP,
			"duration": 4.5,
			"thought": "Warm terracotta tiles make the best napping spot! 🐾💤",
			"particle": "zzz"
		},
		"reaction": null
	},
	# Uncommon
	{
		"id": "kitchen_pan_shimmer",
		"rarity": "uncommon",
		"target": "drink",
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 2.8,
			"thought": "Admiring the shiny hanging copper pans! 🍳✨",
			"particle": "star"
		},
		"reaction": null
	},
	{
		"id": "kitchen_pastry_crumb",
		"rarity": "uncommon",
		"target": "random_floor",
		"primary": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Spotting a golden pastry crumb... 🧁",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Nom nom nom! Delicious treat! 😋💖",
			"particle": "heart",
			"tween": "happy_hop"
		}
	}
]

const STYX_BEHAVIORS: Array[Dictionary] = [
	# Common
	{
		"id": "styx_peer_water",
		"rarity": "common",
		"target": "drink", # 310.0, Boat edge
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 3.5,
			"thought": "Peering cautiously into the murky River Styx... 🌊👻",
			"particle": "heart"
		},
		"reaction": null
	},
	{
		"id": "styx_lantern_nap",
		"rarity": "common",
		"target": "nap", # 250.0, Near lantern
		"primary": {
			"anim": PetRenderer.AnimState.NAP,
			"duration": 5.0,
			"thought": "Curled up under the warm spectral lantern glow 🏮💤",
			"particle": "zzz"
		},
		"reaction": null
	},
	# Uncommon
	{
		"id": "styx_rattle_bars",
		"rarity": "uncommon",
		"target": "min_x", # 220.0, Near foreground bars
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.5,
			"thought": "Rattling the ancient underworld prison bars! ⛓️🐾",
			"particle": "star"
		},
		"reaction": null
	},
	{
		"id": "styx_watch_fog",
		"rarity": "uncommon",
		"target": "desk", # 280.0, Skiff center
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 4.0,
			"thought": "Watching spectral green fog drift across the water... 🌫️✨",
			"particle": "heart"
		},
		"reaction": null
	},
	{
		"id": "styx_chain_creak",
		"rarity": "uncommon",
		"target": "random_floor",
		"primary": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Hearing a heavy chain creak in the dark... ⛓️",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.0,
			"thought": "Flinched! Spooky echoes! 💨👻",
			"particle": "exclamation",
			"tween": "startle_hop"
		}
	},
	# Rare
	{
		"id": "styx_nearly_fall",
		"rarity": "rare",
		"target": "max_x", # 340.0, Prow edge
		"primary": {
			"anim": PetRenderer.AnimState.WINDOW_GAZE,
			"duration": 2.0,
			"thought": "Whoa, slipping near the edge of the boat! 🌊",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Whew! Caught my balance just in time! 😮‍💨🐾",
			"particle": "exclamation",
			"tween": "wobble"
		}
	},
	{
		"id": "styx_water_reflection",
		"rarity": "rare",
		"target": "drink",
		"primary": {
			"anim": PetRenderer.AnimState.CHEF_SNIFF,
			"duration": 2.5,
			"thought": "Confused by my own green reflection in the Styx 👻❓",
			"particle": null
		},
		"reaction": {
			"anim": PetRenderer.AnimState.IDLE,
			"duration": 2.2,
			"thought": "Poking at the phantom ripples! ✨🐾",
			"particle": "heart",
			"tween": "head_shake"
		}
	}
]

var _special_behavior_cooldown: float = 20.0
var _active_sequence: Dictionary = {}
var _sequence_stage: int = 0 # 0 = none, 1 = primary, 2 = reaction
var _sequence_timer: float = 0.0
var _sequence_tween: Tween = null

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	# Removed local randomize() to prevent identical RNG seeds when spawning multiple pets simultaneously
	# Only initialize position if we don't have one set by RoomManager
	if position.x == 0:
		position.x = 120.0
	target_x = position.x
	current_target_y = floor_y
	post_target_y = floor_y
	position.y = floor_y
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	visible = true
	_reset_roam_timer()
	_work_patience_duration = randf_range(120.0, 240.0)
	_special_behavior_cooldown = randf_range(15.0, 30.0)
	
	# Jitter timers so pets don't do the exact same things on the exact same frame
	state_timer = randf_range(0.0, 3.0)
	_periodic_thought_timer = randf_range(0.0, 10.0)
	
	if not renderer:
		renderer = get_node_or_null("PetRenderer")
	if renderer:
		renderer.species = species
		renderer.queue_redraw()
		
	_connect_event_bus()
	
	if click_area:
		click_area.input_event.connect(_on_click_area_input_event)
		
	_sync_initial_state()
	_update_visibility_from_room_state()

func _connect_event_bus() -> void:
	EventBus.timer_state_changed.connect(_on_timer_state_changed)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.session_completed.connect(_on_session_completed)
	EventBus.session_skipped.connect(_on_session_skipped)
	EventBus.item_used.connect(_on_item_used)
	if EventBus.has_signal("pet_fed"):
		EventBus.pet_fed.connect(_on_pet_fed)
	EventBus.room_changed.connect(_on_room_changed)
	EventBus.pet_room_changed.connect(_on_pet_room_changed)
	EventBus.pet_called.connect(_on_pet_called)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.object_state_changed.connect(_on_object_state_changed)
	if EventBus.has_signal("floor_y_offset_changed"):
		EventBus.floor_y_offset_changed.connect(_on_floor_y_offset_changed)

func _on_floor_y_offset_changed(offset: float) -> void:
	_floor_bob_y = offset

func _physics_process(delta: float) -> void:
	state_timer += delta
	_periodic_thought_timer += delta
	
	if _pet_spam_timer > 0.0:
		_pet_spam_timer -= delta
		if _pet_spam_timer <= 0.0:
			_pet_click_count = 0
			
	if _hunger_prompt_cooldown > 0.0:
		_hunger_prompt_cooldown -= delta

	_hunger_check_timer += delta
	if _hunger_check_timer >= HUNGER_CHECK_INTERVAL:
		_hunger_check_timer = 0.0
		_check_hunger_state()
			
	# Process autonomous roaming across connected rooms
	_process_autonomous_room_roaming(delta)
	
	# Random periodic thoughts strictly matched to the active activity
	_process_periodic_thoughts()
	
	# Execute active state logic
	match current_state:
		State.IDLE:
			_process_idle_state(delta)
		State.WANDER, State.WALK_TO_TARGET:
			_process_walk_state(delta)
		State.TYPE:
			_process_type_state(delta)
		State.DRINK:
			_process_drink_state(delta)
		State.NAP:
			_process_nap_state(delta)
		State.PETTED:
			_process_petted_state(delta)
		State.VICTORY:
			_process_victory_state(delta)
		State.WATCH_TV:
			_process_watch_tv_state(delta)
		State.WARM_PAWS:
			_process_warm_paws_state(delta)
		State.STUDY:
			_process_study_state(delta)
		State.WINDOW_GAZE:
			_process_window_gaze_state(delta)
		State.TUCKED_IN:
			_process_tucked_in_state(delta)
		State.CHEF_SNIFF:
			_process_chef_sniff_state(delta)
		State.EXITING_ROOM:
			_process_exiting_room_state(delta)
		State.PLAY:
			_process_play_state(delta)
		State.SPECIAL_INTERACTION:
			_process_special_interaction_state(delta)
		State.SOCIALIZING:
			_process_socializing_state(delta)
		State.FOLLOWING:
			_process_following_state(delta)
		State.FETCHING:
			_process_fetching_state(delta)
		State.DEPARTING_OUTSIDE:
			_process_departing_outside_state(delta)
		State.EATING:
			_process_eating_state(delta)
		State.ASK_FOOD:
			_process_ask_food_state(delta)
		State.HANGRY:
			_process_hangry_state(delta)
			
	# Enforce room boundaries & target y level (including dynamic floor bobbing)
	var is_exiting_bounds: bool = (
		current_state == State.EXITING_ROOM or post_target_state == State.EXITING_ROOM or
		current_state == State.DEPARTING_OUTSIDE or post_target_state == State.DEPARTING_OUTSIDE or
		current_state == State.FETCHING or post_target_state == State.FETCHING
	)
	if not is_exiting_bounds:
		position.x = clampf(position.x, min_x, max_x)
	var effective_y: float = (floor_y if current_state == State.WALK_TO_TARGET else current_target_y) + _floor_bob_y
	position.y = move_toward(position.y, effective_y, delta * 60.0)

# ==============================================================================
# ⏰ DIURNAL PROFILE (REAL-TIME DAY / NIGHT)
# ==============================================================================
func _get_time_profile() -> Dictionary:
	var hour: int = Time.get_time_dict_from_system().get("hour", 12)
	var is_night: bool = (hour >= 20 or hour < 6)
	return {
		"hour": hour,
		"is_night": is_night,
		"roam_interval_min": 50.0 if is_night else 30.0,
		"roam_interval_max": 95.0 if is_night else 60.0,
		"nap_bias": 0.50 if is_night else 0.15
	}

func _reset_roam_timer() -> void:
	var profile: Dictionary = _get_time_profile()
	_next_roam_interval = randf_range(profile.roam_interval_min, profile.roam_interval_max)
	_roam_timer = 0.0

# ==============================================================================
# 🔄 CONTEXTUAL STATE HANDLERS
# ==============================================================================
func _process_idle_state(delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.IDLE)
	
	var profile: Dictionary = _get_time_profile()
	var cur_room: String = assigned_room if assigned_room != "" else "room_bedroom"
	var is_working: bool = (TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.RUNNING and TimerEngine.current_phase == TimerEngine.TimerPhase.WORK)
	
	# 1. Check autonomous cross-room wander
	if not is_working:
		_roam_timer += delta
		if _roam_timer >= _next_roam_interval:
			_reset_roam_timer()
			if _try_autonomous_room_roam():
				return
	
	# 1.1 Check special weighted-random idle interaction cooldown
	if not is_working:
		_special_behavior_cooldown -= delta
		if _special_behavior_cooldown <= 0.0:
			if _try_start_weighted_idle_interaction():
				return
				
	# 1.2 Multi-Pet Living Household Social Interaction Check
	if not _is_social_partner and not is_working:
		_social_cooldown -= delta
		if _social_cooldown <= 0.0:
			_social_cooldown = randf_range(20.0, 45.0)
			if _try_multi_pet_social():
				return

	# 1.3 Autonomous Outdoor Stroll / Expedition Check (3-5 min)
	if not is_working:
		_expedition_check_timer += delta
		if _expedition_check_timer >= _next_expedition_check:
			_expedition_check_timer = 0.0
			_next_expedition_check = randf_range(90.0, 180.0)
			if _try_start_autonomous_expedition():
				return

	# 1.4 Autonomous Companion Fetch Check
	if not is_working:
		_fetch_check_timer += delta
		if _fetch_check_timer >= _next_fetch_check:
			_fetch_check_timer = 0.0
			_next_fetch_check = randf_range(90.0, 180.0)
			if _try_autonomous_companion_fetch():
				return
	
	# 1.5 Weather Overrides
	if state_timer > 2.0 and GameState:
		var w = GameState.current_weather
		if w == GameState.Weather.RAIN and randf() < 0.6:
			# Seek shelter / nap
			walk_to(nap_x + randf_range(-10, 10), State.NAP, floor_y)
			return
		elif w == GameState.Weather.SNOW and randf() < 0.5:
			# Seek warmth
			walk_to(180 + randf_range(-20, 20), State.WARM_PAWS, floor_y)
			return
		elif w == GameState.Weather.STAR_SHOWER and randf() < 0.4:
			# Watch the stars
			var tz = desk_x if cur_room != "room_bedroom" else nap_x
			walk_to(tz, State.WINDOW_GAZE, floor_y)
			return

	# 2. Decide standard action after a few seconds of idle
	if state_timer >= randf_range(4.0, 8.0):
		state_timer = 0.0
		
		# Designated Study Buddy works alongside user; other companions live freely
		if is_working:
			if GameState and pet_index == GameState.get_study_buddy_idx():
				_join_work_session()
				return
			
		# Context-Aware Room Prop Behaviors
		if _try_room_specific_activity(cur_room, profile):
			return
			
		# Standard autonomous decision roll
		var roll: float = randf()
		if roll < 0.60:
			# Wander around room floor
			walk_to(randf_range(min_x, max_x), State.IDLE, floor_y)
		elif roll < 0.80:
			# Change facing direction
			if renderer:
				renderer.facing_right = not renderer.facing_right
		elif roll < 0.90:
			# Quick nap
			if thought_bubble and visible:
				thought_bubble.show_random_thought("go_to_sleep", 3.0)
			walk_to(nap_x, State.NAP, floor_y)
		else:
			# Drink/snack
			if thought_bubble and visible:
				thought_bubble.show_random_thought("drink", 3.0)
			walk_to(drink_x, State.DRINK, floor_y)

## Evaluates room props and initiates special activities
func _try_room_specific_activity(room: String, profile: Dictionary) -> bool:
	if not GameState:
		return false
		
	match room:
		"room_bedroom": # Temple of Morpheus
			var roll: float = randf()
			if roll < 0.35:
				if thought_bubble and visible: thought_bubble.show_thought("Staring into the Font of Lethe... 💧", 3.5)
				walk_to(drink_x, State.WINDOW_GAZE, floor_y)
				return true
			elif roll < 0.70:
				if thought_bubble and visible: thought_bubble.show_thought("Floating in the canopy bed~ ☁️💤", 3.5)
				walk_to(nap_x, State.NAP, floor_y)
				return true
			elif roll < 0.90:
				if thought_bubble and visible: thought_bubble.show_thought("Watching the sands of time... ⏳", 3.5)
				walk_to(desk_x, State.STUDY, floor_y)
				return true
				
		"room_livingroom": # Hearth of Hestia
			var roll: float = randf()
			if roll < 0.35:
				if thought_bubble and visible: thought_bubble.show_thought("Fresh water from the amphora! 🏺", 3.5)
				walk_to(drink_x, State.DRINK, floor_y)
				return true
			elif roll < 0.70:
				if thought_bubble and visible: thought_bubble.show_thought("Warming paws by the sacred fire~ 🔥🐾", 3.5)
				walk_to(nap_x, State.WARM_PAWS, floor_y)
				return true
			elif roll < 0.90:
				if thought_bubble and visible: thought_bubble.show_thought("Studying the ancient scrolls 📜", 3.5)
				walk_to(desk_x, State.STUDY, floor_y)
				return true
				
		"room_library": # Tower of Urania
			var roll: float = randf()
			if roll < 0.35:
				if thought_bubble and visible: thought_bubble.show_thought("Looking for shooting stars! 🔭✨", 3.5)
				walk_to(max_x - 40.0, State.WINDOW_GAZE, floor_y)
				return true
			elif roll < 0.70:
				if thought_bubble and visible: thought_bubble.show_thought("Resting by the celestial globe 🌍💤", 3.5)
				walk_to(nap_x, State.NAP, floor_y)
				return true
			elif roll < 0.90:
				if thought_bubble and visible: thought_bubble.show_thought("Consulting the Oracle's star map 🌌", 3.5)
				walk_to(desk_x, State.STUDY, floor_y)
				return true
				
		"room_kitchen": # Chef's Kitchen
			var roll: float = randf()
			if roll < 0.35:
				if thought_bubble and visible: thought_bubble.show_thought("Sniffing fresh baked croissants! 🥐✨", 3.5)
				walk_to(min_x + 20.0, State.CHEF_SNIFF, floor_y)
				return true
			elif roll < 0.70:
				if thought_bubble and visible: thought_bubble.show_thought("Watching espresso steam at the coffee bar ☕✨", 3.5)
				walk_to(desk_x, State.WINDOW_GAZE, floor_y)
				return true
			elif roll < 0.90:
				if thought_bubble and visible: thought_bubble.show_thought("Cozy nap on the bakery mat 💤", 3.5)
				walk_to(nap_x, State.NAP, floor_y)
				return true
				
		"room_styx": # Banks of the Styx
			var roll: float = randf()
			if roll < 0.35:
				if thought_bubble and visible: thought_bubble.show_thought("Riding Charon's ferry... 🛶👻", 3.5)
				walk_to(drink_x, State.WINDOW_GAZE, floor_y)
				return true
			elif roll < 0.70:
				if thought_bubble and visible: thought_bubble.show_thought("Watching the murky waters of Styx 🌊", 3.5)
				walk_to(desk_x, State.IDLE, floor_y)
				return true
			elif roll < 0.90:
				if thought_bubble and visible: thought_bubble.show_thought("Resting on the creaking deck 💤", 3.5)
				walk_to(nap_x, State.NAP, floor_y)
				return true
				
		"room_greenhouse": # Elysian Fields
			var roll: float = randf()
			if roll < 0.30:
				if thought_bubble and visible: thought_bubble.show_thought("Golden wheat swaying in the breeze! 🌾✨", 3.5)
				walk_to(desk_x, State.WINDOW_GAZE, floor_y)
				return true
			elif roll < 0.50:
				if thought_bubble and visible: thought_bubble.show_thought("Crystal clear spring water! 💧✨", 3.5)
				walk_to(drink_x, State.DRINK, floor_y)
				return true
			elif roll < 0.70:
				if thought_bubble and visible: thought_bubble.show_thought("Warm sun and soft fields~ 🌾💤", 3.5)
				walk_to(nap_x, State.NAP, floor_y)
				return true
			elif roll < 0.90:
				if thought_bubble and visible: thought_bubble.show_thought("Saying hello to the scarecrow 🌾🐦", 3.5)
				walk_to(desk_x, State.STUDY, floor_y)
				return true
	
	return false

func _process_walk_state(_delta: float) -> void:
	_set_renderer_state(PetRenderer.AnimState.WALK)
	var diff: float = target_x - position.x
	
	if absf(diff) <= arrival_tolerance:
		# Arrived at destination horizontal coordinate
		velocity.x = 0.0
		position.x = target_x
		current_state = post_target_state
		current_target_y = post_target_y
		state_timer = 0.0
		
		# If target is on elevated furniture, play cute hop jump!
		if post_target_y < floor_y - 2.0:
			var hop_tween: Tween = create_tween()
			hop_tween.tween_property(self, "position:y", post_target_y - 8.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			hop_tween.tween_property(self, "position:y", post_target_y, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		else:
			position.y = post_target_y
			
		# Specific arrival facing logic
		if current_state == State.SPECIAL_INTERACTION:
			_execute_primary_stage()
		elif current_state == State.WATCH_TV or current_state == State.STUDY or current_state == State.TYPE:
			if renderer:
				renderer.facing_right = true
		elif current_state == State.WARM_PAWS:
			if renderer:
				renderer.facing_right = false
		elif current_state == State.EXITING_ROOM:
			_execute_room_transition_fade(_pending_target_room)
		elif current_state == State.EATING:
			# Reset eating animation on arrival (for drinks walking to drink_x)
			_eating_timer = 0.0
			if renderer:
				renderer.feeding_item_id = _fed_item_id
				renderer.feeding_stage = 0
	else:
		var dir: float = signf(diff)
		velocity.x = dir * walk_speed
		if renderer:
			renderer.facing_right = (dir > 0)
		move_and_slide()

func _process_type_state(delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.TYPE)
	if renderer:
		renderer.facing_right = true
		
	_work_patience_timer += delta
	if _work_patience_timer >= _work_patience_duration:
		_work_patience_timer = 0.0
		var exit_roll: float = randf()
		if exit_roll < 0.40:
			if thought_bubble and visible:
				thought_bubble.show_random_thought("go_to_sleep", 3.0)
			walk_to(nap_x, State.NAP, floor_y)
		elif exit_roll < 0.70:
			if thought_bubble and visible:
				thought_bubble.show_random_thought("stretch_wander", 3.0)
			walk_to(randf_range(min_x, max_x), State.IDLE, floor_y)
		else:
			if thought_bubble and visible:
				thought_bubble.show_random_thought("drink", 3.0)
			walk_to(drink_x, State.DRINK, floor_y)

func _process_drink_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.DRINK)
	if state_timer >= 6.0:
		current_state = State.IDLE
		state_timer = 0.0

func _process_nap_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.NAP)
	var profile: Dictionary = _get_time_profile()
	var nap_limit: float = randf_range(35.0, 65.0) if profile.is_night else randf_range(14.0, 28.0)
	if state_timer >= nap_limit:
		state_timer = 0.0
		current_state = State.IDLE

func _process_tucked_in_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.TUCKED_IN)
	var profile: Dictionary = _get_time_profile()
	var nap_limit: float = randf_range(45.0, 90.0) if profile.is_night else randf_range(20.0, 40.0)
	if state_timer >= nap_limit:
		state_timer = 0.0
		current_state = State.IDLE

func _process_watch_tv_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.WATCH_TV)
	if renderer:
		renderer.facing_right = true
	# Binge-watch for 20-40 seconds
	if state_timer >= randf_range(20.0, 40.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_warm_paws_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.WARM_PAWS)
	if renderer:
		renderer.facing_right = false
	if state_timer >= randf_range(16.0, 32.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_study_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.STUDY)
	if renderer:
		renderer.facing_right = true
	if state_timer >= randf_range(18.0, 36.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_window_gaze_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.WINDOW_GAZE)
	
	if assigned_room == "room_bedroom" and absf(position.x - 540.0) < 5.0:
		if GameState and fmod(state_timer, 3.0) < 0.05:
			EventBus.object_state_changed.emit("lethe_paw_dip", true)
			
	if state_timer >= randf_range(12.0, 24.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_chef_sniff_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.CHEF_SNIFF)
	if state_timer >= randf_range(8.0, 16.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_play_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.VICTORY) # Use jump animation for catching!
	if state_timer >= 3.0:
		state_timer = 0.0
		current_state = State.IDLE
		if thought_bubble and visible:
			thought_bubble.show_thought("Caught a dream! ✨", 3.0)

func _process_petted_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.PETTED)
	if state_timer >= _petted_duration:
		state_timer = 0.0
		current_state = _previous_state
		if current_state == State.WALK_TO_TARGET or current_state == State.WANDER or current_state == State.EXITING_ROOM:
			current_state = State.IDLE

## Forces the pet into a celebratory victory bounce
func trigger_victory() -> void:
	current_state = State.VICTORY
	state_timer = 0.0
	if thought_bubble:
		thought_bubble.show_thought("heart", 2.5)

func _process_victory_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.VICTORY)
	if state_timer >= _victory_duration:
		state_timer = 0.0
		_start_break_behavior()

func _process_exiting_room_state(_delta: float) -> void:
	velocity.x = 0.0
	# Held during exit tween

# ------------------------------------------------------------------------------
# 🍴 HUNGER STATE HANDLERS
# ------------------------------------------------------------------------------
func _process_eating_state(delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.FEEDING)
	_eating_timer += delta
	# Advance through 3 stages: 0→1 at 0.8s, 1→2 at 1.6s
	if renderer:
		if _eating_timer >= 1.6:
			renderer.feeding_stage = 2
		elif _eating_timer >= 0.8:
			renderer.feeding_stage = 1
		else:
			renderer.feeding_stage = 0
	if _eating_timer >= EATING_DURATION:
		_eating_timer = 0.0
		# Celebration after eating
		if renderer:
			renderer.feeding_stage = 0
		if thought_bubble and visible:
			thought_bubble.show_random_thought("fed_happy_" + species.to_upper(), 3.0)
		current_state = State.VICTORY
		state_timer = 0.0
		if renderer:
			renderer._spawn_particle("heart")
			renderer._spawn_particle("star")

func _process_ask_food_state(delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.ASK_FOOD)
	if state_timer >= 4.0:
		state_timer = 0.0
		current_state = State.IDLE

func _process_hangry_state(delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.HANGRY)
	if state_timer >= 4.5:
		state_timer = 0.0
		current_state = State.IDLE

## Checks hunger level and enters ASK_FOOD or HANGRY states if appropriate.
## Only fires if pet is visible, idle-ish, and not already in a food-related state.
func _check_hunger_state() -> void:
	if not visible or not GameState:
		return
	# Don't interrupt critical states
	var interruptible_states: Array = [State.IDLE, State.WANDER, State.WALK_TO_TARGET, State.DRINK, State.NAP]
	if not (current_state in interruptible_states):
		return
	if _hunger_prompt_cooldown > 0.0:
		return
	var h: float = GameState.get_pet_hunger(pet_index)
	if h <= 15.0:
		# Hangry — pet is very hungry and upset
		if thought_bubble and visible:
			thought_bubble.show_random_thought("hangry_" + species.to_upper(), 4.5)
		current_state = State.HANGRY
		state_timer = 0.0
		_hunger_prompt_cooldown = HUNGER_PROMPT_COOLDOWN_TIME
	elif h <= 40.0:
		# Asking for food politely
		if thought_bubble and visible:
			thought_bubble.show_random_thought("ask_food_" + species.to_upper(), 4.0)
		current_state = State.ASK_FOOD
		state_timer = 0.0
		_hunger_prompt_cooldown = HUNGER_PROMPT_COOLDOWN_TIME

# ==============================================================================
# 🚶 NAVIGATION & COMMANDS
# ==============================================================================
func walk_to(dest_x: float, next_state: State = State.IDLE, dest_y: float = 115.0) -> void:
	target_x = clampf(dest_x, min_x, max_x)
	post_target_state = next_state
	post_target_y = dest_y
	current_state = State.WALK_TO_TARGET
	state_timer = 0.0

func set_room_anchors(p_min_x: float, p_max_x: float, p_desk_x: float, p_nap_x: float, p_drink_x: float, p_floor_y: float = 115.0) -> void:
	min_x = p_min_x
	max_x = p_max_x
	desk_x = p_desk_x
	nap_x = p_nap_x
	drink_x = p_drink_x
	floor_y = p_floor_y
	current_target_y = floor_y
	post_target_y = floor_y
	position.y = floor_y
	position.x = clampf(position.x, min_x, max_x)
	target_x = clampf(target_x, min_x, max_x)

# ==============================================================================
# 🚪 ANIMATED ROOM ROAMING TRANSITIONS
# ==============================================================================
func _process_autonomous_room_roaming(delta: float) -> void:
	# Disabled: Pets no longer autonomously roam between domains.
	# They stay in the domain they are assigned to.
	return

func _start_room_transition_walk(from_room: String, to_room: String) -> void:
	# Disabled: No more walking to doors.
	return

func _on_object_state_changed(key: String, val: Variant) -> void:
	if not GameState or assigned_room != GameState.active_view_room:
		return
	var cur_room: String = assigned_room
	
	# ==========================================================================
	# 🏛️ DOMAIN INTERACTIVE PROP REACTIONS
	# ==========================================================================
	
	# 1. Temple of Morpheus (room_bedroom)
	if cur_room == "room_bedroom":
		if key == "lethe_toggled":
			if renderer:
				renderer.facing_right = (drink_x > position.x)
			if thought_bubble:
				if val == true:
					thought_bubble.show_thought("Lethe waterfall is flowing~ 💧✨", 3.0)
				else:
					thought_bubble.show_thought("Quiet temple waters... 🌙", 3.0)
			return
		elif key == "lethe_paw_dip":
			if thought_bubble:
				thought_bubble.show_thought("Dream orb appeared! ✨", 3.0)
			if renderer:
				renderer._spawn_particle("star")
			var hop_tween = create_tween()
			hop_tween.tween_property(self, "position:y", position.y - 6.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			hop_tween.tween_property(self, "position:y", position.y, 0.10).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			return
		elif key == "chimes_struck":
			if thought_bubble:
				thought_bubble.show_thought("Gentle chime melodies~ 🎐✨", 3.0)
			if renderer:
				renderer._spawn_particle("star")
			return
		elif key == "weaver_dropped_dust" and current_state == State.IDLE:
			var dust_x = float(val)
			if abs(position.x - dust_x) < 120.0 and randf() < 0.5:
				walk_to(dust_x, State.PLAY, floor_y)
				return

	# 2. Hearth of Hestia (room_livingroom)
	elif cur_room == "room_livingroom":
		if key == "hearth_toggled":
			if val == true:
				if thought_bubble:
					thought_bubble.show_thought("The sacred fire is roaring! 🔥🐾", 3.0)
				if current_state == State.IDLE and randf() < 0.60:
					walk_to(nap_x, State.WARM_PAWS, floor_y)
			else:
				if thought_bubble:
					thought_bubble.show_thought("Fire went out~ chilly! ❄️", 3.0)
				if current_state == State.WARM_PAWS:
					current_state = State.IDLE
			return
		elif key == "hearth_offering_burned":
			if thought_bubble:
				thought_bubble.show_thought("Sacred offering accepted! 🍇🔥", 3.0)
			if renderer:
				renderer._spawn_particle("heart")
			var bounce_tween = create_tween()
			bounce_tween.tween_property(self, "position:y", position.y - 5.0, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			bounce_tween.tween_property(self, "position:y", position.y, 0.10).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			if current_state == State.IDLE and randf() < 0.50:
				walk_to(nap_x, State.WARM_PAWS, floor_y)
			return

	# 3. Tower of Urania (room_library)
	elif cur_room == "room_library":
		if key == "telescope_used":
			if renderer:
				renderer.facing_right = true
				renderer._spawn_particle("star")
			if thought_bubble:
				thought_bubble.show_thought("A shooting star! Make a wish! 🌠✨", 3.5)
			if current_state == State.IDLE and randf() < 0.70:
				walk_to(clampf(max_x - 40.0, min_x, max_x), State.WINDOW_GAZE, floor_y)
			return
		elif key == "globe_spun":
			if thought_bubble:
				thought_bubble.show_thought("Spinning the golden cosmos! 🌍✨", 3.0)
			if renderer:
				renderer._spawn_particle("star")
			if current_state == State.IDLE and randf() < 0.45:
				walk_to(drink_x, State.STUDY, floor_y)
			return

	# 4. Banks of the Styx (room_kitchen)
	elif cur_room == "room_kitchen":
		if key == "styx_splashed":
			if renderer:
				renderer.facing_right = (drink_x > position.x)
			if thought_bubble:
				thought_bubble.show_thought("Ripples in the River Styx! 🌊👻", 3.0)
			if current_state == State.IDLE and randf() < 0.50:
				walk_to(drink_x, State.WINDOW_GAZE, floor_y)
			return

	# 5. Elysian Fields (room_greenhouse)
	elif cur_room == "room_greenhouse":
		if key == "scarecrow_clicked":
			if thought_bubble:
				thought_bubble.show_thought("Crows flying everywhere! 🐦🌾", 3.0)
			if renderer:
				renderer._spawn_particle("exclamation")
			var startle_tween = create_tween()
			startle_tween.tween_property(self, "position:y", position.y - 5.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			startle_tween.tween_property(self, "position:y", position.y, 0.10).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			if current_state == State.IDLE and randf() < 0.40:
				walk_to(desk_x, State.STUDY, floor_y)
			return

func _try_autonomous_room_roam() -> bool:
	if not GameState or GameState.active_pets.is_empty():
		return false
		
	var cur_room: String = assigned_room if assigned_room != "" else "room_bedroom"
	var topology: Dictionary = GameState.ROOM_TOPOLOGY.get(cur_room, {})
	if topology.is_empty():
		return false
		
	var left_room: String = topology.get("left", "")
	var right_room: String = topology.get("right", "")
	
	var candidates: Array[String] = []
	if left_room != "" and GameState.is_room_unlocked(left_room):
		candidates.append(left_room)
	if right_room != "" and GameState.is_room_unlocked(right_room):
		candidates.append(right_room)
		
	if candidates.is_empty():
		return false
		
	# Smart Need-Based Target Preference:
	var chosen_target: String = ""
	var p_energy: float = GameState.energy
	var p_joy: float = GameState.joy
	var hour: int = Time.get_time_dict_from_system().get("hour", 12)
	
	if p_energy < 40.0 and candidates.has("room_kitchen"):
		chosen_target = "room_kitchen"
	elif p_joy < 40.0 and candidates.has("room_livingroom"):
		chosen_target = "room_livingroom"
	elif (hour >= 22 or hour < 6) and candidates.has("room_bedroom"):
		chosen_target = "room_bedroom"
	else:
		chosen_target = candidates.pick_random()
		
	if chosen_target == "":
		return false
		
	# Determine exit direction
	var is_moving_left: bool = (chosen_target == left_room)
	var exit_door_x: float = min_x - 14.0 if is_moving_left else max_x + 14.0
	
	var r_name: String = GameState.ITEM_DEFINITIONS.get(chosen_target, {}).get("name", "next room")
	
	# Buddy Invitation (40% chance to invite an idle roommate)
	var invited_buddy: PetBrain = null
	if randf() < 0.40 and get_parent():
		for child in get_parent().get_children():
			if child is PetBrain and child != self and is_instance_valid(child) and child.visible:
				if child.current_state in [State.IDLE, State.WINDOW_GAZE, State.WARM_PAWS] and not child._is_social_partner:
					invited_buddy = child
					break
					
	if invited_buddy:
		if thought_bubble and visible:
			thought_bubble.show_buddy_invite(invited_buddy.pet_name, r_name)
		invited_buddy.accept_buddy_invite(self, chosen_target, exit_door_x)
		EventBus.pet_invited_to_room.emit(pet_index, invited_buddy.pet_index, chosen_target)
	else:
		if thought_bubble and visible:
			thought_bubble.show_thought("Trotting to the %s... 🐾" % r_name, 3.0)
		
	walk_to_door_and_exit(chosen_target, exit_door_x)
	return true

func walk_to_door_and_exit(next_room: String, door_x: float) -> void:
	_cancel_active_sequence()
	_pending_target_room = next_room
	target_x = door_x # Unclamped so pet crosses the doorway threshold
	post_target_state = State.EXITING_ROOM
	post_target_y = floor_y
	current_target_y = floor_y
	current_state = State.WALK_TO_TARGET
	state_timer = 0.0
	_set_renderer_state(PetRenderer.AnimState.WALK)
	if renderer:
		renderer.facing_right = (door_x > position.x)

func walk_in_from_door(direction: int) -> void:
	_cancel_active_sequence()
	var start_x: float = min_x - 12.0 if direction > 0 else max_x + 12.0
	var dest_x: float = min_x + 22.0 + get_slot_offset_x() if direction > 0 else max_x - 22.0 + get_slot_offset_x()
	position.x = start_x
	position.y = floor_y
	modulate.a = 0.0
	visible = true
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.18)
	
	walk_to(dest_x, State.IDLE, floor_y)
	if renderer:
		renderer.facing_right = (direction > 0)

func _execute_room_transition_fade(next_room: String) -> void:
	if not GameState or not GameState.is_room_unlocked(next_room):
		current_state = State.IDLE
		return
		
	# Update this pet's individual location in active_pets roster
	assigned_room = next_room
	for p in GameState.active_pets:
		if p.get("id", "") == pet_id:
			p["room"] = next_room
			break
			
	EventBus.pet_room_changed.emit(next_room)
	if DatabaseManager:
		DatabaseManager.save_game()
		
	# Fade out smoothly as it steps through the door archway into the hallway
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		queue_free()
	)

# ==============================================================================
# ⏱️ EVENT BUS HANDLERS
# ==============================================================================
func _sync_initial_state() -> void:
	current_state = State.IDLE
	_reset_roam_timer()

func _on_timer_state_changed(is_running: bool, is_paused: bool) -> void:
	if is_running:
		if TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
			if GameState:
				if GameState.study_buddy_idx == -1:
					GameState.assign_study_buddy(assigned_room)
				if pet_index == GameState.get_study_buddy_idx():
					_join_work_session()
				else:
					if current_state == State.TYPE:
						current_state = State.IDLE
		else:
			if GameState:
				GameState.clear_study_buddy()
			_start_break_behavior()
	elif is_paused:
		if current_state == State.TYPE:
			_set_renderer_state(PetRenderer.AnimState.IDLE)
	else:
		if GameState:
			GameState.clear_study_buddy()
		if current_state == State.TYPE:
			current_state = State.IDLE

func _on_phase_changed(new_phase: String, _duration: float) -> void:
	if new_phase == "work":
		if GameState:
			if GameState.study_buddy_idx == -1:
				GameState.assign_study_buddy(assigned_room)
			if pet_index == GameState.get_study_buddy_idx():
				_join_work_session()
	else:
		if GameState:
			GameState.clear_study_buddy()
		_start_break_behavior()

func _on_session_completed(session_type: String, _coins: int, _xp: int, _streak: int) -> void:
	_cancel_active_sequence()
	if session_type == "work":
		current_state = State.VICTORY
		state_timer = 0.0
		if renderer:
			for i in range(3):
				renderer._spawn_particle("star")
		if thought_bubble and visible:
			if GameState and GameState.streak >= 2:
				thought_bubble.show_thought("Focus streak +%d! 🔥🏆" % GameState.streak, 3.5)
			else:
				thought_bubble.show_thought("Focus session complete! 🎉🏆", 3.5)
	else:
		if thought_bubble and visible:
			thought_bubble.show_thought("Refreshed & ready! 🚀", 3.0)
		current_state = State.IDLE

func _on_session_skipped(_session_type: String) -> void:
	_cancel_active_sequence()
	current_state = State.IDLE
	if thought_bubble and visible:
		thought_bubble.show_thought("Taking a breather~", 2.5)

func _start_break_behavior() -> void:
	_cancel_active_sequence()
	var roll: float = randf()
	var cur_room = GameState.pet_room if GameState else "room_bedroom"
	if roll < 0.5:
		if thought_bubble and visible:
			thought_bubble.show_random_thought("stretch_wander", 3.0)
		walk_to(randf_range(min_x, max_x), State.IDLE, floor_y)
	else:
		if thought_bubble and visible:
			thought_bubble.show_random_thought("napping", 3.0)
		walk_to(nap_x, State.NAP, floor_y)

func _join_work_session() -> void:
	_cancel_active_sequence()
	_work_patience_timer = 0.0
	_work_patience_duration = randf_range(120.0, 240.0)
	if thought_bubble and visible:
		thought_bubble.show_random_thought("work_join", 3.0)
		
	var work_state: State = State.TYPE
	var offset: float = (float(pet_index) - 0.5) * 25.0
	var work_x: float = clampf(desk_x + offset, min_x + 5.0, max_x - 5.0)
	walk_to(work_x, work_state, floor_y)

func _on_pet_interacted(interaction_type: String) -> void:
	if interaction_type == "pet":
		_pet_click_count += 1
		_pet_spam_timer = 2.5
		
		# 1. Annoyed Reaction if Spam Petted (4+ rapid clicks)
		if _pet_click_count >= 4:
			_pet_click_count = 0
			if thought_bubble and visible:
				thought_bubble.show_random_thought("annoyed", 3.0)
			if renderer:
				renderer._spawn_particle("anger")
			return
			
		# Play cute purr/chirp sound
		if has_node("/root/AudioManager"):
			var am = get_node("/root/AudioManager")
			if am and am.has_method("play_sfx"):
				am.play_sfx("chirp")
				
		# 2. In-Place Petting (If resting on furniture, watching TV, sleeping, or typing)
		var in_furniture: bool = (current_state == State.WATCH_TV or current_state == State.TYPE or current_state == State.NAP or current_state == State.TUCKED_IN or current_state == State.WARM_PAWS or current_state == State.STUDY or current_state == State.WINDOW_GAZE)
		if in_furniture:
			if thought_bubble and visible:
				thought_bubble.show_random_thought("petted", 2.0)
			if renderer:
				renderer._spawn_particle("heart")
			return
			
		# 3. Regular Standing Petting Bounce
		if current_state != State.PETTED:
			_previous_state = current_state
		current_state = State.PETTED
		state_timer = 0.0
		if thought_bubble and visible:
			thought_bubble.show_random_thought("petted", 2.5)
		if renderer:
			renderer._spawn_particle("heart")

func _on_pet_fed(target_pet_idx: int, item_id: String, item_data: Dictionary) -> void:
	if not visible:
		return
	if target_pet_idx >= 0 and target_pet_idx != pet_index:
		return
	_react_to_food_item(item_id, item_data)

func _on_item_used(item_id: String, item_data: Dictionary) -> void:
	if not visible:
		return
	# If multiple pets exist, _on_pet_fed handles targeted reaction to prevent all pets reacting simultaneously
	if GameState and GameState.active_pets.size() > 1:
		return
	_react_to_food_item(item_id, item_data)

func _react_to_food_item(item_id: String, _item_data: Dictionary) -> void:
	# Reset hunger prompt cooldown since pet is now being fed
	_hunger_prompt_cooldown = HUNGER_PROMPT_COOLDOWN_TIME
	
	# Drinks walk to the drink spot and use DRINK state
	var is_drink: bool = item_id in ["snack_coffee", "snack_matcha", "snack_boba"]
	if is_drink:
		var drink_thought: String = ""
		match item_id:
			"snack_coffee": drink_thought = "Delicious espresso! ☕ +25⚡"
			"snack_matcha": drink_thought = "Zen focus... fragrant matcha! 🍵✨"
			"snack_boba":   drink_thought = "Tapioca pearls! Slurp~ 🧋❤️"
		if thought_bubble:
			thought_bubble.show_thought(drink_thought, 3.5)
		# After walking to drink_x, start EATING animation with drink overlay
		_fed_item_id = item_id
		if renderer:
			renderer.feeding_item_id = item_id
			renderer.feeding_stage = 0
		walk_to(drink_x, State.EATING, floor_y)
		return
	
	# Solid food: show thought and start eating in-place
	var food_thought: String = ""
	match item_id:
		"snack_croissant":    food_thought = "Crispy & buttery flake! 🥐💖"
		"snack_donut":        food_thought = "Sprinkles & strawberry glaze! 🍩✨"
		"snack_pancake":      food_thought = "Fluffy souffle cloud pancakes! 🥞🍯"
		"snack_onigiri":      food_thought = "Tasty salmon filling! 🍙🐾"
		"snack_ramen":        food_thought = "Steaming midnight tonkotsu! 🍜🔥"
		"snack_bento":        food_thought = "Deluxe feast of champions! 🍱👑"
		"snack_energy_drink": food_thought = "SUPER CHARGED! 🥤⚡"
		"snack_mystery_box":  food_thought = "Woah, surprise snack! 🎁✨"
		_:                    food_thought = "Yum! So tasty! ❤️🐾"
	if thought_bubble:
		thought_bubble.show_thought(food_thought, 3.2)
	_play_eating_animation(item_id)

func _play_eating_animation(item_id: String) -> void:
	_fed_item_id = item_id
	_eating_timer = 0.0
	if renderer:
		renderer.feeding_item_id = item_id
		renderer.feeding_stage = 0
	_previous_state = current_state
	current_state = State.EATING
	state_timer = 0.0

func _on_energy_changed(new_energy: float, _max: float, _is_buffed: bool) -> void:
	if new_energy <= 20.0 and current_state == State.IDLE and randf() < 0.3:
		if thought_bubble and visible:
			thought_bubble.show_random_thought("low_energy", 3.0)

func _on_pet_called(_target_room: String) -> void:
	# RoomManager/GameState already updated active_pets rooms and will respawn us.
	# If we're still alive in the scene, just play a greeting bounce.
	if not is_inside_tree():
		return
	_play_summon_bounce()

func _play_summon_bounce() -> void:
	if current_state != State.PETTED:
		_previous_state = current_state
	current_state = State.PETTED
	state_timer = 0.0
	_set_renderer_state(PetRenderer.AnimState.PETTED)
	
	if thought_bubble:
		thought_bubble.show_thought("I'm here! ❤️🐾", 3.0)
		
	var base_y: float = floor_y
	var bounce_tween: Tween = create_tween()
	bounce_tween.tween_property(self, "position:y", base_y - 14.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "position:y", base_y, 0.14).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "position:y", base_y - 7.0, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "position:y", base_y, 0.10).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_pet_room_changed(_new_pet_room: String) -> void:
	_update_visibility_from_room_state()

func _on_room_changed(_room_id: String) -> void:
	_cancel_active_sequence()
	_update_visibility_from_room_state()
	position.x = clampf(position.x, min_x, max_x)
	current_target_y = floor_y
	post_target_y = floor_y
	position.y = floor_y
	if current_state == State.TYPE and (not TimerEngine or TimerEngine.status != TimerEngine.TimerStatus.RUNNING):
		current_state = State.IDLE

func _update_visibility_from_room_state() -> void:
	# Each pet uses its OWN assigned_room to determine visibility, not the global pet_room
	var is_in_view: bool = (assigned_room == GameState.active_view_room) if GameState else true
	visible = is_in_view
	if is_in_view:
		modulate.a = 1.0
	if click_area:
		click_area.set_deferred("monitoring", is_in_view)
		click_area.set_deferred("monitorable", is_in_view)

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not visible:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_perform_pet_action()
			get_viewport().set_input_as_handled()

func _perform_pet_action() -> void:
	_cancel_active_sequence()
	if GameState:
		GameState.add_joy(5.0)
		
	if EventBus:
		EventBus.pet_interacted.emit("pet")
		
	_pet_click_count += 1
	_pet_spam_timer = 2.5
	
	# 1. Annoyed Reaction if Spam Petted (4+ rapid clicks)
	if _pet_click_count >= 4:
		_pet_click_count = 0
		if thought_bubble:
			thought_bubble.show_random_thought("annoyed", 3.0)
		if renderer:
			renderer._spawn_particle("anger")
		return
		
	# Play cute purr/chirp sound
	if AudioManager:
		AudioManager.play_sfx("chirp")
			
	# 2. In-Place Petting (If resting on furniture, watching TV, sleeping, or typing)
	var in_furniture: bool = (current_state == State.WATCH_TV or current_state == State.TYPE or current_state == State.NAP or current_state == State.TUCKED_IN or current_state == State.WARM_PAWS or current_state == State.STUDY or current_state == State.WINDOW_GAZE)
	if in_furniture:
		if thought_bubble:
			thought_bubble.show_random_thought("petted", 2.0)
		if renderer:
			renderer._spawn_particle("heart")
		return
		
	# 3. Regular Standing Petting Bounce
	if current_state != State.PETTED:
		_previous_state = current_state
	current_state = State.PETTED
	state_timer = 0.0
	if thought_bubble:
		thought_bubble.show_random_thought("petted", 2.5)
	if renderer:
		renderer._spawn_particle("heart")

func _process_periodic_thoughts() -> void:
	if _periodic_thought_timer >= 25.0:
		_periodic_thought_timer = 0.0
		if not visible:
			return
		if thought_bubble and not thought_bubble._is_showing:
			match current_state:
				State.TYPE: thought_bubble.show_random_thought("working", 3.0)
				State.NAP: thought_bubble.show_random_thought("napping", 3.0)
				State.TUCKED_IN: thought_bubble.show_random_thought("bedroom_tucked", 3.0)
				State.DRINK: thought_bubble.show_random_thought("drink", 3.0)
				State.WATCH_TV: thought_bubble.show_random_thought("watch_tv", 3.0)
				State.WARM_PAWS: thought_bubble.show_random_thought("warm_paws", 3.0)
				State.STUDY: thought_bubble.show_random_thought("attic_study", 3.0)
				State.WINDOW_GAZE: thought_bubble.show_random_thought("window_gaze", 3.0)
				State.CHEF_SNIFF: thought_bubble.show_random_thought("kitchen_stove", 3.0)
				State.IDLE, State.WANDER, State.WALK_TO_TARGET:
					var profile: Dictionary = _get_time_profile()
					if profile.is_night and randf() < 0.5:
						thought_bubble.show_random_thought("night", 3.0)
					elif randf() < 0.4:
						thought_bubble.show_random_thought("idle", 3.0)

func _set_renderer_state(anim_state: PetRenderer.AnimState) -> void:
	if renderer and renderer.current_state != anim_state:
		renderer.current_state = anim_state

# ==============================================================================
# 🎭 SPECIAL IDLE INTERACTION SEQUENCE RUNNER
# ==============================================================================
func _try_start_weighted_idle_interaction() -> bool:
	if not visible:
		_special_behavior_cooldown = randf_range(20.0, 40.0)
		return false
		
	# 1. Collect eligible behaviors from Universal and Active Room pools
	var pool: Array[Dictionary] = []
	for b in UNIVERSAL_BEHAVIORS:
		var cond = b.get("condition", "")
		if cond == "timer_running":
			var is_working: bool = (TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.RUNNING)
			if not is_working:
				continue
		pool.append(b)
		
	# Room-specific candidate pools
	var cur_room: String = assigned_room if assigned_room != "" else "room_bedroom"
	match cur_room:
		"room_bedroom":
			pool.append_array(BEDROOM_BEHAVIORS)
		"room_livingroom":
			pool.append_array(LIVINGROOM_BEHAVIORS)
		"room_library":
			pool.append_array(LIBRARY_BEHAVIORS)
		"room_greenhouse":
			pool.append_array(GREENHOUSE_BEHAVIORS)
		"room_kitchen":
			pool.append_array(KITCHEN_BEHAVIORS)
		"room_styx":
			pool.append_array(STYX_BEHAVIORS)
		
	if pool.is_empty():
		_special_behavior_cooldown = randf_range(25.0, 50.0)
		return false
		
	# 2. Compute total weight and roll
	var total_weight: float = 0.0
	for b in pool:
		var r: String = b.get("rarity", "common")
		total_weight += RARITY_WEIGHTS.get(r, 60.0)
		
	var roll: float = randf_range(0.0, total_weight)
	var cumulative: float = 0.0
	var chosen: Dictionary = pool[0]
	for b in pool:
		var r: String = b.get("rarity", "common")
		cumulative += RARITY_WEIGHTS.get(r, 60.0)
		if roll <= cumulative:
			chosen = b
			break
			
	_start_behavior_sequence(chosen)
	return true

func _start_behavior_sequence(b: Dictionary) -> void:
	_active_sequence = b.duplicate(true)
	_sequence_stage = 1
	_sequence_timer = 0.0
	
	var target: String = b.get("target", "in_place")
	var target_x_pos: float = position.x
	match target:
		"desk": target_x_pos = desk_x
		"nap": target_x_pos = nap_x
		"drink": target_x_pos = drink_x
		"min_x": target_x_pos = min_x + 10.0
		"max_x": target_x_pos = max_x - 10.0
		"random_floor": target_x_pos = randf_range(min_x, max_x)
		_: target_x_pos = position.x
		
	if abs(position.x - target_x_pos) > 10.0:
		walk_to(target_x_pos, State.SPECIAL_INTERACTION, floor_y)
	else:
		_execute_primary_stage()

func _execute_primary_stage() -> void:
	current_state = State.SPECIAL_INTERACTION
	_sequence_stage = 1
	_sequence_timer = 0.0
	
	var prim: Dictionary = _active_sequence.get("primary", {})
	var anim = prim.get("anim", PetRenderer.AnimState.IDLE)
	_set_renderer_state(anim)
	
	var thought_txt: String = prim.get("thought", "")
	if thought_txt != "" and thought_bubble and visible:
		thought_bubble.show_thought(thought_txt, prim.get("duration", 3.0))
		
	var part = prim.get("particle", null)
	if part != null and renderer:
		renderer._spawn_particle(part)

func _process_special_interaction_state(delta: float) -> void:
	velocity.x = 0.0
	_sequence_timer += delta
	
	if _sequence_stage == 1:
		var prim: Dictionary = _active_sequence.get("primary", {})
		var dur: float = prim.get("duration", 3.0)
		if _sequence_timer >= dur:
			var react = _active_sequence.get("reaction", null)
			if react != null:
				_execute_reaction_stage(react)
			else:
				_finish_special_sequence()
	elif _sequence_stage == 2:
		var react: Dictionary = _active_sequence.get("reaction", {})
		var dur: float = react.get("duration", 2.0)
		if _sequence_timer >= dur:
			_finish_special_sequence()

func _execute_reaction_stage(react: Dictionary) -> void:
	_sequence_stage = 2
	_sequence_timer = 0.0
	
	var anim = react.get("anim", PetRenderer.AnimState.IDLE)
	_set_renderer_state(anim)
	
	var thought_txt: String = react.get("thought", "")
	if thought_txt != "" and thought_bubble and visible:
		thought_bubble.show_thought(thought_txt, react.get("duration", 2.5))
		
	var part = react.get("particle", null)
	if part != null and renderer:
		renderer._spawn_particle(part)
		
	var tween_type: String = react.get("tween", "")
	if tween_type == "head_shake":
		_play_head_shake_tween()
	elif tween_type == "startle_hop":
		_play_startle_hop_tween()
	elif tween_type == "happy_hop":
		_play_happy_hop_tween()
	elif tween_type == "wobble":
		_play_wobble_tween()

func _finish_special_sequence() -> void:
	_cancel_active_sequence()
	_special_behavior_cooldown = randf_range(25.0, 50.0)
	current_state = State.IDLE
	state_timer = 0.0

func _cancel_active_sequence() -> void:
	if _sequence_tween and _sequence_tween.is_valid():
		_sequence_tween.kill()
		_sequence_tween = null
	_active_sequence = {}
	_sequence_stage = 0
	_sequence_timer = 0.0
	rotation = 0.0

# ==============================================================================
# ✨ PROCEDURAL MICRO-TWEENS & REACTIVE HOOKS
# ==============================================================================
func _play_head_shake_tween() -> void:
	if _sequence_tween and _sequence_tween.is_valid():
		_sequence_tween.kill()
	_sequence_tween = create_tween()
	_sequence_tween.tween_property(self, "rotation", -0.15, 0.08)
	_sequence_tween.tween_property(self, "rotation", 0.15, 0.08)
	_sequence_tween.tween_property(self, "rotation", -0.10, 0.08)
	_sequence_tween.tween_property(self, "rotation", 0.0, 0.08)

func _play_startle_hop_tween() -> void:
	if _sequence_tween and _sequence_tween.is_valid():
		_sequence_tween.kill()
	_sequence_tween = create_tween()
	_sequence_tween.tween_property(self, "position:y", position.y - 7.0, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_sequence_tween.tween_property(self, "position:y", position.y, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _play_happy_hop_tween() -> void:
	if _sequence_tween and _sequence_tween.is_valid():
		_sequence_tween.kill()
	_sequence_tween = create_tween()
	_sequence_tween.tween_property(self, "position:y", position.y - 5.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_sequence_tween.tween_property(self, "position:y", position.y, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _play_wobble_tween() -> void:
	if _sequence_tween and _sequence_tween.is_valid():
		_sequence_tween.kill()
	_sequence_tween = create_tween()
	_sequence_tween.tween_property(self, "rotation", 0.22, 0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_sequence_tween.tween_property(self, "rotation", -0.08, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_sequence_tween.tween_property(self, "rotation", 0.0, 0.08)

func _on_coins_changed(_new_balance: int, amount_delta: int, _reason: String) -> void:
	if amount_delta > 0 and current_state == State.IDLE and visible:
		if thought_bubble and not thought_bubble._is_showing:
			thought_bubble.show_thought("+Coins! 🪙✨", 2.0)
		if renderer:
			renderer._spawn_particle("star")
		_play_happy_hop_tween()

# ==============================================================================
# 🐾 LIVING HOUSEHOLD, BUDDY TRAVEL, FETCH & EXPEDITION HANDLERS
# ==============================================================================
func _process_socializing_state(delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.IDLE)
	
	if state_timer == delta:
		# First frame of social interaction arrival!
		if is_instance_valid(_social_partner_node):
			if renderer:
				renderer.facing_right = (_social_partner_node.position.x > position.x)
			if _social_partner_node.renderer:
				_social_partner_node.renderer.facing_right = (position.x > _social_partner_node.position.x)
				
			var p_name: String = _social_partner_node.pet_name
			var topic: String = ""
			if thought_bubble and visible:
				topic = thought_bubble.show_social_initiator(p_name)
			if renderer:
				renderer._spawn_particle("heart")
			_play_happy_hop_tween()
			
			EventBus.pet_social_started.emit(pet_index, _social_partner_node.pet_index, topic)
			
			# Partner responds after 0.8s
			var partner_ref = _social_partner_node
			var self_name = pet_name
			var timer = get_tree().create_timer(0.8)
			timer.timeout.connect(func():
				if is_instance_valid(partner_ref) and partner_ref.visible:
					partner_ref.play_social_response(self_name)
			)
			
			if GameState:
				GameState.adjust_pet_joy(pet_index, 5.0)
				GameState.adjust_pet_joy(_social_partner_node.pet_index, 5.0)
				
	if state_timer >= 3.6:
		if is_instance_valid(_social_partner_node):
			_social_partner_node._is_social_partner = false
			_social_partner_node._social_partner_node = null
		_is_social_partner = false
		_social_partner_node = null
		current_state = State.IDLE
		state_timer = 0.0

func play_social_response(partner_name: String) -> void:
	if thought_bubble and visible:
		thought_bubble.show_social_reply(partner_name)
	if renderer:
		renderer._spawn_particle("heart")
	_play_happy_hop_tween()

func _try_multi_pet_social() -> bool:
	if not get_parent():
		return false
	var candidates: Array[PetBrain] = []
	for child in get_parent().get_children():
		if child is PetBrain and child != self and is_instance_valid(child) and child.visible:
			if child.current_state in [State.IDLE, State.WINDOW_GAZE, State.WARM_PAWS] and not child._is_social_partner:
				candidates.append(child)
	if candidates.is_empty():
		return false
		
	var partner: PetBrain = candidates.pick_random()
	_is_social_partner = true
	partner._is_social_partner = true
	_social_partner_node = partner
	partner._social_partner_node = self
	
	# Determine meeting position (22px apart)
	var meet_x: float = partner.position.x + (-22.0 if position.x < partner.position.x else 22.0)
	meet_x = clampf(meet_x, min_x + 5.0, max_x - 5.0)
	
	_cancel_active_sequence()
	target_x = meet_x
	post_target_state = State.SOCIALIZING
	post_target_y = floor_y
	current_target_y = floor_y
	current_state = State.WALK_TO_TARGET
	state_timer = 0.0
	_set_renderer_state(PetRenderer.AnimState.WALK)
	if renderer:
		renderer.facing_right = (meet_x > position.x)
	return true

func accept_buddy_invite(leader: PetBrain, target_room: String, door_x: float) -> void:
	if thought_bubble and visible:
		thought_bubble.show_buddy_accept()
	_buddy_leader_node = leader
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		walk_to_door_and_exit(target_room, door_x)
	)

func _process_following_state(_delta: float) -> void:
	if is_instance_valid(_buddy_leader_node):
		var lead_x: float = _buddy_leader_node.position.x
		var follow_offset: float = -22.0 if _buddy_leader_node.velocity.x >= 0 else 22.0
		var target_follow_x = lead_x + follow_offset
		if abs(position.x - target_follow_x) > 6.0:
			velocity.x = signf(target_follow_x - position.x) * walk_speed
			_set_renderer_state(PetRenderer.AnimState.WALK)
			if renderer:
				renderer.facing_right = (velocity.x > 0)
			move_and_slide()
		else:
			velocity.x = 0.0
			_set_renderer_state(PetRenderer.AnimState.IDLE)
	else:
		current_state = State.IDLE

func _try_start_autonomous_expedition() -> bool:
	if not GameState or not visible or is_queued_for_deletion():
		return false
	if GameState.is_pet_newcomer(pet_index) or GameState.is_pet_outside(pet_index):
		return false
	if GameState.study_buddy_idx == pet_index:
		return false
	if randf() > 0.25:
		return false
		
	var destinations: Array[String] = ["the garden", "the backyard", "the patio", "the woods"]
	var dest: String = destinations.pick_random()
	
	if thought_bubble and visible:
		thought_bubble.show_expedition_depart(dest)
		
	var exit_door_x: float = min_x - 14.0 if randf() < 0.5 else max_x + 14.0
	_cancel_active_sequence()
	target_x = exit_door_x
	post_target_state = State.DEPARTING_OUTSIDE
	post_target_y = floor_y
	current_target_y = floor_y
	current_state = State.WALK_TO_TARGET
	state_timer = 0.0
	_set_renderer_state(PetRenderer.AnimState.WALK)
	if renderer:
		renderer.facing_right = (exit_door_x > position.x)
	return true

func _process_departing_outside_state(_delta: float) -> void:
	if GameState:
		GameState.start_pet_expedition(pet_index, 0.0, "garden")
		
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		queue_free()
	)
	current_state = State.IDLE

func _try_autonomous_companion_fetch() -> bool:
	if not GameState or GameState.active_pets.size() <= 1:
		return false
	if assigned_room != GameState.active_view_room:
		return false
		
	var separated: Array[int] = []
	for i in range(GameState.active_pets.size()):
		var p = GameState.active_pets[i]
		if i != pet_index and not p.get("is_outside", false) and p.get("room", "") != assigned_room:
			separated.append(i)
			
	if separated.is_empty():
		return false
		
	if randf() > 0.30:
		return false
		
	start_fetch_mission(separated.pick_random())
	return true

func start_fetch_mission(target_idx: int) -> void:
	if target_idx < 0 or target_idx >= GameState.active_pets.size():
		return
	var target_p = GameState.active_pets[target_idx]
	var target_name = target_p.get("name", "friend")
	
	if thought_bubble and visible:
		thought_bubble.show_fetch_depart(target_name)
		
	var dir = GameState.get_room_direction(assigned_room, target_p.get("room", "room_bedroom"))
	var door_x = min_x - 14.0 if dir <= 0 else max_x + 14.0
	
	_cancel_active_sequence()
	target_x = door_x
	post_target_state = State.FETCHING
	post_target_y = floor_y
	current_target_y = floor_y
	current_state = State.WALK_TO_TARGET
	state_timer = 0.0
	_fetching_target_pet_id = target_p.get("id", "")
	_set_renderer_state(PetRenderer.AnimState.WALK)
	if renderer:
		renderer.facing_right = (door_x > position.x)

func _process_fetching_state(_delta: float) -> void:
	if GameState:
		for i in range(GameState.active_pets.size()):
			if GameState.active_pets[i].get("id", "") == _fetching_target_pet_id:
				GameState.send_pet_to_fetch(pet_index, i)
				break
				
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		queue_free()
	)
	current_state = State.IDLE
