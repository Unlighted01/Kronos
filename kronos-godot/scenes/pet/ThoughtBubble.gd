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

const THOUGHTS_WORK_JOIN: Array[String] = [
	"Let's work together! 💻",
	"I'll help you code! ✨",
	"Joining focus mode! 🐾",
	"Coding buddy on duty! 🚀"
]

const THOUGHTS_WORKING: Array[String] = [
	"Writing clean code... 💻",
	"Typing away! 🐾",
	"Crushing bugs! ✨",
	"So focused!",
	"Almost there!"
]

const THOUGHTS_GO_TO_SLEEP: Array[String] = [
	"Zzz... cozy nap time 💤",
	"Power nap incoming~",
	"Curling up for a bit ✨",
	"Paws need a rest 💤"
]

const THOUGHTS_NAPPING: Array[String] = [
	"Zzz... 💭",
	"*dreaming of treats* 🥐",
	"Zzz... 💤",
	"*soft snores* ✨",
	"Zzz... 🌙"
]

const THOUGHTS_STRETCH_WANDER: Array[String] = [
	"Time to stretch my paws! 🐾",
	"Going for a little walk~",
	"Standing up to stretch! ✨",
	"Just taking a stroll~ 🐾"
]

const THOUGHTS_DRINK: Array[String] = [
	"Need some fresh water 💧",
	"Cozy drink break ☕",
	"Sip time! 🍵",
	"Grabbing a beverage ✨"
]

const THOUGHTS_IDLE: Array[String] = [
	"Sniffing around~ 🐾",
	"What a peaceful day ✨",
	"Looking around the room 🌿",
	"Exploring the house! 🐾"
]

const THOUGHTS_STREAK: Array[String] = [
	"Great streak! 🔥",
	"You're on fire! 🔥",
	"Unstoppable momentum!",
	"Focus champion! 🏆"
]

const THOUGHTS_PETTED: Array[String] = [
	"Woof! ❤️",
	"*happy shiba noises*",
	"Best human ever! 🥰",
	"So cozy! ✨",
	"Tail wagging fast!"
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
func show_random_thought(category: String, duration: float = 3.5) -> void:
	var pool: Array[String] = []
	match category:
		"work_start": pool = THOUGHTS_WORK_START
		"work_join": pool = THOUGHTS_WORK_JOIN
		"working": pool = THOUGHTS_WORKING
		"go_to_sleep": pool = THOUGHTS_GO_TO_SLEEP
		"napping": pool = THOUGHTS_NAPPING
		"stretch_wander": pool = THOUGHTS_STRETCH_WANDER
		"drink": pool = THOUGHTS_DRINK
		"idle": pool = THOUGHTS_IDLE
		"streak": pool = THOUGHTS_STREAK
		"petted": pool = THOUGHTS_PETTED
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
		"greenhouse": pool = THOUGHTS_GREENHOUSE
		_: pool = THOUGHTS_IDLE
		
	if pool.size() > 0:
		var text: String = pool[randi() % pool.size()]
		show_thought(text, duration)
