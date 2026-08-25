@tool
extends BaseRoom
class_name TowerOfUrania

## Tower of Urania - Premium Mythological Domain (720px wide).
## Features asymmetric astronomy layout, telescope, and cluttered desk.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_NIGHT_SKY: Color = Color(0.02, 0.03, 0.08, 1.0)
const COL_SPACE_BLUE: Color = Color(0.10, 0.15, 0.25, 1.0)
const COL_NEBULA_PURPLE: Color = Color(0.20, 0.05, 0.25, 0.3)
const COL_NEBULA_TEAL: Color = Color(0.05, 0.25, 0.20, 0.2)

const COL_TOWER_STONE: Color = Color(0.18, 0.20, 0.25, 1.0)
const COL_TOWER_SHADOW: Color = Color(0.10, 0.12, 0.15, 1.0)
const COL_TOWER_HIGHLIGHT: Color = Color(0.25, 0.28, 0.32, 1.0)

const COL_BRASS: Color = Color(0.75, 0.55, 0.25, 1.0)
const COL_BRASS_DARK: Color = Color(0.45, 0.30, 0.15, 1.0)
const COL_WOOD: Color = Color(0.35, 0.22, 0.15, 1.0)
const COL_WOOD_LIGHT: Color = Color(0.45, 0.32, 0.20, 1.0)

const COL_SCROLL: Color = Color(0.9, 0.85, 0.7, 1.0)
const COL_GLOBE_OCEAN: Color = Color(0.1, 0.3, 0.5, 1.0)
const COL_GLOBE_LAND: Color = Color(0.2, 0.5, 0.3, 1.0)
const COL_INK: Color = Color(0.05, 0.05, 0.08, 1.0)
const COL_CANDLE_WAX: Color = Color(0.8, 0.8, 0.7, 1.0)
const COL_CANDLE_FLAME: Color = Color(0.95, 0.8, 0.2, 1.0)

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _anim_clock: float = 0.0
var _stars: Array[Dictionary] = []
var _shooting_stars: Array[Dictionary] = []
var _globe_spin_speed: float = 1.0
var _globe_angle: float = 0.0

# Bounding Boxes
const RECT_TELESCOPE: Rect2 = Rect2(550, 40, 120, 80)
const RECT_GLOBE: Rect2 = Rect2(350, 70, 50, 50)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_library"
	room_name = "Grand Library"
	room_width = 720.0
	min_x = 80.0
	max_x = 650.0
	desk_x = 400.0  # The celestial desk
	nap_x = 200.0   # On the floor by the books
	drink_x = 360.0 # Next to the globe (maybe drinking ink? xD)
	
	for i in range(120):
		_stars.append({
			"x": randf_range(0, 720),
			"y": randf_range(0, 100),
			"phase": randf_range(0, PI * 2),
			"size": randf_range(0.5, 2.0)
		})

func _process(delta: float) -> void:
	_anim_clock += delta
	
	_globe_angle += _globe_spin_speed * delta
	_globe_spin_speed = lerpf(_globe_spin_speed, 1.0, delta * 0.5) # Dampen back to normal
	
	for i in range(_shooting_stars.size() - 1, -1, -1):
		var s = _shooting_stars[i]
		s["x"] -= s["speed"] * delta
		s["y"] += s["speed"] * 0.5 * delta
		s["life"] -= delta
		if s["life"] <= 0:
			_shooting_stars.remove_at(i)
			
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
		var pos: Vector2 = mb.position + Vector2(cam_x, 0)
		
		if RECT_TELESCOPE.has_point(pos):
			# Shoot a shooting star!
			_shooting_stars.append({
				"x": randf_range(400, 700),
				"y": randf_range(-20, 20),
				"speed": randf_range(400.0, 600.0),
				"life": 2.0
			})
			if EventBus: EventBus.object_state_changed.emit("telescope_used", true)
			get_viewport().set_input_as_handled()
			return
			
		if RECT_GLOBE.has_point(pos):
			_globe_spin_speed = 15.0 # Spin rapidly!
			if EventBus: EventBus.object_state_changed.emit("globe_spun", true)
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 DRAWING PIPELINE
# ==============================================================================
func _draw() -> void:
	_draw_cosmos()
	_draw_tower_architecture()
	
	# Left: Bookshelves & Clutter
	_draw_bookshelves(80, 100)
	
	# Center: Celestial Desk
	_draw_desk(400, 100)
	
	# Right: Telescope & Balcony
	_draw_telescope(600, 100)
	
	# Foreground Clutter scattered around
	_draw_clutter()

