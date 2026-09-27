@tool
extends BaseRoom
class_name LivingRoom

## Hearth of Hestia - Ultra-Detailed Mythological Sanctuary (720px wide).
## Features over 120+ active sprites & decor elements, authentic 16-bit Stardew-grade details,
## animated wildlife, hanging chandeliers, silk drapes, incense, and dynamic interactables.

# ==============================================================================
# 🎨 COLOR PALETTES
# ==============================================================================
const COL_SKY_TOP: Color = Color(0.12, 0.08, 0.15, 1.0)
const COL_SKY_BOT: Color = Color(0.85, 0.35, 0.20, 1.0)
const COL_ASH: Color = Color(0.15, 0.12, 0.14, 1.0)
const COL_SCROLL: Color = Color(0.90, 0.85, 0.75, 1.0)
const COL_WATER: Color = Color(0.40, 0.80, 0.95, 0.8)

const FIRE_PALETTES = [
	{ "core": Color(1.0, 0.90, 0.40, 1.0), "mid": Color(1.0, 0.55, 0.15, 1.0), "edge": Color(0.85, 0.20, 0.10, 1.0) },
	{ "core": Color(0.70, 1.0, 0.40, 1.0), "mid": Color(0.20, 0.85, 0.30, 1.0), "edge": Color(0.10, 0.50, 0.20, 1.0) },
	{ "core": Color(0.90, 0.70, 1.0, 1.0), "mid": Color(0.60, 0.30, 0.90, 1.0), "edge": Color(0.30, 0.10, 0.60, 1.0) },
	{ "core": Color(0.60, 0.90, 1.0, 1.0), "mid": Color(0.20, 0.55, 1.0, 1.0), "edge": Color(0.10, 0.20, 0.80, 1.0) }
]

# ==============================================================================
# 📦 16-BIT HANDCRAFTED SPRITE ASSET SUITE
# ==============================================================================
# Core Architectural Foundations
const TEX_HEARTH: Texture2D = preload("res://assets/sprites/rooms/livingroom/hearth.png")
const TEX_COUCH: Texture2D = preload("res://assets/sprites/rooms/livingroom/couch.png")
const TEX_TABLE: Texture2D = preload("res://assets/sprites/rooms/livingroom/table.png")
const TEX_AMPHORA: Texture2D = preload("res://assets/sprites/rooms/livingroom/amphora.png")
const TEX_COLUMN: Texture2D = preload("res://assets/sprites/rooms/livingroom/column.png")
const TEX_FLOOR: Texture2D = preload("res://assets/sprites/rooms/livingroom/floor_tile.png")
const TEX_FLOOR_LIP: Texture2D = preload("res://assets/sprites/rooms/livingroom/floor_lip.png")
const TEX_WALL_STONE: Texture2D = preload("res://assets/sprites/rooms/livingroom/wall_stone.png")
const TEX_WALL_FRIEZE: Texture2D = preload("res://assets/sprites/rooms/livingroom/wall_frieze.png")
const TEX_VISTA: Texture2D = preload("res://assets/sprites/rooms/livingroom/vista_olympus.png")
const TEX_CEILING: Texture2D = preload("res://assets/sprites/rooms/livingroom/ceiling_tile.png")
const TEX_PILLAR_PEDESTAL: Texture2D = preload("res://assets/sprites/rooms/livingroom/pillar_pedestal.png")

# Expansion Furniture & Props
const TEX_LYRE: Texture2D = preload("res://assets/sprites/rooms/livingroom/lyre.png")
const TEX_BRAZIER: Texture2D = preload("res://assets/sprites/rooms/livingroom/brazier.png")
const TEX_CORNUCOPIA: Texture2D = preload("res://assets/sprites/rooms/livingroom/cornucopia.png")
const TEX_RUG: Texture2D = preload("res://assets/sprites/rooms/livingroom/rug.png")
const TEX_OLIVE_PLANTER: Texture2D = preload("res://assets/sprites/rooms/livingroom/olive_planter.png")
const TEX_SHIELD: Texture2D = preload("res://assets/sprites/rooms/livingroom/shield.png")
const TEX_SCROLL_SHELF: Texture2D = preload("res://assets/sprites/rooms/livingroom/scroll_shelf.png")
const TEX_SCONCES: Texture2D = preload("res://assets/sprites/rooms/livingroom/sconces.png")

# 12 New Temple Decor & Wildlife Sprites
const TEX_CHANDELIER: Texture2D = preload("res://assets/sprites/rooms/livingroom/chandelier.png")
const TEX_HANGING_HERBS: Texture2D = preload("res://assets/sprites/rooms/livingroom/hanging_herbs.png")
const TEX_FIREWOOD: Texture2D = preload("res://assets/sprites/rooms/livingroom/firewood.png")
const TEX_TAPESTRY: Texture2D = preload("res://assets/sprites/rooms/livingroom/tapestry.png")
const TEX_COLUMN_DRAPES: Texture2D = preload("res://assets/sprites/rooms/livingroom/column_drapes.png")
const TEX_FLOOR_AMPHORA: Texture2D = preload("res://assets/sprites/rooms/livingroom/floor_amphora.png")
const TEX_THURIBLE: Texture2D = preload("res://assets/sprites/rooms/livingroom/thurible.png")
const TEX_MOSAIC: Texture2D = preload("res://assets/sprites/rooms/livingroom/mosaic_medallion.png")
const TEX_IVY: Texture2D = preload("res://assets/sprites/rooms/livingroom/ivy_vines.png")
const TEX_DOVE: Texture2D = preload("res://assets/sprites/rooms/livingroom/white_dove.png")
const TEX_BUST: Texture2D = preload("res://assets/sprites/rooms/livingroom/marble_bust.png")
const TEX_FOOD_PLATTER: Texture2D = preload("res://assets/sprites/rooms/livingroom/food_platter.png")

