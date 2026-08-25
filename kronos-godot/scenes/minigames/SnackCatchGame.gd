extends Control
class_name SnackCatchGame

## 🥐 Snack Catch 2.0 — Cozy Break-Time Pixel Minigame for Kronos.
## Catch falling croissants, boba, sushi & golden stars with combo multipliers for Coins, EXP, KP, and physical Treat drops!

signal game_closed()

const GAME_DURATION: float = 30.0
const FLOOR_Y: float = 114.0
const MIN_X: float = 24.0
const MAX_X: float = 212.0
const PLAYER_SPEED: float = 160.0

const ITEM_TYPES: Array[Dictionary] = [
	{ "name": "croissant", "icon": "🥐", "points": 10, "speed": 65.0, "color": Color(0.96, 0.62, 0.04) },
	{ "name": "boba", "icon": "🧋", "points": 15, "speed": 80.0, "color": Color(0.93, 0.28, 0.60) },
	{ "name": "sushi", "icon": "🍣", "points": 25, "speed": 95.0, "color": Color(0.31, 0.82, 0.91) },
	{ "name": "star", "icon": "⭐", "points": 40, "speed": 110.0, "color": Color(1.0, 0.85, 0.2) },
	{ "name": "alarm", "icon": "⏰", "points": -15, "speed": 85.0, "color": Color(0.95, 0.3, 0.3) }
]

var time_left: float = GAME_DURATION
var score: int = 0
var combo_streak: int = 0
var is_playing: bool = false
var is_game_over: bool = false
var fever_timer: float = 0.0

var player_x: float = 118.0
var _spawn_timer: float = 0.0
var _spawn_interval: float = 0.65
var _active_items: Array[Dictionary] = []
var _popups: Array[Dictionary] = []
var _particles: Array[Dictionary] = []

@onready var hud_timer_label: Label = $HUD/HBox/TimerLabel
@onready var hud_score_label: Label = $HUD/HBox/ScoreLabel
@onready var close_btn: Button = $HUD/HBox/CloseButton

@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var final_score_label: Label = $GameOverPanel/VBox/FinalScoreLabel
@onready var reward_label: Label = $GameOverPanel/VBox/RewardLabel
@onready var replay_btn: Button = $GameOverPanel/VBox/HBox/ReplayButton
@onready var exit_btn: Button = $GameOverPanel/VBox/HBox/ExitButton

func _ready() -> void:
	custom_minimum_size = Vector2(236, 140)
	mouse_filter = MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	if close_btn: close_btn.pressed.connect(_on_exit_pressed)
	if replay_btn: replay_btn.pressed.connect(start_game)
	if exit_btn: exit_btn.pressed.connect(_on_exit_pressed)
	if game_over_panel: game_over_panel.visible = false
		
	start_game()

func start_game() -> void:
	time_left = GAME_DURATION
	score = 0
	combo_streak = 0
	fever_timer = 0.0
	is_playing = true
	is_game_over = false
	player_x = 118.0
	_spawn_timer = 0.0
	_spawn_interval = 0.65
	_active_items.clear()
	_popups.clear()
	_particles.clear()
	
	if game_over_panel:
		game_over_panel.visible = false
	if AudioManager:
		AudioManager.play_sfx("chime")
	queue_redraw()

