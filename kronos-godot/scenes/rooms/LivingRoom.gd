@tool
extends BaseRoom
class_name LivingRoom

## Warm Living Room environment for Kronos.
## Features stone fireplace with animated fire and embers, rustic attic ladder,
## plush sofa, coffee table, and warm floor lamp.

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

# Sofa & Furniture
const COL_SOFA_MAIN: Color = Color(0.28, 0.45, 0.48, 1.0) # Teal Plush Sofa
const COL_SOFA_SHADOW: Color = Color(0.18, 0.32, 0.35, 1.0)
const COL_SOFA_CUSHION: Color = Color(0.34, 0.54, 0.58, 1.0)
const COL_PILLOW_GOLD: Color = Color(0.92, 0.74, 0.28, 1.0)

# Floor Lamp
const COL_LAMP_BRASS: Color = Color(0.85, 0.72, 0.32, 1.0)
const COL_LAMP_SHADE: Color = Color(0.98, 0.92, 0.75, 1.0)
const COL_LAMP_GLOW: Color = Color(1.0, 0.94, 0.65, 0.30)

# Coffee Table
const COL_TABLE_WOOD: Color = Color(0.45, 0.30, 0.20, 1.0)

var _fire_anim_timer: float = 0.0
var _fire_frame: int = 0

func _ready() -> void:
	super._ready()
	room_id = "room_livingroom"
	room_name = "Living Room Lounge"
	desk_x = 100.0
	nap_x = 150.0
	drink_x = 145.0

func _process(delta: float) -> void:
	super._process(delta)
	_fire_anim_timer += delta * 8.0
	_fire_frame = int(_fire_anim_timer) % 4
	queue_redraw()

func _draw() -> void:
	# 1. Background Wall & Trim (240x140)
	draw_rect(Rect2(0, 0, 240, 98), COL_WALL)
	draw_rect(Rect2(0, 25, 240, 3), COL_WALL_TRIM) # Chair rail molding
	
	# Framed Picture on Wall centered above sofa (x=145, y=14)
	draw_rect(Rect2(145, 14, 26, 18), COL_MANTEL)
	draw_rect(Rect2(147, 16, 22, 14), Color(0.35, 0.55, 0.65)) # Mountain art
	draw_rect(Rect2(152, 20, 12, 10), Color(0.25, 0.45, 0.35))
	
	# Baseboard
	draw_rect(Rect2(0, 95, 240, 5), COL_BASEBOARD)
	
	# 2. Warm Burgundy Carpet
	draw_rect(Rect2(0, 100, 240, 40), COL_CARPET)
	# Carpet Border / Diamond Patterns
	for cx in range(10, 230, 20):
		draw_rect(Rect2(cx, 115, 10, 8), COL_CARPET_PATTERN)
		
	# 3. Fireplace on Left (x=38..80, y=48)
	_draw_fireplace(38, 48)
	
	# 4. Plush Sofa on Right (x=132..182, y=72)
	_draw_sofa(132, 72)
	
	# 5. Coffee Table (x=144, y=94)
	_draw_coffee_table(144, 94)
	
	# 6. Standing Floor Lamp (x=196, y=45)
	_draw_floor_lamp(196, 45)

