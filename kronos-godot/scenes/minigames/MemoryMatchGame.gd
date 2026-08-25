extends Control
class_name MemoryMatchGame

## 🃏 Attic Memory Match 2.0 — Cozy Card Flip Memory Minigame for Kronos.
## Match 4 pairs of study items with 3D card flips to earn Coins, Knowledge Points (KP), and EXP!

signal game_closed()

const GAME_DURATION: float = 40.0
const CARD_TYPES: Array[Dictionary] = [
	{ "id": 0, "name": "croissant", "color": Color(0.96, 0.62, 0.04) },
	{ "id": 1, "name": "boba", "color": Color(0.93, 0.28, 0.60) },
	{ "id": 2, "name": "plant", "color": Color(0.40, 0.85, 0.55) },
	{ "id": 3, "name": "book", "color": Color(0.31, 0.82, 0.91) }
]

const GRID_COLS: int = 4
const GRID_ROWS: int = 2
const CARD_W: float = 44.0
const CARD_H: float = 44.0
const START_X: float = 22.0
const START_Y: float = 36.0
const GAP_X: float = 8.0
const GAP_Y: float = 8.0

var time_left: float = GAME_DURATION
var is_playing: bool = false
var is_game_over: bool = false

var cards: Array[Dictionary] = []
var first_card_idx: int = -1
var second_card_idx: int = -1
var _lock_input: bool = false
var _matched_pairs: int = 0
var _particles: Array[Dictionary] = []

@onready var timer_label: Label = $HUD/HBox/TimerLabel
@onready var matches_label: Label = $HUD/HBox/MatchesLabel
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
	if replay_btn: replay_btn.pressed.connect(start_game)
	if exit_btn: exit_btn.pressed.connect(_on_exit_pressed)
	if result_panel: result_panel.visible = false
		
	start_game()

func start_game() -> void:
	time_left = GAME_DURATION
	is_playing = true
	is_game_over = false
	first_card_idx = -1
	second_card_idx = -1
	_lock_input = false
	_matched_pairs = 0
	_particles.clear()
	
	# Generate 8 cards (4 pairs)
	cards.clear()
	var pair_ids: Array[int] = [0, 0, 1, 1, 2, 2, 3, 3]
	pair_ids.shuffle()
	
	for i in range(8):
		var tid: int = pair_ids[i]
		cards.append({
			"id": tid,
			"info": CARD_TYPES[tid],
			"is_revealed": false,
			"is_matched": false,
			"flip_scale_x": 1.0
		})
		
	if result_panel: result_panel.visible = false
	if timer_label: timer_label.text = "⏱️ %02ds" % int(time_left)
	if matches_label: matches_label.text = "PAIRS: 0 / 4"
	if AudioManager: AudioManager.play_sfx("chime")
	queue_redraw()

func _process(delta: float) -> void:
	if not is_playing or is_game_over:
		return
		
	time_left -= delta
	if timer_label:
		timer_label.text = "⏱️ %02ds" % maxi(0, int(ceilf(time_left)))
		timer_label.modulate = Color(1.0, 0.4, 0.4) if time_left <= 10.0 else Color(1.0, 1.0, 1.0)
		
	# Update particles
	var pt_idx: int = _particles.size() - 1
	while pt_idx >= 0:
		var pt: Dictionary = _particles[pt_idx]
		pt["life"] -= delta
		pt["pos"] += pt["vel"] * delta
		if pt["life"] <= 0.0:
			_particles.remove_at(pt_idx)
		pt_idx -= 1
		
	if time_left <= 0.0:
		_on_time_up()
		
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not is_playing or is_game_over or _lock_input:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		var click_pos: Vector2 = event.position
		var idx: int = _get_card_at_pos(click_pos)
		if idx != -1:
			_on_card_clicked(idx)

func _get_card_at_pos(pos: Vector2) -> int:
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			var idx: int = row * GRID_COLS + col
			var cx: float = START_X + col * (CARD_W + GAP_X)
			var cy: float = START_Y + row * (CARD_H + GAP_Y)
			if pos.x >= cx and pos.x <= cx + CARD_W and pos.y >= cy and pos.y <= cy + CARD_H:
				return idx
	return -1

func _on_card_clicked(idx: int) -> void:
	var c: Dictionary = cards[idx]
	if c["is_revealed"] or c["is_matched"]:
		return
		
	if AudioManager: AudioManager.play_sfx("click")
	_flip_card(idx, true)
	
	if first_card_idx == -1:
		first_card_idx = idx
	elif second_card_idx == -1:
		second_card_idx = idx
		_lock_input = true
		_check_match()