# Garden & Mystical Plants
const TEX_FLOWER_ROSE: Texture2D = preload("res://assets/sprites/plants/flower_rose.png")
const TEX_FLOWER_BLUEBELL: Texture2D = preload("res://assets/sprites/plants/flower_bluebell.png")
const TEX_POT_GLOW: Texture2D = preload("res://assets/sprites/plants/pot_glow.png")

# Bespoke Animated Pet-Furniture Interactions
const TEX_SHIBA_TABLE_0: Texture2D = preload("res://assets/sprites/rooms/livingroom/interactions/shiba_table_0.png")
const TEX_SHIBA_TABLE_1: Texture2D = preload("res://assets/sprites/rooms/livingroom/interactions/shiba_table_1.png")
const TEX_SHIBA_TABLE_2: Texture2D = preload("res://assets/sprites/rooms/livingroom/interactions/shiba_table_2.png")
const TEX_SHIBA_TABLE_3: Texture2D = preload("res://assets/sprites/rooms/livingroom/interactions/shiba_table_3.png")

var shiba_table_frames: Array[Texture2D] = [
	TEX_SHIBA_TABLE_0,
	TEX_SHIBA_TABLE_1,
	TEX_SHIBA_TABLE_2,
	TEX_SHIBA_TABLE_3
]

var is_shiba_feasting: bool = true
var table_feast_frame: int = 0
var table_feast_timer: float = 0.0

# ==============================================================================
# 📊 INTERNAL STATE & ANIMATION SYSTEMS
# ==============================================================================
var _anim_clock: float = 0.0
var _sparks: Array[Dictionary] = []
var _water_drops: Array[Dictionary] = []
var _music_notes: Array[Dictionary] = []
var _bouncing_fruits: Array[Dictionary] = []
var _incense_smoke: Array[Dictionary] = []
var _food_steam: Array[Dictionary] = []
var _sun_motes: Array[Dictionary] = []
var _dove_hearts: Array[Dictionary] = []

var _brazier_flare: float = 0.0
var _hearth_flare: float = 0.0
var _chandelier_swing: float = 0.0

var is_hearth_lit: bool = true

var cur_fire_core: Color = FIRE_PALETTES[0].core
var cur_fire_mid: Color = FIRE_PALETTES[0].mid
var cur_fire_edge: Color = FIRE_PALETTES[0].edge
var target_fire_idx: int = 0

var ember_x: float = 360.0
var ember_y: float = 80.0
var ember_base_x: float = 360.0
var ember_base_y: float = 80.0
var ember_phase: float = 0.0

# Mouse Interaction Hitboxes
const RECT_HEARTH: Rect2 = Rect2(126, 38, 68, 68)
const RECT_FIREWOOD: Rect2 = Rect2(104, 72, 28, 32)
const RECT_AMPHORA: Rect2 = Rect2(426, 40, 20, 26)
const RECT_CORNUCOPIA: Rect2 = Rect2(446, 40, 28, 26)
const RECT_FOOD_PLATTER: Rect2 = Rect2(396, 46, 28, 20)
const RECT_TABLE: Rect2 = Rect2(386, 50, 92, 58)
const RECT_LYRE: Rect2 = Rect2(504, 56, 22, 50)
const RECT_THURIBLE: Rect2 = Rect2(544, 74, 22, 30)
const RECT_BRAZIER: Rect2 = Rect2(635, 64, 30, 42)
const RECT_DOVE_TERRACE: Rect2 = Rect2(608, 66, 22, 20)
const RECT_CHANDELIER_MID: Rect2 = Rect2(165, 6, 20, 40)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_livingroom"
	room_name = "Hearth of Hestia"
	room_width = 720.0
	min_x = 120.0
	max_x = 680.0
	floor_y = 102.0
	desk_x = 430.0 # Feasting table
	nap_x = 242.0  # Plush daybed cushion
	drink_x = 436.0 # Amphora on table
	
	if GameState:
		is_hearth_lit = GameState.get_object_state("hestia_hearth_lit", true)
		
	# Seed initial embers and sunbeam dust motes
	for i in range(25):
		_spawn_spark(true)
	for i in range(12):
		_spawn_sun_mote(true)

func _spawn_spark(random_y: bool = false) -> void:
	_sparks.append({
		"x": randf_range(130, 230),
		"y": randf_range(0, 140) if random_y else randf_range(90, 108),
		"vx": randf_range(-15.0, 25.0),
		"vy": randf_range(-15.0, -40.0),
		"life": randf_range(0.6, 1.4)
	})

func _spawn_sun_mote(random_pos: bool = false) -> void:
	_sun_motes.append({
		"x": randf_range(350, 720) if random_pos else randf_range(360, 400),
		"y": randf_range(20, 95) if random_pos else randf_range(20, 40),
		"vx": randf_range(4.0, 12.0),
		"vy": randf_range(-3.0, 6.0),
		"phase": randf_range(0, TAU),
		"life": randf_range(3.0, 7.0)
	})

