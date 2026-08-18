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

# Random thought pools
const THOUGHTS_WORK_START: Array[String] = [
	"Focus time! 💻",
	"Let's get to work! ✨",
	"In the zone! 🚀",
	"Deep work mode on!",
	"Leveling up today!"
]

const THOUGHTS_WORKING: Array[String] = [
	"Writing clean code...",
	"Typing away! 🐾",
	"Crushing goals!",
	"So focused!",
	"Almost there!"
]

const THOUGHTS_BREAK: Array[String] = [
	"Need a coffee... ☕",
	"Time to stretch! 🐾",
	"Ahhh, break time!",
	"Cozy rest time~",
	"Yum, snack time!"
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
	"Need snacks!"
]

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

## Helper to show random thought from category
func show_random_thought(category: String, duration: float = 3.5) -> void:
	var pool: Array[String] = []
	match category:
		"work_start": pool = THOUGHTS_WORK_START
		"working": pool = THOUGHTS_WORKING
		"break": pool = THOUGHTS_BREAK
		"streak": pool = THOUGHTS_STREAK
		"petted": pool = THOUGHTS_PETTED
		"low_energy": pool = THOUGHTS_LOW_ENERGY
		_: pool = THOUGHTS_WORKING
		
	if pool.size() > 0:
		var text: String = pool[randi() % pool.size()]
		show_thought(text, duration)
