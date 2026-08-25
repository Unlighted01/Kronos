extends Control
class_name PlantBloomGame

## 🌿 Plant Bloom (Botanical Herbarium) — Musical Simon Pattern Minigame for Kronos.
## Water pots in sequence with pure harmonic chimes to earn Coins, Knowledge Points (KP), and Pet Joy!

signal game_closed()

const ROUND_LENGTHS: Array[int] = [3, 4, 6]
const POT_COLORS: Array[Color] = [
	Color(0.95, 0.35, 0.45), # 0: Rose Pink
	Color(0.96, 0.72, 0.15), # 1: Sunflower Gold
	Color(0.65, 0.45, 0.95), # 2: Lavender Purple
	Color(0.35, 0.85, 0.55)  # 3: Mint Emerald
]
const POT_ICONS: Array[String] = ["🌹", "🌻", "🪻", "🌸"]
const POT_NOTES: Array[float] = [261.63, 329.63, 392.00, 523.25] # C4, E4, G4, C5

enum MinigameState { INTRO, PLAYING_SEQUENCE, PLAYER_INPUT, ROUND_CLEAR, GAME_OVER, VICTORY }

var current_round: int = 0
var sequence: Array[int] = []
var player_step: int = 0
var current_state: MinigameState = MinigameState.INTRO

var _anim_timer: float = 0.0
var _seq_index: int = 0
var _active_highlight_pot: int = -1
var _highlight_timer: float = 0.0

var _bloomed_pots: Array[bool] = [false, false, false, false]
var _bloom_scales: Array[float] = [0.0, 0.0, 0.0, 0.0]
var _particles: Array[Dictionary] = []

@onready var round_label: Label = $HUD/HBox/RoundLabel
@onready var status_label: Label = $HUD/HBox/StatusLabel
@onready var close_btn: Button = $HUD/HBox/CloseButton

@onready var result_panel: PanelContainer = $ResultPanel
@onready var result_title_label: Label = $ResultPanel/VBox/TitleLabel
@onready var result_desc_label: Label = $ResultPanel/VBox/DescLabel
@onready var result_reward_label: Label = $ResultPanel/VBox/RewardLabel
@onready var replay_btn: Button = $ResultPanel/VBox/HBox/ReplayButton
@onready var exit_btn: Button = $ResultPanel/VBox/HBox/ExitButton

func _ready() -> void:
	custom_minimum_size = Vector2(236, 140)
	mouse_filter = MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	if close_btn: close_btn.pressed.connect(_on_exit_pressed)
	if replay_btn: replay_btn.pressed.connect(start_new_game)
	if exit_btn: exit_btn.pressed.connect(_on_exit_pressed)
	if result_panel: result_panel.visible = false
		
	start_new_game()

func start_new_game() -> void:
	current_round = 0
	_bloomed_pots = [false, false, false, false]
	_bloom_scales = [0.0, 0.0, 0.0, 0.0]
	_particles.clear()
	
	if result_panel: result_panel.visible = false
	_start_round(0)

func _start_round(r_idx: int) -> void:
	current_round = r_idx
	player_step = 0
	_seq_index = 0
	_anim_timer = 0.0
	_active_highlight_pot = -1
	
	var length: int = ROUND_LENGTHS[current_round]
	sequence.clear()
	for _i in range(length):
		sequence.append(randi() % 4)
		
	if round_label: round_label.text = "ROUND %d / %d" % [current_round + 1, ROUND_LENGTHS.size()]
	if status_label: status_label.text = "🎶 Listen closely..."
	current_state = MinigameState.PLAYING_SEQUENCE
	queue_redraw()

func _process(delta: float) -> void:
	# Update highlight timer
	if _highlight_timer > 0.0:
		_highlight_timer -= delta
		if _highlight_timer <= 0.0:
			_active_highlight_pot = -1
			queue_redraw()
			
	# Update bloom scales
	for i in range(4):
		var target: float = 1.0 if _bloomed_pots[i] else 0.0
		_bloom_scales[i] = lerpf(_bloom_scales[i], target, delta * 8.0)
		
	# Update particles
	var pt_idx: int = _particles.size() - 1
	while pt_idx >= 0:
		var pt: Dictionary = _particles[pt_idx]
		pt["life"] -= delta
		pt["pos"] += pt["vel"] * delta
		if pt["life"] <= 0.0:
			_particles.remove_at(pt_idx)
		pt_idx -= 1
		
	# Sequence playback state machine
	if current_state == MinigameState.PLAYING_SEQUENCE:
		_anim_timer += delta
		if _anim_timer >= 0.65:
			_anim_timer = 0.0
			if _seq_index < sequence.size():
				var pot_id: int = sequence[_seq_index]
				_play_pot_chime(pot_id)
				_seq_index += 1
			else:
				current_state = MinigameState.PLAYER_INPUT
				if status_label: status_label.text = "💧 Your turn! Water the pots"
				queue_redraw()
				
	queue_redraw()

func _play_pot_chime(pot_id: int) -> void:
	_active_highlight_pot = pot_id
	_highlight_timer = 0.35
	if AudioManager:
		AudioManager.play_sfx("chime")
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if current_state != MinigameState.PLAYER_INPUT:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var click_pos: Vector2 = event.position
		var pot_clicked: int = _get_pot_at_pos(click_pos)
		if pot_clicked != -1:
			_on_pot_clicked(pot_clicked)

