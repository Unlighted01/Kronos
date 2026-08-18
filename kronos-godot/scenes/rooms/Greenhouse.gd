@tool
extends BaseRoom
class_name Greenhouse

## Botanical Conservatory / Greenhouse environment for Kronos.
## Features glass atrium roof, lush monsteras, hanging ferns, blossoming bonsai, and falling sakura petals.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_GLASS_SKY: Color = Color(0.35, 0.62, 0.78, 1.0)
const COL_GLASS_FRAME: Color = Color(0.92, 0.94, 0.96, 0.8)
const COL_STONE_WALL: Color = Color(0.30, 0.36, 0.32, 1.0)
const COL_TERRACOTTA_FLOOR: Color = Color(0.72, 0.38, 0.28, 1.0)
const COL_FLOOR_GROUT: Color = Color(0.58, 0.28, 0.20, 1.0)

# Plants & Nature
const COL_LEAF_DARK: Color = Color(0.12, 0.38, 0.20, 1.0)
const COL_LEAF_MID: Color = Color(0.22, 0.58, 0.32, 1.0)
const COL_LEAF_LIGHT: Color = Color(0.42, 0.78, 0.45, 1.0)
const COL_POT_TERRACOTTA: Color = Color(0.78, 0.42, 0.28, 1.0)
const COL_POT_SHADOW: Color = Color(0.58, 0.30, 0.18, 1.0)

# Sakura Blossom
const COL_BLOSSOM_PINK: Color = Color(0.98, 0.68, 0.78, 1.0)
const COL_BLOSSOM_LIGHT: Color = Color(1.0, 0.85, 0.90, 1.0)
const COL_TRUNK_WOOD: Color = Color(0.38, 0.24, 0.16, 1.0)

# Furniture
const COL_BENCH_WOOD: Color = Color(0.55, 0.40, 0.28, 1.0)
const COL_BENCH_SHADOW: Color = Color(0.40, 0.28, 0.18, 1.0)

func _ready() -> void:
	super._ready()
	room_id = "room_greenhouse"
	room_name = "Botanical Conservatory"
	desk_x = 85.0
	nap_x = 165.0
	drink_x = 85.0

func _process(delta: float) -> void:
	super._process(delta)
	queue_redraw()

func _draw() -> void:
	# 1. Glass Conservatory Sky & Frame (240x140)
	var hour: int = Time.get_time_dict_from_system().get("hour", 12)
	var sky_col = COL_GLASS_SKY
	if hour < 6 or hour >= 20:
		sky_col = Color(0.08, 0.10, 0.20, 1.0)
	elif hour >= 16 and hour < 20:
		sky_col = Color(0.85, 0.52, 0.42, 1.0)
		
	draw_rect(Rect2(0, 0, 240, 70), sky_col)
	
	# Glass Roof Arches & Frames
	for gx in range(0, 240, 40):
		draw_line(Vector2(gx, 0), Vector2(gx, 70), COL_GLASS_FRAME, 2.0)
		draw_line(Vector2(gx, 0), Vector2(gx + 20, 35), COL_GLASS_FRAME, 1.0)
		draw_line(Vector2(gx + 40, 0), Vector2(gx + 20, 35), COL_GLASS_FRAME, 1.0)
	draw_line(Vector2(0, 35), Vector2(240, 35), COL_GLASS_FRAME, 2.0)
	draw_line(Vector2(0, 70), Vector2(240, 70), COL_GLASS_FRAME, 3.0)
	
	# Hanging Ivy & Fern Pots from Ceiling
	_draw_hanging_plant(45, 15)
	_draw_hanging_plant(120, 10)
	_draw_hanging_plant(195, 15)
	
	# 2. Lower Moss Stone Wall (y=70 to 98)
	draw_rect(Rect2(0, 70, 240, 28), COL_STONE_WALL)
	draw_line(Vector2(0, 96), Vector2(240, 96), COL_STONE_WALL.darkened(0.2), 2.0)
	
	# 3. Terracotta Stone Floor (y=98 to 140)
	draw_rect(Rect2(0, 98, 240, 42), COL_TERRACOTTA_FLOOR)
	for fy in range(98, 140, 12):
		draw_line(Vector2(0, fy), Vector2(240, fy), COL_FLOOR_GROUT, 1.0)
	for fx in range(0, 240, 24):
		draw_line(Vector2(fx, 98), Vector2(fx, 110), COL_FLOOR_GROUT, 1.0)
		draw_line(Vector2(fx + 12, 110), Vector2(fx + 12, 122), COL_FLOOR_GROUT, 1.0)
		draw_line(Vector2(fx, 122), Vector2(fx, 134), COL_FLOOR_GROUT, 1.0)
		draw_line(Vector2(fx + 12, 134), Vector2(fx + 12, 140), COL_FLOOR_GROUT, 1.0)
		
	# 4. Blossoming Sakura Bonsai Tree on Wooden Bench (x=55 to 105, y=55 to 115)
	_draw_sakura_bonsai(60, 58)
	
	# 5. Lush Potted Monstera & Ferns (x=115 to 145)
	_draw_monstera_pot(118, 76)
	
	# 6. Garden Potting Bench with Glass Watering Can (x=152 to 198)
	_draw_potting_bench(154, 75)

