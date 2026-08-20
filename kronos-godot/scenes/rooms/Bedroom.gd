@tool
extends BaseRoom
class_name Bedroom

## Cozy Bedroom environment for Kronos.
## Features interactive work desk with glowing laptop, foldable daybed, 
## wall light switch, and opening bay window with real-world seasonal weather particles.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_WALL: Color = Color(0.18, 0.20, 0.28, 1.0)
const COL_WALL_STRIPE: Color = Color(0.15, 0.17, 0.24, 1.0)
const COL_FLOOR_WOOD: Color = Color(0.42, 0.28, 0.18, 1.0)
const COL_FLOOR_PLANK: Color = Color(0.35, 0.22, 0.14, 1.0)
const COL_BASEBOARD: Color = Color(0.28, 0.18, 0.12, 1.0)

# Window Sky Palettes
const COL_SKY_DAY: Color = Color(0.45, 0.72, 0.95, 1.0)
const COL_SKY_SUNSET: Color = Color(0.92, 0.55, 0.42, 1.0)
const COL_SKY_NIGHT: Color = Color(0.08, 0.09, 0.18, 1.0)
const COL_SUN_GOLD: Color = Color(1.0, 0.92, 0.50, 1.0)
const COL_MOON_WHITE: Color = Color(0.95, 0.96, 1.0, 1.0)
const COL_WINDOW_FRAME: Color = Color(0.55, 0.40, 0.28, 1.0)
const COL_WINDOW_FRAME_DARK: Color = Color(0.38, 0.26, 0.18, 1.0)
const COL_WINDOW_GLASS_SHINE: Color = Color(1.0, 1.0, 1.0, 0.22)

# Furniture & Bed
const COL_DESK_WOOD: Color = Color(0.52, 0.35, 0.22, 1.0)
const COL_DESK_SHADOW: Color = Color(0.38, 0.24, 0.15, 1.0)
const COL_BED_FRAME: Color = Color(0.45, 0.30, 0.20, 1.0)
const COL_BED_SHEET: Color = Color(0.88, 0.90, 0.95, 1.0)
const COL_BED_SHEET_SHADOW: Color = Color(0.72, 0.76, 0.84, 1.0)
const COL_BED_DUVET: Color = Color(0.32, 0.52, 0.65, 1.0)
const COL_BED_DUVET_FOLD: Color = Color(0.42, 0.65, 0.78, 1.0)
const COL_BED_DUVET_INNER: Color = Color(0.24, 0.40, 0.52, 1.0)
const COL_BED_PILLOW: Color = Color(0.95, 0.96, 0.98, 1.0)
const COL_LAMP_SHADE: Color = Color(0.98, 0.85, 0.50, 1.0)
const COL_LAMP_GLOW: Color = Color(1.0, 0.92, 0.60, 0.25)
const COL_LAPTOP_GLOW: Color = Color(0.35, 0.75, 1.0, 0.35)

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var seasonal_particles: CPUParticles2D = $SeasonalWeatherParticles

# ==============================================================================
# 📊 INTERACTION STATE
# ==============================================================================
var is_bed_open: bool = false
var is_window_open: bool = false
var _flicker_timer: float = 0.0
var _laptop_glow_alpha: float = 0.35
var _breeze_offset: float = 0.0

# Bounding boxes for click areas
const RECT_BED: Rect2 = Rect2(144, 76, 56, 40)
const RECT_WINDOW: Rect2 = Rect2(103, 16, 38, 52)
const RECT_LIGHT_SWITCH: Rect2 = Rect2(200, 70, 16, 22)
const RECT_LAPTOP: Rect2 = Rect2(52, 72, 40, 30)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_bedroom"
	room_name = "Study Bedroom"
	desk_x = 72.0
	nap_x = 168.0
	drink_x = 115.0
	
	# Load saved object states if available
	if GameState:
		is_bed_open = GameState.get_object_state("bedroom_bed_open", false)
		is_window_open = GameState.get_object_state("bedroom_window_open", false)
		
	_update_seasonal_weather()
	EventBus.object_state_changed.connect(_on_object_state_changed)

func _process(delta: float) -> void:
	_flicker_timer += delta * 3.0
	_laptop_glow_alpha = 0.28 + sin(_flicker_timer) * 0.08
	
	if is_window_open:
		_breeze_offset = sin(_flicker_timer * 1.5) * 1.5
	else:
		_breeze_offset = 0.0
		
	queue_redraw()

