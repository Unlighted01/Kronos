extends Control
class_name SplashIntro

## 🎬 Mythic Card Flip Opening Animation for Kronos.
## Plays an indie studio reveal, 3D card flip animation revealing the Sovereign Shiba Pet RPG emblem,
## radiant celestial flash, and retro crystal fanfare on launch.

signal splash_finished()

@onready var bg_rect: ColorRect = $Background
@onready var studio_label: Label = $CenterContainer/VBox/StudioLabel
@onready var logo_container: VBoxContainer = $CenterContainer/VBox/LogoContainer
@onready var card_stage: Control = $CenterContainer/VBox/LogoContainer/CardStage
@onready var sparkle_canvas: Control = $CenterContainer/VBox/LogoContainer/CardStage/SparkleCanvas
@onready var card_root: Control = $CenterContainer/VBox/LogoContainer/CardStage/CardRoot
@onready var card_back: TextureRect = $CenterContainer/VBox/LogoContainer/CardStage/CardRoot/CardBack
@onready var card_front: TextureRect = $CenterContainer/VBox/LogoContainer/CardStage/CardRoot/CardFront
@onready var card_gleam: ColorRect = $CenterContainer/VBox/LogoContainer/CardStage/CardRoot/CardGleam
@onready var title_label: Label = $CenterContainer/VBox/LogoContainer/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/VBox/LogoContainer/SubtitleLabel
@onready var prompt_label: Label = $CenterContainer/VBox/PromptLabel

var _time: float = 0.0
var _is_skipped: bool = false
var _particles: Array[Dictionary] = []
var _is_flipped: bool = false

func _ready() -> void:
	z_index = 150
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	if sparkle_canvas and not sparkle_canvas.draw.is_connected(_on_sparkle_draw):
		sparkle_canvas.draw.connect(_on_sparkle_draw)
		
	# Initial visibility & transform states
	if studio_label:
		studio_label.modulate.a = 0.0
	if logo_container:
		logo_container.modulate.a = 0.0
	if prompt_label:
		prompt_label.modulate.a = 0.0
	if title_label:
		title_label.modulate.a = 0.0
	if subtitle_label:
		subtitle_label.modulate.a = 0.0
		
	if card_root:
		card_root.pivot_offset = Vector2(42.0, 58.0)
		card_root.scale = Vector2(0.9, 0.9)
	if card_back:
		card_back.visible = true
	if card_front:
		card_front.visible = false
	if card_gleam:
		card_gleam.modulate.a = 0.0
		
	# Spawn initial sparkles
	for i in range(24):
		_spawn_sparkle()
		
	_start_boot_sequence()

func _input(event: InputEvent) -> void:
	if _is_skipped:
		return
	if event is InputEventKey and event.pressed:
		_skip_intro()
	elif event is InputEventMouseButton and event.pressed:
		_skip_intro()

func _process(delta: float) -> void:
	_time += delta
	_update_sparkles(delta)
	
	# Gentle floating card bob
	if card_root and not _is_skipped:
		var bob: float = sin(_time * 3.0) * 2.0
		if card_stage:
			card_root.position.y = (card_stage.size.y - card_root.size.y) * 0.5 + bob
		
	if prompt_label and prompt_label.modulate.a > 0.1:
		prompt_label.modulate.a = 0.4 + 0.6 * abs(sin(_time * 4.0))
		
	if sparkle_canvas:
		sparkle_canvas.queue_redraw()

