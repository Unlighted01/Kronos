extends Control
class_name SplashIntro

## 🎬 Retro Boot Animation Card for Kronos.
## Plays an indie studio reveal, glowing celestial hourglass particle animation,
## and retro crystal chime fanfare on game launch.

signal splash_finished()

@onready var bg_rect: ColorRect = $Background
@onready var studio_label: Label = $CenterContainer/VBox/StudioLabel
@onready var logo_container: VBoxContainer = $CenterContainer/VBox/LogoContainer
@onready var hourglass_canvas: Control = $CenterContainer/VBox/LogoContainer/HourglassCanvas
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
	
	# Connect hourglass drawing
	if hourglass_canvas:
		hourglass_canvas.draw.connect(_on_hourglass_draw)
	
	# Initial visibility states
	if studio_label:
		studio_label.modulate.a = 0.0
	if logo_container:
		logo_container.modulate.a = 0.0
	if prompt_label:
		prompt_label.modulate.a = 0.0
		
	# Spawn initial sparkles
	for i in range(16):
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
		
	if hourglass_canvas:
		hourglass_canvas.queue_redraw()

func _start_boot_sequence() -> void:
	# 1. Play grand crystal chime fanfare
	if AudioManager:
		AudioManager.play_sfx("boot_fanfare")
		
	var tween: Tween = create_tween()
	
	# Stage 1: Studio Reveal (0.0s - 1.1s)
	tween.tween_property(studio_label, "modulate:a", 1.0, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_interval(0.5)
	tween.tween_property(studio_label, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	# Stage 2: Kronos Game Logo & Hourglass Reveal (1.2s - 2.8s)
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
# 🎨 PROCEDURAL PARTICLES & HOURGLASS DRAWING
# ==============================================================================
func _spawn_sparkle() -> void:
	_particles.append({
		"x": randf_range(-24, 24),
		"y": randf_range(-16, 16),
		"vx": randf_range(-5, 5),
		"vy": randf_range(-12, -3),
		"life": randf_range(0.8, 1.8),
		"max_life": 1.8,
		"size": randf_range(1.5, 3.0),
		"color": Color(0.96, 0.78, 0.25) if randf() > 0.4 else Color(0.22, 0.74, 0.97)
	})

func _update_sparkles(delta: float) -> void:
	for i in range(_particles.size() - 1, -1, -1):
		var p = _particles[i]
		p["life"] -= delta
		p["x"] += p["vx"] * delta
		p["y"] += p["vy"] * delta
		if p["life"] <= 0:
			_particles.remove_at(i)
			if _particles.size() < 12:
				_spawn_sparkle()

func _on_hourglass_draw() -> void:
	if not hourglass_canvas:
		return
	var cx: float = hourglass_canvas.size.x * 0.5
	var cy: float = hourglass_canvas.size.y * 0.5
	
	# Top & Bottom Golden Pediments
	hourglass_canvas.draw_rect(Rect2(cx - 20, cy - 26, 40, 5), Color(0.96, 0.62, 0.04)) # Top Base
	hourglass_canvas.draw_rect(Rect2(cx - 18, cy - 28, 36, 2), Color(0.99, 0.94, 0.54)) # Top Highlight
	hourglass_canvas.draw_rect(Rect2(cx - 20, cy + 21, 40, 5), Color(0.96, 0.62, 0.04)) # Bottom Base
	hourglass_canvas.draw_rect(Rect2(cx - 18, cy + 21, 36, 2), Color(0.99, 0.94, 0.54)) # Bottom Highlight
	
	# Outer Pillars
	hourglass_canvas.draw_rect(Rect2(cx - 19, cy - 21, 3, 42), Color(0.85, 0.47, 0.04))
	hourglass_canvas.draw_rect(Rect2(cx + 16, cy - 21, 3, 42), Color(0.85, 0.47, 0.04))
	
	# Glass Bulbs
	for y in range(int(cy - 20), int(cy + 20)):
		var ny: float = (float(y) - cy) / 20.0
		var hw: float = 14.0 * (ny * ny * 0.75 + 0.25)
		hourglass_canvas.draw_rect(Rect2(cx - hw, y, hw * 2.0, 1), Color(0.08, 0.12, 0.24, 0.7))
		
		# Glowing Falling Sand
		if y < cy - 2:
			var sand_w: float = hw - 2.0
			if sand_w > 0:
				hourglass_canvas.draw_rect(Rect2(cx - sand_w, y, sand_w * 2.0, 1), Color(0.96, 0.62, 0.04, 0.9))
		elif y >= cy - 2 and y <= cy + 6:
			# Stream
			hourglass_canvas.draw_rect(Rect2(cx - 1, y, 2, 1), Color(0.99, 0.94, 0.54))
		elif y > cy + 6:
			# Bottom Cyan Dune
			var dune_w: float = (float(y) - (cy + 6)) / 14.0 * (hw - 1.0)
			hourglass_canvas.draw_rect(Rect2(cx - dune_w, y, dune_w * 2.0, 1), Color(0.22, 0.74, 0.97, 0.9))
			
		# Glass Reflection
		hourglass_canvas.draw_rect(Rect2(cx - hw, y, 1, 1), Color(0.73, 0.90, 0.99, 0.8))
		hourglass_canvas.draw_rect(Rect2(cx + hw - 1, y, 1, 1), Color(0.05, 0.41, 0.63, 0.8))
		
	# Draw sparkle particles
	for p in _particles:
		var alpha: float = clampf(p["life"] / p["max_life"], 0.0, 1.0)
		var c: Color = p["color"]
		c.a = alpha
		hourglass_canvas.draw_rect(Rect2(cx + p["x"], cy + p["y"], p["size"], p["size"]), c)