func _process(delta: float) -> void:
	_anim_clock += delta * 2.0
	var tp = FIRE_PALETTES[target_fire_idx]
	cur_fire_core = cur_fire_core.lerp(tp.core, delta * 3.0)
	cur_fire_mid = cur_fire_mid.lerp(tp.mid, delta * 3.0)
	cur_fire_edge = cur_fire_edge.lerp(tp.edge, delta * 3.0)
	
	_brazier_flare = maxf(0.0, _brazier_flare - delta * 1.5)
	_hearth_flare = maxf(0.0, _hearth_flare - delta * 1.8)
	_chandelier_swing = lerpf(_chandelier_swing, 0.0, delta * 2.0)
	
	# Bespoke Pet-Furniture Interaction Animation (Shiba Feasting at Banquet Table)
	if is_shiba_feasting and shiba_table_frames.size() > 0:
		table_feast_timer += delta
		if table_feast_timer >= 0.24:
			table_feast_timer -= 0.24
			table_feast_frame = (table_feast_frame + 1) % shiba_table_frames.size()
	
	# Ambient Food Steam & Incense Emission
	if randf() < delta * 2.5:
		_incense_smoke.append({
			"x": randf_range(552, 558), "y": 78.0,
			"vx": randf_range(-4.0, 6.0), "vy": randf_range(-12.0, -22.0),
			"size": randf_range(2.0, 4.0), "alpha": 0.65, "life": randf_range(1.5, 2.5)
		})
	if randf() < delta * 2.0:
		_food_steam.append({
			"x": randf_range(412, 422), "y": 50.0,
			"vx": randf_range(-3.0, 5.0), "vy": randf_range(-10.0, -18.0),
			"size": randf_range(1.5, 3.0), "alpha": 0.45, "life": randf_range(1.2, 2.0)
		})
	if _sun_motes.size() < 12 and randf() < delta * 3.0:
		_spawn_sun_mote(false)
		
	# Update Particle Systems
	if is_hearth_lit:
		for i in range(_sparks.size() - 1, -1, -1):
			var s = _sparks[i]
			s["x"] += (s["vx"] + sin(_anim_clock * 3.0 + s["y"]) * 4.0) * delta
			s["y"] += s["vy"] * delta
			s["life"] -= delta * 0.5
			if s["life"] <= 0:
				s["y"] = randf_range(98, 104)
				s["x"] = randf_range(150, 170)
				s["vx"] = randf_range(-15.0, 15.0)
				s["vy"] = randf_range(-20.0, -50.0)
				s["life"] = randf_range(0.5, 1.5)
				
		ember_phase += delta
		var orbit_r = 50.0 + sin(ember_phase * 0.5) * 30.0
		ember_base_x = 200.0 + sin(ember_phase * 0.8) * orbit_r
		ember_base_y = 70.0 + cos(ember_phase * 1.2) * (orbit_r * 0.5)
		ember_x = lerpf(ember_x, ember_base_x, delta * 4.0)
		ember_y = lerpf(ember_y, ember_base_y, delta * 4.0)
		
	for i in range(_water_drops.size() - 1, -1, -1):
		var d = _water_drops[i]
		d["vy"] += 200.0 * delta
		d["x"] += d["vx"] * delta
		d["y"] += d["vy"] * delta
		if d["y"] > 68.0: _water_drops.remove_at(i)
			
	for i in range(_music_notes.size() - 1, -1, -1):
		var n = _music_notes[i]
		n["phase"] += delta * 4.0
		n["y"] -= 32.0 * delta
		n["x"] += sin(n["phase"]) * 14.0 * delta
		n["life"] -= delta * 0.65
		if n["life"] <= 0: _music_notes.remove_at(i)
			
	for i in range(_bouncing_fruits.size() - 1, -1, -1):
		var f = _bouncing_fruits[i]
		f["vy"] += 300.0 * delta
		f["x"] += f["vx"] * delta
		f["y"] += f["vy"] * delta
		if f["y"] >= 67.0 and f["vy"] > 0:
			f["vy"] = -f["vy"] * 0.55
			f["vx"] *= 0.75
			f["bounces"] += 1
			if f["bounces"] > 4: _bouncing_fruits.remove_at(i)

	for i in range(_incense_smoke.size() - 1, -1, -1):
		var sm = _incense_smoke[i]
		sm["x"] += (sm["vx"] + sin(_anim_clock * 2.0 + sm["y"]) * 6.0) * delta
		sm["y"] += sm["vy"] * delta
		sm["size"] += delta * 2.0
		sm["life"] -= delta
		if sm["life"] <= 0: _incense_smoke.remove_at(i)

	for i in range(_food_steam.size() - 1, -1, -1):
		var st = _food_steam[i]
		st["x"] += (st["vx"] + sin(_anim_clock * 3.0 + st["y"]) * 4.0) * delta
		st["y"] += st["vy"] * delta
		st["size"] += delta * 1.5
		st["life"] -= delta
		if st["life"] <= 0: _food_steam.remove_at(i)

	for i in range(_sun_motes.size() - 1, -1, -1):
		var m = _sun_motes[i]
		m["phase"] += delta * 2.0
		m["x"] += (m["vx"] + sin(m["phase"]) * 3.0) * delta
		m["y"] += (m["vy"] + cos(m["phase"]) * 3.0) * delta
		m["life"] -= delta
		if m["life"] <= 0 or m["x"] > 740.0: _sun_motes.remove_at(i)

	for i in range(_dove_hearts.size() - 1, -1, -1):
		var h = _dove_hearts[i]
		h["y"] -= 20.0 * delta
		h["x"] += sin(_anim_clock * 4.0) * 8.0 * delta
		h["life"] -= delta * 0.8
		if h["life"] <= 0: _dove_hearts.remove_at(i)
			
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
		var pos: Vector2 = mb.position + Vector2(cam_x, 0)
		
		# 1. Hearth Click: Cycle sacred fire colors + spark burst
		if RECT_HEARTH.has_point(pos):
			if is_hearth_lit:
				target_fire_idx = (target_fire_idx + 1) % FIRE_PALETTES.size()
				for i in range(16):
					_sparks.append({
						"x": ember_x, "y": ember_y,
						"vx": randf_range(-40.0, 40.0), "vy": randf_range(-60.0, -10.0),
						"life": randf_range(1.0, 2.0)
					})
			else:
				is_hearth_lit = true
				if EventBus: EventBus.object_state_changed.emit("hearth_toggled", is_hearth_lit)
			get_viewport().set_input_as_handled()
			return

		# 2. Firewood Rack Click: Toss fresh birch log into hearth!
		if RECT_FIREWOOD.has_point(pos):
			_hearth_flare = 1.0
			is_hearth_lit = true
			for i in range(18):
				_sparks.append({
					"x": randf_range(150, 170), "y": 96.0,
					"vx": randf_range(-35.0, 35.0), "vy": randf_range(-80.0, -25.0),
					"life": randf_range(0.8, 1.8)
				})
			get_viewport().set_input_as_handled()
			return
			
		# 3. Amphora Click: Spray fountain water drops
		if RECT_AMPHORA.has_point(pos):
			for i in range(14):
				_water_drops.append({
					"x": randf_range(434, 442), "y": 44.0,
					"vx": randf_range(-25.0, 25.0), "vy": randf_range(-60.0, -15.0)
				})
			get_viewport().set_input_as_handled()
			return
			
		# 4. Cornucopia Click: Bounce grapes and figs
		if RECT_CORNUCOPIA.has_point(pos):
			for i in range(5):
				_bouncing_fruits.append({
					"x": randf_range(450, 465), "y": 48.0,
					"vx": randf_range(-45.0, 45.0), "vy": randf_range(-90.0, -40.0),
					"color": Color(0.65, 0.22, 0.65) if randf() < 0.6 else Color(0.95, 0.75, 0.2),
					"bounces": 0
				})
			get_viewport().set_input_as_handled()
			return

		# 5. Banquet Table & Food Platter Click: Toggle Shiba Feast & emit steam burst!
		if RECT_FOOD_PLATTER.has_point(pos) or RECT_TABLE.has_point(pos):
			is_shiba_feasting = !is_shiba_feasting
			for i in range(8):
				_food_steam.append({
					"x": randf_range(404, 430), "y": 50.0,
					"vx": randf_range(-12.0, 12.0), "vy": randf_range(-25.0, -12.0),
					"size": randf_range(3.0, 5.0), "alpha": 0.8, "life": randf_range(1.5, 2.5)
				})
			get_viewport().set_input_as_handled()
			return

		# 6. Lyre Click: Pluck golden musical chords
		if RECT_LYRE.has_point(pos):
			var symbols = ["♪", "♫", "♬", "♩"]
			for i in range(5):
				_music_notes.append({
					"x": randf_range(504, 522), "y": 65.0 - float(i) * 6.0,
					"phase": randf_range(0, TAU), "symbol": symbols[i % symbols.size()],
					"life": randf_range(1.2, 1.8)
				})
			get_viewport().set_input_as_handled()
			return

		# 7. Incense Thurible Click: Release wave of fragrant purple smoke
		if RECT_THURIBLE.has_point(pos):
			for i in range(8):
				_incense_smoke.append({
					"x": randf_range(550, 560), "y": 78.0,
					"vx": randf_range(-15.0, 15.0), "vy": randf_range(-30.0, -15.0),
					"size": randf_range(4.0, 7.0), "alpha": 0.85, "life": randf_range(2.0, 3.2)
				})
			get_viewport().set_input_as_handled()
			return
			
		# 8. Brazier Click: Flare divine flame + radial sparks
		if RECT_BRAZIER.has_point(pos):
			_brazier_flare = 1.0
			for i in range(22):
				var angle = randf_range(0, TAU)
				var spd = randf_range(25.0, 75.0)
				_sparks.append({
					"x": 650.0, "y": 78.0,
					"vx": cos(angle) * spd, "vy": sin(angle) * spd - 30.0,
					"life": randf_range(0.8, 1.6)
				})
			get_viewport().set_input_as_handled()
			return

		# 9. Dove Click: Coo chirp with floating hearts
		if RECT_DOVE_TERRACE.has_point(pos):
			for i in range(4):
				_dove_hearts.append({
					"x": randf_range(614, 624), "y": 68.0,
					"life": randf_range(1.2, 1.8)
				})
			get_viewport().set_input_as_handled()
			return

		# 10. Chandelier Click: Swing impulse & spark glow
		if RECT_CHANDELIER_MID.has_point(pos):
			_chandelier_swing = 1.0
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
	_draw_hestias_ember()

