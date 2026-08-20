@tool
extends BaseRoom
class_name LivingRoom

## Cozy Living Room environment for Kronos.
## Features toggleable Fireplace fire, independent Floor Lamp switch,
## opening Bay Window with real seasonal weather,
## and a 3/4 sideways angled Pixel TV that realistically faces the couch
## and projects dynamic ambient CRT light across the seating lounge.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_WALL: Color = Color(0.24, 0.22, 0.28, 1.0)
const COL_WALL_TRIM: Color = Color(0.32, 0.28, 0.36, 1.0)
const COL_CARPET: Color = Color(0.55, 0.24, 0.26, 1.0) # Warm Burgundy Carpet
const COL_CARPET_PATTERN: Color = Color(0.65, 0.30, 0.32, 1.0)
const COL_BASEBOARD: Color = Color(0.28, 0.18, 0.12, 1.0)

# Fireplace
const COL_BRICK_MAIN: Color = Color(0.48, 0.28, 0.24, 1.0)
const COL_BRICK_SHADOW: Color = Color(0.32, 0.18, 0.15, 1.0)
const COL_MANTEL: Color = Color(0.38, 0.22, 0.14, 1.0)
const COL_FIRE_PIT: Color = Color(0.12, 0.08, 0.06, 1.0)
const COL_FIRE_ORANGE: Color = Color(1.0, 0.52, 0.12, 1.0)
const COL_FIRE_YELLOW: Color = Color(1.0, 0.88, 0.20, 1.0)
const COL_FIRE_RED: Color = Color(0.92, 0.22, 0.18, 1.0)
const COL_FIRE_GLOW: Color = Color(1.0, 0.60, 0.15, 0.22)
const COL_ASH_LOG: Color = Color(0.22, 0.18, 0.16, 1.0)

# Sofa & Furniture
const COL_SOFA_MAIN: Color = Color(0.28, 0.45, 0.48, 1.0) # Teal Plush Sofa
const COL_SOFA_SHADOW: Color = Color(0.18, 0.32, 0.35, 1.0)
const COL_SOFA_CUSHION: Color = Color(0.34, 0.54, 0.58, 1.0)
const COL_PILLOW_GOLD: Color = Color(0.92, 0.74, 0.28, 1.0)
const COL_TABLE_WOOD: Color = Color(0.45, 0.30, 0.20, 1.0)

# Floor Lamp
const COL_LAMP_BRASS: Color = Color(0.85, 0.72, 0.32, 1.0)
const COL_LAMP_SHADE: Color = Color(0.98, 0.92, 0.75, 1.0)
const COL_LAMP_SHADE_OFF: Color = Color(0.45, 0.42, 0.38, 1.0)
const COL_LAMP_GLOW: Color = Color(1.0, 0.94, 0.65, 0.30)

# Window Sky Palettes
const COL_SKY_DAY: Color = Color(0.45, 0.72, 0.95, 1.0)
const COL_SKY_SUNSET: Color = Color(0.92, 0.55, 0.42, 1.0)
const COL_SKY_NIGHT: Color = Color(0.08, 0.09, 0.18, 1.0)
const COL_SUN_GOLD: Color = Color(1.0, 0.92, 0.50, 1.0)
const COL_MOON_WHITE: Color = Color(0.95, 0.96, 1.0, 1.0)
const COL_WINDOW_FRAME: Color = Color(0.55, 0.40, 0.28, 1.0)
const COL_WINDOW_FRAME_DARK: Color = Color(0.38, 0.26, 0.18, 1.0)
const COL_WINDOW_GLASS_SHINE: Color = Color(1.0, 1.0, 1.0, 0.22)

