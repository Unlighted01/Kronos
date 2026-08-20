extends Control
class_name MemoryMatchGame

## 🃏 Attic Memory Match — Cozy Card Flip Memory Minigame for Kronos.
## Flip cards and match all 4 pairs before time runs out to earn Coins, EXP, and Joy!

signal game_closed()

# ==============================================================================
# 🎮 GAME DATA & PAIRS
# ==============================================================================
const GAME_DURATION: float = 45.0
const CARD_TYPES: Array[Dictionary] = [
	{ "id": 0, "name": "croissant", "icon": "🥐", "color": Color(0.96, 0.62, 0.04) },
	{ "id": 1, "name": "boba", "icon": "🧋", "color": Color(0.93, 0.28, 0.60) },
	{ "id": 2, "name": "plant", "icon": "🪴", "color": Color(0.40, 0.85, 0.55) },
	{ "id": 3, "name": "pin", "icon": "📌", "color": Color(0.31, 0.82, 0.91) }
]

const GRID_COLS: int = 4
const GRID_ROWS: int = 2
const CARD_W: float = 44.0
const CARD_H: float = 48.0
const START_X: float = 22.0
const START_Y: float = 34.0
const GAP_X: float = 8.0
const GAP_Y: float = 6.0

# ==============================================================================
# 📊 STATE
# ==============================================================================
var time_left: float = GAME_DURATION
var is_playing: bool = false
var is_game_over: bool = false

var cards: Array[Dictionary] = [] # 8 card items
var first_card_idx: int = -1
var second_card_idx: int = -1
var _lock_input: bool = false
var _matched_pairs: int = 0

var _particles: Array[Dictionary] = []

# ==============================================================================
# 🎛️ UI REFERENCES
# ==============================================================================
@onready var timer_label: Label = $HUD/HBox/TimerLabel
@onready var matches_label: Label = $HUD/HBox/MatchesLabel
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
	if close_btn:
		close_btn.pressed.connect(_on_exit_pressed)
	if replay_btn:
		replay_btn.pressed.connect(start_game)
	if exit_btn:
		exit_btn.pressed.connect(_on_exit_pressed)
		
	if result_panel:
		result_panel.visible = false
		
	start_game()

func start_game() -> void:
	time_left = GAME_DURATION
	is_playing = true
	is_game_over = false
	_lock_input = false
	first_card_idx = -1
	second_card_idx = -1
	_matched_pairs = 0
	_particles.clear()
	
	# Generate 8 cards (2 of each type) and shuffle
	var deck: Array[int] = [0, 0, 1, 1, 2, 2, 3, 3]
	deck.shuffle()
	
	cards.clear()
	for i in range(8):
		var type_id: int = deck[i]
		var col: int = i % GRID_COLS
		var row: int = i / GRID_COLS
		var px: float = START_X + col * (CARD_W + GAP_X)
		var py: float = START_Y + row * (CARD_H + GAP_Y)
		
		cards.append({
			"type_id": type_id,
			"rect": Rect2(px, py, CARD_W, CARD_H),
			"is_flipped": false,
			"is_matched": false,
			"flip_scale": 1.0
		})
		
	if result_panel:
		result_panel.visible = false
		
	if AudioManager:
		AudioManager.play_sfx("chime")
		
	queue_redraw()

func _process(delta: float) -> void:
	if not is_playing or is_game_over:
		return
		
	# 1. Timer Countdown
	time_left -= delta
	if timer_label:
		timer_label.text = "⏱️ %02ds" % int(ceilf(time_left))
	if matches_label:
		matches_label.text = "🃏 Pairs: %d/4" % _matched_pairs
		
	if time_left <= 0.0:
		time_left = 0.0
		_trigger_game_over(false)
		return
		
	# 2. Sparkle Particle Animation
	for i in range(_particles.size() - 1, -1, -1):
		var p: Dictionary = _particles[i]
		p["x"] += p["vx"] * delta
		p["y"] += p["vy"] * delta
		p["alpha"] -= 1.8 * delta
		if p["alpha"] <= 0.0:
			_particles.remove_at(i)
			
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not is_playing or is_game_over or _lock_input:
		return
		
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			var clicked_idx: int = _get_card_at_pos(mb.position)
			if clicked_idx >= 0:
				_on_card_clicked(clicked_idx)
				get_viewport().set_input_as_handled()

func _get_card_at_pos(pos: Vector2) -> int:
	for i in range(cards.size()):
		var c: Dictionary = cards[i]
		if not c["is_matched"] and not c["is_flipped"]:
			if c["rect"].has_point(pos):
				return i
	return -1

func _on_card_clicked(idx: int) -> void:
	var card: Dictionary = cards[idx]
	card["is_flipped"] = true
	
	if AudioManager:
		AudioManager.play_sfx("click")
		
	if first_card_idx == -1:
		first_card_idx = idx
	elif second_card_idx == -1:
		second_card_idx = idx
		_lock_input = true
		_check_pair_match()
		
	queue_redraw()

