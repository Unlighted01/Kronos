@tool
extends BaseRoom
class_name Library

## Grand Archive Library environment for Kronos.
## Features tall mahogany bookshelves with tumbling interactive books,
## emerald reading armchair, antique study desk with toggleable candle and openable grimoire,
## and a dedicated library study chair for pet companion activities.

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

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var parchment_sparks: CPUParticles2D = $ParchmentSparks

# ==============================================================================
# 📊 INTERACTION STATE
# ==============================================================================
var is_candle_lit: bool = true
var is_book_open: bool = true
var is_books_tumbled: bool = false

var _candle_flicker: float = 0.0
var _smoke_timer: float = 0.0

# Bounding boxes for click areas
const RECT_CANDLE: Rect2 = Rect2(144, 76, 12, 18)
const RECT_BOOK: Rect2 = Rect2(152, 80, 18, 14)
const RECT_BOOKSHELF: Rect2 = Rect2(38, 8, 164, 88)
const RECT_LIGHT_SWITCH: Rect2 = Rect2(210, 64, 16, 22)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_library"
	room_name = "Grand Archive Library"
	desk_x = 160.0
	nap_x = 75.0
	drink_x = 160.0
	
	if GameState:
		is_candle_lit = GameState.get_object_state("attic_candle_lit", true)
		is_book_open = GameState.get_object_state("attic_book_open", true)
		is_books_tumbled = GameState.get_object_state("attic_books_tumbled", false)
		
	EventBus.object_state_changed.connect(_on_object_state_changed)

var _tumble_timer: float = 0.0

func _process(delta: float) -> void:
	_candle_flicker += delta * 5.0
	_smoke_timer += delta * 2.0
	
	if is_books_tumbled:
		_tumble_timer -= delta
		if _tumble_timer <= 0.0:
			is_books_tumbled = false
			
	queue_redraw()

func _on_object_state_changed(key: String, val: Variant) -> void:
	if key == "attic_candle_lit":
		is_candle_lit = val
		queue_redraw()
	elif key == "attic_book_open":
		is_book_open = val
		queue_redraw()
	elif key == "attic_books_tumbled":
		is_books_tumbled = val
		_tumble_timer = 3.5
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
			
		# 2. Click Candle (Toggle flame on/off)
		if RECT_CANDLE.has_point(pos):
			is_candle_lit = not is_candle_lit
			if GameState:
				GameState.set_object_state("attic_candle_lit", is_candle_lit)
			EventBus.object_state_changed.emit("attic_candle_lit", is_candle_lit)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 3. Click Study Book (Toggle open/close grimoire)
		if RECT_BOOK.has_point(pos):
			is_book_open = not is_book_open
			if GameState:
				GameState.set_object_state("attic_book_open", is_book_open)
			EventBus.object_state_changed.emit("attic_book_open", is_book_open)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 4. Click Reading Armchair
		if Rect2(58, 70, 36, 32).has_point(pos):
			EventBus.object_state_changed.emit("attic_armchair", true)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 5. Click Bookshelf (Trigger 3.5s book cascade tumble)
		if RECT_BOOKSHELF.has_point(pos):
			is_books_tumbled = true
			_tumble_timer = 3.5
			if GameState:
				GameState.set_object_state("attic_books_tumbled", true)
			EventBus.object_state_changed.emit("attic_books_tumbled", true)
			if parchment_sparks:
				parchment_sparks.restart()
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			queue_redraw()
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 DRAWING PIPELINE (240x140 CANVAS)
# ==============================================================================
func _draw() -> void:
	# 1. Background Wall & Trim (240x140)
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
	
	# 3. Reading Armchair (x=60, y=72)
	_draw_reading_chair(60, 72)
	
	# 4. Library Study Chair (x=130, y=78 - facing desk for pet focus)
	_draw_study_chair(130, 78)
	
	# 5. Antique Study Desk with Candle & Grimoire (x=142, y=74)
	_draw_study_desk(142, 74)
	
	# 6. Wall Light Switch (x=214, y=68 - on open right wall clear of bookshelves)
	var is_light_on: bool = GameState.is_room_light_on(room_id) if GameState else false
	draw_light_switch(214, 68, is_light_on)
	
	# 7. Placed Room Decorations
	_draw_placed_decorations()