func _flip_card(idx: int, reveal: bool) -> void:
	if idx < 0 or idx >= cards.size():
		return
	var tween: Tween = create_tween()
	tween.tween_method(func(val: float):
		if idx < cards.size():
			cards[idx]["flip_scale_x"] = val
			queue_redraw()
	, 1.0, 0.0, 0.08)
	tween.tween_callback(func():
		if idx < cards.size():
			cards[idx]["is_revealed"] = reveal
			queue_redraw()
	)
	tween.tween_method(func(val: float):
		if idx < cards.size():
			cards[idx]["flip_scale_x"] = val
			queue_redraw()
	, 0.0, 1.0, 0.08)

func _check_match() -> void:
	var c1: Dictionary = cards[first_card_idx]
	var c2: Dictionary = cards[second_card_idx]
	
	if c1["id"] == c2["id"]:
		# Match
		c1["is_matched"] = true
		c2["is_matched"] = true
		_matched_pairs += 1
		if matches_label: matches_label.text = "PAIRS: %d / 4" % _matched_pairs
		if AudioManager: AudioManager.play_sfx("levelup")
		
		# Add star particles
		for _p in range(6):
			_particles.append({
				"pos": Vector2(START_X + (first_card_idx % GRID_COLS) * (CARD_W + GAP_X) + 22.0, 60.0),
				"vel": Vector2(randf_range(-30, 30), randf_range(-30, 30)),
				"color": Color(1.0, 0.85, 0.2),
				"life": 0.45,
				"max_life": 0.45
			})
			
		first_card_idx = -1
		second_card_idx = -1
		_lock_input = false
		
		if _matched_pairs >= 4:
			_on_victory()
	else:
		# No match -> Flip back
		var tween = create_tween()
		tween.tween_interval(0.55)
		tween.tween_callback(func():
			_flip_card(first_card_idx, false)
			_flip_card(second_card_idx, false)
			first_card_idx = -1
			second_card_idx = -1
			_lock_input = false
		)

func _on_victory() -> void:
	is_playing = false
	is_game_over = true
	if AudioManager: AudioManager.play_sfx("victory")
	
	var time_bonus_coins: int = int(time_left * 0.5)
	var total_coins: int = 25 + time_bonus_coins
	
	if GameState:
		GameState.add_coins(total_coins, "minigame_memory_match")
		GameState.add_knowledge_points(8, "minigame_memory_match")
		GameState.add_exp(50)
		GameState.record_minigame_score("memory_match", int(time_left))
		
	if result_panel: result_panel.visible = true
	if result_title_label: result_title_label.text = "🧠 ATTIC MEMORY MASTER!"
	if result_desc_label: result_desc_label.text = "All 4 study pairs recalled in record time!"
	if result_reward_label: result_reward_label.text = "+%d 🪙  +8 ⭐ KP  +50 EXP" % total_coins

func _on_time_up() -> void:
	is_playing = false
	is_game_over = true
	if GameState:
		GameState.add_coins(10, "minigame_memory_match")
		GameState.add_knowledge_points(2, "minigame_memory_match")
		
	if result_panel: result_panel.visible = true
	if result_title_label: result_title_label.text = "⏳ TIME EXPIRED"
	if result_desc_label: result_desc_label.text = "Matched %d of 4 pairs! Keep sharpening recall!" % _matched_pairs
	if result_reward_label: result_reward_label.text = "+10 🪙  +2 ⭐ KP"

func _draw() -> void:
	# Background
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.04, 0.05, 0.09, 0.96))
	
	for row in range(GRID_ROWS):
		for col in range(GRID_COLS):
			var idx: int = row * GRID_COLS + col
			var c: Dictionary = cards[idx]
			var cx: float = START_X + col * (CARD_W + GAP_X)
			var cy: float = START_Y + row * (CARD_H + GAP_Y)
			var s_x: float = c.get("flip_scale_x", 1.0)
			
			var draw_w: float = CARD_W * s_x
			var offset_x: float = (CARD_W - draw_w) * 0.5
			var card_rect: Rect2 = Rect2(cx + offset_x, cy, draw_w, CARD_H)
			
			if c["is_matched"]:
				draw_rect(card_rect, Color(0.12, 0.22, 0.16, 0.7))
				draw_rect(card_rect, Color(0.35, 0.85, 0.55), false, 1.0)
				draw_circle(Vector2(cx + CARD_W * 0.5, cy + CARD_H * 0.5), 8.0 * s_x, c["info"]["color"])
			elif c["is_revealed"]:
				draw_rect(card_rect, Color(0.12, 0.16, 0.26))
				draw_rect(card_rect, Color(0.38, 0.77, 0.99), false, 1.0)
				draw_circle(Vector2(cx + CARD_W * 0.5, cy + CARD_H * 0.5), 10.0 * s_x, c["info"]["color"])
			else:
				# Face down card
				draw_rect(card_rect, Color(0.16, 0.19, 0.31))
				draw_rect(card_rect, Color(0.28, 0.35, 0.54), false, 1.0)
				# Pixel diamond pattern on card back
				draw_circle(Vector2(cx + CARD_W * 0.5, cy + CARD_H * 0.5), 4.0 * s_x, Color(0.38, 0.48, 0.72, 0.6))
				
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
