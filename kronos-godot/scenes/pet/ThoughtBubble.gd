extends Node2D
class_name ThoughtBubble

## Cozy Thought Bubble for Kronos Pet Companion.
## Renders a pixel-styled speech/thought bubble above the pet with smooth pop-in/out.

@onready var container: PanelContainer = $Container
@onready var label: Label = $Container/Margin/Label
@onready var tail_dot1: ColorRect = $TailDot1
@onready var tail_dot2: ColorRect = $TailDot2

var _tween: Tween
var _hide_timer: float = 0.0
var _is_showing: bool = false
var species: String = "shiba"

# ==============================================================================
# 💭 CONTEXT-BOUND THOUGHT POOLS
# ==============================================================================
const THOUGHTS_WORK_START: Array[String] = [
	"Focus time! 💻",
	"Let's get to work! ✨",
	"In the zone! 🚀",
	"Deep work mode on!",
	"Leveling up today!"
]

const THOUGHTS_WORK_JOIN_SHIBA: Array[String] = [
	"Let's work together! 💻",
	"I'll help you code! ✨",
	"Joining focus mode! 🐾",
	"Coding buddy on duty! 🚀"
]
const THOUGHTS_WORK_JOIN_PENGUIN: Array[String] = [
	"Taking notes! 📋",
	"I'll organize the data! ✨",
	"Clipboard ready! 🐧",
	"Note-taking buddy! 🚀"
]
const THOUGHTS_WORK_JOIN_BUNNY: Array[String] = [
	"Sorting the files! 📑",
	"I'll organize everything! ✨",
	"Paper sorting time! 🐰",
	"Filing buddy on duty! 🚀"
]
const THOUGHTS_WORK_JOIN_FOX: Array[String] = [
	"Studying the scrolls! 📜",
	"I'll research this! ✨",
	"Deep study mode! 🦊",
	"Research buddy on duty! 🚀"
]
const THOUGHTS_WORK_JOIN_CAT: Array[String] = [
	"Supervising you~ 👀",
	"I'll watch from here! ✨",
	"Quality control! 🐱",
	"Manager on duty~ 🚀"
]

const THOUGHTS_WORKING: Array[String] = [
	"Writing clean code... 💻",
	"Typing away! 🐾",
	"Crushing bugs! ✨",
	"So focused!",
	"Almost there!"
]

const THOUGHTS_GO_TO_SLEEP_SHIBA: Array[String] = [
	"Zzz... cozy nap time 💤",
	"Power nap incoming~",
	"Curling up for a bit ✨",
	"Paws need a rest 💤"
]
const THOUGHTS_GO_TO_SLEEP_PENGUIN: Array[String] = [
	"Zzz... cozy nap time 💤",
	"Huddle nap incoming~",
	"Tucking in for a bit ✨",
	"Flippers need a rest 💤"
]
const THOUGHTS_GO_TO_SLEEP_BUNNY: Array[String] = [
	"Zzz... cozy nap time 💤",
	"Bunny loaf incoming~",
	"Folding my ears down ✨",
	"Ears need a rest 💤"
]
const THOUGHTS_GO_TO_SLEEP_FOX: Array[String] = [
	"Zzz... cozy nap time 💤",
	"Tail-wrap nap incoming~",
	"Curling up tight ✨",
	"Tail needs a rest 💤"
]
const THOUGHTS_GO_TO_SLEEP_CAT: Array[String] = [
	"Time for a catnap~ 💤",
	"Power nap incoming~",
	"Curling into a ball ✨",
	"Catnap o'clock 💤"
]

const THOUGHTS_NAPPING_SHIBA: Array[String] = [
	"Zzz... 💭",
	"*dreaming of treats* 🥐",
	"Zzz... 💤",
	"*soft snores* ✨",
	"Zzz... 🌙"
]
const THOUGHTS_NAPPING_PENGUIN: Array[String] = [
	"Zzz... 💭",
	"*dreaming of fish* 🐟",
	"Zzz... 💤",
	"*soft peeps* ✨",
	"Zzz... 🌙"
]
const THOUGHTS_NAPPING_BUNNY: Array[String] = [
	"Zzz... 💭",
	"*dreaming of carrots* 🥕",
	"Zzz... 💤",
	"*nose twitches in sleep* ✨",
	"Zzz... 🌙"
]
const THOUGHTS_NAPPING_FOX: Array[String] = [
	"Zzz... 💭",
	"*dreaming of berries* 🫐",
	"Zzz... 💤",
	"*tail twitches in sleep* ✨",
	"Zzz... 🌙"
]
const THOUGHTS_NAPPING_CAT: Array[String] = [
	"Zzz... 💭",
	"*dreaming of yarn* 🧶",
	"Zzz... 💤",
	"*soft purring* ✨",
	"Zzz... 🌙"
]