func _draw_placed_decorations() -> void:
	if not GameState:
		return
		
	# 🎮 Mini Arcade Cabinet on Desk Nook (x=174, y=74)
	if GameState.is_decor_placed("decor_arcade"):
		var ax: float = 174.0
		var ay: float = 74.0
		# Wooden/Black Cabinet Body
		draw_rect(Rect2(ax, ay, 12, 18), Color(0.12, 0.14, 0.20))
		draw_rect(Rect2(ax + 1, ay + 1, 10, 3), Color(0.95, 0.25, 0.35)) # Glowing Marquee
		# CRT Screen (Glowing cyan/magenta demo pixel lines)
		draw_rect(Rect2(ax + 2, ay + 5, 8, 7), Color(0.08, 0.12, 0.24))
		draw_rect(Rect2(ax + 3, ay + 6, 6, 2), Color(0.35, 0.85, 0.95)) # Player sprite
		draw_rect(Rect2(ax + 5, ay + 9, 3, 2), Color(0.95, 0.80, 0.20)) # Coin / star
		# Control Panel & Joystick
		draw_rect(Rect2(ax + 1, ay + 13, 10, 3), Color(0.25, 0.28, 0.35))
		draw_rect(Rect2(ax + 3, ay + 12, 2, 2), Color(0.95, 0.25, 0.30)) # Red balltop joystick
		draw_rect(Rect2(ax + 7, ay + 14, 1, 1), Color(0.3, 0.8, 0.4))   # Button
		draw_rect(Rect2(ax + 9, ay + 14, 1, 1), Color(0.3, 0.6, 0.9))   # Button
		
	# 🔭 Brass Stargazing Telescope on Tripod (x=44, y=82)
	if GameState.is_decor_placed("decor_telescope"):
		var tx: float = 44.0
		var ty: float = 82.0
		# Tripod Legs (dark walnut wood)
		draw_line(Vector2(tx, ty), Vector2(tx - 6, ty + 18), Color(0.40, 0.25, 0.15), 1.5)
		draw_line(Vector2(tx, ty), Vector2(tx, ty + 18), Color(0.35, 0.20, 0.12), 1.5)
		draw_line(Vector2(tx, ty), Vector2(tx + 6, ty + 18), Color(0.40, 0.25, 0.15), 1.5)
		# Brass Swivel Mount
		draw_rect(Rect2(tx - 2, ty - 2, 4, 4), Color(0.90, 0.72, 0.20))
		# Angled Brass Telescope Barrel (pointed top-left towards upper window)
		draw_line(Vector2(tx - 8, ty - 8), Vector2(tx + 6, ty + 4), Color(0.95, 0.78, 0.22), 3.0)
		draw_line(Vector2(tx - 9, ty - 9), Vector2(tx - 7, ty - 7), Color(0.65, 0.90, 1.0), 2.0) # Lens shine
		draw_rect(Rect2(tx + 5, ty + 3, 3, 3), Color(0.75, 0.58, 0.15)) # Eyepiece

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
			# Skip area where sliding ladder is
			if x_cursor > 112 and x_cursor < 128:
				x_cursor += 4
				continue
				
			var book_w = 4
			var book_col = book_colors[book_idx % book_colors.size()]
			
			# Tumble effect on row 1 (second shelf from top) when clicked!
			if is_books_tumbled and row == 1 and x_cursor >= 70 and x_cursor <= 96:
				# Tilted book cluster domino effect
				var tilt_poly: PackedVector2Array = [
					Vector2(x_cursor, ry + (shelf_h - r_height - 3)),
					Vector2(x_cursor + book_w + 3, ry + (shelf_h - r_height - 1)),
					Vector2(x_cursor + book_w, ry + shelf_h - 4),
					Vector2(x_cursor - 3, ry + shelf_h - 4)
				]
				draw_colored_polygon(tilt_poly, book_col)
				x_cursor += book_w + 3
				book_idx += 1
				continue
			elif is_books_tumbled and row == 2 and x_cursor >= 148 and x_cursor <= 156:
				# Fallen horizontal book lying on shelf
				draw_rect(Rect2(x_cursor, ry + shelf_h - 7, 12, 3), book_col)
				draw_rect(Rect2(x_cursor, ry + shelf_h - 7, 12, 1), COL_BOOK_GOLD)
				x_cursor += 14
				book_idx += 1
				continue
				
			# Standard neat book stack
			draw_rect(Rect2(x_cursor, ry + (shelf_h - r_height - 3), book_w, r_height), book_col)
			draw_rect(Rect2(x_cursor, ry + (shelf_h - r_height), book_w, 1), COL_BOOK_GOLD)
			x_cursor += book_w + 1
			book_idx += 1
			
	# Wooden Sliding Ladder (x=118, y=by+2)
	_draw_ladder(118, by + 2, bh)

