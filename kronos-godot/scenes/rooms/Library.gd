@tool
extends BaseRoom
class_name Library

## Grand Archive Library environment for Kronos.
## Features tall mahogany bookshelves, emerald reading armchair, and antique study desk.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_WALL: Color = Color(0.16, 0.14, 0.20, 1.0)
const COL_FLOOR_PARQUET: Color = Color(0.38, 0.24, 0.16, 1.0)
const COL_FLOOR_DARK: Color = Color(0.28, 0.16, 0.10, 1.0)
const COL_RUG: Color = Color(0.18, 0.38, 0.35, 1.0) # Emerald Persian Rug
const COL_RUG_GOLD: Color = Color(0.85, 0.70, 0.25, 1.0)
const COL_BASEBOARD: Color = Color(0.25, 0.15, 0.10, 1.0)

# Bookshelves & Books
const COL_SHELF_WOOD: Color = Color(0.34, 0.20, 0.12, 1.0)
const COL_SHELF_SHADOW: Color = Color(0.22, 0.12, 0.08, 1.0)
const COL_LADDER: Color = Color(0.48, 0.32, 0.20, 1.0)

# Book Spines
const COL_BOOK_RED: Color = Color(0.75, 0.22, 0.22, 1.0)
const COL_BOOK_BLUE: Color = Color(0.24, 0.45, 0.75, 1.0)
const COL_BOOK_GREEN: Color = Color(0.22, 0.58, 0.35, 1.0)
const COL_BOOK_GOLD: Color = Color(0.85, 0.68, 0.20, 1.0)
const COL_BOOK_PURPLE: Color = Color(0.52, 0.28, 0.65, 1.0)
const COL_BOOK_TEAL: Color = Color(0.20, 0.60, 0.65, 1.0)

# Furniture
const COL_CHAIR_EMERALD: Color = Color(0.15, 0.42, 0.32, 1.0)
const COL_CHAIR_SHADOW: Color = Color(0.10, 0.28, 0.20, 1.0)
const COL_DESK_WOOD: Color = Color(0.42, 0.26, 0.16, 1.0)
const COL_CANDLE_GLOW: Color = Color(1.0, 0.88, 0.50, 0.35)

var _candle_flicker: float = 0.0

func _ready() -> void:
	super._ready()
	room_id = "room_library"
	room_name = "Grand Archive Library"
	desk_x = 160.0
	nap_x = 75.0
	drink_x = 160.0

func _process(delta: float) -> void:
	super._process(delta)
	_candle_flicker += delta * 5.0
	queue_redraw()

func _draw() -> void:
	# 1. Background Wall & Bookshelf Rows (240x140)
	draw_rect(Rect2(0, 0, 240, 98), COL_WALL)
	
	# Baseboard
	draw_rect(Rect2(0, 96, 240, 4), COL_BASEBOARD)
	
	# Floor Parquet Wood
	draw_rect(Rect2(0, 100, 240, 40), COL_FLOOR_PARQUET)
	for py in range(100, 140, 8):
		draw_line(Vector2(0, py), Vector2(240, py), COL_FLOOR_DARK, 1.0)
		
	# Persian Emerald Rug (x=50 to 190)
	draw_rect(Rect2(50, 104, 140, 32), COL_RUG)
	draw_rect(Rect2(52, 106, 136, 28), COL_RUG_GOLD, false, 1.0)
	
	# 2. Giant Wall Bookshelves (x=38 to 202, y=8 to 96)
	_draw_grand_bookshelf(38, 8, 164, 88)
	
	# 3. Reading Armchair (x=60, y=70)
	_draw_reading_chair(60, 72)
	
	# 4. Antique Study Desk (x=142, y=74)
	_draw_study_desk(142, 74)

func _draw_grand_bookshelf(bx: float, by: float, bw: float, bh: float) -> void:
	# Outer Frame
	draw_rect(Rect2(bx, by, bw, bh), COL_SHELF_SHADOW)
	draw_rect(Rect2(bx - 2, by - 2, bw + 4, 3), COL_SHELF_WOOD)
	draw_rect(Rect2(bx - 2, by, 3, bh), COL_SHELF_WOOD)
	draw_rect(Rect2(bx + bw - 1, by, 3, bh), COL_SHELF_WOOD)
	
	# 3 Shelf Dividers
	var shelf_h: float = bh / 4.0
	for i in range(1, 4):
		var sy = by + i * shelf_h
		draw_rect(Rect2(bx, sy - 1, bw, 3), COL_SHELF_WOOD)
		
	# Fill Shelves with Multi-Colored Book Spines
	var book_colors = [COL_BOOK_RED, COL_BOOK_BLUE, COL_BOOK_GREEN, COL_BOOK_GOLD, COL_BOOK_PURPLE, COL_BOOK_TEAL]
	for row in range(4):
		var ry = by + row * shelf_h + 3
		var r_height = shelf_h - 4
		var x_cursor = bx + 4
		var book_idx = row * 3
		
		while x_cursor < bx + bw - 6:
			var book_w = randi_range(3, 5) if Engine.is_editor_hint() else ((book_idx % 3) + 3)
			var book_col = book_colors[book_idx % book_colors.size()]
			
			# Leave occasional gaps for small artifacts/globes/scrolls
			if book_idx % 7 == 0:
				x_cursor += 6
				book_idx += 1
				continue
				
			draw_rect(Rect2(x_cursor, ry + (shelf_h - r_height - 3), book_w, r_height), book_col)
			# Book spine gold line
			draw_rect(Rect2(x_cursor, ry + (shelf_h - r_height), book_w, 1), COL_BOOK_GOLD)
			x_cursor += book_w + 1
			book_idx += 1
			
	# Wooden Sliding Ladder (x=115, y=10)
	_draw_ladder(118, by + 2, bh)