const THOUGHTS_STRETCH_WANDER_SHIBA: Array[String] = [
	"Time to stretch my paws! 🐾",
	"Going for a little walk~",
	"Standing up to stretch! ✨",
	"Just taking a stroll~ 🐾"
]
const THOUGHTS_STRETCH_WANDER_PENGUIN: Array[String] = [
	"Time for a waddle! 🐧",
	"Going for a little slide~",
	"Stretching my flippers! ✨",
	"Just waddling around~ 🐧"
]
const THOUGHTS_STRETCH_WANDER_BUNNY: Array[String] = [
	"Time for a hop! 🐰",
	"Going for a little bounce~",
	"Stretching my ears! ✨",
	"Just hopping around~ 🐰"
]
const THOUGHTS_STRETCH_WANDER_FOX: Array[String] = [
	"Time to prowl! 🦊",
	"Going for a little trot~",
	"Stretching out! ✨",
	"Just scouting around~ 🦊"
]
const THOUGHTS_STRETCH_WANDER_CAT: Array[String] = [
	"Time to slink around~ 🐱",
	"Going for a little prowl~",
	"Stretching my claws! ✨",
	"Just exploring~ 🐱"
]

const THOUGHTS_DRINK: Array[String] = [
	"Need some fresh water 💧",
	"Cozy drink break ☕",
	"Sip time! 🍵",
	"Grabbing a beverage ✨"
]

const THOUGHTS_IDLE_SHIBA: Array[String] = [
	"Sniffing around~ 🐾",
	"What a peaceful day ✨",
	"Looking around the room 🌿",
	"Exploring the house! 🐾"
]
const THOUGHTS_IDLE_PENGUIN: Array[String] = [
	"Waddling around~ 🐧",
	"What a peaceful day ✨",
	"Surveying the room 🌿",
	"Exploring the house! 🐧"
]
const THOUGHTS_IDLE_BUNNY: Array[String] = [
	"Hopping around~ 🐰",
	"What a peaceful day ✨",
	"Ears perked up! 🌿",
	"Exploring the house! 🐰"
]
const THOUGHTS_IDLE_FOX: Array[String] = [
	"Prowling around~ 🦊",
	"What a peaceful day ✨",
	"Ears rotating! 🌿",
	"Scouting the house! 🦊"
]
const THOUGHTS_IDLE_CAT: Array[String] = [
	"Slinking around~ 🐱",
	"What a peaceful day ✨",
	"Watching everything 🌿",
	"Patrolling my domain! 🐱"
]

const THOUGHTS_STREAK: Array[String] = [
	"Great streak! 🔥",
	"You're on fire! 🔥",
	"Unstoppable momentum!",
	"Focus champion! 🏆"
]

const THOUGHTS_PETTED_SHIBA: Array[String] = [
	"Woof! ❤️",
	"*happy shiba noises*",
	"Best human ever! 🥰",
	"So cozy! ✨",
	"Tail wagging fast!"
]

const THOUGHTS_PETTED_PENGUIN: Array[String] = [
	"Noot noot! ❤️",
	"*happy waddle*",
	"Best human ever! 🥰",
	"So warm! ✨",
	"Flipper flap!"
]

const THOUGHTS_PETTED_BUNNY: Array[String] = [
	"*nose wiggle* ❤️",
	"*binky jump!*",
	"Best human ever! 🥰",
	"So soft! ✨",
	"Thump thump!"
]

const THOUGHTS_PETTED_FOX: Array[String] = [
	"*yip yip!* ❤️",
	"*sly happy grin*",
	"Best human ever! 🥰",
	"So cozy! ✨",
	"Brush tail swish!"
]

const THOUGHTS_PETTED_CAT: Array[String] = [
	"*purrr~* ❤️",
	"*happy kneading*",
	"Best human ever! 🥰",
	"So warm~ ✨",
	"Mrrrow~! ✨"
]

const THOUGHTS_LOW_ENERGY: Array[String] = [
	"Running low on energy... ⚡",
	"A coffee would help!",
	"Yawning... *yawn*",
	"Need snacks! 🥐"
]

const THOUGHTS_NIGHT: Array[String] = [
	"Getting sleepy... 🌙",
	"Yawn... time for bed 💤",
	"Such a quiet night ✨",
	"Resting my paws~",
	"Zzz... so cozy 🌙"
]

const THOUGHTS_BEDROOM_TUCKED: Array[String] = [
	"So warm under the blanket... 🛏️💤",
	"Zzz... sweetest dreams ✨",
	"Tucked in so snug~ 🌙",
	"Coziest bed in the world 💤"
]

