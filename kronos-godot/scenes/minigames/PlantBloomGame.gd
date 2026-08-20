extends Control
class_name PlantBloomGame

## 🌿 Plant Bloom — Greenhouse Musical Pattern Minigame for Kronos.
## Listen to the melodic plant chime sequence and water the pots in rhythm to make flowers bloom!

signal game_closed()

# ==============================================================================
# 🎮 GAME DATA & TONES
# ==============================================================================
const ROUND_LENGTHS: Array[int] = [3, 5, 7] # 3 Progressive rounds
const POT_COLORS: Array[Color] = [
	Color(0.95, 0.35, 0.45), # 0: Rose Pink
	Color(0.96, 0.72, 0.15), # 1: Sunflower Gold
	Color(0.65, 0.45, 0.95), # 2: Lavender Purple
	Color(0.35, 0.85, 0.55)  # 3: Mint Emerald
]
const POT_ICONS: Array[String] = ["🌹", "🌻", "🪻", "🌸"]
const POT_NOTES: Array[float] = [261.63, 329.63, 392.00, 523.25] # C4, E4, G4, C5

enum GameState { INTRO, PLAYING_SEQUENCE, PLAYER_INPUT, ROUND_CLEAR, GAME_OVER, VICTORY }

# ==============================================================================
# 📊 STATE
# ==============================================================================
var current_round: int = 0 # 0, 1, 2
var sequence: Array[int] = []
var player_step: int = 0
var current_state: GameState = GameState.INTRO

var _anim_timer: float = 0.0
var _seq_index: int = 0
var _active_highlight_pot: int = -1
var _highlight_timer: float = 0.0

var _bloomed_pots: Array[bool] = [false, false, false, false]
var _bloom_scales: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _particles: Array[Dictionary] = []

# ==============================================================================
# 🎛️ UI REFERENCES
# ==============================================================================
@onready var round_label: Label = $HUD/HBox/RoundLabel
@onready var status_label: Label = $HUD/HBox/StatusLabel
@onready var close_btn: Button = $HUD/HBox/CloseButton

@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_title_label: Label = $ResultPanel/VBox/TitleLabel
@onready var result_desc_label: Label = $ResultPanel/VBox/DescLabel
@onready var result_reward_label: Label = $ResultPanel/VBox/RewardLabel
@onready var replay_btn: Button = $ResultPanel/VBox/HBox/ReplayButton
@onready var exit_btn: Button = $ResultPanel/VBox/HBox/ExitButton

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	custom_minimum_size = Vector2(236, 140)
	mouse_filter = MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	if close_btn:
		close_btn.pressed.connect(_on_exit_pressed)
	if replay_btn:
		replay_btn.pressed.connect(start_new_game)
	if exit_btn:
		exit_btn.pressed.connect(_on_exit_pressed)
		
	if result_panel:
		result_panel.visible = false
		
	start_new_game()

func start_new_game() -> void:
	current_round = 0
	_bloomed_pots = [false, false, false, false]
	_bloom_scales = [0.0, 0.0, 0.0, 0.0]
	_particles.clear()
	
	if result_panel:
		result_panel.visible = false
		
	start_round(0)

func start_round(round_idx: int) -> void:
	current_round = round_idx
	player_step = 0
	sequence.clear()
	
	var length: int = ROUND_LENGTHS[mini(round_idx, ROUND_LENGTHS.size() - 1)]
	for i in range(length):
		sequence.append(randi() % 4)
		
	if round_label:
		round_label.text = "🌿 Round %d/%d" % [current_round + 1, ROUND_LENGTHS.size()]
	if status_label:
		status_label.text = "👂 Listen to the melody..."
		status_label.modulate = Color(0.96, 0.62, 0.04)
		
	current_state = GameState.PLAYING_SEQUENCE
	_seq_index = 0
	_anim_timer = 0.6
	queue_redraw()