# ------------------------------------------------------------------------------
# 1. PARALLAX BACKGROUND & SUNSET SKY
# ------------------------------------------------------------------------------
func _draw_parallax_background() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	# Full panoramic sky gradient (-120..880, -80..102)
	for y in range(-80, 102, 4):
		var lerp_val = clampf((float(y) + 80.0) / 182.0, 0.0, 1.0)
		draw_rect(Rect2(-120, y, 1000, 4), COL_SKY_TOP.lerp(COL_SKY_BOT, lerp_val))
		
	# Seamless Mount Olympus Vista tiled across the open terrace (x = 320..880)
	var v_offset = cam_x * 0.12
	var start_vx = 320.0 - v_offset
	for i in range(3):
		var vx_pos = start_vx + float(i) * 380.0
		draw_texture_rect(TEX_VISTA, Rect2(vx_pos, 12.0, 380.0, 88.0), false)
	
	# Sunset god rays from Mount Olympus
	var sun_cx = 540.0 - cam_x * 0.06
	var sun_cy = 70.0
	for r in range(5):
		var angle = (r * PI / 4.5) + _anim_clock * 0.04
		var r_alpha = 0.12 + sin(_anim_clock + r) * 0.04
		var pts = PackedVector2Array([
			Vector2(sun_cx, sun_cy),
			Vector2(sun_cx + 700 * cos(angle - 0.12), sun_cy - 700 * sin(angle - 0.12)),
			Vector2(sun_cx + 700 * cos(angle + 0.12), sun_cy - 700 * sin(angle + 0.12))
		])
		draw_colored_polygon(pts, Color(1.0, 0.88, 0.65, r_alpha))