# Retro Angled TV Palettes
const COL_TV_CASING: Color = Color(0.20, 0.18, 0.22, 1.0)
const COL_TV_CASING_DEPTH: Color = Color(0.14, 0.12, 0.16, 1.0)
const COL_TV_STAND: Color = Color(0.42, 0.28, 0.18, 1.0)
const COL_TV_STAND_SHADOW: Color = Color(0.28, 0.18, 0.12, 1.0)
const COL_TV_SCREEN_OFF: Color = Color(0.08, 0.08, 0.10, 1.0)
const COL_TV_SCREEN_ON: Color = Color(0.12, 0.25, 0.48, 1.0)
const COL_TV_GLOW: Color = Color(0.35, 0.65, 0.95, 0.22)

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var fire_embers: CPUParticles2D = $FireEmbers
@onready var seasonal_particles: CPUParticles2D = $SeasonalWeatherParticles

# ==============================================================================
# 📊 INTERACTION STATE
# ==============================================================================
var is_fireplace_lit: bool = true
var is_floor_lamp_on: bool = true
var is_window_open: bool = false
var is_tv_on: bool = false

var _fire_anim_timer: float = 0.0
var _fire_frame: int = 0
var _tv_anim_timer: float = 0.0
var _tv_frame: int = 0
var _flicker_timer: float = 0.0
var _breeze_offset: float = 0.0

# Bounding boxes for click areas
const RECT_FIREPLACE: Rect2 = Rect2(36, 48, 40, 50)
const RECT_FLOOR_LAMP: Rect2 = Rect2(102, 44, 12, 56)
const RECT_WINDOW: Rect2 = Rect2(118, 12, 38, 44)
const RECT_TV: Rect2 = Rect2(168, 62, 30, 42)
const RECT_LIGHT_SWITCH: Rect2 = Rect2(202, 70, 14, 22)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_livingroom"
	room_name = "Living Room Lounge"
	desk_x = 92.0
	nap_x = 138.0
	drink_x = 138.0
	
	# Load saved object states
	if GameState:
		is_fireplace_lit = GameState.get_object_state("livingroom_fireplace_lit", true)
		is_floor_lamp_on = GameState.get_object_state("livingroom_lamp_on", true)
		is_window_open = GameState.get_object_state("livingroom_window_open", false)
		is_tv_on = GameState.get_object_state("livingroom_tv_on", false)
		
	if fire_embers:
		fire_embers.emitting = is_fireplace_lit
		
	_update_seasonal_weather()
	EventBus.object_state_changed.connect(_on_object_state_changed)

func _process(delta: float) -> void:
	_fire_anim_timer += delta * 8.0
	_fire_frame = int(_fire_anim_timer) % 4
	_flicker_timer += delta * 3.0
	
	_tv_anim_timer += delta * 6.0
	_tv_frame = int(_tv_anim_timer) % 8
	
	if is_window_open:
		_breeze_offset = sin(_fire_anim_timer * 0.4) * 1.5
	else:
		_breeze_offset = 0.0
		
	queue_redraw()

func _on_object_state_changed(key: String, val: Variant) -> void:
	if key == "livingroom_fireplace_lit":
		is_fireplace_lit = val
		if fire_embers:
			fire_embers.emitting = is_fireplace_lit
		queue_redraw()
	elif key == "livingroom_lamp_on":
		is_floor_lamp_on = val
		queue_redraw()
	elif key == "livingroom_window_open":
		is_window_open = val
		_update_seasonal_weather()
		queue_redraw()
	elif key == "livingroom_tv_on":
		is_tv_on = val
		queue_redraw()