const THOUGHTS_WINDOW_GAZE: Array[String] = [
	"Such a refreshing breeze! 🪟✨",
	"Watching the clouds drift by~",
	"Love this fresh air! 🌿",
	"Look at the season outside! 🌸"
]

const THOUGHTS_WATCH_TV: Array[String] = [
	"Whoa, look at that 8-bit jump! 📺🎮",
	"What an intense boss fight! ✨",
	"My favorite retro show! 🐾",
	"Just one more episode... 🛋️",
	"Level cleared! 🎮✨"
]

const THOUGHTS_WARM_PAWS: Array[String] = [
	"Crackling fire is so soothing... 🔥",
	"Toasting my paws~ ✨",
	"Warmest hearth ever! 🛋️",
	"So cozy by the embers 🔥",
	"Fireplace warmth feels amazing! ✨"
]

const THOUGHTS_ATTIC_STUDY: Array[String] = [
	"Deciphering ancient runes... 📖✨",
	"Fascinating chapter on stars! 📚",
	"Studying deep in the archives 🕯️",
	"Knowledge +10! 🧠✨",
	"Ancient wisdom revealed! 📜"
]

const THOUGHTS_ATTIC_ARMCHAIR: Array[String] = [
	"The green armchair is pure luxury ✨",
	"Curling up in the velvet cushions~",
	"Reading nook perfection 📚💤",
	"Softest chair in the archive 🌿"
]

const THOUGHTS_KITCHEN_STOVE: Array[String] = [
	"Mmm, stew smells so savory! 🍲✨",
	"Bubbling soup is almost ready!",
	"Chef is on duty! 🐾",
	"Smells delicious in here! 🍲"
]

const THOUGHTS_KITCHEN_OVEN: Array[String] = [
	"Hot golden croissants! 🥐✨",
	"Pastry aroma is heavenly~",
	"Waiting for treats to cool down! 😋",
	"Fresh baked goodness! 🥐"
]

const THOUGHTS_KITCHEN_COFFEE: Array[String] = [
	"Fresh espresso aroma! ☕✨",
	"Morning brew hits the spot~",
	"Coziest cafe vibes 🥐☕",
	"Sipping warmth! ☕"
]

const THOUGHTS_KITCHEN_CHOPPING: Array[String] = [
	"Dicing carrots for dinner! 🥕✨",
	"Chop chop chop! 🔪🐾",
	"Food prep master! 🥗",
	"Fresh veggies ready! 🥕"
]

const THOUGHTS_GREENHOUSE: Array[String] = [
	"Blooming cherry blossoms! 🌸✨",
	"Sniffing the fresh monsteras 🌿",
	"Such peaceful green energy~ 🍃",
	"Catching falling petals! 🌸"
]

const THOUGHTS_ANNOYED: Array[String] = [
	"Hey, that tickles! >_<",
	"Too many pats! 💢",
	"Paws off for a sec! 🐾",
	"Overstimulated! (,,>﹏<,,)",
	"Grumpy mode activated! 💢"
]

const THOUGHTS_STARTLED: Array[String] = [
	"Eep! What was that noise?! ⚡",
	"Whoa! Careful there! 🐾",
	"Heard that loud and clear! 👂",
	"Did something drop?! 💥"
]

# ==============================================================================
# ⚙️ LIFECYCLE & METHODS
# ==============================================================================
func _ready() -> void:
	visible = false
	modulate.a = 0.0

func _process(delta: float) -> void:
	if _is_showing:
		_hide_timer -= delta
		if _hide_timer <= 0.0:
			hide_thought()

## Displays a custom thought text with smooth pop-in animation
func show_thought(text: String, duration: float = 3.5) -> void:
	if not label:
		return
		
	label.text = text
	_hide_timer = duration
	_is_showing = true
	visible = true
	
	if _tween and _tween.is_valid():
		_tween.kill()
		
	_tween = create_tween().set_parallel(true)
	scale = Vector2(0.3, 0.3)
	modulate.a = 0.0
	
	_tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate:a", 1.0, 0.20)

## Smoothly dismisses the thought bubble
func hide_thought() -> void:
	if not _is_showing:
		return
		
	_is_showing = false
	if _tween and _tween.is_valid():
		_tween.kill()
		
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	_tween.chain().tween_callback(func(): visible = false)

