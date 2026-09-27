@tool
extends BaseRoom
class_name TowerOfUrania

## Tower of Urania - Ultra-Detailed Mythological Sanctuary (720px wide).
## Features over 120+ active sprites & decor elements, open celestial observatory,
## spinning brass celestial globe, grand observatory telescope, walnut bookshelves, and scholar desk.

# ==============================================================================
# 🎨 COLOR PALETTES
# ==============================================================================
const COL_SKY_TOP: Color = Color(0.02, 0.03, 0.10, 1.0) # Deep cosmic navy
const COL_SKY_BOT: Color = Color(0.14, 0.08, 0.24, 1.0) # Violet nebula twilight
const COL_BRASS_GOLD: Color = Color(0.85, 0.68, 0.32, 1.0)
const COL_AMBER_GLOW: Color = Color(1.0, 0.75, 0.28, 1.0)
const COL_STAR_MOTE: Color = Color(0.95, 0.92, 0.70, 0.85)

# ==============================================================================
# 📦 16-BIT HANDCRAFTED SPRITE ASSET SUITE
# ==============================================================================
# Architectural Foundations
const TEX_FLOOR: Texture2D = preload("res://assets/sprites/rooms/library/floor_tile.png")
const TEX_FLOOR_LIP: Texture2D = preload("res://assets/sprites/rooms/library/floor_lip.png")
const TEX_WALL_STONE: Texture2D = preload("res://assets/sprites/rooms/library/wall_stone.png")
const TEX_WALL_FRIEZE: Texture2D = preload("res://assets/sprites/rooms/library/wall_frieze.png")
const TEX_COLUMN: Texture2D = preload("res://assets/sprites/rooms/library/column.png")
const TEX_CEILING: Texture2D = preload("res://assets/sprites/rooms/library/ceiling_beam.png")
const TEX_BALUSTRADE: Texture2D = preload("res://assets/sprites/rooms/library/balustrade.png")
const TEX_VISTA_GALAXY: Texture2D = preload("res://assets/sprites/rooms/library/vista_olympus_galaxy.png")

# Furniture & Interactive Props
const TEX_CELESTIAL_GLOBE: Texture2D = preload("res://assets/sprites/rooms/library/celestial_globe.png")
const TEX_TELESCOPE: Texture2D = preload("res://assets/sprites/rooms/library/observatory_telescope.png")
const TEX_SCHOLAR_DESK: Texture2D = preload("res://assets/sprites/rooms/library/scholar_desk.png")
const TEX_READING_ARMCHAIR: Texture2D = preload("res://assets/sprites/rooms/library/reading_armchair.png")
const TEX_TEA_SAMOVAR: Texture2D = preload("res://assets/sprites/rooms/library/tea_samovar.png")
const TEX_LIBRARY_LADDER: Texture2D = preload("res://assets/sprites/rooms/library/library_ladder.png")
const TEX_BOOKCASE_LOW: Texture2D = preload("res://assets/sprites/rooms/library/bookcase_low.png")
const TEX_ZODIAC_RUG: Texture2D = preload("res://assets/sprites/rooms/library/zodiac_rug.png")
const TEX_BOOK_STACKS: Texture2D = preload("res://assets/sprites/rooms/library/book_stacks.png")

# Expansion Observatory Decor
const TEX_BOOKSHELF_TALL: Texture2D = preload("res://assets/sprites/rooms/library/bookshelf_tall.png")
const TEX_HANGING_LANTERN: Texture2D = preload("res://assets/sprites/rooms/library/hanging_lantern.png")
const TEX_WALL_SCONCE: Texture2D = preload("res://assets/sprites/rooms/library/wall_sconce.png")
const TEX_ORRERY: Texture2D = preload("res://assets/sprites/rooms/library/orrery.png")
const TEX_STAR_CHART: Texture2D = preload("res://assets/sprites/rooms/library/star_chart.png")

# ==============================================================================
# 📊 INTERNAL STATE & ANIMATION SYSTEMS
# ==============================================================================
var _anim_clock: float = 0.0
var _stars: Array[Dictionary] = []
var _shooting_stars: Array[Dictionary] = []
var _celestial_motes: Array[Dictionary] = []
var _tea_steam: Array[Dictionary] = []
var _star_twinkles: Array[Dictionary] = []

# Interactive State
var _globe_angle: float = 0.0
var _globe_spin_speed: float = 1.0
var _telescope_tilt: float = 0.0
var _lantern_swing: float = 0.0
var is_constellation_active: bool = false
var _desk_lamp_flare: float = 0.0