# ==============================================================================
# 🖱️ INTERACTION HANDLING
# ==============================================================================
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var pos: Vector2 = mb.position
		
		# 1. Click Light Switch
		if RECT_LIGHT_SWITCH.has_point(pos):
			if GameState:
				GameState.toggle_room_light(room_id)
			get_viewport().set_input_as_handled()
			return
			
		# 2. Click Fireplace
		if RECT_FIREPLACE.has_point(pos):
			is_fireplace_lit = not is_fireplace_lit
			if fire_embers:
				fire_embers.emitting = is_fireplace_lit
			if GameState:
				GameState.set_object_state("livingroom_fireplace_lit", is_fireplace_lit)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 3. Click Floor Lamp
		if RECT_FLOOR_LAMP.has_point(pos):
			is_floor_lamp_on = not is_floor_lamp_on
			if GameState:
				GameState.set_object_state("livingroom_lamp_on", is_floor_lamp_on)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 4. Click Window
		if RECT_WINDOW.has_point(pos):
			is_window_open = not is_window_open
			if GameState:
				GameState.set_object_state("livingroom_window_open", is_window_open)
			_update_seasonal_weather()
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 5. Click Angled TV
		if RECT_TV.has_point(pos):
			is_tv_on = not is_tv_on
			if GameState:
				GameState.set_object_state("livingroom_tv_on", is_tv_on)
			EventBus.object_state_changed.emit("livingroom_tv_on", is_tv_on)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 6. Click Sofa
		if Rect2(116, 72, 42, 26).has_point(pos):
			EventBus.object_state_changed.emit("livingroom_couch", true)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🍂 SEASONAL WEATHER CONFIGURATION
# ==============================================================================
func _update_seasonal_weather() -> void:
	if not seasonal_particles:
		return
		
	var season: String = GameState.get_current_season() if GameState else "summer"
	match season:
		"spring":
			seasonal_particles.color = Color(1.0, 0.72, 0.82, 0.85)
			seasonal_particles.gravity = Vector2(10, 12)
			seasonal_particles.scale_amount_min = 1.5
			seasonal_particles.scale_amount_max = 2.5
			seasonal_particles.amount = 16
		"summer":
			seasonal_particles.color = Color(1.0, 0.94, 0.55, 0.75)
			seasonal_particles.gravity = Vector2(4, 6)
			seasonal_particles.scale_amount_min = 1.0
			seasonal_particles.scale_amount_max = 2.0
			seasonal_particles.amount = 14
		"autumn":
			seasonal_particles.color = Color(0.92, 0.42, 0.16, 0.90)
			seasonal_particles.gravity = Vector2(16, 15)
			seasonal_particles.scale_amount_min = 1.8
			seasonal_particles.scale_amount_max = 3.0
			seasonal_particles.amount = 22
		"winter":
			seasonal_particles.color = Color(0.95, 0.98, 1.0, 0.92)
			seasonal_particles.gravity = Vector2(6, 16)
			seasonal_particles.scale_amount_min = 1.2
			seasonal_particles.scale_amount_max = 2.2
			seasonal_particles.amount = 25
			
	seasonal_particles.emitting = is_window_open

# ==============================================================================
# 🎨 DRAWING PIPELINE (240x140 CANVAS)
# ==============================================================================
func _draw() -> void:
	# 1. Background Wall & Trim
	draw_rect(Rect2(0, 0, 240, 98), COL_WALL)
	draw_rect(Rect2(0, 25, 240, 3), COL_WALL_TRIM)
	
	# Baseboard
	draw_rect(Rect2(0, 95, 240, 5), COL_BASEBOARD)
	
	# 2. Warm Burgundy Carpet
	draw_rect(Rect2(0, 100, 240, 40), COL_CARPET)
	for cx in range(10, 230, 20):
		draw_rect(Rect2(cx, 115, 10, 8), COL_CARPET_PATTERN)
		
	# 3. Fireplace on Left (x=36..74, y=48)
	_draw_fireplace(36, 48)
	
	# 4. Standing Floor Lamp (x=108, y=48 - cozy reading lamp beside sofa)
	_draw_floor_lamp(108, 48)
	
	# 5. Living Room Window above Sofa (x=120, y=14, w=34, h=40)
	_draw_window_view(120, 14, 34, 40)
	
	# 6. Plush Sofa (x=116..158, y=72)
	_draw_sofa(116, 72)
	
	# 7. Coffee Table (x=126, y=94)
	_draw_coffee_table(126, 94)
	
	# 8. 3/4 Sideways Angled Pixel TV & Stand (x=172, y=66 - facing left towards Couch!)
	_draw_angled_pixel_tv(172, 66)
	
	# 9. Wall Light Switch (x=206, y=74 - beside right door at standard wall height)
	var is_light_on: bool = GameState.is_room_light_on(room_id) if GameState else false
	draw_light_switch(206, 74, is_light_on)
	
	# 10. Placed Room Decorations
	_draw_placed_decorations()

