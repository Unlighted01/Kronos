extends Control
class_name MinigameHub

## 🕹️ Break-Time Arcade Hub Modal for Kronos.
## High score tracking, quick break launchers, and instant rewards.

signal hub_closed()

@onready var close_btn: Button = $Panel/VBox/Header/CloseButton
@onready var play_snack_btn: Button = $Panel/VBox/GamesVBox/SnackCatchRow/HBox/PlayButton
@onready var play_plant_btn: Button = $Panel/VBox/GamesVBox/PlantBloomRow/HBox/PlayButton
@onready var play_memory_btn: Button = $Panel/VBox/GamesVBox/MemoryMatchRow/HBox/PlayButton

@onready var snack_high_label: Label = $Panel/VBox/GamesVBox/SnackCatchRow/HBox/InfoVBox/DescLabel
@onready var plant_high_label: Label = $Panel/VBox/GamesVBox/PlantBloomRow/HBox/InfoVBox/DescLabel
@onready var memory_high_label: Label = $Panel/VBox/GamesVBox/MemoryMatchRow/HBox/InfoVBox/DescLabel

func _ready() -> void:
	if close_btn: close_btn.pressed.connect(_on_close_pressed)
	if play_snack_btn: play_snack_btn.pressed.connect(func(): _launch_game("res://scenes/minigames/SnackCatchGame.tscn"))
	if play_plant_btn: play_plant_btn.pressed.connect(func(): _launch_game("res://scenes/minigames/PlantBloomGame.tscn"))
	if play_memory_btn: play_memory_btn.pressed.connect(func(): _launch_game("res://scenes/minigames/MemoryMatchGame.tscn"))
	_refresh_high_scores()

func _refresh_high_scores() -> void:
	if not GameState:
		return
	if snack_high_label:
		snack_high_label.text = "Catch falling treats! 👑 Best: %d pts" % GameState.get_minigame_high_score("snack_catch")
	if plant_high_label:
		plant_high_label.text = "Melodic herbarium! 👑 Best: %d" % GameState.get_minigame_high_score("plant_bloom")
	if memory_high_label:
		memory_high_label.text = "Recall card pairs! 👑 Best: %ds left" % GameState.get_minigame_high_score("memory_match")

func _launch_game(scene_path: String) -> void:
	if AudioManager: AudioManager.play_sfx("click")
		
	var scene = load(scene_path)
	if scene:
		var game_instance: Control = scene.instantiate()
		game_instance.position = Vector2.ZERO
		game_instance.size = Vector2(236, 140)
		game_instance.custom_minimum_size = Vector2(236, 140)
		game_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		var p = get_parent()
		if p: p.add_child(game_instance)
		queue_free()

func _on_close_pressed() -> void:
	if AudioManager: AudioManager.play_sfx("click")
	hub_closed.emit()
	queue_free()