func _process(delta: float) -> void:
	if not is_playing or is_game_over:
		return
		
	time_left -= delta
	if fever_timer > 0.0:
		fever_timer -= delta
		
	if hud_timer_label:
		hud_timer_label.text = "⏱️ %02ds" % int(ceilf(time_left))
	if hud_score_label:
		var combo_txt: String = " (x%.1f)" % _get_combo_multiplier() if combo_streak >= 3 else ""
		hud_score_label.text = "🏆 %d%s" % [score, combo_txt]
		
	# Keyboard movement
	var move_dir: float = 0.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		move_dir -= 1.0
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		move_dir += 1.0
		
	if move_dir != 0.0:
		player_x = clampf(player_x + move_dir * PLAYER_SPEED * delta, MIN_X, MAX_X)
		
	# Spawn falling items
	_spawn_timer += delta
	var cur_interval: float = _spawn_interval * (0.5 if fever_timer > 0.0 else 1.0)
	if _spawn_timer >= cur_interval:
		_spawn_timer = 0.0
		_spawn_item()
		
	# Update items
	var basket_w: float = 24.0
	var basket_y: float = FLOOR_Y - 8.0
	var i: int = _active_items.size() - 1
	while i >= 0:
		var it: Dictionary = _active_items[i]
		it["y"] += it["speed"] * delta
		
		# Collision check with player basket
		if it["y"] >= basket_y - 4.0 and it["y"] <= basket_y + 8.0:
			if absf(it["x"] - player_x) <= (basket_w * 0.5 + 4.0):
				_catch_item(it)
				_active_items.remove_at(i)
				i -= 1
				continue
				
		# Missed floor check
		if it["y"] >= FLOOR_Y + 12.0:
			if it["name"] != "alarm":
				combo_streak = 0
			_active_items.remove_at(i)
			i -= 1
			continue
			
		i -= 1
		
	# Update popups
	var p_idx: int = _popups.size() - 1
	while p_idx >= 0:
		var pop: Dictionary = _popups[p_idx]
		pop["life"] -= delta
		pop["y"] -= 18.0 * delta
		if pop["life"] <= 0.0:
			_popups.remove_at(p_idx)
		p_idx -= 1
		
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
		_game_over()
		
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if not is_playing or is_game_over:
		return
	if event is InputEventMouseMotion:
		player_x = clampf(event.position.x, MIN_X, MAX_X)

func _get_combo_multiplier() -> float:
	if combo_streak >= 9: return 2.5
	if combo_streak >= 6: return 2.0
	if combo_streak >= 3: return 1.5
	return 1.0

func _spawn_item() -> void:
	var roll: float = randf()
	var type_idx: int = 0
	
	if fever_timer > 0.0:
		type_idx = 0 if randf() < 0.6 else 2 # Croissants & sushi during fever
	else:
		if roll < 0.40: type_idx = 0       # 40% Croissant
		elif roll < 0.65: type_idx = 1     # 25% Boba
		elif roll < 0.82: type_idx = 2     # 17% Sushi
		elif roll < 0.90: type_idx = 3     # 8% Golden Star
		else: type_idx = 4                 # 10% Red Alarm
		
	var item_template: Dictionary = ITEM_TYPES[type_idx]
	var item_data: Dictionary = item_template.duplicate()
	item_data["x"] = randf_range(MIN_X + 10.0, MAX_X - 10.0)
	item_data["y"] = 16.0
	_active_items.append(item_data)

func _catch_item(it: Dictionary) -> void:
	var is_alarm: bool = (it["name"] == "alarm")
	if is_alarm:
		combo_streak = 0
		score = maxi(0, score + it["points"])
		if AudioManager: AudioManager.play_sfx("click")
		_add_popup(it["x"], it["y"] - 10.0, "-15 ⏰", Color(1.0, 0.4, 0.4))
		return
		
	combo_streak += 1
	var mult: float = _get_combo_multiplier()
	var pts_earned: int = int(it["points"] * mult)
	score += pts_earned
	
	if it["name"] == "star":
		fever_timer = 4.0
		if AudioManager: AudioManager.play_sfx("levelup")
		_add_popup(it["x"], it["y"] - 12.0, "FEVER! ⭐ +%d" % pts_earned, Color(1.0, 0.9, 0.2))
	else:
		if AudioManager: AudioManager.play_sfx("chime")
		var combo_str: String = " (x%.1f)" % mult if mult > 1.0 else ""
		_add_popup(it["x"], it["y"] - 8.0, "+%d%s" % [pts_earned, combo_str], it["color"])
		
	# Spawn particle sparkles
	for _p in range(4):
		_particles.append({
			"pos": Vector2(it["x"], it["y"]),
			"vel": Vector2(randf_range(-30, 30), randf_range(-40, -10)),
			"color": it["color"],
			"life": 0.4,
			"max_life": 0.4
		})