## Helper to show random thought from a category
func _get_species_pool(base_category: String) -> Array[String]:
	var suffix: String = "_SHIBA"
	match species:
		"penguin": suffix = "_PENGUIN"
		"bunny": suffix = "_BUNNY"
		"fox": suffix = "_FOX"
		"cat": suffix = "_CAT"
	
	# Try species-specific pool first, fall back to generic
	match base_category + suffix:
		# Petted
		"petted_SHIBA": return THOUGHTS_PETTED_SHIBA
		"petted_PENGUIN": return THOUGHTS_PETTED_PENGUIN
		"petted_BUNNY": return THOUGHTS_PETTED_BUNNY
		"petted_FOX": return THOUGHTS_PETTED_FOX
		"petted_CAT": return THOUGHTS_PETTED_CAT
		# Stretch/Wander
		"stretch_wander_SHIBA": return THOUGHTS_STRETCH_WANDER_SHIBA
		"stretch_wander_PENGUIN": return THOUGHTS_STRETCH_WANDER_PENGUIN
		"stretch_wander_BUNNY": return THOUGHTS_STRETCH_WANDER_BUNNY
		"stretch_wander_FOX": return THOUGHTS_STRETCH_WANDER_FOX
		"stretch_wander_CAT": return THOUGHTS_STRETCH_WANDER_CAT
		# Go to sleep
		"go_to_sleep_SHIBA": return THOUGHTS_GO_TO_SLEEP_SHIBA
		"go_to_sleep_PENGUIN": return THOUGHTS_GO_TO_SLEEP_PENGUIN
		"go_to_sleep_BUNNY": return THOUGHTS_GO_TO_SLEEP_BUNNY
		"go_to_sleep_FOX": return THOUGHTS_GO_TO_SLEEP_FOX
		"go_to_sleep_CAT": return THOUGHTS_GO_TO_SLEEP_CAT
		# Work join
		"work_join_SHIBA": return THOUGHTS_WORK_JOIN_SHIBA
		"work_join_PENGUIN": return THOUGHTS_WORK_JOIN_PENGUIN
		"work_join_BUNNY": return THOUGHTS_WORK_JOIN_BUNNY
		"work_join_FOX": return THOUGHTS_WORK_JOIN_FOX
		"work_join_CAT": return THOUGHTS_WORK_JOIN_CAT
		# Napping
		"napping_SHIBA": return THOUGHTS_NAPPING_SHIBA
		"napping_PENGUIN": return THOUGHTS_NAPPING_PENGUIN
		"napping_BUNNY": return THOUGHTS_NAPPING_BUNNY
		"napping_FOX": return THOUGHTS_NAPPING_FOX
		"napping_CAT": return THOUGHTS_NAPPING_CAT
		# Idle
		"idle_SHIBA": return THOUGHTS_IDLE_SHIBA
		"idle_PENGUIN": return THOUGHTS_IDLE_PENGUIN
		"idle_BUNNY": return THOUGHTS_IDLE_BUNNY
		"idle_FOX": return THOUGHTS_IDLE_FOX
		"idle_CAT": return THOUGHTS_IDLE_CAT
	return []

func show_random_thought(category: String, duration: float = 3.5) -> void:
	var pool: Array[String] = []
	
	# Try species-specific pool first for categories that have them
	var species_categories: Array[String] = ["petted", "stretch_wander", "go_to_sleep", "work_join", "napping", "idle"]
	if category in species_categories:
		pool = _get_species_pool(category)
	
	# Fall back to generic pools
	if pool.is_empty():
		match category:
			"work_start": pool = THOUGHTS_WORK_START
			"working": pool = THOUGHTS_WORKING
			"streak": pool = THOUGHTS_STREAK
			"annoyed": pool = THOUGHTS_ANNOYED
			"startled": pool = THOUGHTS_STARTLED
			"low_energy": pool = THOUGHTS_LOW_ENERGY
			"night": pool = THOUGHTS_NIGHT
			"bedroom_tucked": pool = THOUGHTS_BEDROOM_TUCKED
			"window_gaze": pool = THOUGHTS_WINDOW_GAZE
			"watch_tv": pool = THOUGHTS_WATCH_TV
			"warm_paws": pool = THOUGHTS_WARM_PAWS
			"attic_study": pool = THOUGHTS_ATTIC_STUDY
			"attic_armchair": pool = THOUGHTS_ATTIC_ARMCHAIR
			"kitchen_stove": pool = THOUGHTS_KITCHEN_STOVE
			"kitchen_oven": pool = THOUGHTS_KITCHEN_OVEN
			"kitchen_coffee": pool = THOUGHTS_KITCHEN_COFFEE
			"kitchen_chopping": pool = THOUGHTS_KITCHEN_CHOPPING
			"greenhouse": pool = THOUGHTS_GREENHOUSE
			_: pool = THOUGHTS_IDLE_SHIBA
	
	if pool.size() > 0:
		var text: String = pool[randi() % pool.size()]
		show_thought(text, duration)