# ------------------------------------------------------------------------------
# 2. TEMPLE WALLS, CEILING, COLUMNS & DRAPES (50+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_temple_structure() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var a_offset = cam_x * 0.25
	
	# A. Upper Solid Cedar Wood Backing & Coffered Ceiling Tiles (x = -120..340, y = -80..16)
	draw_rect(Rect2(-120, -80, 460, 96), Color(0.20, 0.12, 0.08, 1.0))
	for cx in range(-120, 340, 32):
		for cy in range(-80, 16, 32):
			draw_texture_rect(TEX_CEILING, Rect2(cx, cy, 32, 32), false)
			
	# B. Seamless Greek Ashlar Stone Wall Tiles (x = -120..340, y = 16..100)
	for wx in range(-120, 340, 32):
		for wy in range(16, 96, 32):
			draw_texture_rect(TEX_WALL_STONE, Rect2(wx, wy, 32, 32), false)
			
	# Baseboard drop shadow under indoor wall
	draw_rect(Rect2(-120, 97, 460, 5), Color(0.08, 0.06, 0.08, 0.45))
	
	# C. Carved Doric Frieze Architrave along ceiling (x = -120..880, y = 0..20)
	for fx in range(-120, 880, 260):
		draw_texture_rect(TEX_WALL_FRIEZE, Rect2(fx, 0, 260, 20), false)
		
	# D. Terrace Marble Balustrade Railing (x = 340..880, y = 86..100)
	draw_rect(Rect2(340, 86, 540, 14), Color(0.86, 0.83, 0.80, 1.0))
	draw_rect(Rect2(340, 86, 540, 3), Color(0.96, 0.94, 0.90, 1.0))
	draw_rect(Rect2(340, 97, 540, 3), Color(0.68, 0.64, 0.60, 1.0))

	# E. Terrace Frieze Hanging Climbing Ivy Garlands (4 clusters)
	for iv_x in [390.0, 500.0, 610.0, 680.0]:
		var x = iv_x - a_offset
		draw_texture_rect(TEX_IVY, Rect2(x, 16, 26, 26), false)

	# F. Fluted Doric Marble Columns & Column Silk Drapes
	for col_x in [370.0, 480.0, 590.0]:
		var x = col_x - a_offset
		# Column Shaft
		draw_texture_rect(TEX_COLUMN, Rect2(x, 16, 28, 88), false)
		# Flowing Silk Column Drape (Billowing in breeze)
		var drape_sway = sin(_anim_clock * 2.5 + col_x) * 1.5
		draw_texture_rect(TEX_COLUMN_DRAPES, Rect2(x - 2 + drape_sway, 36, 20, 60), false)
		# Climbing Green Ivy Vines along column base and shaft
		draw_texture_rect(TEX_IVY, Rect2(x + 4, 72, 22, 22), false)
		draw_texture_rect(TEX_IVY, Rect2(x + 2, 44, 20, 20), false)
		
	# G. Terrace Pedestals & Classical Statuary
	draw_texture_rect(TEX_PILLAR_PEDESTAL, Rect2(345, 36, 28, 68), false)
	draw_texture_rect(TEX_PILLAR_PEDESTAL, Rect2(706, 36, 28, 68), false)
	# Classical Marble Bust on Eastern Terrace Pedestal
	draw_texture_rect(TEX_BUST, Rect2(711, 14, 18, 38), false)
	
	# H. White Temple Doves Perched (Animated wing rustle & breathing)
	var dove_bob = sin(_anim_clock * 3.0) * 0.8
	# Dove 1: Perched on Middle Column Capital
	draw_texture_rect(TEX_DOVE, Rect2(484 - a_offset, 6 + dove_bob, 20, 18), false)
	# Dove 2: Perched on Terrace Marble Balustrade Railing
	draw_texture_rect(TEX_DOVE, Rect2(610 - a_offset, 72 + dove_bob, 20, 18), false)

	# I. Indoor Wall Tapestry Banners (Crimson & Gold with Greek meanders)
	draw_texture_rect(TEX_TAPESTRY, Rect2(38, 32, 28, 42), false)
	draw_texture_rect(TEX_TAPESTRY, Rect2(248, 32, 28, 42), false)

	# J. Wall Trophies, Shelves & Sculptures
	draw_texture_rect(TEX_SHIELD, Rect2(82, 36, 34, 36), false)
	draw_texture_rect(TEX_SCROLL_SHELF, Rect2(310, 42, 36, 30), false)
	# Classical Marble Bust mounted on wall corbel above hearth mantle
	draw_texture_rect(TEX_BUST, Rect2(151, 12, 18, 38), false)

	# K. 4 Brass Wall Sconces with Animated Flickering Flames
	var flame_bob = sin(_anim_clock * 6.0) * 1.5
	for sc_x in [18.0, 122.0, 198.0, 282.0]:
		draw_texture_rect(TEX_SCONCES, Rect2(sc_x, 48, 18, 24), false)
		draw_circle(Vector2(sc_x + 9, 46 + flame_bob), 2.5, Color(1.0, 0.85, 0.3, 0.9))

	# L. Ceiling Hanging Bronze Chain Chandeliers (Swaying with flame orbs)
	var chan_sway = sin(_anim_clock * 2.0) * 1.5 + _chandelier_swing * 4.0
	for ch_x in [65.0, 175.0, 285.0]:
		var swing_offset = (ch_x - 175.0) * 0.01 * chan_sway
		draw_texture_rect(TEX_CHANDELIER, Rect2(ch_x + swing_offset, 4, 20, 40), false)
		# Chandelier Glowing Oil Flame
		draw_circle(Vector2(ch_x + 10 + swing_offset, 34), 3.0, Color(1.0, 0.88, 0.35, 0.95))
		draw_circle(Vector2(ch_x + 10 + swing_offset, 34), 8.0, Color(1.0, 0.70, 0.20, 0.25))

	# M. Ceiling Hanging Dried Herb & Laurel Bundles (Swaying gently)
	for hb_idx in range(6):
		var hb_x = 24.0 + float(hb_idx) * 54.0
		var h_sway = sin(_anim_clock * 2.2 + float(hb_idx)) * 1.0
		draw_texture_rect(TEX_HANGING_HERBS, Rect2(hb_x + h_sway, 12, 24, 26), false)