func _add_popup(px: float, py: float, txt: String, col: Color) -> void:
	_popups.append({
		"x": px,
		"y": py,
		"text": txt,
		"color": col,
		"life": 0.65
	})

func _game_over() -> void:
	is_playing = false
	is_game_over = true
	
	var coins_reward: int = maxi(15, int(score * 0.15))
	var exp_reward: int = maxi(20, int(score * 0.20))
	var got_snack: bool = (score >= 150)
	
	if GameState:
		GameState.add_coins(coins_reward, "minigame_snack_catch")
		GameState.add_exp(exp_reward)
		GameState.modify_pet_joy(25.0)
		if got_snack:
			GameState.add_item("snack_croissant", 1)
			if NotificationManager:
				NotificationManager.show_toast("Bonus Snack Earned! 🥐✨", NotificationManager.ToastType.SUCCESS)
		GameState.record_minigame_score("snack_catch", score)
		
	if AudioManager:
		AudioManager.play_sfx("victory")
		
	if game_over_panel:
		game_over_panel.visible = true
	if final_score_label:
		final_score_label.text = "FINAL SCORE: %d" % score
	if reward_label:
		var bonus_txt: String = " + 🥐 CROISSANT" if got_snack else ""
		reward_label.text = "+%d 🪙  +%d EXP  +25 💖%s" % [coins_reward, exp_reward, bonus_txt]

func _draw() -> void:
	# Background dim
	draw_rect(Rect2(0, 0, size.x, size.y), Color(0.04, 0.05, 0.08, 0.96))
	
	# Floor line
	draw_line(Vector2(MIN_X - 10, FLOOR_Y), Vector2(MAX_X + 10, FLOOR_Y), Color(0.2, 0.25, 0.35, 0.8), 2.0)
	
	# Fever background glow
	if fever_timer > 0.0:
		var fever_alpha: float = (sin(Time.get_ticks_msec() * 0.01) * 0.5 + 0.5) * 0.15
		draw_rect(Rect2(0, 0, size.x, size.y), Color(1.0, 0.8, 0.2, fever_alpha))
		
	# Draw Falling Items
	for it in _active_items:
		var ix: float = it["x"]
		var iy: float = it["y"]
		draw_circle(Vector2(ix, iy), 8.0, it["color"])
		draw_circle(Vector2(ix, iy), 6.0, Color(0.1, 0.1, 0.1, 0.85))
		# Draw mini icon dot
		draw_circle(Vector2(ix, iy), 3.0, it["color"])
		
	# Draw Player Shiba & Basket
	var py: float = FLOOR_Y - 8.0
	# Basket
	draw_rect(Rect2(player_x - 12, py - 4, 24, 8), Color(0.72, 0.45, 0.20))
	draw_rect(Rect2(player_x - 10, py - 2, 20, 4), Color(0.45, 0.25, 0.10))
	# Shiba Head
	draw_circle(Vector2(player_x, py + 3), 7.0, Color(0.96, 0.62, 0.04))
	draw_circle(Vector2(player_x - 2, py + 2), 1.5, Color(0.1, 0.1, 0.1))
	draw_circle(Vector2(player_x + 2, py + 2), 1.5, Color(0.1, 0.1, 0.1))
	
	# Draw Popups
	var font: Font = ThemeDB.fallback_font
	for pop in _popups:
		var alpha: float = clampf(pop["life"] / 0.65, 0.0, 1.0)
		var col: Color = pop["color"]
		col.a = alpha
		draw_string(font, Vector2(pop["x"] - 18, pop["y"]), pop["text"], HORIZONTAL_ALIGNMENT_CENTER, -1, 7, col)
		
	# Draw Particles
	for pt in _particles:
		var p_alpha: float = clampf(pt["life"] / pt["max_life"], 0.0, 1.0)
		var p_col: Color = pt["color"]
		p_col.a = p_alpha
		draw_rect(Rect2(pt["pos"].x, pt["pos"].y, 2, 2), p_col)

func _on_exit_pressed() -> void:
	if AudioManager: AudioManager.play_sfx("click")
	game_closed.emit()
	queue_free()