func _process(delta: float) -> void:
	# 1. Update Highlight timers
	if _highlight_timer > 0.0:
		_highlight_timer -= delta
		if _highlight_timer <= 0.0:
			_active_highlight_pot = -1
			queue_redraw()
			
	# 2. Sequence Playback Machine
	if current_state == GameState.PLAYING_SEQUENCE:
		_anim_timer -= delta
		if _anim_timer <= 0.0:
			if _seq_index < sequence.size():
				var pot_id: int = sequence[_seq_index]
				_flash_pot(pot_id, 0.4)
				_seq_index += 1
				_anim_timer = 0.55
			else:
				# Sequence finished -> hand over to player
				current_state = GameState.PLAYER_INPUT
				if status_label:
					status_label.text = "💧 Water the pots in order!"
					status_label.modulate = Color(0.31, 0.82, 0.91)
					
	# 3. Animate Blooming Flowers
	for i in range(4):
		if _bloomed_pots[i]:
			_bloom_scales[i] = lerpf(_bloom_scales[i], 1.0, 8.0 * delta)
		else:
			_bloom_scales[i] = lerpf(_bloom_scales[i], 0.0, 8.0 * delta)
			
	# 4. Animate Water Sparkle Particles
	for i in range(_particles.size() - 1, -1, -1):
		var p: Dictionary = _particles[i]
		p["y"] += p["vy"] * delta
		p["x"] += p["vx"] * delta
		p["alpha"] -= 1.8 * delta
		if p["alpha"] <= 0.0:
			_particles.remove_at(i)
			
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if current_state != GameState.PLAYER_INPUT:
		return
		
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _on_player_pot_clicked(0)
			KEY_2: _on_player_pot_clicked(1)
			KEY_3: _on_player_pot_clicked(2)
			KEY_4: _on_player_pot_clicked(3)
			
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos: Vector2 = get_local_mouse_position()
		var clicked_pot: int = _get_pot_at_pos(local_pos)
		if clicked_pot >= 0:
			_on_player_pot_clicked(clicked_pot)
			get_viewport().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if current_state != GameState.PLAYER_INPUT:
		return
		
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var clicked_pot: int = _get_pot_at_pos(mb.position)
			if clicked_pot >= 0:
				_on_player_pot_clicked(clicked_pot)
				get_viewport().set_input_as_handled()

func _get_pot_at_pos(pos: Vector2) -> int:
	var start_x: float = 24.0
	var pot_w: float = 44.0
	var pot_gap: float = 6.0
	var pot_y: float = 50.0
	var pot_h: float = 75.0
	
	for i in range(4):
		var px: float = start_x + i * (pot_w + pot_gap)
		if Rect2(px, pot_y, pot_w, pot_h).has_point(pos):
			return i
	return -1

func _on_player_pot_clicked(pot_id: int) -> void:
	_flash_pot(pot_id, 0.3)
	_spawn_water_splash(pot_id)
	
	var expected_pot: int = sequence[player_step]
	if pot_id == expected_pot:
		# Correct note!
		player_step += 1
		if player_step >= sequence.size():
			# Round Cleared!
			_on_round_completed()
	else:
		# Mistake made!
		_on_wrong_note()

func _flash_pot(pot_id: int, duration: float) -> void:
	_active_highlight_pot = pot_id
	_highlight_timer = duration
	_play_pot_chime(pot_id)
	queue_redraw()

func _play_pot_chime(pot_id: int) -> void:
	if AudioManager:
		# Play audio chime
		match pot_id:
			0: AudioManager.play_sfx("chime")
			1: AudioManager.play_sfx("bell")
			2: AudioManager.play_sfx("chirp")
			3: AudioManager.play_sfx("coin")

func _spawn_water_splash(pot_id: int) -> void:
	var start_x: float = 24.0 + pot_id * 50.0 + 22.0
	var pot_y: float = 78.0
	for i in range(6):
		_particles.append({
			"x": start_x,
			"y": pot_y,
			"vx": randf_range(-30.0, 30.0),
			"vy": randf_range(-40.0, -10.0),
			"color": POT_COLORS[pot_id],
			"alpha": 1.0
		})

func _on_round_completed() -> void:
	current_state = GameState.ROUND_CLEAR
	_bloomed_pots[current_round] = true
	
	if current_round + 1 < ROUND_LENGTHS.size():
		if status_label:
			status_label.text = "✨ Beautiful! Next round..."
			status_label.modulate = Color(0.4, 0.85, 0.55)
		get_tree().create_timer(1.2).timeout.connect(func():
			start_round(current_round + 1)
		)
	else:
		# Grand Victory! All 3 rounds complete
		_trigger_victory()

func _on_wrong_note() -> void:
	current_state = GameState.GAME_OVER
	if status_label:
		status_label.text = "❌ Oops! Wrong pot."
		status_label.modulate = Color(0.9, 0.35, 0.35)
		
	if AudioManager:
		AudioManager.play_sfx("click")
		
	get_tree().create_timer(1.0).timeout.connect(func():
		_show_result_panel(false)
	)

func _trigger_victory() -> void:
	current_state = GameState.VICTORY
	for i in range(4):
		_bloomed_pots[i] = true
		
	var reward_coins: int = 75
	var reward_exp: int = 40
	
	if GameState:
		GameState.add_coins(reward_coins, "plant_bloom_minigame")
		GameState.add_exp(reward_exp)
		GameState.add_energy(30.0) # Restores +30 Pet Energy!
		
	if AudioManager:
		AudioManager.play_sfx("chime")
		
	_show_result_panel(true)

func _show_result_panel(is_victory: bool) -> void:
	if not result_panel:
		return
		
	if is_victory:
		result_title_label.text = "🌸 ALL PLANTS BLOOMED!"
		result_title_label.modulate = Color(0.96, 0.62, 0.04)
		result_desc_label.text = "Your greenhouse is vibrant and flourishing!"
		result_reward_label.text = "+75 G Coins  +40 XP  +30 Energy! ⚡"
		result_reward_label.modulate = Color(0.4, 0.85, 0.55)
	else:
		result_title_label.text = "🌱 GOOD EFFORT!"
		result_title_label.modulate = Color(0.7, 0.75, 0.85)
		result_desc_label.text = "Reached Round %d of %d" % [current_round + 1, ROUND_LENGTHS.size()]
		result_reward_label.text = "+15 G Coins  +10 XP"
		result_reward_label.modulate = Color(0.96, 0.62, 0.04)
		if GameState:
			GameState.add_coins(15, "plant_bloom_minigame")
			GameState.add_exp(10)
			
	result_panel.visible = true
	queue_redraw()