func _on_object_state_changed(key: String, val: Variant) -> void:
	if key == "bedroom_bed_open":
		is_bed_open = val
		queue_redraw()
	elif key == "bedroom_window_open":
		is_window_open = val
		_update_seasonal_weather()
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
			
		# 2. Click Bay Window
		if RECT_WINDOW.has_point(pos):
			is_window_open = not is_window_open
			if GameState:
				GameState.set_object_state("bedroom_window_open", is_window_open)
			_update_seasonal_weather()
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 3. Click Bed (Right Side)
		if RECT_BED.has_point(pos):
			is_bed_open = not is_bed_open
			if GameState:
				GameState.set_object_state("bedroom_bed_open", is_bed_open)
				GameState.set_object_state("bedroom_blanket_folded", is_bed_open)
			EventBus.object_state_changed.emit("bedroom_bed_open", is_bed_open)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 4. Click Computer Desk / Laptop (Left Side)
		if RECT_LAPTOP.has_point(pos):
			EventBus.object_state_changed.emit("bedroom_desk", true)
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
			# Pink sakura / blossom petals
			seasonal_particles.color = Color(1.0, 0.72, 0.82, 0.85)
			seasonal_particles.gravity = Vector2(10, 12)
			seasonal_particles.scale_amount_min = 1.5
			seasonal_particles.scale_amount_max = 2.5
			seasonal_particles.amount = 16
		"summer":
			# Warm golden dust motes & sunbeams
			seasonal_particles.color = Color(1.0, 0.94, 0.55, 0.75)
			seasonal_particles.gravity = Vector2(4, 6)
			seasonal_particles.scale_amount_min = 1.0
			seasonal_particles.scale_amount_max = 2.0
			seasonal_particles.amount = 14
		"autumn":
			# Amber, crimson, and golden maple leaves
			seasonal_particles.color = Color(0.92, 0.42, 0.16, 0.90)
			seasonal_particles.gravity = Vector2(16, 15)
			seasonal_particles.scale_amount_min = 1.8
			seasonal_particles.scale_amount_max = 3.0
			seasonal_particles.amount = 22
		"winter":
			# Crisp white snowflakes
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
	# 1. Background Wallpaper & Floor (240x140)
	draw_rect(Rect2(0, 0, 240, 100), COL_WALL)
	# Vertical wallpaper stripes
	for sx in range(0, 240, 16):
		draw_rect(Rect2(sx, 0, 8, 100), COL_WALL_STRIPE)
		
	# Baseboard
	draw_rect(Rect2(0, 96, 240, 6), COL_BASEBOARD)
	
	# Floor Planks
	draw_rect(Rect2(0, 102, 240, 38), COL_FLOOR_WOOD)
	for fy in range(102, 140, 8):
		draw_line(Vector2(0, fy), Vector2(240, fy), COL_FLOOR_PLANK, 1.0)
	for fx in range(0, 240, 32):
		draw_line(Vector2(fx, 102), Vector2(fx, 110), COL_FLOOR_PLANK, 1.0)
		draw_line(Vector2(fx + 16, 110), Vector2(fx + 16, 118), COL_FLOOR_PLANK, 1.0)
		draw_line(Vector2(fx, 118), Vector2(fx, 126), COL_FLOOR_PLANK, 1.0)
		draw_line(Vector2(fx + 16, 126), Vector2(fx + 16, 140), COL_FLOOR_PLANK, 1.0)
		
	# 2. Window with Dynamic Sky & Open/Closed States (x=105, y=18, w=34, h=48)
	_draw_window_view(105, 18, 34, 48)
	
	# 3. Work Desk (x=50 to 94, y=70 to 115)
	_draw_work_desk(52, 76)
	
	# 4. Cozy Bed with Foldable Blanket (x=144 to 200, y=75 to 115)
	_draw_cozy_bed(146, 78)
	
	# 5. Wall Light Switch (x=204, y=74 - beside the right door)
	var is_light_on: bool = GameState.is_room_light_on(room_id) if GameState else false
	draw_light_switch(204, 74, is_light_on)
	
	# 6. Placed Room Decorations
	_draw_placed_decorations()