# ------------------------------------------------------------------------------
# 1. COSMOS BACKGROUND
# ------------------------------------------------------------------------------
func _draw_cosmos() -> void:
	draw_rect(Rect2(0, 0, 720, 100), COL_NIGHT_SKY)
	
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var p_offset = cam_x * 0.1
	
	# Nebulas
	for i in range(3):
		var nx = fmod(100 + i * 300 - p_offset * 0.5, 720)
		draw_circle(Vector2(nx, 40 + sin(i)*20), 80.0, COL_NEBULA_PURPLE)
		draw_circle(Vector2(nx + 40, 60 + cos(i)*20), 60.0, COL_NEBULA_TEAL)
		
	# Stars
	for s in _stars:
		var sx = fmod(s["x"] - p_offset, 720.0)
		if sx < 0: sx += 720.0
		var flicker = sin(_anim_clock * 0.5 + s["phase"]) * 0.5 + 0.5 # Slower flicker
		draw_rect(Rect2(sx, s["y"], s["size"], s["size"]), Color(1.0, 0.95, 0.9, 0.2 + 0.8 * flicker))
		
	# Shooting Stars
	for s in _shooting_stars:
		draw_line(Vector2(s["x"], s["y"]), Vector2(s["x"] + 40, s["y"] - 20), Color(1.0, 1.0, 1.0, s["life"]), 2.0)
		draw_circle(Vector2(s["x"], s["y"]), 2.0, Color(1.0, 1.0, 1.0, s["life"]))

# ------------------------------------------------------------------------------
# 2. ARCHITECTURE
# ------------------------------------------------------------------------------
func _draw_tower_architecture() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var a_offset = cam_x * 0.2
	
	# Giant Observatory Arches in the background
	for ax in range(50, 720, 200):
		var rx = ax - a_offset
		# Arch pillars
		draw_rect(Rect2(rx, 20, 16, 80), COL_TOWER_STONE.darkened(0.2))
		draw_rect(Rect2(rx + 120, 20, 16, 80), COL_TOWER_STONE.darkened(0.2))
		# Arch top
		draw_arc(Vector2(rx + 68, 20), 60.0, PI, PI*2, 24, COL_TOWER_STONE.darkened(0.2), 16.0)
		
	# Heavy wooden crossbeams across the ceiling
	draw_rect(Rect2(0, -50, 720, 60), COL_WOOD.darkened(0.2))
	for bx in range(0, 720, 100):
		draw_rect(Rect2(bx - a_offset, 10, 10, 15), COL_WOOD.darkened(0.1))
	
	# Floor
	draw_rect(Rect2(0, 100, 720, 40), COL_TOWER_STONE)
	draw_line(Vector2(0, 100), Vector2(720, 100), COL_TOWER_HIGHLIGHT, 2.0)
	
	# Stone Tiles
	for mx in range(20, 720, 40):
		draw_line(Vector2(mx, 100), Vector2(mx + 10, 140), COL_TOWER_SHADOW, 1.0)
		draw_line(Vector2(0, 115), Vector2(720, 115), COL_TOWER_SHADOW, 1.0)
		
	# Balcony railing on the right
	draw_rect(Rect2(650, 80, 10, 20), COL_TOWER_STONE)
	draw_rect(Rect2(690, 80, 10, 20), COL_TOWER_STONE)
	draw_rect(Rect2(640, 75, 80, 5), COL_TOWER_HIGHLIGHT)