# Mouse Interaction Hitboxes
const RECT_GLOBE: Rect2 = Rect2(330, 50, 52, 58)
const RECT_TELESCOPE: Rect2 = Rect2(560, 48, 64, 60)
const RECT_DESK: Rect2 = Rect2(380, 60, 84, 48)
const RECT_ARMCHAIR: Rect2 = Rect2(195, 54, 50, 54)
const RECT_SAMOVAR: Rect2 = Rect2(298, 68, 26, 40)
const RECT_BOOKSHELF: Rect2 = Rect2(55, 36, 52, 68)
const RECT_BALUSTRADE: Rect2 = Rect2(550, 72, 140, 32)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_library"
	room_name = "Tower of Urania"
	room_width = 720.0
	min_x = 60.0
	max_x = 670.0
	floor_y = 102.0
	desk_x = 420.0 # Scholar Study Desk (Study / Feast)
	nap_x = 220.0  # Plush Reading Armchair (Nap / Loaf)
	drink_x = 310.0 # Tea Samovar on stone plinth (Drink)
	
	# Seed celestial star clusters
	for i in range(60):
		_stars.append({
			"x": randf_range(-100, 850),
			"y": randf_range(-60, 85),
			"size": randf_range(1.0, 2.5),
			"phase": randf_range(0, TAU)
		})
		
	# Seed ambient floating golden celestial motes
	for i in range(16):
		_celestial_motes.append({
			"x": randf_range(50, 700),
			"y": randf_range(20, 110),
			"vx": randf_range(-5.0, 8.0),
			"vy": randf_range(-4.0, -14.0),
			"phase": randf_range(0, TAU),
			"life": randf_range(3.0, 7.0)
		})

# ==============================================================================
# 🔄 SIMULATION & PROCESS LOOP
# ==============================================================================
func _process(delta: float) -> void:
	_anim_clock += delta * 2.0
	
	# Globe rotation physics with gradual dampening
	_globe_angle += _globe_spin_speed * delta * 1.5
	_globe_spin_speed = lerpf(_globe_spin_speed, 1.0, delta * 0.6)
	
	_lantern_swing = lerpf(_lantern_swing, 0.0, delta * 2.0)
	_desk_lamp_flare = maxf(0.0, _desk_lamp_flare - delta * 1.6)
	
	# Ambient tea steam emission
	if randf() < delta * 2.0:
		_tea_steam.append({
			"x": randf_range(308, 314), "y": 70.0,
			"vx": randf_range(-3.0, 5.0), "vy": randf_range(-10.0, -20.0),
			"size": randf_range(1.5, 3.2), "alpha": 0.5, "life": randf_range(1.2, 2.2)
		})
		
	# Update Tea Steam
	for i in range(_tea_steam.size() - 1, -1, -1):
		var st = _tea_steam[i]
		st["x"] += (st["vx"] + sin(_anim_clock * 3.0 + st["y"]) * 4.0) * delta
		st["y"] += st["vy"] * delta
		st["size"] += delta * 1.5
		st["life"] -= delta
		if st["life"] <= 0:
			_tea_steam.remove_at(i)
			
	# Update Celestial Motes
	for i in range(_celestial_motes.size() - 1, -1, -1):
		var m = _celestial_motes[i]
		m["x"] += (m["vx"] + sin(_anim_clock + m["phase"]) * 4.0) * delta
		m["y"] += m["vy"] * delta
		m["life"] -= delta
		if m["life"] <= 0 or m["y"] < -20:
			m["y"] = randf_range(95, 115)
			m["x"] = randf_range(60, 680)
			m["life"] = randf_range(3.0, 6.0)
			
	# Update Shooting Stars
	for i in range(_shooting_stars.size() - 1, -1, -1):
		var ss = _shooting_stars[i]
		ss["x"] += ss["vx"] * delta
		ss["y"] += ss["vy"] * delta
		ss["life"] -= delta * 1.4
		if ss["life"] <= 0:
			_shooting_stars.remove_at(i)
			
	# Random cosmic shooting star
	if randf() < delta * 0.20 and _shooting_stars.size() < 3:
		_shooting_stars.append({
			"x": randf_range(380, 660),
			"y": randf_range(-10, 30),
			"vx": randf_range(-160.0, -260.0),
			"vy": randf_range(80.0, 140.0),
			"life": 1.2
		})
			
	queue_redraw()

