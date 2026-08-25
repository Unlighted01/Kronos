@tool
extends BaseRoom
class_name DomainElysian

## Elysian Fields - A Sprawling Mythological Farm (720px wide).
## Features structured rice/wheat rows, a distant background windmill, and a scarecrow.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_SKY_TOP: Color = Color(0.18, 0.25, 0.35, 1.0)
const COL_SKY_BOT: Color = Color(0.40, 0.50, 0.60, 1.0)
const COL_NIGHT_TOP: Color = Color(0.05, 0.08, 0.18, 1.0)
const COL_NIGHT_BOT: Color = Color(0.12, 0.20, 0.38, 1.0)

const COL_CLOUD: Color = Color(0.85, 0.85, 0.90, 0.8)
const COL_RIVER: Color = Color(0.25, 0.35, 0.45, 1.0)

const COL_HILL_BACK: Color = Color(0.25, 0.30, 0.25, 1.0)
const COL_HILL_FRONT: Color = Color(0.35, 0.40, 0.30, 1.0)

# Lo-Fi Desaturated Crop Palette
const COL_CROP_BG: Color = Color(0.35, 0.35, 0.20, 1.0)
const COL_CROP_MID: Color = Color(0.45, 0.42, 0.22, 1.0)
const COL_CROP_FG: Color = Color(0.55, 0.50, 0.25, 1.0)
const COL_CROP_HEAD: Color = Color(0.70, 0.65, 0.30, 1.0)

const COL_DIRT: Color = Color(0.25, 0.20, 0.15, 1.0)
const COL_WOOD_DARK: Color = Color(0.20, 0.15, 0.10, 1.0)
const COL_WOOD_LIGHT: Color = Color(0.35, 0.25, 0.15, 1.0)
const COL_SAIL: Color = Color(0.70, 0.65, 0.55, 1.0)

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _anim_clock: float = 0.0
var _clouds: Array[Dictionary] = []
var _crows: Array[Dictionary] = []
var _crops: Array[Dictionary] = []
var _windmill_angle: float = 0.0

# Bounding Boxes
const RECT_SCARECROW: Rect2 = Rect2(40, 50, 60, 80)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_greenhouse"
	room_name = "Zen Greenhouse"
	room_width = 720.0
	min_x = 50.0
	max_x = 650.0
	desk_x = 100.0  # Near the scarecrow
	nap_x = 600.0   # In the soft rice fields
	drink_x = 350.0 # Field center
	
	for i in range(4):
		_spawn_cloud(randf_range(0, 720))
		
	_generate_crop_cache()

func _generate_crop_cache() -> void:
	# Pre-generate stalks so they never jitter in _draw!
	_crops.clear()
	
	for layer in range(3): # 0 = BG, 1 = MID, 2 = FG
		var base_y = 95.0 + layer * 15.0
		var x = -50.0
		
		while x < 800.0:
			# Random spacing
			x += randf_range(4.0, 10.0)
			
			# Scarecrow clearing logic (Foreground only)
			if layer == 2 and abs(x - 70.0) < 45.0:
				continue
				
			_crops.append({
				"layer": layer,
				"x": x,
				"y": base_y + randf_range(-4.0, 4.0),
				"height": randf_range(0.8, 1.2),
				"shade": randf_range(-0.05, 0.05)
			})

func _spawn_cloud(x_pos: float) -> void:
	_clouds.append({
		"x": x_pos,
		"y": randf_range(10, 35),
		"speed": randf_range(4.0, 8.0),
		"scale": randf_range(0.6, 1.4)
	})

func _process(delta: float) -> void:
	_anim_clock += delta
	_windmill_angle += 1.0 * delta
	
	# Update Crows
	for i in range(_crows.size() - 1, -1, -1):
		var c = _crows[i]
		c["x"] += c["vx"] * delta
		c["y"] += c["vy"] * delta
		c["life"] -= delta
		if c["life"] <= 0:
			_crows.remove_at(i)
	
	# Update Clouds
	for i in range(_clouds.size() - 1, -1, -1):
		var c = _clouds[i]
		c["x"] -= c["speed"] * delta
		if c["x"] < -150:
			_clouds.remove_at(i)
			_spawn_cloud(800.0)
			
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
		var pos: Vector2 = mb.position + Vector2(cam_x, 0)
		
		# Click Scarecrow to scare away crows!
		if RECT_SCARECROW.has_point(pos):
			for i in range(3):
				_crows.append({
					"x": 70.0 + randf_range(-10, 10),
					"y": 60.0 + randf_range(-10, 10),
					"vx": randf_range(100, 200), # Fly up and right
					"vy": randf_range(-100, -200),
					"life": 3.0,
					"phase": randf_range(0, PI)
				})
			if EventBus: EventBus.object_state_changed.emit("scarecrow_clicked", true)
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 DRAWING PIPELINE
# ==============================================================================
func _draw() -> void:
	var is_night = false
	if GameState and GameState.has_method("get_day_night_cycle"):
		is_night = (GameState.get_day_night_cycle() == "night")
		
	# 1. Sky & Clouds
	_draw_sky(is_night)
	
	# 2. Background River & Distant Hills
	_draw_background_hills_and_river()
	
	# 3. Background Windmill
	_draw_windmill(550, 70, 0.4)
	
	# 4. Dirt Base
	draw_rect(Rect2(0, 100, 720, 40), COL_DIRT)
	
	# 5. Cropped Fields (3 Layers)
	_draw_cached_crops()
	
	# 6. Left side: Scarecrow & Rustic Fence
	_draw_fence_and_scarecrow(70, 115)
	
	# 7. Flying Crows
	_draw_crows()