# ------------------------------------------------------------------------------
# 3. BOOKSHELVES & LADDER
# ------------------------------------------------------------------------------
func _draw_bookshelves(bx: float, by: float) -> void:
	seed(hash("library_books")) # Ensure books don't jitter every frame!
	
	# Massive curved bookshelf on the left
	draw_rect(Rect2(bx - 60, by - 90, 140, 90), COL_WOOD.darkened(0.2))
	
	# Shelves
	for y in range(int(by) - 20, int(by) - 90, -25):
		draw_rect(Rect2(bx - 60, y, 140, 4), COL_WOOD_LIGHT)
		# Draw books on this shelf
		var book_x = bx - 55
		while book_x < bx + 70:
			var bw = randf_range(4.0, 12.0)
			var bh = randf_range(10.0, 22.0)
			if randf() > 0.2: # 80% chance of a book
				var bc = Color(randf_range(0.2, 0.8), randf_range(0.2, 0.5), randf_range(0.2, 0.8))
				# Leaning book?
				if randf() > 0.8:
					draw_rect(Rect2(book_x, y - bh, bw, bh), bc)
					draw_line(Vector2(book_x, y - bh), Vector2(book_x+bw, y - bh), COL_SCROLL, 1.0)
				else:
					# Draw it tilted
					var tilt = randf_range(2.0, 8.0)
					var bpts = PackedVector2Array([
						Vector2(book_x, y), Vector2(book_x+bw, y),
						Vector2(book_x+bw+tilt, y-bh), Vector2(book_x+tilt, y-bh)
					])
					draw_colored_polygon(bpts, bc)
			book_x += bw + randf_range(1.0, 5.0)

	# Rolling Ladder
	var lx = bx + 40
	draw_line(Vector2(lx, by), Vector2(lx, by - 80), COL_WOOD_LIGHT, 3.0)
	draw_line(Vector2(lx + 15, by), Vector2(lx + 15, by - 80), COL_WOOD_LIGHT, 3.0)
	for ly in range(int(by) - 10, int(by) - 80, -15):
		draw_line(Vector2(lx, ly), Vector2(lx + 15, ly), COL_WOOD_LIGHT, 2.0)
	# Ladder wheels
	draw_circle(Vector2(lx + 2, by - 2), 3.0, COL_BRASS_DARK)
	draw_circle(Vector2(lx + 13, by - 2), 3.0, COL_BRASS_DARK)
	
	seed(int(Time.get_ticks_msec())) # Reset seed to random for other systems

# ------------------------------------------------------------------------------
# 4. CELESTIAL DESK
# ------------------------------------------------------------------------------
func _draw_desk(dx: float, dy: float) -> void:
	# Heavy wooden desk
	draw_rect(Rect2(dx - 40, dy - 20, 80, 20), COL_WOOD.darkened(0.1))
	draw_rect(Rect2(dx - 45, dy - 20, 90, 6), COL_WOOD_LIGHT)
	# Legs
	draw_rect(Rect2(dx - 35, dy, 8, 10), COL_WOOD)
	draw_rect(Rect2(dx + 27, dy, 8, 10), COL_WOOD)
	
	# The Interactive Celestial Globe
	var gx = dx - 20
	var gy = dy - 35
	draw_rect(Rect2(gx - 4, gy + 15, 8, 5), COL_BRASS) # Base
	draw_arc(Vector2(gx, gy), 12.0, -PI/4, PI*1.25, 12, COL_BRASS, 2.0) # Axis ring
	draw_circle(Vector2(gx, gy), 10.0, COL_GLOBE_OCEAN)
	
	# Spin the continents!
	var cx1 = gx + sin(_globe_angle) * 6.0
	draw_circle(Vector2(cx1, gy - 2), 3.0, COL_GLOBE_LAND)
	var cx2 = gx + cos(_globe_angle) * 8.0
	draw_circle(Vector2(cx2, gy + 4), 4.0, COL_GLOBE_LAND)

	# Candles
	var cx = dx + 15
	var cy_c = dy - 25
	draw_rect(Rect2(cx, cy_c, 4, 8), COL_CANDLE_WAX)
	draw_rect(Rect2(cx + 8, cy_c + 3, 3, 5), COL_CANDLE_WAX)
	var flicker = sin(_anim_clock * 15.0) * 1.5
	draw_circle(Vector2(cx + 2, cy_c - 2), 2.0 + flicker * 0.2, COL_CANDLE_FLAME)
	draw_circle(Vector2(cx + 2, cy_c - 2), 6.0 + flicker, Color(COL_CANDLE_FLAME.r, COL_CANDLE_FLAME.g, 0.0, 0.2))

	# Spilled Ink Bottle
	draw_rect(Rect2(dx + 30, dy - 24, 6, 8), Color(0.2, 0.2, 0.2)) # Bottle
	draw_rect(Rect2(dx + 25, dy - 18, 15, 3), COL_INK) # Spill puddle
	# Dripping ink off the desk
	draw_line(Vector2(dx + 35, dy - 15), Vector2(dx + 35, dy - 5), COL_INK, 1.5)