func _draw_placed_decorations() -> void:
	if not GameState:
		return
		
	# 📻 Retro Boombox on Coffee Table (x=134, y=89)
	if GameState.is_decor_placed("decor_boombox"):
		var bx: float = 134.0
		var by: float = 89.0
		# Dark Metallic Chassis & Handle
		draw_rect(Rect2(bx - 6, by + 1, 14, 8), Color(0.20, 0.22, 0.28))
		draw_rect(Rect2(bx - 4, by - 1, 10, 2), Color(0.45, 0.48, 0.55)) # Handle
		# Left & Right Speaker Grilles
		draw_rect(Rect2(bx - 5, by + 3, 4, 4), Color(0.10, 0.12, 0.16))
		draw_rect(Rect2(bx + 3, by + 3, 4, 4), Color(0.10, 0.12, 0.16))
		# Cassette Tape Deck & VU Meter
		draw_rect(Rect2(bx, by + 4, 2, 3), Color(0.85, 0.40, 0.20))
		var vu_pulse: float = sin(_flicker_timer * 6.0)
		var led_col = Color(0.3, 0.9, 0.4) if vu_pulse > 0.0 else Color(0.9, 0.7, 0.2)
		draw_rect(Rect2(bx - 1, by + 2, 4, 1), led_col)
		
	# 🎶 Vinyl Records Stack on Floor beside Fireplace (x=80, y=94)
	if GameState.is_decor_placed("decor_record_stack"):
		var rx: float = 80.0
		var ry: float = 94.0
		# 4 Leaning Vinyl Record Sleeves
		draw_rect(Rect2(rx, ry + 2, 2, 10), Color(0.85, 0.20, 0.25)) # Red album
		draw_rect(Rect2(rx + 2, ry + 1, 2, 10), Color(0.20, 0.50, 0.85)) # Blue album
		draw_rect(Rect2(rx + 4, ry + 3, 2, 9), Color(0.95, 0.75, 0.20)) # Gold album
		draw_rect(Rect2(rx + 6, ry + 2, 2, 10), Color(0.55, 0.25, 0.75)) # Purple album
		# Vinyl disc peaking out
		draw_rect(Rect2(rx + 5, ry - 1, 3, 3), Color(0.10, 0.10, 0.12))
		draw_rect(Rect2(rx + 6, ry, 1, 1), Color(0.95, 0.75, 0.20))