# ==============================================================================
# 🖱️ INTERACTIVE MOUSE INPUT
# ==============================================================================
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
		var pos: Vector2 = mb.position + Vector2(cam_x, 0)
		
		# 1. Celestial Globe Click: Spin rapidly & spawn zodiac sparkles
		if RECT_GLOBE.has_point(pos):
			_globe_spin_speed += 8.0
			for i in range(12):
				_celestial_motes.append({
					"x": randf_range(345, 365), "y": 75.0,
					"vx": randf_range(-25.0, 25.0), "vy": randf_range(-30.0, -10.0),
					"phase": randf_range(0, TAU), "life": randf_range(1.0, 2.0)
				})
			if GameState:
				GameState.knowledge = minf(GameState.MAX_KNOWLEDGE, GameState.knowledge + 5.0)
				if EventBus: EventBus.object_state_changed.emit("globe_spun", true)
			get_viewport().set_input_as_handled()
			return
			
		# 2. Grand Observatory Telescope Click: Toggle constellation & meteor shower
		if RECT_TELESCOPE.has_point(pos):
			is_constellation_active = not is_constellation_active
			for i in range(3):
				_shooting_stars.append({
					"x": randf_range(520, 680), "y": randf_range(-10, 20),
					"vx": randf_range(-220.0, -320.0), "vy": randf_range(90.0, 160.0),
					"life": 1.5
				})
			if EventBus: EventBus.object_state_changed.emit("telescope_observed", is_constellation_active)
			get_viewport().set_input_as_handled()
			return
			
		# 3. Scholar Desk Click: Flare amber study lamp & rustle star map
		if RECT_DESK.has_point(pos):
			_desk_lamp_flare = 1.0
			for i in range(8):
				_celestial_motes.append({
					"x": randf_range(410, 440), "y": 62.0,
					"vx": randf_range(-15.0, 15.0), "vy": randf_range(-20.0, -8.0),
					"phase": randf_range(0, TAU), "life": randf_range(1.0, 1.8)
				})
			get_viewport().set_input_as_handled()
			return
			
		# 4. Reading Armchair Click: Cozy cushion fluff & floating zzz
		if RECT_ARMCHAIR.has_point(pos):
			for i in range(6):
				_celestial_motes.append({
					"x": randf_range(205, 235), "y": 70.0,
					"vx": randf_range(-8.0, 8.0), "vy": randf_range(-16.0, -6.0),
					"phase": randf_range(0, TAU), "life": randf_range(1.5, 2.5)
				})
			get_viewport().set_input_as_handled()
			return
			
		# 5. Tea Samovar Click: Fragrant herbal tea steam burst
		if RECT_SAMOVAR.has_point(pos):
			for i in range(8):
				_tea_steam.append({
					"x": randf_range(306, 316), "y": 70.0,
					"vx": randf_range(-12.0, 12.0), "vy": randf_range(-25.0, -12.0),
					"size": randf_range(3.0, 5.0), "alpha": 0.8, "life": randf_range(1.5, 2.5)
				})
			get_viewport().set_input_as_handled()
			return
			
		# 6. Balustrade Terrace Click: Trigger shooting star over Olympus!
		if RECT_BALUSTRADE.has_point(pos):
			_shooting_stars.append({
				"x": randf_range(580, 680), "y": 10.0,
				"vx": randf_range(-200.0, -300.0), "vy": randf_range(90.0, 150.0),
				"life": 1.4
			})
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 DRAWING PIPELINE (120+ SPRITES ARCHITECTURE)
# ==============================================================================
func _draw() -> void:
	_draw_parallax_background()
	_draw_temple_structure()
	_draw_floor()
	_draw_props()
	_draw_dynamic_particles()