# ------------------------------------------------------------------------------
# 5. MASSIVE TELESCOPE
# ------------------------------------------------------------------------------
func _draw_telescope(tx: float, ty: float) -> void:
	# Tripod Base
	draw_line(Vector2(tx, ty - 30), Vector2(tx - 20, ty), COL_WOOD, 3.0)
	draw_line(Vector2(tx, ty - 30), Vector2(tx + 20, ty), COL_WOOD, 3.0)
	draw_line(Vector2(tx, ty - 30), Vector2(tx, ty), COL_WOOD.darkened(0.2), 3.0)
	# Crossbeams for tripod
	draw_line(Vector2(tx - 10, ty - 15), Vector2(tx + 10, ty - 15), COL_BRASS_DARK, 2.0)
	
	# Mount
	draw_circle(Vector2(tx, ty - 30), 6.0, COL_BRASS)
	draw_rect(Rect2(tx - 4, ty - 38, 8, 8), COL_BRASS_DARK)
	
	# Telescope Tube (Rotated)
	draw_set_transform(Vector2(tx, ty - 36), -PI / 6.0, Vector2.ONE)
	
	# Main back barrel
	draw_rect(Rect2(-20, -10, 40, 20), COL_BRASS_DARK)
	draw_rect(Rect2(-20, -10, 40, 4), COL_BRASS) # Highlight
	
	# Middle extending barrel
	draw_rect(Rect2(20, -8, 25, 16), COL_BRASS)
	draw_rect(Rect2(20, -8, 25, 4), Color(0.9, 0.7, 0.4, 1.0)) # Highlight
	
	# Front Lens cap / ring
	draw_rect(Rect2(45, -10, 10, 20), COL_BRASS_DARK)
	draw_rect(Rect2(55, -8, 5, 16), COL_SPACE_BLUE) # Lens glass
	
	# Eyepiece
	draw_rect(Rect2(-30, -5, 10, 10), COL_BRASS)
	draw_rect(Rect2(-35, -3, 5, 6), COL_SPACE_BLUE)
	
	# Finder Scope on top
	draw_rect(Rect2(5, -16, 20, 6), COL_BRASS)
	draw_rect(Rect2(10, -10, 4, 4), COL_BRASS_DARK) # mount
	
	# Reset transform!
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ------------------------------------------------------------------------------
# 6. GROUND CLUTTER
# ------------------------------------------------------------------------------
func _draw_clutter() -> void:
	# Dropped scrolls on the floor
	_draw_scroll(150, 105, 0.2)
	_draw_scroll(170, 108, -0.1)
	_draw_scroll(380, 112, 0.5)
	
	# Reading Stool
	draw_rect(Rect2(280, 90, 20, 4), COL_WOOD_LIGHT)
	draw_line(Vector2(282, 94), Vector2(280, 105), COL_WOOD, 2.0)
	draw_line(Vector2(298, 94), Vector2(300, 105), COL_WOOD, 2.0)
	
	# Dropped Astrolabe gear
	draw_circle(Vector2(500, 110), 5.0, COL_BRASS)
	draw_circle(Vector2(500, 110), 3.0, COL_TOWER_STONE.darkened(0.2)) # Hole

func _draw_scroll(sx: float, sy: float, rot: float) -> void:
	var w = 15.0
	var h = 5.0
	var pts = PackedVector2Array([
		Vector2(sx, sy), Vector2(sx + cos(rot)*w, sy + sin(rot)*w),
		Vector2(sx + cos(rot)*w - sin(rot)*h, sy + sin(rot)*w + cos(rot)*h),
		Vector2(sx - sin(rot)*h, sy + cos(rot)*h)
	])
	draw_colored_polygon(pts, COL_SCROLL)
	# Scroll ends
	draw_circle(Vector2(sx, sy + h/2.0), h/2.0, COL_WOOD_LIGHT)
	draw_circle(Vector2(sx + cos(rot)*w, sy + sin(rot)*w + h/2.0), h/2.0, COL_WOOD_LIGHT)