func _get_pot_at_pos(pos: Vector2) -> int:
	var pot_w: float = 38.0
	var pot_h: float = 46.0
	var start_x: float = 24.0
	var start_y: float = 46.0
	var gap: float = 12.0
	
	for i in range(4):
		var px: float = start_x + i * (pot_w + gap)
		var py: float = start_y
		if pos.x >= px and pos.x <= px + pot_w and pos.y >= py and pos.y <= py + pot_h:
			return i
	return -1

func _on_pot_clicked(pot_id: int) -> void:
	_play_pot_chime(pot_id)
	
	if pot_id == sequence[player_step]:
		# Correct step
		player_step += 1
		_bloomed_pots[pot_id] = true
		
		# Add spore particles
		var pot_center: Vector2 = Vector2(24.0 + pot_id * 50.0 + 19.0, 60.0)
		for _p in range(5):
			_particles.append({
				"pos": pot_center,
				"vel": Vector2(randf_range(-25, 25), randf_range(-35, -5)),
				"color": POT_COLORS[pot_id],
				"life": 0.5,
				"max_life": 0.5
			})
			
		if player_step >= sequence.size():
			_on_round_clear()
	else:
		# Mistake
		if AudioManager: AudioManager.play_sfx("click")
		_on_game_over()

func _on_round_clear() -> void:
	if current_round + 1 < ROUND_LENGTHS.size():
		current_state = MinigameState.ROUND_CLEAR
		if status_label: status_label.text = "✨ Perfect! Next Round ✨"
		var tween = create_tween()
		tween.tween_interval(0.9)
		tween.tween_callback(func(): _start_round(current_round + 1))
	else:
		_on_victory()

func _on_victory() -> void:
	current_state = MinigameState.VICTORY
	if AudioManager: AudioManager.play_sfx("victory")
	
	if GameState:
		GameState.add_coins(40, "minigame_plant_bloom")
		GameState.add_knowledge_points(10, "minigame_plant_bloom")
		GameState.modify_pet_joy(30.0)
		GameState.record_minigame_score("plant_bloom", 100)
		
	if result_panel: result_panel.visible = true
	if result_title_label: result_title_label.text = "🌸 BOTANICAL MASTERY!"
	if result_desc_label: result_desc_label.text = "All melody sequences mastered in harmony!"
	if result_reward_label: result_reward_label.text = "+40 🪙  +10 ⭐ KP  +30 💖 Joy"

func _on_game_over() -> void:
	current_state = MinigameState.GAME_OVER
	if GameState:
		GameState.add_coins(10, "minigame_plant_bloom")
		GameState.add_knowledge_points(3, "minigame_plant_bloom")
		
	if result_panel: result_panel.visible = true
	if result_title_label: result_title_label.text = "🥀 WILTED MELODY"
	if result_desc_label: result_desc_label.text = "A missed note! The flowers need more rehearsal."
	if result_reward_label: result_reward_label.text = "+10 🪙  +3 ⭐ KP"

func _draw() -> void:
	# Background
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.04, 0.06, 0.08, 0.96))
	
	# Pot positions
	var pot_w: float = 38.0
	var pot_h: float = 46.0
	var start_x: float = 24.0
	var start_y: float = 46.0
	var gap: float = 12.0
	
	for i in range(4):
		var px: float = start_x + i * (pot_w + gap)
		var py: float = start_y
		var is_highlight: bool = (_active_highlight_pot == i)
		var col: Color = POT_COLORS[i]
		
		# Pot body (Terracotta base)
		var pot_body_col: Color = Color(0.72, 0.42, 0.22) if not is_highlight else Color(0.92, 0.62, 0.32)
		draw_rect(Rect2(px + 4, py + 18, pot_w - 8, 22), pot_body_col)
		draw_rect(Rect2(px + 2, py + 14, pot_w - 4, 6), Color(0.58, 0.30, 0.12)) # Rim
		
		# Plant stem & Blooming Flower
		var stem_x: float = px + pot_w * 0.5
		draw_line(Vector2(stem_x, py + 14), Vector2(stem_x, py + 4), Color(0.2, 0.65, 0.3), 2.0)
		
		# Flower Blossom (Scale with bloom scale)
		var bloom_r: float = 8.0 * maxf(0.3, _bloom_scales[i])
		if is_highlight:
			bloom_r *= 1.25
			draw_circle(Vector2(stem_x, py + 2), bloom_r + 3.0, Color(col.r, col.g, col.b, 0.4))
			
		draw_circle(Vector2(stem_x, py + 2), bloom_r, col)
		draw_circle(Vector2(stem_x, py + 2), bloom_r * 0.4, Color(1.0, 0.9, 0.4)) # Center
		
	# Particles
	for pt in _particles:
		var p_alpha: float = clampf(pt["life"] / pt["max_life"], 0.0, 1.0)
		var p_col: Color = pt["color"]
		p_col.a = p_alpha
		draw_rect(Rect2(pt["pos"].x, pt["pos"].y, 2, 2), p_col)

func _on_exit_pressed() -> void:
	if AudioManager: AudioManager.play_sfx("click")
	game_closed.emit()
	queue_free()