# ------------------------------------------------------------------------------
# 3. FLOOR SLABS, MOSAICS & STEPPED FOUNDATION (40+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_floor() -> void:
	# Tier 0A: Circular Sunburst Greek Marble Mosaic Medallion embedded in floor
	draw_texture_rect(TEX_MOSAIC, Rect2(242, 92, 38, 38), false)

	# Tier 0B: Hellenic Crimson & Gold Wool Rug under couch & hearth
	draw_texture_rect(TEX_RUG, Rect2(195, 84, 96, 44), false)
	
	# Tier 1: Seamless Grecian Marble Floor Slabs (x = -120..880, y = 100..120)
	for tx in range(-120, 880, 32):
		draw_texture_rect(TEX_FLOOR, Rect2(tx, 100, 32, 20), false)
		
	# Tier 2: Stepped Foundation Front Lip with Dentils (x = -120..880, y = 120..144)
	for lx in range(-120, 880, 64):
		draw_texture_rect(TEX_FLOOR_LIP, Rect2(lx, 120, 64, 24), false)
		
	# Tier 3: Sub-foundation bedrock plinth fill down to y = 240 (Zero black void on zoom-out)
	draw_rect(Rect2(-120, 144, 1000, 96), Color(0.18, 0.16, 0.18, 1.0))
	
	# Polished marble edge highlight line
	draw_line(Vector2(-120, 100), Vector2(880, 100), Color(0.96, 0.94, 0.90), 1.2)

	# Scattered Flower Petals and Laurel Leaves on Marble Steps
	var leaf_pts = [
		Vector2(110, 106), Vector2(175, 108), Vector2(285, 106),
		Vector2(365, 107), Vector2(495, 106), Vector2(630, 108), Vector2(675, 106)
	]
	for lp in leaf_pts:
		draw_circle(lp, 1.5, Color(0.85, 0.35, 0.40, 0.75) if lp.x < 300 else Color(0.40, 0.65, 0.35, 0.8))
	
	# Dynamic Warm Ambient Firelight Glow
	if is_hearth_lit:
		var flicker = sin(_anim_clock * 3.0) * 0.1 + 0.9 + _hearth_flare * 0.5
		draw_circle(Vector2(160, 104), 170.0, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, 0.08 * flicker))
		draw_circle(Vector2(160, 104), 85.0, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, 0.16 * flicker))