func _check_pair_match() -> void:
	var c1: Dictionary = cards[first_card_idx]
	var c2: Dictionary = cards[second_card_idx]
	
	if c1["type_id"] == c2["type_id"]:
		# Match!
		c1["is_matched"] = true
		c2["is_matched"] = true
		_matched_pairs += 1
		
		if AudioManager:
			AudioManager.play_sfx("chime")
			
		_spawn_match_sparkles(c1["rect"])
		_spawn_match_sparkles(c2["rect"])
		
		first_card_idx = -1
		second_card_idx = -1
		_lock_input = false
		
		if _matched_pairs >= 4:
			# All 4 pairs cleared!
			_trigger_game_over(true)
	else:
		# Mismatch -> flip back after brief pause
		get_tree().create_timer(0.65).timeout.connect(func():
			if first_card_idx >= 0 and first_card_idx < cards.size():
				cards[first_card_idx]["is_flipped"] = false
			if second_card_idx >= 0 and second_card_idx < cards.size():
				cards[second_card_idx]["is_flipped"] = false
			first_card_idx = -1
			second_card_idx = -1
			_lock_input = false
			queue_redraw()
		)

func _spawn_match_sparkles(rect: Rect2) -> void:
	var cx: float = rect.position.x + rect.size.x / 2
	var cy: float = rect.position.y + rect.size.y / 2
	for i in range(8):
		_particles.append({
			"x": cx,
			"y": cy,
			"vx": randf_range(-40.0, 40.0),
			"vy": randf_range(-40.0, 40.0),
			"color": Color(0.96, 0.84, 0.15),
			"alpha": 1.0
		})

func _trigger_game_over(is_victory: bool) -> void:
	is_game_over = true
	is_playing = false
	
	if not result_panel:
		return
		
	if is_victory:
		var time_bonus: int = int(time_left * 1.5)
		var total_coins: int = 50 + time_bonus
		var total_exp: int = 30
		
		if GameState:
			GameState.add_coins(total_coins, "memory_match_minigame")
			GameState.add_exp(total_exp)
			GameState.add_joy(20.0)
			
		if AudioManager:
			AudioManager.play_sfx("bell")
			
		result_title_label.text = "🏆 ALL PAIRS MATCHED!"
		result_title_label.modulate = Color(0.96, 0.62, 0.04)
		result_desc_label.text = "Finished with %02ds remaining!" % int(ceilf(time_left))
		result_reward_label.text = "+%d G Coins  +%d XP  +20 Joy! 🐾" % [total_coins, total_exp]
		result_reward_label.modulate = Color(0.4, 0.85, 0.55)
	else:
		result_title_label.text = "⏱️ TIME'S UP!"
		result_title_label.modulate = Color(0.7, 0.75, 0.85)
		result_desc_label.text = "Matched %d of 4 pairs." % _matched_pairs
		result_reward_label.text = "+15 G Coins  +10 XP"
		result_reward_label.modulate = Color(0.96, 0.62, 0.04)
		if GameState:
			GameState.add_coins(15, "memory_match_minigame")
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
	# 1. Dark Attic Wood Backdrop
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.08, 0.07, 0.14, 0.96))
	
	var font: Font = ThemeDB.fallback_font
	
	# 2. Draw 8 Cards
	for i in range(cards.size()):
		var c: Dictionary = cards[i]
		var r: Rect2 = c["rect"]
		var is_open: bool = c["is_flipped"] or c["is_matched"]
		
		# Drop shadow
		draw_rect(Rect2(r.position.x + 2, r.position.y + 2, r.size.x, r.size.y), Color(0, 0, 0, 0.35))
		
		if is_open:
			# Front Face (Light Cream #fdf8e2)
			var tpl: Dictionary = CARD_TYPES[c["type_id"]]
			draw_rect(r, Color(0.96, 0.94, 0.88))
			# 1px border outline
			var border_col: Color = tpl["color"] if not c["is_matched"] else Color(0.4, 0.85, 0.55)
			draw_rect_outline(r, border_col, 1.5)
			# Card Icon
			draw_string(font, Vector2(r.position.x + r.size.x / 2 - 8, r.position.y + r.size.y / 2 + 6), tpl["icon"], HORIZONTAL_ALIGNMENT_CENTER, -1, 16)
		else:
			# Back Face (Deep Indigo with Pixel Diamond #1e1b4b)
			draw_rect(r, Color(0.18, 0.22, 0.35))
			draw_rect_outline(r, Color(0.31, 0.42, 0.60), 1.0)
			# Decorative back pattern
			var cx: float = r.position.x + r.size.x / 2
			var cy: float = r.position.y + r.size.y / 2
			draw_colored_polygon(PackedVector2Array([Vector2(cx, cy - 8), Vector2(cx + 8, cy), Vector2(cx, cy + 8), Vector2(cx - 8, cy)]), Color(0.31, 0.82, 0.91, 0.6))
			
	# 3. Sparkle Particles
	for p in _particles:
		var col: Color = p["color"]
		col.a = p["alpha"]
		draw_circle(Vector2(p["x"], p["y"]), 2.5, col)

func draw_rect_outline(rect: Rect2, color: Color, width: float = 1.0) -> void:
	draw_line(rect.position, Vector2(rect.position.x + rect.size.x, rect.position.y), color, width)
	draw_line(Vector2(rect.position.x + rect.size.x, rect.position.y), rect.position + rect.size, color, width)
	draw_line(rect.position + rect.size, Vector2(rect.position.x, rect.position.y + rect.size.y), color, width)
	draw_line(Vector2(rect.position.x, rect.position.y + rect.size.y), rect.position, color, width)
