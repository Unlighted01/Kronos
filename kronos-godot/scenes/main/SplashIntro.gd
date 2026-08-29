extends Control
class_name SplashIntro

## 🎬 Retro Boot Animation Card for Kronos.
## Plays an indie studio reveal, glowing Crowned Shiba Pet RPG emblem animation,
## and retro crystal chime fanfare on game launch.

signal splash_finished()

@onready var bg_rect: ColorRect = $Background
@onready var studio_label: Label = $CenterContainer/VBox/StudioLabel
@onready var logo_container: VBoxContainer = $CenterContainer/VBox/LogoContainer
@onready var emblem_canvas: Control = $CenterContainer/VBox/LogoContainer/EmblemCanvas
@onready var title_label: Label = $CenterContainer/VBox/LogoContainer/TitleLabel
@onready var subtitle_label: Label = $CenterContainer/VBox/LogoContainer/SubtitleLabel
@onready var prompt_label: Label = $CenterContainer/VBox/PromptLabel

var _time: float = 0.0
var _is_skipped: bool = false
var _particles: Array[Dictionary] = []

func _ready() -> void:
	z_index = 150
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Connect emblem drawing
	if emblem_canvas:
		emblem_canvas.draw.connect(_on_emblem_draw)
	
	# Initial visibility states
	if studio_label:
		studio_label.modulate.a = 0.0
	if logo_container:
		logo_container.modulate.a = 0.0
	if prompt_label:
		prompt_label.modulate.a = 0.0
		
	# Spawn initial sparkles
	for i in range(18):
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
	
	if prompt_label and prompt_label.modulate.a > 0.1:
		prompt_label.modulate.a = 0.4 + 0.6 * abs(sin(_time * 4.0))
		
	if emblem_canvas:
		emblem_canvas.queue_redraw()