# ------------------------------------------------------------------------------
# 1. PARALLAX BACKGROUND & COSMIC SKY
# ------------------------------------------------------------------------------
func _draw_parallax_background() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	# Full panoramic cosmic sky gradient (-120..880, -80..102)
	for y in range(-80, 102, 4):
		var lerp_val = clampf((float(y) + 80.0) / 182.0, 0.0, 1.0)
		draw_rect(Rect2(-120, y, 1000, 4), COL_SKY_TOP.lerp(COL_SKY_BOT, lerp_val))
		
	# Seamless Galaxy Vista tiled across the open observatory terrace (x = 340..880)
	var v_offset = cam_x * 0.12
	var start_vx = 340.0 - v_offset
	for i in range(3):
		var vx_pos = start_vx + float(i) * 380.0
		draw_texture_rect(TEX_VISTA_GALAXY, Rect2(vx_pos, 12.0, 380.0, 88.0), false)
		
	# Twinkling Constellation Stars with Parallax
	var p_offset = cam_x * 0.2
	for s in _stars:
		var sx = fmod(s["x"] - p_offset + 120.0, 1000.0) - 120.0
		var flicker = sin(_anim_clock * 1.6 + s["phase"]) * 0.4 + 0.6
		draw_rect(Rect2(sx, s["y"], s["size"], s["size"]), Color(0.95, 0.95, 1.0, 0.3 + 0.6 * flicker))
		
	# Constellation Overlay Lines when Telescope is active
	if is_constellation_active:
		var const_pts = [
			Vector2(420, 25), Vector2(450, 35), Vector2(480, 20),
			Vector2(510, 40), Vector2(550, 30), Vector2(580, 45)
		]
		for i in range(const_pts.size() - 1):
			draw_line(const_pts[i], const_pts[i+1], Color(0.7, 0.9, 1.0, 0.45), 1.2)
			draw_circle(const_pts[i], 2.0, Color(1.0, 1.0, 1.0, 0.8))
		draw_circle(const_pts[-1], 2.0, Color(1.0, 1.0, 1.0, 0.8))

# ------------------------------------------------------------------------------
# 2. TEMPLE WALLS, CEILING, COLUMNS & DRAPES (50+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_temple_structure() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var a_offset = cam_x * 0.25
	
	# A. Ceiling Cedar Rafter Beams with Iron Brackets (x = -120..880, y = -14..2) [22 sprites]
	for cx in range(-120, 880, 48):
		draw_texture_rect(TEX_CEILING, Rect2(cx, -14, 48, 16), false)
		draw_rect(Rect2(cx, 1, 48, 2), Color(0.06, 0.08, 0.12, 0.8))
		
	# B. Hanging Brass Astrolabe Star Lanterns [4 sprites]
	for lx in [80.0, 200.0, 330.0, 610.0]:
		var swing_offset = sin(_anim_clock * 1.5 + lx * 0.01) * 2.0 + _lantern_swing * 4.0
		draw_line(Vector2(lx, 2), Vector2(lx + swing_offset, 14), COL_BRASS_GOLD, 1.0)
		draw_texture_rect(TEX_HANGING_LANTERN, Rect2(lx + swing_offset - 9, 14, 18, 36), false)
		# Warm amber flame light glow
		var glow_r = 16.0 + sin(_anim_clock * 3.5 + lx) * 3.0
		draw_circle(Vector2(lx + swing_offset, 32), glow_r, Color(1.0, 0.75, 0.3, 0.14))
		
	# C. Interior Ashlar Library Wall (x = -120..360, y = 2..102) [36 sprites]
	for wx in range(-120, 360, 32):
		for wy in range(2, 102, 32):
			draw_texture_rect(TEX_WALL_STONE, Rect2(wx, wy, 32, 32), false)
			
	# D. Carved Brass Zodiac Wall Frieze along upper wall (x = -120..360, y = 2..18) [10 sprites]
	for fx in range(-120, 360, 48):
		draw_texture_rect(TEX_WALL_FRIEZE, Rect2(fx, 2, 48, 16), false)
		
	# Wall Shadow boundary separating library archive from open observatory
	draw_rect(Rect2(340, 2, 20, 100), Color(0.04, 0.05, 0.08, 0.6))
	
	# E. Framed Celestial Star Chart on wall (x = 165, y = 28)
	draw_texture_rect(TEX_STAR_CHART, Rect2(151, 26, 28, 32), false)
	
	# F. Brass Wall Sconces with Glowing Flames [3 sprites]
	for sc_x in [65.0, 275.0]:
		draw_texture_rect(TEX_WALL_SCONCE, Rect2(sc_x - 8, 48, 16, 34), false)
		var flame_glow = 12.0 + sin(_anim_clock * 4.0 + sc_x) * 2.5
		draw_circle(Vector2(sc_x, 52), flame_glow, Color(1.0, 0.65, 0.2, 0.22))
		draw_circle(Vector2(sc_x, 52), 2.5, Color(1.0, 0.95, 0.8, 0.85))
		
	# G. Fluted Classical Observatory Columns [5 sprites]
	for col_x in [40.0, 160.0, 340.0, 480.0, 640.0]:
		var cx = col_x - a_offset * 0.15
		draw_rect(Rect2(cx - 15, 6, 30, 96), Color(0.04, 0.05, 0.08, 0.35))
		draw_texture_rect(TEX_COLUMN, Rect2(cx - 13, 4, 26, 96), false)
		
	# H. Classical Marble and Brass Observatory Balustrade Railing (x = 520..740) [4 sprites]
	for bx in range(520, 740, 64):
		draw_texture_rect(TEX_BALUSTRADE, Rect2(bx, 74, 64, 28), false)

