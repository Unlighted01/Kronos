extends Control
class_name SnackCatchGame

## 🥐 Snack Catch — Cozy Break-Time Pixel Minigame for Kronos.
## Catch falling croissants, boba, and sushi during break to earn Bonus Coins, EXP, and Pet Joy!

signal game_closed()

# ==============================================================================
# 🎮 GAME CONSTANTS & REWARDS
# ==============================================================================
const GAME_DURATION: float = 30.0 # 30-second rapid break sprint
const FLOOR_Y: float = 114.0
const MIN_X: float = 24.0
const MAX_X: float = 212.0
const PLAYER_SPEED: float = 150.0

const ITEM_TYPES: Array[Dictionary] = [
	{ "name": "croissant", "icon": "🥐", "points": 10, "speed": 65.0, "color": Color(0.96, 0.62, 0.04) },
	{ "name": "boba", "icon": "🧋", "points": 15, "speed": 80.0, "color": Color(0.93, 0.28, 0.60) },
	{ "name": "sushi", "icon": "🍣", "points": 25, "speed": 100.0, "color": Color(0.31, 0.82, 0.91) },
	{ "name": "alarm", "icon": "⏰", "points": -15, "speed": 90.0, "color": Color(0.9, 0.3, 0.3) }
]

# ==============================================================================
# 📊 GAME STATE
# ==============================================================================
var time_left: float = GAME_DURATION
var score: int = 0
var is_playing: bool = false
var is_game_over: bool = false

var player_x: float = 118.0
var _spawn_timer: float = 0.0
var _spawn_interval: float = 0.75
var _active_items: Array[Dictionary] = []
var _popups: Array[Dictionary] = []

# ==============================================================================
# 🎛️ UI REFERENCES
# ==============================================================================
@onready var hud_timer_label: Label = $HUD/HBox/TimerLabel
@onready var hud_score_label: Label = $HUD/HBox/ScoreLabel
@onready var close_btn: Button = $HUD/HBox/CloseButton

@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/VBox/FinalScoreLabel
@onready var reward_label: Label = $GameOverPanel/VBox/RewardLabel
@onready var replay_btn: Button = $GameOverPanel/VBox/HBox/ReplayButton
@onready var exit_btn: Button = $GameOverPanel/VBox/HBox/ExitButton

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
		
	if game_over_panel:
		game_over_panel.visible = false
		
	start_game()

func start_game() -> void:
	time_left = GAME_DURATION
	score = 0
	is_playing = true
	is_game_over = false
	player_x = 118.0
	_spawn_timer = 0.0
	_spawn_interval = 0.75
	_active_items.clear()
	_popups.clear()
	
	if game_over_panel:
		game_over_panel.visible = false
		
	if AudioManager:
		AudioManager.play_sfx("chime")
		
	queue_redraw()

func _process(delta: float) -> void:
	if not is_playing or is_game_over:
		return
		
	# 1. Timer Countdown
	time_left -= delta
	if hud_timer_label:
		hud_timer_label.text = "⏱️ %02ds" % int(ceilf(time_left))
	if hud_score_label:
		hud_score_label.text = "🏆 %d" % score
		
	if time_left <= 0.0:
		time_left = 0.0
		_trigger_game_over()
		return
		
	# 2. Player Input Movement
	var move_dir: float = 0.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		move_dir -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		move_dir += 1.0
		
	if move_dir != 0.0:
		player_x += move_dir * PLAYER_SPEED * delta
	else:
		# Smoothly track mouse cursor if hovering over canvas
		var local_mouse_x: float = get_local_mouse_position().x
		if local_mouse_x >= 0 and local_mouse_x <= size.x:
			player_x = lerpf(player_x, local_mouse_x, 14.0 * delta)
			
	player_x = clampf(player_x, MIN_X, MAX_X)
	
	# 3. Item Spawning
	_spawn_timer += delta
	if _spawn_timer >= _spawn_interval:
		_spawn_timer = 0.0
		_spawn_random_item()
		_spawn_interval = randf_range(0.45, 0.85)
		
	# 4. Item Falling & Catch Physics
	for i in range(_active_items.size() - 1, -1, -1):
		var item: Dictionary = _active_items[i]
		item["y"] += item["speed"] * delta
		
		# Check Catch Hitbox
		if item["y"] >= (FLOOR_Y - 14.0) and item["y"] <= (FLOOR_Y + 4.0):
			if absf(item["x"] - player_x) <= 18.0:
				# Caught!
				_on_item_caught(item)
				_active_items.remove_at(i)
				continue
				
		# Missed / Fallen off bottom
		if item["y"] > size.y + 10.0:
			_active_items.remove_at(i)
			
	# 5. Process Floating Score Popups
	for i in range(_popups.size() - 1, -1, -1):
		var p: Dictionary = _popups[i]
		p["y"] -= 20.0 * delta
		p["alpha"] -= 1.4 * delta
		if p["alpha"] <= 0.0:
			_popups.remove_at(i)
			
	queue_redraw()

