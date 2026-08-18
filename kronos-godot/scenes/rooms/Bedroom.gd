@tool
extends BaseRoom
class_name Bedroom

## Cozy Bedroom environment for Kronos.
## Features work desk with glowing laptop, cozy bed, and dynamic Day/Night window.

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

# Furniture
const COL_DESK_WOOD: Color = Color(0.52, 0.35, 0.22, 1.0)
const COL_DESK_SHADOW: Color = Color(0.38, 0.24, 0.15, 1.0)
const COL_BED_FRAME: Color = Color(0.45, 0.30, 0.20, 1.0)
const COL_BED_SHEET: Color = Color(0.85, 0.88, 0.94, 1.0)
const COL_BED_DUVET: Color = Color(0.32, 0.52, 0.65, 1.0)
const COL_BED_PILLOW: Color = Color(0.95, 0.96, 0.98, 1.0)
const COL_LAMP_SHADE: Color = Color(0.98, 0.85, 0.50, 1.0)
const COL_LAMP_GLOW: Color = Color(1.0, 0.92, 0.60, 0.25)
const COL_LAPTOP_GLOW: Color = Color(0.35, 0.75, 1.0, 0.35)

var _flicker_timer: float = 0.0
var _laptop_glow_alpha: float = 0.35

func _ready() -> void:
	super._ready()
	room_id = "room_bedroom"
	room_name = "Cozy Bedroom"
	desk_x = 72.0
	nap_x = 168.0
	drink_x = 115.0

func _process(delta: float) -> void:
	super._process(delta)
	_flicker_timer += delta * 3.0
	_laptop_glow_alpha = 0.28 + sin(_flicker_timer) * 0.08
	queue_redraw()

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
		
	# 2. Window with Dynamic Sky (x=105, y=18, w=34, h=48)
	_draw_window_view(105, 18, 34, 48)
	
	# 3. Work Desk (x=50 to 94, y=70 to 115)
	_draw_work_desk(52, 76)
	
	# 4. Cozy Bed & Nightstand (x=144 to 200, y=75 to 115)
	_draw_cozy_bed(146, 78)

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
		
	# Window Frame (Outer & Panes)
	draw_rect(Rect2(wx - 2, wy - 2, ww + 4, 3), COL_WINDOW_FRAME) # Top frame
	draw_rect(Rect2(wx - 2, wy + wh - 1, ww + 4, 4), COL_WINDOW_FRAME) # Sill
	draw_rect(Rect2(wx - 2, wy, 2, wh), COL_WINDOW_FRAME) # Left
	draw_rect(Rect2(wx + ww, wy, 2, wh), COL_WINDOW_FRAME) # Right
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
		
	# Mini Desk Plant / Mug
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
	
	# Bed Frame (Headboard)
	draw_rect(Rect2(bx + 40, by + 4, 5, 25), COL_BED_FRAME)
	draw_rect(Rect2(bx, by + 22, 45, 7), COL_BED_FRAME)
	
	# Mattress & Sheet
	draw_rect(Rect2(bx + 2, by + 14, 40, 10), COL_BED_SHEET)
	
	# Fluffy Duvet / Quilt
	draw_rect(Rect2(bx + 2, by + 16, 28, 10), COL_BED_DUVET)
	draw_rect(Rect2(bx + 2, by + 15, 28, 2), Color(0.4, 0.62, 0.75)) # Fold
	
	# Soft Pillow
	draw_rect(Rect2(bx + 30, by + 11, 9, 6), COL_BED_PILLOW)