func _draw_placed_decorations() -> void:
	if not GameState:
		return
		
	# 🪴 Mini Pine Bonsai on Desk Right Edge (x=84, y=83)
	if GameState.is_decor_placed("decor_bonsai"):
		var bx: float = 84.0
		var by: float = 83.0
		# Ceramic Bonsai Pot
		draw_rect(Rect2(bx - 4, by + 5, 8, 4), Color(0.35, 0.22, 0.15))
		draw_rect(Rect2(bx - 3, by + 4, 6, 1), Color(0.25, 0.15, 0.10)) # Soil
		# Gnarled Trunk
		draw_rect(Rect2(bx - 1, by + 1, 2, 4), Color(0.45, 0.30, 0.18))
		draw_rect(Rect2(bx + 1, by - 1, 2, 3), Color(0.45, 0.30, 0.18))
		# Lush Pine Needles (Puffed green clusters)
		draw_rect(Rect2(bx - 4, by - 3, 5, 4), Color(0.18, 0.55, 0.28))
		draw_rect(Rect2(bx - 1, by - 5, 6, 4), Color(0.24, 0.68, 0.35))
		draw_rect(Rect2(bx + 1, by - 2, 4, 3), Color(0.18, 0.55, 0.28))
		
	# 🏮 Retro Lava Lamp on Nightstand (x=136, y=82)
	if GameState.is_decor_placed("decor_lava_lamp"):
		var lx: float = 136.0
		var ly: float = 82.0
		# Silver Metallic Base & Cap
		draw_rect(Rect2(lx - 2, ly + 8, 5, 3), Color(0.70, 0.72, 0.78))
		draw_rect(Rect2(lx - 1, ly - 2, 3, 2), Color(0.70, 0.72, 0.78))
		# Glass Chamber
		draw_rect(Rect2(lx - 2, ly, 5, 8), Color(0.95, 0.35, 0.45, 0.85)) # Deep magenta liquid
		# Floating Warm Wax Blobs (sinusoidal pulse)
		var blob_y1: float = ly + 1.5 + sin(_flicker_timer * 2.5) * 1.5
		var blob_y2: float = ly + 5.0 - sin(_flicker_timer * 2.0) * 1.5
		draw_rect(Rect2(lx - 1, blob_y1, 3, 2), Color(1.0, 0.85, 0.20)) # Golden wax
		draw_rect(Rect2(lx, blob_y2, 2, 2), Color(1.0, 0.65, 0.15))
		# Subtle Ambient Glow
		draw_circle(Vector2(lx + 0.5, ly + 4), 10.0, Color(1.0, 0.45, 0.35, 0.22))

