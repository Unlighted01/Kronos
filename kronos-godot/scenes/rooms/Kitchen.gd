@tool
extends BaseRoom
class_name Kitchen

## Pixel Cafe & Kitchen environment for Kronos.
## Features espresso coffee bar, oven stove with simmering pot, and snack counter.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_WALL_TILES: Color = Color(0.85, 0.88, 0.90, 1.0) # Subway Tile Backsplash
const COL_TILE_GROUT: Color = Color(0.72, 0.76, 0.80, 1.0)
const COL_WALL_TOP: Color = Color(0.25, 0.35, 0.38, 1.0)
const COL_CHECKER_A: Color = Color(0.92, 0.90, 0.85, 1.0)  # Checkered Floor Light
const COL_CHECKER_B: Color = Color(0.20, 0.22, 0.28, 1.0)  # Checkered Floor Dark

# Cabinets & Counter
const COL_CABINET_WOOD: Color = Color(0.48, 0.34, 0.24, 1.0)
const COL_CABINET_SHADOW: Color = Color(0.35, 0.24, 0.16, 1.0)
const COL_COUNTER_MARBLE: Color = Color(0.94, 0.95, 0.96, 1.0)
const COL_COUNTER_EDGE: Color = Color(0.78, 0.80, 0.84, 1.0)

# Espresso Machine & Appliances
const COL_STEEL: Color = Color(0.70, 0.74, 0.80, 1.0)
const COL_STEEL_DARK: Color = Color(0.45, 0.48, 0.55, 1.0)
const COL_ESPRESSO_RED: Color = Color(0.85, 0.22, 0.22, 1.0)
const COL_OVEN_BODY: Color = Color(0.30, 0.32, 0.38, 1.0)
const COL_OVEN_GLASS: Color = Color(0.18, 0.19, 0.24, 1.0)
const COL_CROISSANT_GOLD: Color = Color(0.92, 0.65, 0.25, 1.0)

func _ready() -> void:
	super._ready()
	room_id = "room_kitchen"
	room_name = "Pixel Cafe & Kitchen"
	desk_x = 65.0
	nap_x = 165.0
	drink_x = 65.0

func _process(delta: float) -> void:
	super._process(delta)
	queue_redraw()

func _draw() -> void:
	# 1. Background Wall Top & Subway Tiles (240x140)
	draw_rect(Rect2(0, 0, 240, 30), COL_WALL_TOP)
	
	# Subway Tile Backsplash (y=30 to 98)
	draw_rect(Rect2(0, 30, 240, 68), COL_WALL_TILES)
	for ty in range(30, 98, 8):
		draw_line(Vector2(0, ty), Vector2(240, ty), COL_TILE_GROUT, 1.0)
	for ty in range(30, 98, 16):
		for tx in range(0, 240, 16):
			draw_line(Vector2(tx, ty), Vector2(tx, ty + 8), COL_TILE_GROUT, 1.0)
			draw_line(Vector2(tx + 8, ty + 8), Vector2(tx + 8, ty + 16), COL_TILE_GROUT, 1.0)
			
	# Hanging Utensils Rack (x=105, y=36)
	draw_line(Vector2(95, 36), Vector2(145, 36), COL_STEEL, 2.0)
	# Hanging pots & ladles
	draw_rect(Rect2(100, 38, 2, 8), COL_STEEL_DARK)
	draw_circle(Vector2(101, 48), 4.0, COL_STEEL_DARK)
	draw_rect(Rect2(118, 38, 2, 10), COL_STEEL_DARK)
	draw_rect(Rect2(116, 48, 6, 6), Color(0.85, 0.4, 0.3)) # Copper pan
	draw_rect(Rect2(136, 38, 2, 7), COL_STEEL_DARK)
	draw_circle(Vector2(137, 46), 3.0, COL_STEEL_DARK)
	
	# 2. Checkered Floor (y=98 to 140)
	var tile_size: int = 14
	for fy in range(98, 140, tile_size):
		for fx in range(0, 240, tile_size):
			var is_even: bool = ((fx / tile_size) + (fy / tile_size)) % 2 == 0
			var col = COL_CHECKER_A if is_even else COL_CHECKER_B
			draw_rect(Rect2(fx, fy, tile_size, tile_size), col)
			
	# 3. Espresso Coffee Bar (x=42 to 88, y=65 to 115)
	_draw_coffee_bar(44, 66)
	
	# 4. Stove Oven (x=98 to 134, y=68 to 115)
	_draw_oven_stove(98, 68)
	
	# 5. Snack Island Counter (x=144 to 196, y=70 to 115)
	_draw_snack_counter(146, 70)