func _draw_ladder(lx: float, ly: float, lh: float) -> void:
	draw_line(Vector2(lx - 20, ly + 2), Vector2(lx + 30, ly + 2), COL_RUG_GOLD, 2.0)
	draw_line(Vector2(lx, ly), Vector2(lx - 6, ly + lh + 14), COL_LADDER, 2.0)
	draw_line(Vector2(lx + 10, ly), Vector2(lx + 4, ly + lh + 14), COL_LADDER, 2.0)
	for i in range(6):
		var ry = ly + 12 + i * 14
		draw_line(Vector2(lx - 1 - i, ry), Vector2(lx + 9 - i, ry), COL_LADDER, 2.0)

func _draw_reading_chair(cx: float, cy: float) -> void:
	# Emerald Wingback Armchair
	draw_rect(Rect2(cx, cy, 32, 28), COL_CHAIR_EMERALD)
	draw_rect(Rect2(cx, cy, 32, 3), COL_CHAIR_SHADOW)
	draw_rect(Rect2(cx - 3, cy + 4, 5, 24), COL_CHAIR_EMERALD)
	draw_rect(Rect2(cx + 30, cy + 4, 5, 24), COL_CHAIR_EMERALD)
	draw_rect(Rect2(cx + 2, cy + 14, 28, 14), Color(0.20, 0.50, 0.38))
	draw_rect(Rect2(cx + 2, cy + 14, 28, 2), COL_CHAIR_SHADOW)
	draw_rect(Rect2(cx + 3, cy + 15, 26, 1), COL_RUG_GOLD)
	draw_rect(Rect2(cx, cy + 28, 3, 6), COL_SHELF_WOOD)
	draw_rect(Rect2(cx + 29, cy + 28, 3, 6), COL_SHELF_WOOD)

## Draws the dedicated study chair positioned at the desk for pet companion
func _draw_study_chair(sx: float, sy: float) -> void:
	# Wooden Spindle Backrest (facing right toward desk)
	draw_rect(Rect2(sx, sy, 3, 20), COL_SHELF_WOOD)
	draw_rect(Rect2(sx, sy, 8, 2), COL_SHELF_WOOD) # Top crest rail
	# Spindles
	draw_rect(Rect2(sx + 3, sy + 3, 1, 14), COL_DESK_WOOD)
	draw_rect(Rect2(sx + 6, sy + 3, 1, 14), COL_DESK_WOOD)
	
	# Emerald Velvet Seat Cushion
	draw_rect(Rect2(sx, sy + 18, 12, 4), COL_CHAIR_EMERALD)
	draw_rect(Rect2(sx, sy + 18, 12, 1), Color(0.25, 0.58, 0.44)) # Top highlight
	
	# Turned Wooden Legs
	draw_rect(Rect2(sx + 1, sy + 22, 2, 14), COL_SHELF_WOOD)
	draw_rect(Rect2(sx + 9, sy + 22, 2, 14), COL_SHELF_WOOD)
	# Stretcher bar between legs
	draw_rect(Rect2(sx + 1, sy + 28, 10, 1), COL_SHELF_SHADOW)