func _draw_window_view(wx: float, wy: float, ww: float, wh: float) -> void:
	var hour: int = Time.get_time_dict_from_system().get("hour", 12)
	var sky_col: Color = COL_SKY_DAY
	var is_night: bool = (hour < 6 or hour >= 20)
	var is_sunset: bool = (hour >= 16 and hour < 20)
	
	if is_night:
		sky_col = COL_SKY_NIGHT
	elif is_sunset:
		sky_col = COL_SKY_SUNSET
		
	draw_rect(Rect2(wx, wy, ww, wh), sky_col)
	
	if is_night:
		draw_rect(Rect2(wx + 20, wy + 8, 4, 4), COL_MOON_WHITE)
		draw_rect(Rect2(wx + 19, wy + 8, 2, 4), sky_col)
		draw_rect(Rect2(wx + 6, wy + 12, 1, 1), COL_MOON_WHITE)
		draw_rect(Rect2(wx + 24, wy + 16, 1, 1), COL_MOON_WHITE)
	else:
		draw_circle(Vector2(wx + 22, wy + 10), 4.0, COL_SUN_GOLD)
		draw_rect(Rect2(wx + 6, wy + 20, 12, 3), Color(1.0, 1.0, 1.0, 0.7))
		
	draw_rect(Rect2(wx - 3, wy - 3, ww + 6, 4), COL_WINDOW_FRAME_DARK)
	draw_rect(Rect2(wx - 2, wy - 2, ww + 4, 3), COL_WINDOW_FRAME)
	draw_rect(Rect2(wx - 4, wy + wh - 1, ww + 8, 5), COL_WINDOW_FRAME_DARK)
	draw_rect(Rect2(wx - 3, wy + wh - 2, ww + 6, 4), COL_WINDOW_FRAME)
	draw_rect(Rect2(wx - 3, wy, 3, wh), COL_WINDOW_FRAME)
	draw_rect(Rect2(wx + ww, wy, 3, wh), COL_WINDOW_FRAME)
	
	if is_window_open:
		draw_rect(Rect2(wx - 6 + _breeze_offset, wy + 2, 5, wh - 4), COL_WINDOW_FRAME_DARK)
		draw_rect(Rect2(wx - 5 + _breeze_offset, wy + 3, 3, wh - 6), Color(0.6, 0.8, 1.0, 0.3))
		draw_rect(Rect2(wx + ww + 1 - _breeze_offset, wy + 2, 5, wh - 4), COL_WINDOW_FRAME_DARK)
		draw_rect(Rect2(wx + ww + 2 - _breeze_offset, wy + 3, 3, wh - 6), Color(0.6, 0.8, 1.0, 0.3))
		draw_line(Vector2(wx + 4, wy + wh * 0.4), Vector2(wx + 14 + _breeze_offset, wy + wh * 0.4 + 2), Color(1.0, 1.0, 1.0, 0.25), 1.0)
	else:
		draw_line(Vector2(wx + 4, wy + 8), Vector2(wx + 14, wy + 22), COL_WINDOW_GLASS_SHINE, 1.0)
		draw_line(Vector2(wx + 16, wy + 14), Vector2(wx + 26, wy + 28), COL_WINDOW_GLASS_SHINE, 1.0)
		draw_rect(Rect2(wx + ww * 0.5 - 1, wy, 2, wh), COL_WINDOW_FRAME)
		draw_rect(Rect2(wx, wy + wh * 0.5 - 1, ww, 2), COL_WINDOW_FRAME)