func _draw_coffee_bar(cx: float, cy: float) -> void:
	# Wooden Counter
	draw_rect(Rect2(cx, cy + 18, 42, 30), COL_CABINET_WOOD)
	draw_rect(Rect2(cx, cy + 18, 42, 3), COL_CABINET_SHADOW)
	# Cabinet doors
	draw_rect(Rect2(cx + 3, cy + 24, 16, 20), COL_CABINET_SHADOW)
	draw_rect(Rect2(cx + 23, cy + 24, 16, 20), COL_CABINET_SHADOW)
	
	# Marble Countertop
	draw_rect(Rect2(cx - 2, cy + 14, 46, 5), COL_COUNTER_MARBLE)
	draw_rect(Rect2(cx - 2, cy + 17, 46, 2), COL_COUNTER_EDGE)
	
	# Retro Espresso Machine
	draw_rect(Rect2(cx + 6, cy + 2, 18, 13), COL_ESPRESSO_RED)
	draw_rect(Rect2(cx + 7, cy + 3, 16, 2), COL_STEEL) # Chrome top
	draw_rect(Rect2(cx + 8, cy + 8, 5, 4), COL_STEEL)   # Portafilter grouphead
	draw_rect(Rect2(cx + 10, cy + 12, 5, 3), Color(0.95, 0.95, 0.95)) # Tiny espresso cup
	
	# Coffee Bean Grinder & Hopper
	draw_rect(Rect2(cx + 28, cy + 2, 8, 13), COL_STEEL_DARK)
	draw_rect(Rect2(cx + 29, cy - 2, 6, 5), Color(0.35, 0.22, 0.15, 0.8)) # Glass hopper with beans
	
	# Menu Chalkboard on Wall
	draw_rect(Rect2(cx + 4, cy - 22, 24, 16), COL_CHECKER_B)
	draw_rect(Rect2(cx + 3, cy - 23, 26, 18), COL_CABINET_WOOD, false, 1.0)
	draw_rect(Rect2(cx + 6, cy - 18, 12, 1), Color(1.0, 1.0, 0.8))
	draw_rect(Rect2(cx + 6, cy - 14, 16, 1), Color(0.8, 0.8, 0.8))
	draw_rect(Rect2(cx + 6, cy - 10, 14, 1), Color(0.8, 0.8, 0.8))

func _draw_oven_stove(ox: float, oy: float) -> void:
	# Steel Oven Body
	draw_rect(Rect2(ox, oy + 12, 34, 34), COL_OVEN_BODY)
	draw_rect(Rect2(ox, oy + 12, 34, 3), COL_STEEL_DARK)
	
	# Oven Glass Door
	draw_rect(Rect2(ox + 4, oy + 22, 26, 20), COL_OVEN_GLASS)
	draw_rect(Rect2(ox + 7, oy + 18, 20, 2), COL_STEEL) # Handle
	
	# Stove Burners Top
	draw_rect(Rect2(ox - 1, oy + 10, 36, 4), COL_STEEL)
	draw_rect(Rect2(ox + 4, oy + 8, 8, 3), COL_STEEL_DARK)
	draw_rect(Rect2(ox + 20, oy + 8, 8, 3), COL_STEEL_DARK)
	
	# Simmering Pot on Stove
	draw_rect(Rect2(ox + 5, oy + 1, 10, 7), Color(0.35, 0.65, 0.55)) # Teal pot
	draw_rect(Rect2(ox + 4, oy + 3, 12, 1), COL_STEEL) # Lid edge

func _draw_snack_counter(sx: float, sy: float) -> void:
	# Kitchen Island Counter
	draw_rect(Rect2(sx, sy + 14, 46, 32), COL_CABINET_WOOD)
	draw_rect(Rect2(sx, sy + 14, 46, 3), COL_CABINET_SHADOW)
	
	# Marble Top
	draw_rect(Rect2(sx - 2, sy + 10, 50, 5), COL_COUNTER_MARBLE)
	draw_rect(Rect2(sx - 2, sy + 13, 50, 2), COL_COUNTER_EDGE)
	
	# Plate of Fresh Croissants
	draw_rect(Rect2(sx + 6, sy + 7, 14, 3), COL_COUNTER_MARBLE)
	draw_rect(Rect2(sx + 8, sy + 4, 10, 4), COL_CROISSANT_GOLD)
	draw_rect(Rect2(sx + 9, sy + 3, 6, 2), Color(0.98, 0.78, 0.35))
	
	# Fruit Bowl / Matcha Whisk
	draw_rect(Rect2(sx + 26, sy + 5, 12, 6), Color(0.85, 0.90, 0.95))
	draw_circle(Vector2(sx + 29, sy + 4), 3.0, Color(0.95, 0.25, 0.25)) # Apple
	draw_circle(Vector2(sx + 34, sy + 4), 3.0, Color(0.98, 0.60, 0.15)) # Orange