func _on_exit_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("click")
	game_closed.emit()
	queue_free()

# ==============================================================================
# 🎨 CANVAS DRAWING
# ==============================================================================
func _draw() -> void:
	# 1. Greenhouse Botanical Glass Backdrop
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.05, 0.11, 0.14, 0.95))
	
	# Translucent Sunbeam shafts
	draw_colored_polygon(PackedVector2Array([Vector2(30, 0), Vector2(80, 0), Vector2(130, 140), Vector2(60, 140)]), Color(0.2, 0.8, 0.6, 0.06))
	draw_colored_polygon(PackedVector2Array([Vector2(140, 0), Vector2(190, 0), Vector2(236, 140), Vector2(170, 140)]), Color(0.2, 0.8, 0.6, 0.06))
	
	# Potting Bench Table
	draw_rect(Rect2(12, 118, 212, 18), Color(0.45, 0.22, 0.08))
	draw_rect(Rect2(12, 118, 212, 3), Color(0.65, 0.35, 0.12)) # Highlight edge
	
	var font: Font = ThemeDB.fallback_font
	var start_x: float = 24.0
	var pot_w: float = 44.0
	var pot_gap: float = 6.0
	var pot_y: float = 78.0
	var pot_h: float = 40.0
	
	# 2. Draw 4 Plant Pots
	for i in range(4):
		var px: float = start_x + i * (pot_w + pot_gap)
		var is_active: bool = (_active_highlight_pot == i)
		var p_col: Color = POT_COLORS[i]
		
		# Pot drop shadow
		draw_ellipse(Vector2(px + pot_w / 2, pot_y + pot_h + 2), Vector2(18, 4), Color(0, 0, 0, 0.3))
		
		# Glowing Aura if active
		if is_active:
			draw_circle(Vector2(px + pot_w / 2, pot_y + 12), 26.0, Color(p_col.r, p_col.g, p_col.b, 0.35))
			
		# Terracotta Pot Body
		var pot_body_col: Color = Color(0.78, 0.36, 0.18) if not is_active else Color(0.92, 0.48, 0.25)
		draw_rect(Rect2(px + 4, pot_y + 12, pot_w - 8, pot_h - 12), pot_body_col)
		draw_rect(Rect2(px + 2, pot_y + 8, pot_w - 4, 6), Color(0.88, 0.45, 0.22)) # Pot Rim
		draw_rect(Rect2(px + 6, pot_y + 10, pot_w - 12, 2), Color(0.25, 0.12, 0.05)) # Soil
		
		# Plant Sprout / Bloomed Flower
		var scale_val: float = _bloom_scales[i]
		if scale_val > 0.01:
			# Fully Bloomed Flower
			var flower_y: float = pot_y - 2.0 * scale_val
			# Green Stem
			draw_line(Vector2(px + pot_w / 2, pot_y + 8), Vector2(px + pot_w / 2, flower_y + 6), Color(0.2, 0.65, 0.3), 2.0)
			# Flower Icon
			draw_string(font, Vector2(px + pot_w / 2 - 8, flower_y), POT_ICONS[i], HORIZONTAL_ALIGNMENT_CENTER, -1, 14)
		else:
			# Small Green Sprout
			draw_line(Vector2(px + pot_w / 2, pot_y + 8), Vector2(px + pot_w / 2, pot_y - 2), Color(0.2, 0.65, 0.3), 2.0)
			draw_circle(Vector2(px + pot_w / 2 - 3, pot_y - 1), 2.5, Color(0.3, 0.8, 0.4))
			draw_circle(Vector2(px + pot_w / 2 + 3, pot_y - 1), 2.5, Color(0.3, 0.8, 0.4))
			
		# Number Key Badge (1, 2, 3, 4)
		var key_col: Color = Color(0.95, 0.95, 0.95, 0.8) if not is_active else Color(0.96, 0.62, 0.04)
		draw_string(font, Vector2(px + pot_w / 2 - 3, pot_y + pot_h - 4), str(i + 1), HORIZONTAL_ALIGNMENT_CENTER, -1, 8, key_col)
		
	# 3. Draw Water Droplet Particles
	for p in _particles:
		var col: Color = p["color"]
		col.a = p["alpha"]
		draw_circle(Vector2(p["x"], p["y"]), 2.0, col)

func draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for a in range(16):
		var rad: float = (float(a) / 16.0) * TAU
		points.append(center + Vector2(cos(rad) * radii.x, sin(rad) * radii.y))
	draw_colored_polygon(points, color)