func _draw_ladder(lx: float, ly: float, lh: float) -> void:
	# Top brass rail
	draw_line(Vector2(lx - 20, ly + 2), Vector2(lx + 30, ly + 2), COL_RUG_GOLD, 2.0)
	# Ladder Rails (tilted)
	draw_line(Vector2(lx, ly), Vector2(lx - 6, ly + lh + 14), COL_LADDER, 2.0)
	draw_line(Vector2(lx + 10, ly), Vector2(lx + 4, ly + lh + 14), COL_LADDER, 2.0)
	# Rungs
	for i in range(6):
		var ry = ly + 12 + i * 14
		draw_line(Vector2(lx - 1 - i, ry), Vector2(lx + 9 - i, ry), COL_LADDER, 2.0)

func _draw_reading_chair(cx: float, cy: float) -> void:
	# Emerald Wingback Armchair
	draw_rect(Rect2(cx, cy, 32, 28), COL_CHAIR_EMERALD)
	draw_rect(Rect2(cx, cy, 32, 3), COL_CHAIR_SHADOW)
	# Left/Right Wings
	draw_rect(Rect2(cx - 3, cy + 4, 5, 24), COL_CHAIR_EMERALD)
	draw_rect(Rect2(cx + 30, cy + 4, 5, 24), COL_CHAIR_EMERALD)
	# Cushion
	draw_rect(Rect2(cx + 2, cy + 14, 28, 14), Color(0.20, 0.50, 0.38))
	draw_rect(Rect2(cx + 2, cy + 14, 28, 2), COL_CHAIR_SHADOW)
	# Gold Cushion Piping
	draw_rect(Rect2(cx + 3, cy + 15, 26, 1), COL_RUG_GOLD)
	# Legs
	draw_rect(Rect2(cx, cy + 28, 3, 6), COL_SHELF_WOOD)
	draw_rect(Rect2(cx + 29, cy + 28, 3, 6), COL_SHELF_WOOD)

func _draw_study_desk(dx: float, dy: float) -> void:
	# Mahogany Desk
	draw_rect(Rect2(dx, dy + 16, 38, 4), COL_DESK_WOOD)
	draw_rect(Rect2(dx, dy + 19, 38, 2), COL_SHELF_SHADOW)
	draw_rect(Rect2(dx + 2, dy + 20, 3, 18), COL_DESK_WOOD)
	draw_rect(Rect2(dx + 33, dy + 20, 3, 18), COL_DESK_WOOD)
	
	# Ancient Open Tome on Desk
	draw_rect(Rect2(dx + 10, dy + 11, 16, 6), Color(0.92, 0.88, 0.78)) # Parchment
	draw_rect(Rect2(dx + 17, dy + 11, 2, 6), COL_SHELF_SHADOW)        # Spine fold
	draw_rect(Rect2(dx + 11, dy + 12, 5, 1), COL_SHELF_SHADOW)         # Text lines
	draw_rect(Rect2(dx + 11, dy + 14, 5, 1), COL_SHELF_SHADOW)
	draw_rect(Rect2(dx + 20, dy + 12, 5, 1), COL_SHELF_SHADOW)
	draw_rect(Rect2(dx + 20, dy + 14, 5, 1), COL_SHELF_SHADOW)
	
	# Feather Quill & Inkpot
	draw_rect(Rect2(dx + 28, dy + 12, 4, 4), Color(0.15, 0.15, 0.18))
	draw_line(Vector2(dx + 29, dy + 13), Vector2(dx + 25, dy + 4), Color(0.95, 0.95, 0.95), 1.0)
	
	# Brass Candle & Animated Flame
	draw_rect(Rect2(dx + 4, dy + 11, 4, 2), COL_RUG_GOLD)
	draw_rect(Rect2(dx + 5, dy + 6, 2, 6), Color(0.95, 0.92, 0.85))
	# Candle flame with flicker
	var candle_flick: float = sin(_candle_flicker) * 1.0
	draw_circle(Vector2(dx + 6, dy + 4), 10.0, COL_CANDLE_GLOW)
	draw_rect(Rect2(dx + 5, dy + 3 + candle_flick, 2, 3), Color(1.0, 0.85, 0.2))
	draw_rect(Rect2(dx + 5.5, dy + 2 + candle_flick, 1, 2), Color(1.0, 0.4, 0.1))