func _spawn_random_item() -> void:
	var roll: float = randf()
	var tpl: Dictionary = ITEM_TYPES[0] # Croissant (45%)
	if roll > 0.82:
		tpl = ITEM_TYPES[3] # Alarm clock hazard (18%)
	elif roll > 0.60:
		tpl = ITEM_TYPES[2] # Sushi (22%)
	elif roll > 0.35:
		tpl = ITEM_TYPES[1] # Boba (25%)
		
	var item: Dictionary = {
		"name": tpl["name"],
		"icon": tpl["icon"],
		"points": tpl["points"],
		"speed": tpl["speed"] * randf_range(0.9, 1.2),
		"color": tpl["color"],
		"x": randf_range(MIN_X + 8.0, MAX_X - 8.0),
		"y": 14.0
	}
	_active_items.append(item)

func _on_item_caught(item: Dictionary) -> void:
	var pts: int = item["points"]
	score = maxi(0, score + pts)
	
	if pts > 0:
		if AudioManager:
			AudioManager.play_sfx("munch")
		_spawn_popup("+%d" % pts, item["x"], item["y"] - 10.0, item["color"])
	else:
		if AudioManager:
			AudioManager.play_sfx("click")
		_spawn_popup("%d" % pts, item["x"], item["y"] - 10.0, Color(0.95, 0.3, 0.3))

func _spawn_popup(text: String, x: float, y: float, col: Color) -> void:
	_popups.append({
		"text": text,
		"x": x,
		"y": y,
		"color": col,
		"alpha": 1.0
	})

func _trigger_game_over() -> void:
	is_game_over = true
	is_playing = false
	
	var reward_coins: int = maxi(10, int(score * 1.0))
	var reward_exp: int = maxi(5, int(score * 0.5))
	
	if GameState:
		GameState.add_coins(reward_coins, "snack_catch_minigame")
		GameState.add_exp(reward_exp)
		GameState.add_joy(25.0)
		
	if AudioManager:
		AudioManager.play_sfx("chime")
		
	if final_score_label:
		final_score_label.text = "🏆 Final Score: %d" % score
	if reward_label:
		reward_label.text = "+%d G  +%d XP  +25 Joy! 🐾" % [reward_coins, reward_exp]
		
	if game_over_panel:
		game_over_panel.visible = true
		
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
	# 1. Dark Backdrop
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.06, 0.09, 0.16, 0.94))
	
	# 2. Floor Line
	draw_line(Vector2(0, FLOOR_Y + 14.0), Vector2(size.x, FLOOR_Y + 14.0), Color(0.18, 0.24, 0.36), 2.0)
	draw_line(Vector2(0, FLOOR_Y + 16.0), Vector2(size.x, FLOOR_Y + 16.0), Color(0.12, 0.16, 0.24), 1.0)
	
	# 3. Draw Falling Treats
	var font: Font = ThemeDB.fallback_font
	for item in _active_items:
		var pos: Vector2 = Vector2(item["x"], item["y"])
		# Item soft shadow
		draw_circle(pos + Vector2(0, 4), 6.0, Color(0, 0, 0, 0.3))
		# Draw item icon
		draw_string(font, pos + Vector2(-6, 4), item["icon"], HORIZONTAL_ALIGNMENT_CENTER, -1, 11)
		
	# 4. Draw Shiba Player Basket / Catcher
	var sx: float = player_x
	var sy: float = FLOOR_Y
	
	# Shiba cozy shadow
	draw_circle(Vector2(sx, sy + 12), 14.0, Color(0, 0, 0, 0.35))
	
	# Shiba body block (Honey gold #f59e0b)
	draw_rect(Rect2(sx - 10, sy - 4, 20, 14), Color(0.96, 0.62, 0.04))
	draw_rect(Rect2(sx - 8, sy - 14, 16, 11), Color(0.96, 0.62, 0.04)) # Head
	
	# Muzzle (Cream #fef3c7)
	draw_rect(Rect2(sx - 5, sy - 7, 10, 5), Color(0.99, 0.95, 0.78))
	draw_rect(Rect2(sx - 1, sy - 7, 2, 2), Color(0.1, 0.05, 0.0)) # Nose
	
	# Ears (Alert triangular)
	draw_colored_polygon(PackedVector2Array([Vector2(sx - 8, sy - 14), Vector2(sx - 4, sy - 21), Vector2(sx - 1, sy - 14)]), Color(0.85, 0.47, 0.04))
	draw_colored_polygon(PackedVector2Array([Vector2(sx + 1, sy - 14), Vector2(sx + 4, sy - 21), Vector2(sx + 8, sy - 14)]), Color(0.85, 0.47, 0.04))
	
	# Happy Catching Eyes (^ ^)
	draw_string(font, Vector2(sx - 7, sy - 8), "^", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.1, 0.05, 0.0))
	draw_string(font, Vector2(sx + 2, sy - 8), "^", HORIZONTAL_ALIGNMENT_CENTER, -1, 8, Color(0.1, 0.05, 0.0))
	
	# Catching Basket / Bowl (Carved Wood)
	draw_rect(Rect2(sx - 14, sy - 16, 28, 6), Color(0.57, 0.25, 0.05)) # Bowl rim
	draw_rect(Rect2(sx - 12, sy - 10, 24, 4), Color(0.45, 0.18, 0.03)) # Bowl base
	
	# 5. Draw Floating Popups
	for p in _popups:
		var p_col: Color = p["color"]
		p_col.a = p["alpha"]
		draw_string(font, Vector2(p["x"] - 10, p["y"]), p["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 9, p_col)