# ------------------------------------------------------------------------------
# 1. SKY & CLOUDS
# ------------------------------------------------------------------------------
func _draw_sky(is_night: bool) -> void:
	var top = COL_NIGHT_TOP if is_night else COL_SKY_TOP
	var bot = COL_NIGHT_BOT if is_night else COL_SKY_BOT
	for y in range(0, 80, 4):
		var lerp_val = float(y) / 80.0
		draw_rect(Rect2(0, y, 720, 4), top.lerp(bot, lerp_val))
		
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var c_offset = cam_x * 0.05
	
	for c in _clouds:
		var cx = c["x"] - c_offset
		if cx > -150 and cx < 850:
			var cloud_col = COL_CLOUD.darkened(0.5) if is_night else COL_CLOUD
			draw_circle(Vector2(cx, c["y"]), 15.0 * c["scale"], cloud_col)
			draw_circle(Vector2(cx - 15*c["scale"], c["y"] + 5*c["scale"]), 12.0 * c["scale"], cloud_col)
			draw_circle(Vector2(cx + 18*c["scale"], c["y"] + 8*c["scale"]), 10.0 * c["scale"], cloud_col)
			draw_rect(Rect2(cx - 15*c["scale"], c["y"] + 10*c["scale"], 35*c["scale"], 5*c["scale"]), cloud_col.darkened(0.1))

# ------------------------------------------------------------------------------
# 2. HILLS & RIVER
# ------------------------------------------------------------------------------
func _draw_background_hills_and_river() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	var h_offset_far = cam_x * 0.08
	for mx in range(0, 720, 4):
		var wx = mx + h_offset_far
		var hy = 65.0 + sin(wx * 0.01) * 15.0
		if hy < 80:
			draw_rect(Rect2(mx, hy, 4, 80 - hy), COL_HILL_BACK)
			
	var r_offset = cam_x * 0.12
	draw_rect(Rect2(0, 75, 720, 10), COL_RIVER)
	for i in range(0, 720, 30):
		var rx = fmod(i - r_offset + _anim_clock * 8.0, 720.0)
		if rx < 0: rx += 720.0
		draw_line(Vector2(rx, 78), Vector2(rx + 10, 78), COL_RIVER.lightened(0.2), 1.0)

	var h_offset_near = cam_x * 0.18
	for mx in range(0, 720, 4):
		var wx = mx + h_offset_near
		var hy = 85.0 + cos(wx * 0.015) * 5.0
		if hy < 100:
			draw_rect(Rect2(mx, hy, 4, 100 - hy), COL_HILL_FRONT)

# ------------------------------------------------------------------------------
# 3. BACKGROUND WINDMILL
# ------------------------------------------------------------------------------
func _draw_windmill(wx: float, wy: float, scale_f: float) -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var offset_x = wx - (cam_x * 0.1) 
	
	draw_set_transform(Vector2(offset_x, wy), 0.0, Vector2(scale_f, scale_f))
	
	# Tower
	var tower_pts = PackedVector2Array([
		Vector2(-25, 0), Vector2(25, 0),
		Vector2(15, -60), Vector2(-15, -60)
	])
	draw_colored_polygon(tower_pts, COL_WOOD_DARK)
	# Dome Roof
	draw_arc(Vector2(0, -60), 18.0, PI, PI*2, 16, COL_WOOD_LIGHT, 18.0)
	
	# Sails / Blades rotating automatically!
	var center = Vector2(0, -60)
	draw_set_transform(Vector2(offset_x, wy) + center, _windmill_angle, Vector2(scale_f, scale_f))
	
	for i in range(4):
		draw_set_transform(Vector2(offset_x, wy) + center, _windmill_angle + (i * PI/2.0), Vector2(scale_f, scale_f))
		draw_line(Vector2.ZERO, Vector2(60, 0), COL_WOOD_DARK, 2.0)
		draw_rect(Rect2(15, 2, 40, 12), COL_SAIL)
		for rx in range(15, 50, 8):
			draw_line(Vector2(rx, 2), Vector2(rx, 14), COL_WOOD_DARK, 1.0)
			
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
	draw_circle(Vector2(offset_x, wy - 60*scale_f), 4.0*scale_f, COL_WOOD_DARK)

