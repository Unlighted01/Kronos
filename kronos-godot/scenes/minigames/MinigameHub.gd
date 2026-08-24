extends Control
class_name MinigameHub

## 🕹️ Break-Time Arcade Hub Modal for Kronos.
## Allows Kian to pick between Snack Catch, Plant Bloom, and Attic Memory Match during Pomodoro breaks!

signal hub_closed()

# ==============================================================================
# 🎛️ UI REFERENCES
# ==============================================================================
@onready var close_btn: Button = $Panel/VBox/Header/CloseButton
@onready var play_snack_btn: Button = $Panel/VBox/GamesVBox/SnackCatchRow/HBox/PlayButton
@onready var play_plant_btn: Button = $Panel/VBox/GamesVBox/PlantBloomRow/HBox/PlayButton
@onready var play_memory_btn: Button = $Panel/VBox/GamesVBox/MemoryMatchRow/HBox/PlayButton

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
	if play_snack_btn:
		play_snack_btn.pressed.connect(func(): _launch_game("res://scenes/minigames/SnackCatchGame.tscn"))
	if play_plant_btn:
		play_plant_btn.pressed.connect(func(): _launch_game("res://scenes/minigames/PlantBloomGame.tscn"))
	if play_memory_btn:
		play_memory_btn.pressed.connect(func(): _launch_game("res://scenes/minigames/MemoryMatchGame.tscn"))

func _launch_game(scene_path: String) -> void:
	if AudioManager:
		AudioManager.play_sfx("click")
		
	var scene = load(scene_path)
	if scene:
		var game_instance: Control = scene.instantiate()
		game_instance.position = Vector2.ZERO
		game_instance.size = Vector2(236, 140)
		game_instance.custom_minimum_size = Vector2(236, 140)
		game_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var p = get_parent()
		if p:
			p.add_child(game_instance)
		queue_free()

func _on_close_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("click")
	hub_closed.emit()
	queue_free()