# ------------------------------------------------------------------------------
# 4. LIVING FURNITURE & PROPS (35+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_props() -> void:
	# 1. Firewood Log Rack with stacked birch logs
	draw_rect(Rect2(106, 102, 24, 3), Color(0.08, 0.08, 0.12, 0.4))
	draw_texture_rect(TEX_FIREWOOD, Rect2(104, 72, 28, 32), false)

	# 2. Embroidered Floor Hearth Cushion (Cozy sitting spot for pets)
	draw_rect(Rect2(128, 96, 18, 8), Color(0.65, 0.18, 0.22, 1.0))
	draw_rect(Rect2(129, 97, 16, 6), Color(0.85, 0.70, 0.30, 0.9))

	# 3. Monumental Ashlar Hearth
	_draw_massive_hearth(160, 104)

	# 4. Lounging Daybed Couch (Klinē)
	_draw_lounging_couch(245, 104)

	# 5. Study Piles of Papyrus Scrolls & Leather Tomes on floor
	draw_rect(Rect2(310, 96, 12, 4), Color(0.88, 0.82, 0.70, 1.0))
	draw_rect(Rect2(314, 92, 10, 4), Color(0.55, 0.30, 0.20, 1.0))
	draw_rect(Rect2(311, 88, 12, 4), Color(0.92, 0.86, 0.74, 1.0))

	# 6. Athena's Sacred Olive Tree in Terracotta Urn
	_draw_potted_olive(336, 104)

	# 7. Garden Urns & Mystical Glowing Pots
	draw_texture_rect(TEX_POT_GLOW, Rect2(296, 82, 20, 20), false)
	draw_texture_rect(TEX_FLOWER_ROSE, Rect2(352, 74, 22, 28), false)
	draw_texture_rect(TEX_FLOWER_BLUEBELL, Rect2(676, 74, 22, 28), false)

	# 8. Large Terracotta Floor Amphorae with Scroll Handles
	draw_rect(Rect2(386, 102, 18, 3), Color(0.08, 0.08, 0.12, 0.4))
	draw_texture_rect(TEX_FLOOR_AMPHORA, Rect2(384, 72, 24, 32), false)
	draw_rect(Rect2(476, 102, 18, 3), Color(0.08, 0.08, 0.12, 0.4))
	draw_texture_rect(TEX_FLOOR_AMPHORA, Rect2(474, 72, 24, 32), false)

	# 9. Feasting Banquet Table (Trapeza) & Tabletop Delicacies
	_draw_feasting_table(430, 104)

	# 10. Apollo's Golden Lyre on Sculpted Pedestal
	_draw_apollo_lyre(515, 104)

	# 11. Golden Incense Thurible on Claw Feet
	_draw_incense_thurible(555, 104)

	# 12. Sacred Eternal Tripod Brazier
	_draw_eternal_brazier(650, 104)

func _draw_lounging_couch(cx: float, cy: float) -> void:
	var couch_w = 76.0
	var couch_h = 50.0
	var couch_x = cx - couch_w / 2.0
	var couch_y = cy - couch_h + 2.0
	draw_rect(Rect2(couch_x + 6, cy - 2, couch_w - 12, 3), Color(0.08, 0.08, 0.12, 0.5))
	draw_texture_rect(TEX_COUCH, Rect2(couch_x, couch_y, couch_w, couch_h), false)

func _draw_massive_hearth(hx: float, hy: float) -> void:
	var hearth_w = 68.0
	var hearth_h = 68.0
	var hearth_x = hx - hearth_w / 2.0
	var hearth_y = hy - hearth_h + 2.0
	draw_texture_rect(TEX_HEARTH, Rect2(hearth_x, hearth_y, hearth_w, hearth_h), false)
	
	if is_hearth_lit:
		var fire_cx = hx
		var fire_cy = hy - 14.0
		
		var flare_mult = 1.0 + _hearth_flare * 0.6
		for i in range(1, 6):
			var radius = i * 6.0 * flare_mult
			var alpha = 0.35 * (1.0 - (float(i) / 6.0))
			draw_circle(Vector2(fire_cx, fire_cy), radius, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, alpha))
		
		var f1 = sin(_anim_clock * 4.0) * 2.5
		var f2 = sin(_anim_clock * 5.5 + 1.0) * 3.0
		var f3 = sin(_anim_clock * 3.5 + 2.0) * 2.8
		
		draw_polygon([Vector2(fire_cx - 11, fire_cy + 2), Vector2(fire_cx - 5 + f1, fire_cy - 14 * flare_mult), Vector2(fire_cx + 6, fire_cy + 2)], [cur_fire_edge])
		draw_polygon([Vector2(fire_cx - 6, fire_cy + 2), Vector2(fire_cx + 3 + f2, fire_cy - 18 * flare_mult), Vector2(fire_cx + 11, fire_cy + 2)], [cur_fire_mid])
		draw_polygon([Vector2(fire_cx - 5, fire_cy + 2), Vector2(fire_cx + f3, fire_cy - 12 * flare_mult), Vector2(fire_cx + 5, fire_cy + 2)], [cur_fire_core])
	else:
		draw_rect(Rect2(hx - 12, hy - 8, 24, 5), COL_ASH)

func _draw_feasting_table(dx: float, dy: float) -> void:
	var table_w: float = 88.0
	var table_h: float = 42.0
	var table_x: float = dx - table_w / 2.0
	var table_y: float = dy - table_h + 2.0
	draw_rect(Rect2(table_x + 8, dy - 2, table_w - 16, 3), Color(0.08, 0.08, 0.12, 0.5))
	draw_texture_rect(TEX_TABLE, Rect2(table_x, table_y, table_w, table_h), false)
	
	# Tabletop Accessories
	# A. Food Platter with Bread, Feta & Wine Kylix
	draw_texture_rect(TEX_FOOD_PLATTER, Rect2(dx - 34, dy - 48, 28, 20), false)
	# B. Golden Wine Amphora
	draw_texture_rect(TEX_AMPHORA, Rect2(dx + 2, dy - 46, 20, 26), false)
	# C. Cornucopia Overflowing with Grapes & Figs
	draw_texture_rect(TEX_CORNUCOPIA, Rect2(dx + 20, dy - 46, 28, 26), false)
	# D. Rolled Parchment Map Scroll
	draw_rect(Rect2(dx - 12, dy - 40, 14, 3), COL_SCROLL)