func _draw_hanging_plant(hx: float, hy: float) -> void:
	# Hanging rope
	draw_line(Vector2(hx, 0), Vector2(hx, hy + 6), Color(0.65, 0.55, 0.40), 1.0)
	# Terracotta hanging bowl
	draw_rect(Rect2(hx - 6, hy + 6, 12, 5), COL_POT_TERRACOTTA)
	# Trailing vines
	draw_circle(Vector2(hx, hy + 6), 7.0, COL_LEAF_MID)
	draw_circle(Vector2(hx - 4, hy + 12), 4.0, COL_LEAF_DARK)
	draw_circle(Vector2(hx + 3, hy + 14), 4.0, COL_LEAF_LIGHT)
	draw_line(Vector2(hx - 2, hy + 8), Vector2(hx - 4, hy + 20), COL_LEAF_MID, 2.0)
	draw_line(Vector2(hx + 3, hy + 8), Vector2(hx + 5, hy + 18), COL_LEAF_LIGHT, 2.0)

func _draw_sakura_bonsai(bx: float, by: float) -> void:
	# Wooden Stand Table
	draw_rect(Rect2(bx, by + 34, 38, 4), COL_BENCH_WOOD)
	draw_rect(Rect2(bx, by + 37, 38, 2), COL_BENCH_SHADOW)
	draw_rect(Rect2(bx + 3, dy_offset(by + 38), 3, 16), COL_BENCH_WOOD)
	draw_rect(Rect2(bx + 32, dy_offset(by + 38), 3, 16), COL_BENCH_WOOD)
	
	# Ceramic Bonsai Tray
	draw_rect(Rect2(bx + 6, by + 28, 26, 6), Color(0.22, 0.35, 0.40)) # Slate blue tray
	draw_rect(Rect2(bx + 8, by + 26, 22, 3), Color(0.28, 0.20, 0.15)) # Soil
	
	# Twisted Bonsai Trunk
	draw_line(Vector2(bx + 18, by + 26), Vector2(bx + 14, by + 14), COL_TRUNK_WOOD, 4.0)
	draw_line(Vector2(bx + 14, by + 14), Vector2(bx + 8, by + 6), COL_TRUNK_WOOD, 3.0)
	draw_line(Vector2(bx + 14, by + 14), Vector2(bx + 26, by + 8), COL_TRUNK_WOOD, 3.0)
	
	# Pink Blossom Foliage Clouds
	draw_circle(Vector2(bx + 7, by + 4), 10.0, COL_BLOSSOM_PINK)
	draw_circle(Vector2(bx + 24, by + 6), 11.0, COL_BLOSSOM_PINK)
	draw_circle(Vector2(bx + 16, by - 2), 9.0, COL_BLOSSOM_LIGHT)
	# Blossom highlights
	draw_circle(Vector2(bx + 9, by + 3), 4.0, COL_BLOSSOM_LIGHT)
	draw_circle(Vector2(bx + 22, by + 5), 5.0, Color(1.0, 1.0, 1.0, 0.9))

func _draw_monstera_pot(mx: float, my: float) -> void:
	# Ceramic White Pot
	draw_rect(Rect2(mx + 4, my + 24, 18, 14), Color(0.92, 0.94, 0.95))
	draw_rect(Rect2(mx + 2, my + 22, 22, 3), Color(0.85, 0.88, 0.90))
	
	# Broad Monstera Leaves
	draw_circle(Vector2(mx + 6, my + 14), 8.0, COL_LEAF_MID)
	draw_circle(Vector2(mx + 18, my + 10), 9.0, COL_LEAF_LIGHT)
	draw_circle(Vector2(mx + 12, my + 4), 7.0, COL_LEAF_DARK)
	# Leaf Stems
	draw_line(Vector2(mx + 12, my + 24), Vector2(mx + 6, my + 14), COL_LEAF_DARK, 2.0)
	draw_line(Vector2(mx + 14, my + 24), Vector2(mx + 18, my + 10), COL_LEAF_DARK, 2.0)
	draw_line(Vector2(mx + 13, my + 24), Vector2(mx + 12, my + 4), COL_LEAF_DARK, 2.0)

func _draw_potting_bench(px: float, py: float) -> void:
	# Wooden Table
	draw_rect(Rect2(px, py + 16, 40, 4), COL_BENCH_WOOD)
	draw_rect(Rect2(px, py + 19, 40, 2), COL_BENCH_SHADOW)
	draw_rect(Rect2(px + 2, py + 20, 3, 18), COL_BENCH_WOOD)
	draw_rect(Rect2(px + 35, py + 20, 3, 18), COL_BENCH_WOOD)
	
	# Potted Seedlings
	draw_rect(Rect2(px + 6, py + 10, 6, 6), COL_POT_TERRACOTTA)
	draw_rect(Rect2(px + 8, py + 6, 2, 4), COL_LEAF_LIGHT)
	draw_rect(Rect2(px + 14, py + 10, 6, 6), COL_POT_TERRACOTTA)
	draw_rect(Rect2(px + 16, py + 5, 2, 5), COL_LEAF_LIGHT)
	
	# Glass / Metal Watering Can
	draw_rect(Rect2(px + 24, py + 7, 10, 9), Color(0.4, 0.7, 0.85, 0.9)) # Body
	draw_line(Vector2(px + 34, py + 12), Vector2(px + 39, py + 4), Color(0.4, 0.7, 0.85), 2.0) # Spout
	draw_rect(Rect2(px + 22, py + 6, 2, 8), Color(0.3, 0.6, 0.75)) # Handle

func dy_offset(val: float) -> float:
	return val