func _draw_study_desk(dx: float, dy: float) -> void:
	# Mahogany Desk Surface
	draw_rect(Rect2(dx, dy + 16, 38, 4), COL_DESK_WOOD)
	draw_rect(Rect2(dx, dy + 19, 38, 2), COL_SHELF_SHADOW)
	draw_rect(Rect2(dx + 2, dy + 20, 3, 18), COL_DESK_WOOD)
	draw_rect(Rect2(dx + 33, dy + 20, 3, 18), COL_DESK_WOOD)
	
	# Grimoire / Tome on Desk (Openable State)
	if is_book_open:
		# OPEN: Spread parchment pages with gold gilded edge and runes
		draw_rect(Rect2(dx + 10, dy + 11, 16, 6), Color(0.92, 0.88, 0.78)) # Parchment
		draw_rect(Rect2(dx + 17, dy + 11, 2, 6), COL_SHELF_SHADOW)        # Spine fold
		# Gold page edge trim
		draw_rect(Rect2(dx + 10, dy + 10, 16, 1), COL_RUG_GOLD)
		# Cursive script lines
		draw_rect(Rect2(dx + 11, dy + 12, 5, 1), COL_SHELF_SHADOW)
		draw_rect(Rect2(dx + 11, dy + 14, 5, 1), COL_SHELF_SHADOW)
		draw_rect(Rect2(dx + 20, dy + 12, 5, 1), COL_SHELF_SHADOW)
		draw_rect(Rect2(dx + 20, dy + 14, 5, 1), COL_SHELF_SHADOW)
		# Silk bookmark ribbon hanging down
		draw_line(Vector2(dx + 18, dy + 17), Vector2(dx + 18, dy + 21), Color(0.85, 0.22, 0.22), 1.0)
	else:
		# CLOSED: Thick crimson leather tome with gold clasp
		draw_rect(Rect2(dx + 12, dy + 12, 12, 5), COL_BOOK_RED)
		draw_rect(Rect2(dx + 12, dy + 12, 2, 5), COL_SHELF_SHADOW) # Thick spine
		draw_rect(Rect2(dx + 18, dy + 13, 2, 3), COL_RUG_GOLD)     # Gold clasp
		# Bookmark tail
		draw_line(Vector2(dx + 22, dy + 14), Vector2(dx + 25, dy + 14), Color(0.85, 0.22, 0.22), 1.0)
		
	# Feather Quill & Inkpot
	draw_rect(Rect2(dx + 28, dy + 12, 4, 4), Color(0.15, 0.15, 0.18))
	draw_line(Vector2(dx + 29, dy + 13), Vector2(dx + 25, dy + 4), Color(0.95, 0.95, 0.95), 1.0)
	
	# Brass Candle & Dynamic Flame / Smoke
	draw_rect(Rect2(dx + 4, dy + 11, 4, 2), COL_RUG_GOLD)
	draw_rect(Rect2(dx + 5, dy + 6, 2, 6), Color(0.95, 0.92, 0.85))
	
	if is_candle_lit:
		# Lit candle: Dancing flickering flame + warm halo
		var candle_flick: float = sin(_candle_flicker) * 1.0
		draw_circle(Vector2(dx + 6, dy + 4), 11.0, COL_CANDLE_GLOW)
		draw_rect(Rect2(dx + 5, dy + 3 + candle_flick, 2, 3), Color(1.0, 0.85, 0.2))
		draw_rect(Rect2(dx + 5.5, dy + 2 + candle_flick, 1, 2), Color(1.0, 0.4, 0.1))
	else:
		# Extinguished candle: Dark burnt wick + curling wisps of smoke
		draw_rect(Rect2(dx + 5.5, dy + 5, 1, 2), Color(0.18, 0.18, 0.20)) # Dark wick
		var smoke_ox: float = sin(_smoke_timer) * 1.5
		draw_rect(Rect2(dx + 5.5 + smoke_ox, dy + 2, 1, 1), Color(0.65, 0.65, 0.70, 0.5))
		draw_rect(Rect2(dx + 6.0 - smoke_ox, dy - 1, 1, 1), Color(0.65, 0.65, 0.70, 0.3))