func _draw_window_view(wx: float, wy: float, ww: float, wh: float) -> void:
	var hour: int = Time.get_time_dict_from_system().get("hour", 12)
	var sky_col: Color = COL_SKY_DAY
	var is_night: bool = (hour < 6 or hour >= 20)
	var is_sunset: bool = (hour >= 16 and hour < 20)
	
	if is_night:
		sky_col = COL_SKY_NIGHT
	elif is_sunset:
		sky_col = COL_SKY_SUNSET
		
	# Sky Background
	draw_rect(Rect2(wx, wy, ww, wh), sky_col)
	
	# Celestial Body
	if is_night:
		# Crescent Moon & Stars
		draw_rect(Rect2(wx + 20, wy + 8, 5, 5), COL_MOON_WHITE)
		draw_rect(Rect2(wx + 19, wy + 8, 3, 5), sky_col)
		# Twinkling Stars
		draw_rect(Rect2(wx + 6, wy + 12, 1, 1), COL_MOON_WHITE)
		draw_rect(Rect2(wx + 14, wy + 22, 1, 1), COL_MOON_WHITE)
		draw_rect(Rect2(wx + 26, wy + 16, 1, 1), COL_MOON_WHITE)
	else:
		# Sun & Soft Cloud
		var sun_col = COL_SUN_GOLD
		draw_circle(Vector2(wx + 22, wy + 12), 4.0, sun_col)
		# Fluffy Cloud
		draw_rect(Rect2(wx + 6, wy + 24, 14, 4), Color(1.0, 1.0, 1.0, 0.7))
		draw_rect(Rect2(wx + 9, wy + 21, 8, 3), Color(1.0, 1.0, 1.0, 0.7))
		
	# Outer Window Casing & Sill
	draw_rect(Rect2(wx - 3, wy - 3, ww + 6, 4), COL_WINDOW_FRAME_DARK) # Header
	draw_rect(Rect2(wx - 2, wy - 2, ww + 4, 3), COL_WINDOW_FRAME)
	draw_rect(Rect2(wx - 4, wy + wh - 1, ww + 8, 5), COL_WINDOW_FRAME_DARK) # Sill shadow
	draw_rect(Rect2(wx - 3, wy + wh - 2, ww + 6, 4), COL_WINDOW_FRAME)      # Sill
	draw_rect(Rect2(wx - 3, wy, 3, wh), COL_WINDOW_FRAME)                    # Left jamb
	draw_rect(Rect2(wx + ww, wy, 3, wh), COL_WINDOW_FRAME)                   # Right jamb
	
	if is_window_open:
		# OPEN WINDOW: Sashes are swung open outwards
		# Left open sash panel
		draw_rect(Rect2(wx - 7 + _breeze_offset, wy + 2, 6, wh - 4), COL_WINDOW_FRAME_DARK)
		draw_rect(Rect2(wx - 6 + _breeze_offset, wy + 3, 4, wh - 6), Color(0.6, 0.8, 1.0, 0.3))
		# Right open sash panel
		draw_rect(Rect2(wx + ww + 1 - _breeze_offset, wy + 2, 6, wh - 4), COL_WINDOW_FRAME_DARK)
		draw_rect(Rect2(wx + ww + 2 - _breeze_offset, wy + 3, 4, wh - 6), Color(0.6, 0.8, 1.0, 0.3))
		
		# Breeze indicator / Open highlight
		draw_line(Vector2(wx + 4, wy + wh * 0.4), Vector2(wx + 14 + _breeze_offset, wy + wh * 0.4 + 2), Color(1.0, 1.0, 1.0, 0.25), 1.0)
		draw_line(Vector2(wx + 16, wy + wh * 0.6), Vector2(wx + 26 + _breeze_offset, wy + wh * 0.6 - 2), Color(1.0, 1.0, 1.0, 0.25), 1.0)
	else:
		# CLOSED WINDOW: Sashes locked with center crossbars and glass shine
		draw_line(Vector2(wx + 4, wy + 8), Vector2(wx + 14, wy + 26), COL_WINDOW_GLASS_SHINE, 1.0)
		draw_line(Vector2(wx + 18, wy + 16), Vector2(wx + 28, wy + 34), COL_WINDOW_GLASS_SHINE, 1.0)
		# Crossbars
		draw_rect(Rect2(wx + ww * 0.5 - 1, wy, 2, wh), COL_WINDOW_FRAME)
		draw_rect(Rect2(wx, wy + wh * 0.5 - 1, ww, 2), COL_WINDOW_FRAME)

func _draw_work_desk(dx: float, dy: float) -> void:
	# Wooden Desk Surface
	draw_rect(Rect2(dx, dy + 16, 40, 4), COL_DESK_WOOD)
	draw_rect(Rect2(dx, dy + 19, 40, 2), COL_DESK_SHADOW)
	
	# Desk Legs
	draw_rect(Rect2(dx + 2, dy + 20, 3, 19), COL_DESK_WOOD)
	draw_rect(Rect2(dx + 35, dy + 20, 3, 19), COL_DESK_WOOD)
	
	# Laptop on Desk
	draw_rect(Rect2(dx + 14, dy + 13, 14, 3), Color(0.5, 0.52, 0.58)) # Base
	draw_rect(Rect2(dx + 16, dy + 3, 12, 10), Color(0.18, 0.22, 0.30)) # Screen back
	draw_rect(Rect2(dx + 17, dy + 4, 10, 8), Color(0.35, 0.65, 0.95)) # Glowing screen
	draw_rect(Rect2(dx + 19, dy + 6, 6, 2), Color(0.8, 0.95, 1.0))   # Code line
	draw_rect(Rect2(dx + 18, dy + 9, 8, 1), Color(0.8, 0.95, 1.0))   # Code line
	
	# Laptop Glow Cone on Desk
	var is_working: bool = (TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.RUNNING and TimerEngine.current_phase == TimerEngine.TimerPhase.WORK)
	if is_working:
		var glow_col = Color(COL_LAPTOP_GLOW.r, COL_LAPTOP_GLOW.g, COL_LAPTOP_GLOW.b, _laptop_glow_alpha)
		draw_circle(Vector2(dx + 22, dy + 10), 16.0, glow_col)
		
	# Mini Desk Plant / Succulent
	draw_rect(Rect2(dx + 4, dy + 11, 5, 5), Color(0.8, 0.4, 0.3)) # Terracotta pot
	draw_rect(Rect2(dx + 5, dy + 8, 3, 3), Color(0.3, 0.7, 0.3))  # Green succulent
	
	# Desk Chair
	draw_rect(Rect2(dx + 16, dy + 22, 10, 3), Color(0.3, 0.35, 0.45))
	draw_rect(Rect2(dx + 19, dy + 25, 4, 14), Color(0.2, 0.2, 0.25))