# ------------------------------------------------------------------------------
# 3. WALNUT PARQUET FLOOR & FOUNDATION (40+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_floor() -> void:
	# Tier 1: Polished Walnut Parquet Floor Tiles (x = -120..880, y = 102..120) [32 sprites]
	for tx in range(-120, 880, 32):
		draw_texture_rect(TEX_FLOOR, Rect2(tx, 102, 32, 18), false)
		
	# Tier 2: Stepped Foundation Edge Lip with Brass Inlay (x = -120..880, y = 120..144) [16 sprites]
	for lx in range(-120, 880, 64):
		draw_texture_rect(TEX_FLOOR_LIP, Rect2(lx, 120, 64, 24), false)
		
	# Tier 3: Sub-foundation bedrock plinth fill down to y = 240 (Zero black void on zoom-out)
	draw_rect(Rect2(-120, 144, 1000, 96), Color(0.07, 0.08, 0.11, 1.0))
	
	# Polished brass edge highlight line
	draw_line(Vector2(-120, 100), Vector2(880, 100), COL_BRASS_GOLD, 1.2)
	
	# Grand Navy Velvet Zodiac Astrolabe Rug under the armchair
	draw_texture_rect(TEX_ZODIAC_RUG, Rect2(176, 98, 88, 32), false)

# ------------------------------------------------------------------------------
# 4. LIVING FURNITURE & INTERACTIVE STATIONS (30+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_props() -> void:
	# 1. Grand Floor-to-Ceiling Walnut Bookshelves (x = 55..105, y = 104)
	draw_rect(Rect2(58, 102, 46, 3), Color(0.04, 0.05, 0.08, 0.5))
	draw_texture_rect(TEX_BOOKSHELF_TALL, Rect2(55, 36, 48, 68), false)
	
	# 2. Rolling Wooden Library Ladder leaning on bookshelf (x = 105, y = 104)
	draw_texture_rect(TEX_LIBRARY_LADDER, Rect2(98, 42, 20, 62), false)
	
	# 3. Low Bookshelf with stacks of scrolls & tomes (x = 125, y = 104)
	draw_rect(Rect2(123, 102, 42, 3), Color(0.04, 0.05, 0.08, 0.4))
	draw_texture_rect(TEX_BOOKCASE_LOW, Rect2(120, 58, 44, 46), false)
	draw_texture_rect(TEX_BOOK_STACKS, Rect2(164, 80, 38, 24), false)
	
	# 4. Plush Tufted Leather Reading Armchair (x = 220, y = 104)
	draw_rect(Rect2(199, 102, 42, 3), Color(0.04, 0.05, 0.08, 0.5))
	draw_texture_rect(TEX_READING_ARMCHAIR, Rect2(197, 54, 46, 50), false)
	
	# 5. Antique Brass Tea Samovar & Porcelain Cup (x = 310, y = 104)
	draw_rect(Rect2(301, 102, 18, 3), Color(0.04, 0.05, 0.08, 0.4))
	draw_texture_rect(TEX_TEA_SAMOVAR, Rect2(299, 68, 22, 36), false)
	
	# 6. Giant Interactive Spinning Celestial Globe (x = 355, y = 104)
	_draw_spinning_globe(355, 104)
	
	# 7. Scholar Study Desk with Star Map & Lamp (x = 420, y = 104)
	_draw_scholar_desk(420, 104)
	
	# 8. Classical Planetary Orrery Sphere on Pedestal (x = 515, y = 104)
	draw_rect(Rect2(506, 102, 18, 3), Color(0.04, 0.05, 0.08, 0.4))
	draw_texture_rect(TEX_ORRERY, Rect2(504, 66, 22, 38), false)
	# Orrery planetary orbit rotation
	var orb_angle = _anim_clock * 2.5
	var orb_x = 515.0 + cos(orb_angle) * 7.0
	var orb_y = 78.0 + sin(orb_angle) * 3.5
	draw_circle(Vector2(orb_x, orb_y), 1.5, Color(0.4, 0.8, 1.0, 0.85))
	
	# 9. Grand Brass Observatory Telescope pointed at cosmos (x = 590, y = 104)
	_draw_telescope(590, 104)