func _start_boot_sequence() -> void:
	# 1. Play grand crystal chime fanfare
	if AudioManager:
		AudioManager.play_sfx("boot_fanfare")
		
	var tween: Tween = create_tween()
	
	# Stage 1: Studio Reveal (0.0s - 1.1s)
	tween.tween_property(studio_label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.5)
	tween.tween_property(studio_label, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Stage 2: Kronos Game Logo & Pet RPG Emblem Reveal (1.2s - 2.8s)
	tween.tween_callback(func():
		if studio_label: studio_label.visible = false
	)
	tween.tween_property(logo_container, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(prompt_label, "modulate:a", 1.0, 0.3)
	
	# Stage 3: Hold and smooth transition into workspace
	tween.tween_interval(1.4)
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
# 🎨 PROCEDURAL PARTICLES & SHIBA PET RPG EMBLEM DRAWING
# ==============================================================================
func _spawn_sparkle() -> void:
	_particles.append({
		"angle": randf_range(0, TAU),
		"dist": randf_range(18, 36),
		"speed": randf_range(0.8, 2.2),
		"life": randf_range(1.0, 2.2),
		"max_life": 2.2,
		"size": randf_range(1.5, 3.5),
		"color": Color(0.96, 0.78, 0.25) if randf() > 0.35 else Color(0.31, 0.82, 0.91)
	})

func _update_sparkles(delta: float) -> void:
	for i in range(_particles.size() - 1, -1, -1):
		var p = _particles[i]
		p["life"] -= delta
		p["angle"] += p["speed"] * delta
		if p["life"] <= 0:
			_particles.remove_at(i)
			if _particles.size() < 16:
				_spawn_sparkle()

func _on_emblem_draw() -> void:
	if not emblem_canvas:
		return
	var cx: float = emblem_canvas.size.x * 0.5
	var cy: float = emblem_canvas.size.y * 0.5 + sin(_time * 3.0) * 1.5 # Gentle pet breathing bob
	
	# 1. Dark Celestial Crest Shield / Medallion
	var crest_radius: float = 26.0
	emblem_canvas.draw_circle(Vector2(cx, cy), crest_radius + 2.0, Color(0.96, 0.78, 0.25, 0.9)) # Gold Outer Rim
	emblem_canvas.draw_circle(Vector2(cx, cy), crest_radius, Color(0.06, 0.07, 0.12, 0.95)) # Obsidian Center
	emblem_canvas.draw_arc(Vector2(cx, cy), crest_radius - 2.0, 0, TAU, 32, Color(0.31, 0.82, 0.91, 0.4), 1.0)
	
	# 2. Shiba Inu Pet Head & Ears
	var ear_twitch: float = sin(_time * 5.0) * 1.0
	
	# Left Ear (Honey Gold + Pink Inner)
	var left_ear_pts: PackedVector2Array = [
		Vector2(cx - 16, cy - 8 + ear_twitch),
		Vector2(cx - 9, cy - 20 + ear_twitch),
		Vector2(cx - 4, cy - 9 + ear_twitch)
	]
	emblem_canvas.draw_colored_polygon(left_ear_pts, Color(0.85, 0.47, 0.04))
	var left_ear_inner: PackedVector2Array = [
		Vector2(cx - 14, cy - 9 + ear_twitch),
		Vector2(cx - 9, cy - 18 + ear_twitch),
		Vector2(cx - 6, cy - 10 + ear_twitch)
	]
	emblem_canvas.draw_colored_polygon(left_ear_inner, Color(0.98, 0.55, 0.68))
	
	# Right Ear (Honey Gold + Pink Inner)
	var right_ear_pts: PackedVector2Array = [
		Vector2(cx + 4, cy - 9 - ear_twitch),
		Vector2(cx + 9, cy - 20 - ear_twitch),
		Vector2(cx + 16, cy - 8 - ear_twitch)
	]
	emblem_canvas.draw_colored_polygon(right_ear_pts, Color(0.85, 0.47, 0.04))
	var right_ear_inner: PackedVector2Array = [
		Vector2(cx + 6, cy - 10 - ear_twitch),
		Vector2(cx + 9, cy - 18 - ear_twitch),
		Vector2(cx + 14, cy - 9 - ear_twitch)
	]
	emblem_canvas.draw_colored_polygon(right_ear_inner, Color(0.98, 0.55, 0.68))
	
	# Head (Honey Gold Base)
	emblem_canvas.draw_rect(Rect2(cx - 14, cy - 10, 28, 20), Color(0.96, 0.62, 0.04))
	emblem_canvas.draw_circle(Vector2(cx, cy), 13.0, Color(0.96, 0.62, 0.04))
	
	# Cream Cheeks & Muzzle
	emblem_canvas.draw_circle(Vector2(cx - 7, cy + 4), 6.0, Color(0.99, 0.95, 0.78))
	emblem_canvas.draw_circle(Vector2(cx + 7, cy + 4), 6.0, Color(0.99, 0.95, 0.78))
	emblem_canvas.draw_rect(Rect2(cx - 6, cy + 1, 12, 8), Color(0.99, 0.95, 0.78))
	
	# Tiny Black Nose
	emblem_canvas.draw_rect(Rect2(cx - 2, cy + 2, 4, 3), Color(0.12, 0.06, 0.02))
	
	# Anime Eyes with Specular Sparkle (with periodic blink)
	var is_blinking: bool = fmod(_time, 3.2) < 0.15
	if is_blinking:
		emblem_canvas.draw_rect(Rect2(cx - 9, cy - 2, 5, 2), Color(0.12, 0.06, 0.02))
		emblem_canvas.draw_rect(Rect2(cx + 4, cy - 2, 5, 2), Color(0.12, 0.06, 0.02))
	else:
		# Left Eye
		emblem_canvas.draw_rect(Rect2(cx - 9, cy - 4, 5, 5), Color(0.12, 0.06, 0.02))
		emblem_canvas.draw_rect(Rect2(cx - 8, cy - 3, 2, 2), Color(1.0, 1.0, 1.0)) # Specular dot
		# Right Eye
		emblem_canvas.draw_rect(Rect2(cx + 4, cy - 4, 5, 5), Color(0.12, 0.06, 0.02))
		emblem_canvas.draw_rect(Rect2(cx + 5, cy - 3, 2, 2), Color(1.0, 1.0, 1.0)) # Specular dot
		
	# Rosy Blush Cheeks
	emblem_canvas.draw_circle(Vector2(cx - 10, cy + 3), 3.0, Color(0.98, 0.45, 0.55, 0.7))
	emblem_canvas.draw_circle(Vector2(cx + 10, cy + 3), 3.0, Color(0.98, 0.45, 0.55, 0.7))
	
	# 3. Golden Sovereign RPG Crown
	var crown_y: float = cy - 14.0
	var crown_pts: PackedVector2Array = [
		Vector2(cx - 8, crown_y),
		Vector2(cx - 10, crown_y - 8),
		Vector2(cx - 4, crown_y - 4),
		Vector2(cx, crown_y - 10),
		Vector2(cx + 4, crown_y - 4),
		Vector2(cx + 10, crown_y - 8),
		Vector2(cx + 8, crown_y)
	]
	emblem_canvas.draw_colored_polygon(crown_pts, Color(0.96, 0.78, 0.25))
	# Crown Rim & Ruby Gem
	emblem_canvas.draw_rect(Rect2(cx - 7, crown_y - 1, 14, 2), Color(0.99, 0.94, 0.54))
	emblem_canvas.draw_rect(Rect2(cx - 1.5, crown_y - 5, 3, 3), Color(0.95, 0.25, 0.35)) # Centered Ruby Gem
	
	# 4. Celestial Orbiting Sparkles & Magic Stars
	for p in _particles:
		var alpha: float = clampf(p["life"] / p["max_life"], 0.0, 1.0)
		var px: float = cx + cos(p["angle"]) * p["dist"]
		var py: float = cy + sin(p["angle"]) * p["dist"] * 0.7
		var c: Color = p["color"]
		c.a = alpha
		
		# Draw 4-point pixel star
		var s: float = p["size"]
		emblem_canvas.draw_rect(Rect2(px - s * 0.5, py - s * 0.5, s, s), c)
		emblem_canvas.draw_rect(Rect2(px - s, py - 0.5, s * 2.0, 1.0), c)
		emblem_canvas.draw_rect(Rect2(px - 0.5, py - s, 1.0, s * 2.0), c)