func _draw_cozy_bed(bx: float, by: float) -> void:
	# Nightstand with Lamp (Left of bed)
	draw_rect(Rect2(bx - 12, by + 14, 10, 15), COL_DESK_WOOD)
	draw_rect(Rect2(bx - 11, by + 18, 8, 1), COL_DESK_SHADOW) # Drawer
	# Small Lamp
	draw_rect(Rect2(bx - 8, by + 10, 2, 4), Color(0.7, 0.6, 0.4))
	draw_rect(Rect2(bx - 10, by + 5, 6, 5), COL_LAMP_SHADE)
	draw_circle(Vector2(bx - 7, by + 7), 8.0, COL_LAMP_GLOW)
	
	# Bed Frame (Headboard on right & Base rail)
	draw_rect(Rect2(bx + 40, by + 4, 5, 25), COL_BED_FRAME) # Headboard
	draw_rect(Rect2(bx, by + 22, 45, 7), COL_BED_FRAME)     # Base rail
	
	# Mattress & Crisp Sheet
	draw_rect(Rect2(bx + 2, by + 14, 40, 10), COL_BED_SHEET)
	draw_rect(Rect2(bx + 2, by + 22, 40, 2), COL_BED_SHEET_SHADOW)
	
	# Soft Fluffy Pillow (on the right side next to headboard)
	draw_rect(Rect2(bx + 30, by + 11, 9, 6), COL_BED_PILLOW)
	draw_rect(Rect2(bx + 31, by + 15, 8, 2), Color(0.85, 0.88, 0.92)) # Pillow crease
	
	# Duvet / Quilt (Foldable State)
	if is_bed_open:
		# PARTIALLY OPEN: Folded back from the RIGHT (pillow/headboard side)
		# Main body covers feet & lower bed (left side bx+2 to bx+18)
		draw_rect(Rect2(bx + 2, by + 16, 18, 10), COL_BED_DUVET)
		draw_rect(Rect2(bx + 2, by + 15, 18, 2), COL_BED_DUVET_FOLD)
		
		# Lower edge of right duvet
		draw_rect(Rect2(bx + 20, by + 20, 10, 6), COL_BED_DUVET)
		
		# Exposed crisp sheet on top-right (under the pillow fold)
		draw_rect(Rect2(bx + 18, by + 14, 12, 6), COL_BED_SHEET)
		draw_rect(Rect2(bx + 18, by + 18, 12, 2), COL_BED_SHEET_SHADOW)
		
		# Diagonal folded corner polygon folding back from top-right towards bottom-left
		var fold_pts: PackedVector2Array = [
			Vector2(bx + 28, by + 15), # top-right near pillow
			Vector2(bx + 18, by + 15), # fold apex on top hem
			Vector2(bx + 28, by + 22)  # fold corner on right edge
		]
		draw_colored_polygon(fold_pts, COL_BED_DUVET_FOLD)
		# Inner fold crease line
		draw_line(Vector2(bx + 18, by + 15), Vector2(bx + 28, by + 22), COL_BED_DUVET_INNER, 1.0)
	else:
		# CLOSED: Neatly pulled up duvet
		draw_rect(Rect2(bx + 2, by + 16, 28, 10), COL_BED_DUVET)
		draw_rect(Rect2(bx + 2, by + 15, 28, 2), COL_BED_DUVET_FOLD) # Top fold hem
		# Quilt pattern pixel dots
		draw_rect(Rect2(bx + 8, by + 19, 2, 2), COL_BED_DUVET_FOLD)
		draw_rect(Rect2(bx + 18, by + 19, 2, 2), COL_BED_DUVET_FOLD)
		draw_rect(Rect2(bx + 13, by + 23, 2, 2), COL_BED_DUVET_FOLD)