# ------------------------------------------------------------------------------
# 4. CACHED CROP LAYERS
# ------------------------------------------------------------------------------
func _draw_cached_crops() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	for c in _crops:
		var layer = c["layer"]
		var parallax = 0.2 + (layer * 0.15) # Layer 0 is 0.2, Layer 1 is 0.35, Layer 2 is 0.5
		var w_offset = cam_x * parallax
		var px = c["x"] - w_offset
		
		# Only draw if on screen
		if px < -20 or px > 740:
			continue
			
		var py = c["y"]
		var h = (12.0 + (layer * 6.0)) * c["height"] # Foreground is tallest
		var sway = sin(_anim_clock * 1.5 + px * 0.05) * (3.0 + layer) 
		
		var stalk_col: Color
		if layer == 0: stalk_col = COL_CROP_BG
		elif layer == 1: stalk_col = COL_CROP_MID
		else: stalk_col = COL_CROP_FG
		
		stalk_col = stalk_col.lightened(c["shade"])
		var head_col = COL_CROP_HEAD.lightened(c["shade"]).darkened((2 - layer) * 0.1)
		
		var thickness = 1.0 + (layer * 0.5)
		
		# Stem
		draw_line(Vector2(px, py), Vector2(px + sway, py - h), stalk_col, thickness)
		# Grain head (Drooping)
		draw_line(Vector2(px + sway, py - h), Vector2(px + sway + 3, py - h + 4), head_col, thickness)
		draw_line(Vector2(px + sway, py - h + 2), Vector2(px + sway - 2, py - h + 5), head_col, thickness * 0.8)

# ------------------------------------------------------------------------------
# 5. SCARECROW & FENCE
# ------------------------------------------------------------------------------
func _draw_fence_and_scarecrow(sx: float, sy: float) -> void:
	# Rustic wooden fence extending from the left
	draw_line(Vector2(0, sy - 15), Vector2(150, sy - 15), COL_WOOD_DARK, 2.0)
	draw_line(Vector2(0, sy - 5), Vector2(160, sy - 5), COL_WOOD_DARK, 2.0)
	for fx in range(10, 160, 30):
		draw_line(Vector2(fx, sy), Vector2(fx, sy - 25), COL_WOOD_LIGHT, 3.0)
		draw_line(Vector2(fx - 1, sy), Vector2(fx - 1, sy - 25), COL_WOOD_DARK, 1.0)
		
	# The Scarecrow
	var cx = sx
	var cy = sy - 20
	# Post
	draw_line(Vector2(cx, cy + 20), Vector2(cx, cy - 30), COL_WOOD_DARK, 4.0)
	# Crossbar (Arms)
	draw_line(Vector2(cx - 20, cy - 10), Vector2(cx + 20, cy - 10), COL_WOOD_DARK, 3.0)
	
	# Straw body
	draw_rect(Rect2(cx - 10, cy - 10, 20, 25), COL_CROP_FG)
	draw_line(Vector2(cx - 20, cy - 10), Vector2(cx - 20, cy + 5), COL_CROP_FG, 2.0)
	draw_line(Vector2(cx + 20, cy - 10), Vector2(cx + 20, cy + 5), COL_CROP_FG, 2.0)
	
	# Pumpkin/Burlap Head
	draw_circle(Vector2(cx, cy - 20), 8.0, COL_WOOD_LIGHT)
	# Straw Hat
	var hat_pts = PackedVector2Array([
		Vector2(cx - 15, cy - 25), Vector2(cx + 15, cy - 25),
		Vector2(cx, cy - 35)
	])
	draw_colored_polygon(hat_pts, COL_CROP_HEAD)

# ------------------------------------------------------------------------------
# 7. CROWS
# ------------------------------------------------------------------------------
func _draw_crows() -> void:
	for c in _crows:
		var cx = c["x"]
		var cy = c["y"]
		# Wing flap animation
		var wing_y = sin(_anim_clock * 20.0 + c["phase"]) * 6.0
		# Body
		draw_circle(Vector2(cx, cy), 2.0, Color.BLACK)
		# Wings
		draw_line(Vector2(cx, cy), Vector2(cx - 6, cy + wing_y), Color.BLACK, 1.5)
		draw_line(Vector2(cx, cy), Vector2(cx + 6, cy + wing_y), Color.BLACK, 1.5)