func _draw_fireplace(fx: float, fy: float) -> void:
	var fw: float = 38.0
	var fh: float = 50.0
	
	# Stone/Brick Chimney & Fireplace Body
	draw_rect(Rect2(fx, fy, fw, fh), COL_BRICK_MAIN)
	for by in range(int(fy) + 4, int(fy + fh), 6):
		draw_line(Vector2(fx, by), Vector2(fx + fw, by), COL_BRICK_SHADOW, 1.0)
		
	# Upper Chimney rising to ceiling
	draw_rect(Rect2(fx + 5, 0, fw - 10, int(fy)), COL_BRICK_MAIN)
	draw_rect(Rect2(fx + 4, int(fy) - 3, fw - 8, 3), COL_BRICK_SHADOW)
	
	# Wall Clock on Chimney
	draw_rect(Rect2(fx + 14, 24, 10, 10), Color(0.85, 0.72, 0.45))
	draw_rect(Rect2(fx + 15, 25, 8, 8), Color(0.95, 0.95, 0.95))
	draw_rect(Rect2(fx + 19, 28, 2, 3), Color(0.15, 0.15, 0.15))
	
	# Wooden Hearth Mantelpiece
	draw_rect(Rect2(fx - 3, fy, fw + 6, 5), COL_MANTEL)
	draw_rect(Rect2(fx - 2, fy + 1, fw + 4, 2), Color(0.55, 0.35, 0.22))
	
	# Firebox Pit
	draw_rect(Rect2(fx + 5, fy + 12, fw - 10, fh - 14), COL_FIRE_PIT)
	draw_rect(Rect2(fx + 4, fy + 11, fw - 8, fh - 12), Color(0.2, 0.12, 0.08), false, 2.0)
	
	if is_fireplace_lit:
		# Ambient Radial Firelight Glow
		draw_circle(Vector2(fx + fw * 0.5, fy + fh * 0.65), 30.0, COL_FIRE_GLOW)
		
		# Animated Dancing Fire Shapes
		var ox = (sin(_fire_frame * 1.5) * 1.5)
		# Red Backing Flame
		draw_polygon([
			Vector2(fx + 10, fy + fh - 4),
			Vector2(fx + 19 + ox, fy + 24),
			Vector2(fx + 28, fy + fh - 4)
		], [COL_FIRE_RED])
		
		# Orange Mid Flame
		draw_polygon([
			Vector2(fx + 12, fy + fh - 4),
			Vector2(fx + 19 - ox, fy + 27),
			Vector2(fx + 26, fy + fh - 4)
		], [COL_FIRE_ORANGE])
		
		# Yellow Inner Core Flame
		draw_polygon([
			Vector2(fx + 14, fy + fh - 4),
			Vector2(fx + 19 + ox * 0.5, fy + 32),
			Vector2(fx + 24, fy + fh - 4)
		], [COL_FIRE_YELLOW])
	else:
		# Dormant ash bed and extinguished firewood logs
		draw_rect(Rect2(fx + 10, fy + fh - 8, 18, 4), COL_ASH_LOG)
		draw_rect(Rect2(fx + 13, fy + fh - 11, 12, 3), COL_ASH_LOG.darkened(0.2))
		draw_rect(Rect2(fx + 8, fy + fh - 4, 22, 2), Color(0.3, 0.3, 0.32, 0.8))