func _start_boot_sequence() -> void:
	var tween: Tween = create_tween()
	
	# Stage 1: Studio Reveal (0.0s - 1.1s)
	tween.tween_property(studio_label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.5)
	tween.tween_property(studio_label, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Stage 2: Card Introduction (1.2s - 1.8s)
	tween.tween_callback(func():
		if studio_label: studio_label.visible = false
	)
	tween.tween_property(logo_container, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card_root, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	# Stage 3: The 3D Mythic Card Flip! (1.8s - 2.6s)
	tween.tween_interval(0.3)
	
	# Flip half 1: Frontward fold (scale.x -> 0.0)
	tween.tween_property(card_root, "scale:x", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(card_root, "scale:y", 1.08, 0.28)
	
	# Midpoint swap: Switch back texture to front texture
	tween.tween_callback(func():
		if card_back: card_back.visible = false
		if card_front: card_front.visible = true
		_is_flipped = true
		# Crystal fanfare sound right as card turns
		if AudioManager:
			AudioManager.play_sfx("boot_fanfare")
		# Burst sparkle particles outward
		for i in range(20):
			_spawn_burst_particle()
	)
	
	# Flip half 2: Unfold to front face (scale.x -> 1.0 with juicy bounce)
	tween.tween_property(card_root, "scale:x", 1.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(card_root, "scale:y", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Flash golden gleam
	tween.tween_callback(func():
		if card_gleam:
			card_gleam.modulate.a = 0.85
			var gleam_tw: Tween = create_tween()
			gleam_tw.tween_property(card_gleam, "modulate:a", 0.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	)
	
	# Reveal Title, Subtitle, and Prompt
	tween.parallel().tween_property(title_label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(subtitle_label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(prompt_label, "modulate:a", 1.0, 0.3)
	
	# Stage 4: Hold and smooth transition into workspace
	tween.tween_interval(1.8)
	tween.tween_callback(_finish_intro)

func _skip_intro() -> void:
	if _is_skipped:
		return
	_is_skipped = true
	_finish_intro()

func _finish_intro() -> void:
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.chain().tween_callback(func():
		splash_finished.emit()
		queue_free()
	)

# ==============================================================================
# 🎨 CELESTIAL ORBITING & BURST SPARKLES
# ==============================================================================
func _spawn_sparkle() -> void:
	_particles.append({
		"angle": randf_range(0, TAU),
		"dist": randf_range(28, 54),
		"speed": randf_range(0.8, 2.2),
		"life": randf_range(1.0, 2.2),
		"max_life": 2.2,
		"size": randf_range(1.5, 3.5),
		"color": Color(0.96, 0.78, 0.25) if randf() > 0.35 else Color(0.31, 0.82, 0.91),
		"is_burst": false,
		"pos": Vector2.ZERO,
		"vel": Vector2.ZERO
	})

func _spawn_burst_particle() -> void:
	var dir: Vector2 = Vector2.from_angle(randf_range(0, TAU))
	var spd: float = randf_range(40.0, 110.0)
	_particles.append({
		"angle": 0.0,
		"dist": 0.0,
		"speed": 0.0,
		"life": randf_range(0.5, 1.2),
		"max_life": 1.2,
		"size": randf_range(2.0, 4.0),
		"color": Color(1.0, 0.95, 0.6) if randf() > 0.4 else Color(0.4, 0.88, 1.0),
		"is_burst": true,
		"pos": Vector2.ZERO,
		"vel": dir * spd
	})

func _update_sparkles(delta: float) -> void:
	for i in range(_particles.size() - 1, -1, -1):
		var p = _particles[i]
		p["life"] -= delta
		if p["is_burst"]:
			p["pos"] += p["vel"] * delta
			p["vel"] *= 0.92
		else:
			p["angle"] += p["speed"] * delta
		if p["life"] <= 0:
			_particles.remove_at(i)
			if _particles.size() < 20 and not _is_skipped:
				_spawn_sparkle()

func _on_sparkle_draw() -> void:
	if not sparkle_canvas:
		return
	var cx: float = sparkle_canvas.size.x * 0.5
	var cy: float = sparkle_canvas.size.y * 0.5
	
	for p in _particles:
		var alpha: float = clampf(p["life"] / p["max_life"], 0.0, 1.0)
		var px: float
		var py: float
		if p["is_burst"]:
			px = cx + p["pos"].x
			py = cy + p["pos"].y
		else:
			px = cx + cos(p["angle"]) * p["dist"]
			py = cy + sin(p["angle"]) * p["dist"] * 0.85
			
		var c: Color = p["color"]
		c.a = alpha
		
		# Draw 4-point pixel star
		var s: float = p["size"]
		sparkle_canvas.draw_rect(Rect2(px - s * 0.5, py - s * 0.5, s, s), c)
		sparkle_canvas.draw_rect(Rect2(px - s, py - 0.5, s * 2.0, 1.0), c)
		sparkle_canvas.draw_rect(Rect2(px - 0.5, py - s, 1.0, s * 2.0), c)