func _draw_potted_olive(px: float, py: float) -> void:
	var pw = 36.0
	var ph = 32.0
	draw_rect(Rect2(px - 10, py - 2, 20, 3), Color(0.08, 0.08, 0.12, 0.4))
	draw_texture_rect(TEX_OLIVE_PLANTER, Rect2(px - pw / 2.0, py - ph + 2.0, pw, ph), false)

func _draw_apollo_lyre(lx: float, ly: float) -> void:
	var lw = 22.0
	var lh = 50.0
	draw_rect(Rect2(lx - 7, ly - 2, 14, 3), Color(0.08, 0.08, 0.12, 0.4))
	draw_texture_rect(TEX_LYRE, Rect2(lx - lw / 2.0, ly - lh + 2.0, lw, lh), false)

func _draw_incense_thurible(tx: float, ty: float) -> void:
	var tw = 22.0
	var th = 30.0
	draw_rect(Rect2(tx - 6, ty - 2, 12, 3), Color(0.08, 0.08, 0.12, 0.4))
	draw_texture_rect(TEX_THURIBLE, Rect2(tx - tw / 2.0, ty - th + 2.0, tw, th), false)
	# Glowing incense coal
	var ember_glow = sin(_anim_clock * 5.0) * 0.2 + 0.8
	draw_circle(Vector2(tx, ty - 18.0), 2.0, Color(1.0, 0.4, 0.2, ember_glow))

func _draw_eternal_brazier(bx: float, by: float) -> void:
	var bw = 30.0
	var bh = 42.0
	draw_rect(Rect2(bx - 10, by - 2, 20, 3), Color(0.08, 0.08, 0.12, 0.5))
	draw_texture_rect(TEX_BRAZIER, Rect2(bx - bw / 2.0, by - bh + 2.0, bw, bh), false)
	
	# Brazier Flame Glow & Dynamic Click Flare
	var flare_r = 25.0 + _brazier_flare * 40.0
	var flare_alpha = 0.15 + _brazier_flare * 0.35
	draw_circle(Vector2(bx, by - 28.0), flare_r, Color(1.0, 0.75, 0.25, flare_alpha))

# ------------------------------------------------------------------------------
# 5. DYNAMIC PARTICLE SYSTEMS (30+ ELEMENTS)
# ------------------------------------------------------------------------------
func _draw_dynamic_particles() -> void:
	# A. Hearth Flying Embers
	if is_hearth_lit:
		for s in _sparks:
			var alpha = clampf(s.get("life", 1.0), 0.0, 1.0)
			draw_circle(Vector2(s["x"], s["y"]), 2.0, Color(cur_fire_mid.r, cur_fire_mid.g, cur_fire_mid.b, alpha * 0.4))
			draw_circle(Vector2(s["x"], s["y"]), 1.0, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, alpha))

	# B. Amphora Water Drops
	for d in _water_drops:
		draw_circle(Vector2(d["x"], d["y"]), 1.5, COL_WATER)
		
	# C. Bouncing Cornucopia Fruits
	for f in _bouncing_fruits:
		draw_circle(Vector2(f["x"], f["y"]), 2.0, f["color"])
		
	# D. Apollo's Musical Chords
	for n in _music_notes:
		var alpha = clampf(n.get("life", 1.0), 0.0, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(n["x"], n["y"]), n["symbol"], HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(1.0, 0.9, 0.4, alpha))

	# E. Fragrant Purple Incense Smoke Rings
	for sm in _incense_smoke:
		var alpha = clampf(sm["life"] / 2.5, 0.0, 1.0) * sm["alpha"]
		draw_circle(Vector2(sm["x"], sm["y"]), sm["size"], Color(0.72, 0.45, 0.85, alpha * 0.35))
		draw_circle(Vector2(sm["x"], sm["y"]), sm["size"] * 0.5, Color(0.85, 0.70, 0.95, alpha * 0.6))

	# F. Aromatic Food Steam Wisps
	for st in _food_steam:
		var alpha = clampf(st["life"] / 1.8, 0.0, 1.0) * st["alpha"]
		draw_circle(Vector2(st["x"], st["y"]), st["size"], Color(1.0, 0.98, 0.92, alpha * 0.4))

	# G. Sunset Golden Dust Motes / Fireflies
	for m in _sun_motes:
		var alpha = sin(m["phase"]) * 0.35 + 0.45
		draw_circle(Vector2(m["x"], m["y"]), 1.2, Color(1.0, 0.90, 0.55, alpha))

	# H. White Dove Coo Hearts
	for dh in _dove_hearts:
		var alpha = clampf(dh["life"] / 1.5, 0.0, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(dh["x"], dh["y"]), "♡", HORIZONTAL_ALIGNMENT_CENTER, -1, 9, Color(1.0, 0.6, 0.7, alpha))

# ------------------------------------------------------------------------------
# 6. HESTIA'S CELESTIAL SPIRIT EMBER
# ------------------------------------------------------------------------------
func _draw_hestias_ember() -> void:
	if not is_hearth_lit: return
	var throb = sin(_anim_clock * 8.0) * 2.0
	draw_circle(Vector2(ember_x, ember_y), 4.0 + throb * 0.2, cur_fire_core)
	draw_circle(Vector2(ember_x, ember_y), 2.0, Color(1.0, 1.0, 1.0))
	draw_circle(Vector2(ember_x, ember_y), 20.0 + throb, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, 0.3))