## Draws the 3/4 sideways angled TV facing LEFT towards the couch
func _draw_angled_pixel_tv(tx: float, ty: float) -> void:
	# 1. Angled Wooden Media Stand (x=173..197, y=86..100)
	# Angled Top Surface
	var stand_top: PackedVector2Array = [
		Vector2(tx - 2, ty + 20),
		Vector2(tx + 20, ty + 18),
		Vector2(tx + 24, ty + 20),
		Vector2(tx + 2, ty + 22)
	]
	draw_colored_polygon(stand_top, Color(0.52, 0.36, 0.24))
	
	# Stand Front Face (angled leftwards)
	var stand_front: PackedVector2Array = [
		Vector2(tx - 2, ty + 20),
		Vector2(tx + 2, ty + 22),
		Vector2(tx + 2, ty + 33),
		Vector2(tx - 2, ty + 31)
	]
	draw_colored_polygon(stand_front, COL_TV_STAND)
	
	# Stand Side Face (facing viewer)
	var stand_side: PackedVector2Array = [
		Vector2(tx + 2, ty + 22),
		Vector2(tx + 24, ty + 20),
		Vector2(tx + 24, ty + 31),
		Vector2(tx + 2, ty + 33)
	]
	draw_colored_polygon(stand_side, COL_TV_STAND_SHADOW)
	
	# Console Shelf Slot & Media Devices
	draw_rect(Rect2(tx + 5, ty + 24, 14, 5), Color(0.18, 0.12, 0.08))
	draw_rect(Rect2(tx + 7, ty + 26, 10, 2), Color(0.4, 0.45, 0.52)) # Game console
	
	# Stand Legs
	draw_rect(Rect2(tx - 1, ty + 31, 2, 4), COL_TV_STAND)
	draw_rect(Rect2(tx + 21, ty + 31, 2, 4), COL_TV_STAND_SHADOW)
	
	# 2. TV Antenna (angled backwards)
	draw_line(Vector2(tx + 12, ty + 2), Vector2(tx + 4, ty - 6), Color(0.65, 0.65, 0.70), 1.0)
	draw_line(Vector2(tx + 12, ty + 2), Vector2(tx + 18, ty - 5), Color(0.50, 0.50, 0.55), 1.0)
	
	# 3. TV Chassis Depth (Right side & back casing)
	var casing_depth: PackedVector2Array = [
		Vector2(tx + 16, ty + 3),   # Top-front right
		Vector2(tx + 22, ty + 1),   # Top-back right
		Vector2(tx + 22, ty + 16),  # Bottom-back right
		Vector2(tx + 16, ty + 19)   # Bottom-front right
	]
	draw_colored_polygon(casing_depth, COL_TV_CASING_DEPTH)
	draw_line(Vector2(tx + 16, ty + 3), Vector2(tx + 22, ty + 1), Color(0.35, 0.32, 0.38), 1.0)
	
	# Top Chassis Slope
	var casing_top: PackedVector2Array = [
		Vector2(tx + 2, ty + 1),
		Vector2(tx + 8, ty - 1),
		Vector2(tx + 22, ty + 1),
		Vector2(tx + 16, ty + 3)
	]
	draw_colored_polygon(casing_top, Color(0.28, 0.25, 0.30))
	
	# 4. Front Bezel Frame (facing left towards couch)
	var bezel_front: PackedVector2Array = [
		Vector2(tx + 2, ty + 1),
		Vector2(tx + 16, ty + 3),
		Vector2(tx + 16, ty + 19),
		Vector2(tx + 2, ty + 20)
	]
	draw_colored_polygon(bezel_front, COL_TV_CASING)
	
	# 5. Screen Glass Polygon (Angled 3/4 perspective face)
	var screen_poly: PackedVector2Array = [
		Vector2(tx + 4, ty + 3),
		Vector2(tx + 14, ty + 5),
		Vector2(tx + 14, ty + 17),
		Vector2(tx + 4, ty + 18)
	]
	
	if is_tv_on:
		# TV ON: Leftward Screen Projection Cone across floor & couch
		var cone_pts: PackedVector2Array = [
			Vector2(tx + 3, ty + 5),     # Top-left of screen
			Vector2(tx + 3, ty + 17),    # Bottom-left of screen
			Vector2(tx - 65, ty + 38),   # Floor wash under coffee table
			Vector2(tx - 65, ty - 4)     # Upper wash over sofa
		]
		draw_colored_polygon(cone_pts, Color(0.35, 0.65, 0.95, 0.14))
		
		# Inner concentrated light beam
		draw_colored_polygon([
			Vector2(tx + 3, ty + 8),
			Vector2(tx + 3, ty + 14),
			Vector2(tx - 40, ty + 25),
			Vector2(tx - 40, ty + 2)
		], Color(0.50, 0.80, 1.0, 0.18))
		
		# Glowing Screen Face
		draw_colored_polygon(screen_poly, COL_TV_SCREEN_ON)
		
		# Animated 8-bit hero on perspective screen
		var step_x = int(_tv_frame * 1.5) % 8
		# Green hill line
		draw_line(Vector2(tx + 4, ty + 15), Vector2(tx + 14, ty + 15), Color(0.25, 0.70, 0.35), 2.0)
		# Running sprite
		draw_rect(Rect2(tx + 4 + step_x, ty + 11, 2, 3), Color(0.95, 0.85, 0.40))
		draw_rect(Rect2(tx + 4 + step_x, ty + 9, 2, 2), Color(0.95, 0.45, 0.40))
		# Star / moon
		draw_rect(Rect2(tx + 11, ty + 6, 2, 2), Color(0.9, 0.95, 1.0))
		
		# CRT Scanlines along angle
		draw_line(Vector2(tx + 4, ty + 7), Vector2(tx + 14, ty + 8), Color(0.0, 0.0, 0.0, 0.2), 1.0)
		draw_line(Vector2(tx + 4, ty + 11), Vector2(tx + 14, ty + 12), Color(0.0, 0.0, 0.0, 0.2), 1.0)
		
		# Green Power LED on side bezel
		draw_rect(Rect2(tx + 14, ty + 17, 1, 1), Color(0.2, 0.9, 0.3))
	else:
		# TV OFF: Dark glass with reflection
		draw_colored_polygon(screen_poly, COL_TV_SCREEN_OFF)
		draw_line(Vector2(tx + 5, ty + 5), Vector2(tx + 9, ty + 9), Color(1.0, 1.0, 1.0, 0.18), 1.0)
		# Red Standby LED on side bezel
		draw_rect(Rect2(tx + 14, ty + 17, 1, 1), Color(0.9, 0.2, 0.2))