func _draw_fireplace(fx: float, fy: float) -> void:
	var fw: float = 42.0
	var fh: float = 50.0
	
	# Stone/Brick Chimney & Fireplace Body (x=38 to 80)
	draw_rect(Rect2(fx, fy, fw, fh), COL_BRICK_MAIN)
	
	# Brick texture lines
	for by in range(int(fy) + 4, int(fy + fh), 6):
		draw_line(Vector2(fx, by), Vector2(fx + fw, by), COL_BRICK_SHADOW, 1.0)
		
	# Wooden Mantel Shelf (x=36 to 84)
	draw_rect(Rect2(fx - 2, fy - 3, fw + 4, 5), COL_MANTEL)
	
	# Clock on Mantel
	draw_rect(Rect2(fx + fw * 0.5 - 4, fy - 10, 8, 7), COL_LAMP_BRASS)
	draw_rect(Rect2(fx + fw * 0.5 - 3, fy - 9, 6, 5), Color(0.95, 0.95, 0.95))
	draw_rect(Rect2(fx + fw * 0.5 - 1, fy - 8, 1, 3), COL_BRICK_SHADOW)
	
	# Fire Pit Inset
	draw_rect(Rect2(fx + 6, fy + 16, 30, 34), COL_FIRE_PIT)
	
	# Animated Fire Flames
	var fire_center_x: float = fx + fw * 0.5
	var fire_base_y: float = fy + fh - 2
	
	# Fire ambient glow halo
	var flicker_rad: float = 22.0 + sin(_fire_anim_timer * 1.5) * 3.0
	draw_circle(Vector2(fire_center_x, fire_base_y - 12), flicker_rad, COL_FIRE_GLOW)
	
	# Fire Logs
	draw_rect(Rect2(fire_center_x - 9, fire_base_y - 4, 18, 4), COL_MANTEL)
	draw_rect(Rect2(fire_center_x - 7, fire_base_y - 7, 14, 3), Color(0.25, 0.15, 0.10))
	
	# Flame Layers
	var flame_offset: float = (_fire_frame % 2) * 1.5 - 0.75
	# Red base flame
	draw_rect(Rect2(fire_center_x - 7, fire_base_y - 16 + flame_offset, 14, 12), COL_FIRE_RED)
	# Orange middle flame
	draw_rect(Rect2(fire_center_x - 5, fire_base_y - 19 - flame_offset, 10, 14), COL_FIRE_ORANGE)
	# Yellow core flame
	draw_rect(Rect2(fire_center_x - 3, fire_base_y - 17 + flame_offset, 6, 10), COL_FIRE_YELLOW)
	# Yellow tip sparks
	draw_rect(Rect2(fire_center_x - 1 + flame_offset, fire_base_y - 22, 2, 4), COL_FIRE_YELLOW)

func _draw_sofa(sx: float, sy: float) -> void:
	var sw: float = 50.0
	var sh: float = 28.0
	
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
		var cx = sx + 3 + i * 15
		draw_rect(Rect2(cx, sy + 13, 14, 13), COL_SOFA_CUSHION)
		draw_rect(Rect2(cx, sy + 13, 14, 2), COL_SOFA_SHADOW)
		
	# Throw Pillows
	draw_rect(Rect2(sx + 4, sy + 9, 8, 8), COL_PILLOW_GOLD)
	draw_rect(Rect2(sx + sw - 12, sy + 9, 8, 8), Color(0.9, 0.45, 0.45))
	
	# Wooden Sofa Feet
	draw_rect(Rect2(sx, sy + sh - 2, 4, 4), COL_TABLE_WOOD)
	draw_rect(Rect2(sx + sw - 4, sy + sh - 2, 4, 4), COL_TABLE_WOOD)

func _draw_coffee_table(tx: float, ty: float) -> void:
	# Wooden Oval/Rect Table
	draw_rect(Rect2(tx, ty + 6, 26, 4), COL_TABLE_WOOD)
	draw_rect(Rect2(tx, ty + 9, 26, 2), COL_MANTEL)
	draw_rect(Rect2(tx + 2, ty + 10, 3, 10), COL_TABLE_WOOD)
	draw_rect(Rect2(tx + 21, ty + 10, 3, 10), COL_TABLE_WOOD)
	
	# Steaming Mug on Table
	draw_rect(Rect2(tx + 10, ty + 1, 6, 5), Color(0.95, 0.95, 0.95))
	draw_rect(Rect2(tx + 11, ty + 1, 4, 1), Color(0.35, 0.22, 0.15))
	draw_rect(Rect2(tx + 16, ty + 2, 2, 3), Color(0.95, 0.95, 0.95))

func _draw_floor_lamp(lx: float, ly: float) -> void:
	# Brass Base & Pole
	draw_rect(Rect2(lx - 4, ly + 58, 8, 3), COL_LAMP_BRASS)
	draw_rect(Rect2(lx - 1, ly + 12, 2, 48), COL_LAMP_BRASS)
	
	# Lamp Shade
	draw_rect(Rect2(lx - 8, ly, 16, 12), COL_LAMP_SHADE)
	draw_rect(Rect2(lx - 6, ly, 12, 2), COL_LAMP_BRASS)
	
	# Ambient Warm Halo
	draw_circle(Vector2(lx, ly + 6), 26.0, COL_LAMP_GLOW)