func _draw_spinning_globe(gx: float, gy: float) -> void:
	var gw = 48.0
	var gh = 54.0
	var x_pos = gx - gw / 2.0
	var y_pos = gy - gh + 2.0
	draw_rect(Rect2(x_pos + 6, gy - 2, gw - 12, 3), Color(0.04, 0.05, 0.08, 0.5))
	draw_texture_rect(TEX_CELESTIAL_GLOBE, Rect2(x_pos, y_pos, gw, gh), false)
	
	# Spinning constellation latitude / longitude line glow
	var g_center = Vector2(gx, gy - 32.0)
	var wobble = sin(_globe_angle) * 6.0
	draw_arc(g_center, 14.0, 0, TAU, 16, Color(COL_BRASS_GOLD.r, COL_BRASS_GOLD.g, COL_BRASS_GOLD.b, 0.25), 1.0)
	draw_line(Vector2(gx + wobble, gy - 45), Vector2(gx - wobble, gy - 19), Color(0.95, 0.85, 0.4, 0.35), 1.0)

func _draw_scholar_desk(dx: float, dy: float) -> void:
	var dw = 80.0
	var dh = 44.0
	var x_pos = dx - dw / 2.0
	var y_pos = dy - dh + 2.0
	draw_rect(Rect2(x_pos + 6, dy - 2, dw - 12, 3), Color(0.04, 0.05, 0.08, 0.5))
	draw_texture_rect(TEX_SCHOLAR_DESK, Rect2(x_pos, y_pos, dw, dh), false)
	
	# Study Lamp Glow & Flare
	var lamp_x = dx + 26.0
	var lamp_y = dy - 38.0
	var flare = 1.0 + _desk_lamp_flare * 0.8
	var flicker = sin(_anim_clock * 4.5) * 1.5
	draw_circle(Vector2(lamp_x, lamp_y + flicker), 16.0 * flare, Color(1.0, 0.75, 0.3, 0.16))
	draw_circle(Vector2(lamp_x, lamp_y + flicker), 3.0, Color(1.0, 0.95, 0.85, 0.9))

func _draw_telescope(tx: float, ty: float) -> void:
	var tw = 58.0
	var th = 56.0
	var x_pos = tx - tw / 2.0
	var y_pos = ty - th + 2.0
	draw_rect(Rect2(x_pos + 8, ty - 2, tw - 16, 3), Color(0.04, 0.05, 0.08, 0.5))
	draw_texture_rect(TEX_TELESCOPE, Rect2(x_pos, y_pos, tw, th), false)
	
	# Lens gleam
	var gleam = sin(_anim_clock * 3.0) * 0.25 + 0.75
	draw_circle(Vector2(tx + 22, ty - 46), 2.0, Color(0.7, 0.9, 1.0, gleam))

# ------------------------------------------------------------------------------
# 5. DYNAMIC PARTICLE SYSTEMS (30+ ELEMENTS)
# ------------------------------------------------------------------------------
func _draw_dynamic_particles() -> void:
	# A. Floating Golden Celestial Dust Motes
	for m in _celestial_motes:
		var alpha = sin(_anim_clock * 2.0 + m["phase"]) * 0.3 + 0.55
		draw_circle(Vector2(m["x"], m["y"]), 1.4, Color(1.0, 0.88, 0.5, alpha))
		draw_circle(Vector2(m["x"], m["y"]), 0.7, Color(1.0, 1.0, 1.0, alpha))
		
	# B. Tea Steam Wisps
	for st in _tea_steam:
		var alpha = clampf(st["life"] / 2.0, 0.0, 1.0) * st["alpha"]
		draw_circle(Vector2(st["x"], st["y"]), st["size"], Color(0.95, 0.92, 0.85, alpha * 0.35))
		
	# C. Streaking Cosmic Shooting Stars
	for ss in _shooting_stars:
		var alpha = clampf(ss["life"], 0.0, 1.0)
		var p1 = Vector2(ss["x"], ss["y"])
		var p2 = Vector2(ss["x"] - ss["vx"] * 0.08, ss["y"] - ss["vy"] * 0.08)
		draw_line(p1, p2, Color(1.0, 0.95, 0.85, alpha), 1.6)
		draw_circle(p1, 2.2, Color(1.0, 0.8, 0.4, alpha))