func _draw_sofa(sx: float, sy: float) -> void:
	var sw: float = 42.0
	var sh: float = 26.0
	
	# Sofa Backrest
	draw_rect(Rect2(sx, sy, sw, sh - 8), COL_SOFA_MAIN)
	draw_rect(Rect2(sx, sy, sw, 3), COL_SOFA_SHADOW)
	
	# Armrests
	draw_rect(Rect2(sx - 2, sy + 6, 5, 22), COL_SOFA_MAIN)
	draw_rect(Rect2(sx - 2, sy + 6, 5, 2), COL_SOFA_SHADOW)
	draw_rect(Rect2(sx + sw - 3, sy + 6, 5, 22), COL_SOFA_MAIN)
	draw_rect(Rect2(sx + sw - 3, sy + 6, 5, 2), COL_SOFA_SHADOW)
	
	# Seat Cushions (3 cushions)
	for i in range(3):
		var cx = sx + 3 + i * 12
		draw_rect(Rect2(cx, sy + 13, 12, 13), COL_SOFA_CUSHION)
		draw_rect(Rect2(cx, sy + 13, 12, 2), COL_SOFA_SHADOW)
		
	# Throw Pillows
	draw_rect(Rect2(sx + 4, sy + 9, 7, 7), COL_PILLOW_GOLD)
	draw_rect(Rect2(sx + sw - 11, sy + 9, 7, 7), Color(0.9, 0.45, 0.45))
	
	# Wooden Sofa Feet
	draw_rect(Rect2(sx, sy + sh - 2, 4, 4), COL_TABLE_WOOD)
	draw_rect(Rect2(sx + sw - 4, sy + sh - 2, 4, 4), COL_TABLE_WOOD)

func _draw_coffee_table(tx: float, ty: float) -> void:
	draw_rect(Rect2(tx, ty + 6, 22, 4), COL_TABLE_WOOD)
	draw_rect(Rect2(tx, ty + 9, 22, 2), COL_MANTEL)
	draw_rect(Rect2(tx + 2, ty + 10, 3, 10), COL_TABLE_WOOD)
	draw_rect(Rect2(tx + 17, ty + 10, 3, 10), COL_TABLE_WOOD)
	
	# Steaming Mug
	draw_rect(Rect2(tx + 8, ty + 1, 5, 5), Color(0.95, 0.95, 0.95))
	draw_rect(Rect2(tx + 9, ty + 1, 3, 1), Color(0.35, 0.22, 0.15))
	draw_rect(Rect2(tx + 13, ty + 2, 2, 3), Color(0.95, 0.95, 0.95))

func _draw_floor_lamp(lx: float, ly: float) -> void:
	# Brass Base & Pole
	draw_rect(Rect2(lx - 4, ly + 52, 8, 3), COL_LAMP_BRASS)
	draw_rect(Rect2(lx - 1, ly + 10, 2, 44), COL_LAMP_BRASS)
	
	# Lamp Shade
	var shade_col = COL_LAMP_SHADE if is_floor_lamp_on else COL_LAMP_SHADE_OFF
	draw_rect(Rect2(lx - 6, ly, 12, 10), shade_col)
	draw_rect(Rect2(lx - 5, ly, 10, 2), COL_LAMP_BRASS)
	
	# Ambient Warm Halo
	if is_floor_lamp_on:
		draw_circle(Vector2(lx, ly + 5), 22.0, COL_LAMP_GLOW)
