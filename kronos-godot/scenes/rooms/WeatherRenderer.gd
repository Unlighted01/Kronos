extends Node2D
class_name WeatherRenderer

var _anim_clock: float = 0.0
var _raindrops: Array[Dictionary] = []
var _snowflakes: Array[Dictionary] = []
var _shooting_stars: Array[Dictionary] = []

func _ready() -> void:
	z_index = 100 # Draw over pets
	if EventBus and EventBus.has_signal("weather_changed"):
		EventBus.weather_changed.connect(_on_weather_changed)

func _on_weather_changed(_weather_id: int) -> void:
	# Clear particles when weather changes
	_raindrops.clear()
	_snowflakes.clear()
	queue_redraw()

func _process(delta: float) -> void:
	if not GameState: return
	
	var w = GameState.current_weather
	if w == GameState.Weather.CLEAR:
		return
		
	_anim_clock += delta
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	if w == GameState.Weather.RAIN:
		if _raindrops.size() < 60:
			_raindrops.append({
				"x": randf_range(cam_x - 100, cam_x + 340),
				"y": randf_range(-50, 0),
				"speed": randf_range(300.0, 450.0)
			})
		for i in range(_raindrops.size() - 1, -1, -1):
			var r = _raindrops[i]
			r["x"] -= r["speed"] * delta * 0.2 # Slant left
			r["y"] += r["speed"] * delta
			if r["y"] > 140:
				_raindrops.remove_at(i)
				
	elif w == GameState.Weather.SNOW:
		if _snowflakes.size() < 40 and randf() < 0.3:
			_snowflakes.append({
				"x": randf_range(cam_x - 50, cam_x + 290),
				"y": -10,
				"speed": randf_range(20.0, 40.0),
				"sway": randf_range(1.0, 2.0),
				"phase": randf_range(0, PI*2),
				"size": randf_range(1.0, 2.5)
			})
		for i in range(_snowflakes.size() - 1, -1, -1):
			var s = _snowflakes[i]
			s["y"] += s["speed"] * delta
			s["x"] += sin(_anim_clock * s["sway"] + s["phase"]) * 15.0 * delta
			if s["y"] > 140:
				_snowflakes.remove_at(i)
				
	elif w == GameState.Weather.STAR_SHOWER:
		if _shooting_stars.size() < 3 and randf() < 0.05:
			_shooting_stars.append({
				"x": randf_range(cam_x + 100, cam_x + 400),
				"y": randf_range(-20, 20),
				"speed": randf_range(200.0, 400.0),
				"life": randf_range(1.5, 3.0)
			})
		for i in range(_shooting_stars.size() - 1, -1, -1):
			var s = _shooting_stars[i]
			s["x"] -= s["speed"] * delta
			s["y"] += s["speed"] * delta * 0.5
			s["life"] -= delta
			if s["life"] <= 0:
				_shooting_stars.remove_at(i)
				
	queue_redraw()

func _draw() -> void:
	if not GameState: return
	var w = GameState.current_weather
	
	if w == GameState.Weather.RAIN:
		# Lightning flashes
		if fmod(_anim_clock, 5.0) < 0.1 and randf() < 0.2:
			var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
			draw_rect(Rect2(cam_x, 0, 240, 140), Color(1.0, 1.0, 1.0, 0.3))
			
		for r in _raindrops:
			draw_line(Vector2(r["x"], r["y"]), Vector2(r["x"] - 2, r["y"] + 6), Color(0.5, 0.6, 0.8, 0.5), 1.0)
			
	elif w == GameState.Weather.SNOW:
		for s in _snowflakes:
			draw_circle(Vector2(s["x"], s["y"]), s["size"], Color(1.0, 1.0, 1.0, 0.6))
			
	elif w == GameState.Weather.STAR_SHOWER:
		for s in _shooting_stars:
			var alpha = clampf(s["life"], 0.0, 1.0)
			draw_line(Vector2(s["x"], s["y"]), Vector2(s["x"] + 15, s["y"] - 7.5), Color(1.0, 0.9, 0.6, alpha), 1.5)
			draw_circle(Vector2(s["x"], s["y"]), 2.0, Color(1.0, 0.9, 0.6, alpha))
