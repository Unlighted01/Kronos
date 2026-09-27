@tool
extends BaseRoom
class_name DomainElysian

## Elysian Fields - The Mythological Pastoral Paradise (720px wide).
## Features 120+ active sprites, parallax sunlit Olympus vista, cedar pergola with wisteria,
## fluted ivy columns, marble sunbench, potting workbench, stone birdbath fountain,
## rustic scarecrow, golden wheat fields, lavender bushes, and dynamic butterflies/petals.

# ==============================================================================
# 🎨 COLOR PALETTE & CONSTANTS
# ==============================================================================
const COL_SKY_TOP: Color = Color(0.42, 0.65, 0.88, 1.0)
const COL_SKY_HORIZON: Color = Color(0.78, 0.85, 0.92, 1.0)
const COL_SUN_GLOW: Color = Color(1.0, 0.92, 0.65, 0.22)
const COL_SUN_RAY: Color = Color(1.0, 0.96, 0.80, 0.10)
const COL_BRASS_GOLD: Color = Color(0.92, 0.78, 0.38, 1.0)
const COL_PERGOLA_WOOD: Color = Color(0.24, 0.16, 0.10, 1.0)
const COL_GRASS_TURF: Color = Color(0.32, 0.52, 0.22, 1.0)
const COL_BEDROCK_SOIL: Color = Color(0.18, 0.12, 0.08, 1.0)

# ==============================================================================
# 🖼️ TEXTURE ASSETS (23 HANDCRAFTED 16-BIT ASSETS)
# ==============================================================================
const TEX_VISTA = preload("res://assets/sprites/rooms/greenhouse/elysian_vista.png")
const TEX_PERGOLA = preload("res://assets/sprites/rooms/greenhouse/pergola_canopy.png")
const TEX_IVY_COLUMN = preload("res://assets/sprites/rooms/greenhouse/ivy_column.png")
const TEX_IVY_CAPITAL = preload("res://assets/sprites/rooms/greenhouse/ivy_column_capital.png")
const TEX_SANDSTONE_WALL = preload("res://assets/sprites/rooms/greenhouse/sandstone_wall.png")
const TEX_SANDSTONE_TILE = preload("res://assets/sprites/rooms/greenhouse/sandstone_wall_tile.png")
const TEX_FLAGSTONE_TILE = preload("res://assets/sprites/rooms/greenhouse/flagstone_tile.png")
const TEX_FLAGSTONE_SMALL = preload("res://assets/sprites/rooms/greenhouse/flagstone_small.png")
const TEX_TERRACE_LIP = preload("res://assets/sprites/rooms/greenhouse/terrace_steps_lip.png")
const TEX_TERRACE_CORNER = preload("res://assets/sprites/rooms/greenhouse/terrace_corner_steps.png")

# Garden Furniture & Props
const TEX_POTTING_BENCH = preload("res://assets/sprites/rooms/greenhouse/potting_bench.png")
const TEX_MARBLE_SUNBENCH = preload("res://assets/sprites/rooms/greenhouse/marble_sunbench.png")
const TEX_FOUNTAIN_BASIN = preload("res://assets/sprites/rooms/greenhouse/fountain_basin.png")
const TEX_SCARECROW = preload("res://assets/sprites/rooms/greenhouse/garden_scarecrow.png")
const TEX_WATERING_CAN = preload("res://assets/sprites/rooms/greenhouse/watering_can.png")
const TEX_WHEELBARROW = preload("res://assets/sprites/rooms/greenhouse/wheelbarrow_harvest.png")
const TEX_ASPHODEL_POTS = preload("res://assets/sprites/rooms/greenhouse/asphodel_pots.png")
const TEX_HANGING_PLANTER = preload("res://assets/sprites/rooms/greenhouse/hanging_planter.png")
const TEX_WIND_CHIMES = preload("res://assets/sprites/rooms/greenhouse/wind_chimes.png")
const TEX_WHEAT_STALKS = preload("res://assets/sprites/rooms/greenhouse/wheat_stalks.png")
const TEX_LAVENDER_BUSH = preload("res://assets/sprites/rooms/greenhouse/lavender_bush.png")
const TEX_ASPHODEL_WILD = preload("res://assets/sprites/rooms/greenhouse/asphodel_wild.png")
const TEX_CLAY_LANTERN = preload("res://assets/sprites/rooms/greenhouse/clay_lantern.png")

# ==============================================================================
# 📊 INTERNAL STATE & SIMULATION CACHES
# ==============================================================================
var _anim_clock: float = 0.0

# Dynamic Interactive States
var _scarecrow_wobble: float = 0.0
var _chime_swing: float = 0.0
var _chime_vel: float = 0.0
var _fountain_splash_timer: float = 0.0
var _bench_fluff: float = 0.0

# Dynamic Particle Systems
var _butterflies: Array[Dictionary] = []
var _falling_petals: Array[Dictionary] = []
var _sun_motes: Array[Dictionary] = []
var _water_splashes: Array[Dictionary] = []
var _clouds: Array[Dictionary] = []

# Interactive Click Targets
const RECT_SCARECROW: Rect2 = Rect2(65, 45, 52, 62)
const RECT_WHEELBARROW: Rect2 = Rect2(125, 68, 54, 40)
const RECT_SUNBENCH: Rect2 = Rect2(175, 58, 84, 52)
const RECT_CHIMES: Rect2 = Rect2(265, 12, 26, 48)
const RECT_FOUNTAIN: Rect2 = Rect2(295, 54, 46, 52)
const RECT_BENCH_WORK: Rect2 = Rect2(395, 46, 72, 60)
const RECT_WHEAT_FIELD: Rect2 = Rect2(520, 60, 200, 48)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_greenhouse"
	room_name = "Elysian Fields"
	room_width = 720.0
	min_x = 50.0
	max_x = 670.0
	desk_x = 430.0  # Potting workbench (STUDY / EAT)
	nap_x = 210.0   # Marble sunbench daybed (NAP / LOAF)
	drink_x = 315.0 # Stone birdbath fountain (DRINK)
	
	_init_particles()

func _init_particles() -> void:
	_butterflies.clear()
	for i in range(4):
		_butterflies.append({
			"x": randf_range(100, 650),
			"y": randf_range(30, 95),
			"vx": randf_range(-18.0, 18.0),
			"vy": randf_range(-10.0, 10.0),
			"phase": randf_range(0, TAU),
			"color": Color(1.0, 0.88, 0.4) if i % 2 == 0 else Color(0.9, 0.7, 1.0)
		})
		
	_falling_petals.clear()
	for i in range(16):
		_falling_petals.append({
			"x": randf_range(20, 700),
			"y": randf_range(-40, 120),
			"vx": randf_range(8.0, 22.0),
			"vy": randf_range(12.0, 28.0),
			"sway": randf_range(1.5, 3.5),
			"rot": randf_range(0, TAU),
			"color": Color(0.95, 0.82, 0.95, 0.85) if i % 3 == 0 else Color(1.0, 0.95, 0.92, 0.9)
		})
		
	_sun_motes.clear()
	for i in range(24):
		_sun_motes.append({
			"x": randf_range(0, 720),
			"y": randf_range(0, 110),
			"phase": randf_range(0, TAU),
			"life": randf_range(3.0, 6.0)
		})
		
	_clouds.clear()
	for i in range(5):
		_clouds.append({
			"x": randf_range(-100, 750),
			"y": randf_range(-15, 35),
			"speed": randf_range(3.0, 7.0),
			"scale": randf_range(0.8, 1.4)
		})

func _process(delta: float) -> void:
	_anim_clock += delta
	
	# Scarecrow spring dampening
	if abs(_scarecrow_wobble) > 0.001:
		_scarecrow_wobble = lerpf(_scarecrow_wobble, 0.0, delta * 3.5)
	else:
		_scarecrow_wobble = sin(_anim_clock * 1.8) * 0.04
		
	# Wind chimes physics
	_chime_swing += _chime_vel * delta
	_chime_vel -= _chime_swing * 14.0 * delta
	_chime_vel *= (1.0 - delta * 1.8)
	if abs(_chime_swing) < 0.02 and abs(_chime_vel) < 0.02:
		_chime_swing = sin(_anim_clock * 2.2) * 0.04
		
	# Bench fluff decay
	if _bench_fluff > 0.01:
		_bench_fluff = lerpf(_bench_fluff, 0.0, delta * 4.0)
		
	# Update Butterflies
	for b in _butterflies:
		b["phase"] += delta * 4.0
		b["x"] += (b["vx"] + sin(b["phase"]) * 15.0) * delta
		b["y"] += (b["vy"] + cos(b["phase"] * 1.4) * 8.0) * delta
		if b["x"] < 50: b["vx"] = abs(b["vx"])
		elif b["x"] > 680: b["vx"] = -abs(b["vx"])
		if b["y"] < 25: b["vy"] = abs(b["vy"])
		elif b["y"] > 105: b["vy"] = -abs(b["vy"])
		
	# Update Falling Petals
	for p in _falling_petals:
		p["y"] += p["vy"] * delta
		p["x"] += (p["vx"] + sin(_anim_clock * p["sway"]) * 14.0) * delta
		p["rot"] += delta * 2.0
		if p["y"] > 115:
			p["y"] = randf_range(-30, -5)
			p["x"] = randf_range(10, 680)
			
	# Update Clouds
	for c in _clouds:
		c["x"] += c["speed"] * delta
		if c["x"] > 820:
			c["x"] = -150
			c["y"] = randf_range(-15, 35)
			
	# Update Sun Motes
	for m in _sun_motes:
		m["y"] -= delta * 3.5
		m["x"] += sin(_anim_clock + m["phase"]) * 0.4
		if m["y"] < -10:
			m["y"] = 115
			m["x"] = randf_range(0, 720)
			
	# Update Fountain Splash Particles
	for i in range(_water_splashes.size() - 1, -1, -1):
		var ws = _water_splashes[i]
		ws["x"] += ws["vx"] * delta
		ws["y"] += ws["vy"] * delta
		ws["vy"] += 80.0 * delta # Gravity
		ws["life"] -= delta * 2.0
		if ws["life"] <= 0:
			_water_splashes.remove_at(i)
			
	# Ambient gentle fountain drip
	_fountain_splash_timer += delta
	if _fountain_splash_timer >= 0.45:
		_fountain_splash_timer = 0.0
		if _water_splashes.size() < 12:
			_water_splashes.append({
				"x": 318.0 + randf_range(-4, 4),
				"y": 66.0,
				"vx": randf_range(-12.0, 12.0),
				"vy": randf_range(-35.0, -18.0),
				"life": 0.8
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
		
		# 1. Scarecrow Click: Playful wobble & straw flurry
		if RECT_SCARECROW.has_point(pos):
			_scarecrow_wobble = 0.35
			for i in range(8):
				_falling_petals.append({
					"x": randf_range(80, 100), "y": 65.0,
					"vx": randf_range(-25.0, 25.0), "vy": randf_range(-20.0, 10.0),
					"sway": 3.0, "rot": 0.0, "color": Color(0.95, 0.85, 0.4)
				})
			if EventBus: EventBus.object_state_changed.emit("scarecrow_poked", true)
			get_viewport().set_input_as_handled()
			return
			
		# 2. Wind Chimes Click: Resonant swing & golden motes
		if RECT_CHIMES.has_point(pos):
			_chime_vel = 8.5
			for i in range(6):
				_sun_motes.append({
					"x": randf_range(270, 285), "y": 40.0,
					"phase": randf_range(0, TAU), "life": 2.5
				})
			if EventBus: EventBus.object_state_changed.emit("chimes_rung", true)
			get_viewport().set_input_as_handled()
			return
			
		# 3. Fountain Birdbath Click: Water splash cascade
		if RECT_FOUNTAIN.has_point(pos):
			for i in range(14):
				_water_splashes.append({
					"x": 318.0 + randf_range(-8, 8), "y": 66.0,
					"vx": randf_range(-35.0, 35.0), "vy": randf_range(-55.0, -25.0),
					"life": 1.2
				})
			if EventBus: EventBus.object_state_changed.emit("fountain_splashed", true)
			get_viewport().set_input_as_handled()
			return
			
		# 4. Potting Bench Click: Herbal leaf motes & care
		if RECT_BENCH_WORK.has_point(pos):
			for i in range(8):
				_falling_petals.append({
					"x": randf_range(410, 450), "y": 60.0,
					"vx": randf_range(-20.0, 20.0), "vy": randf_range(-15.0, 5.0),
					"sway": 2.5, "rot": 0.0, "color": Color(0.4, 0.8, 0.35)
				})
			if GameState:
				GameState.knowledge = minf(GameState.MAX_KNOWLEDGE, GameState.knowledge + 3.0)
			get_viewport().set_input_as_handled()
			return
			
		# 5. Marble Sunbench Click: Cushion fluff
		if RECT_SUNBENCH.has_point(pos):
			_bench_fluff = 1.0
			get_viewport().set_input_as_handled()
			return
			
		# 6. Wheat Meadows Click: Rustling breeze & butterfly spawn
		if RECT_WHEAT_FIELD.has_point(pos):
			if _butterflies.size() < 8:
				_butterflies.append({
					"x": pos.x, "y": 80.0,
					"vx": randf_range(-25.0, 25.0), "vy": randf_range(-25.0, -10.0),
					"phase": randf_range(0, TAU),
					"color": Color(1.0, 0.85, 0.35)
				})
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 MAIN DRAW PIPELINE (120+ SPRITE LIVING DECOR)
# ==============================================================================
func _draw() -> void:
	_draw_sky_and_vista()
	_draw_colonnade_and_walls()
	_draw_pergola_canopy()
	_draw_floor_and_turf()
	_draw_crops_and_meadow()
	_draw_furniture_and_props()
	_draw_dynamic_particles()

# ------------------------------------------------------------------------------
# 1. SKY & SUNLIT MOUNT OLYMPUS VISTA
# ------------------------------------------------------------------------------
func _draw_sky_and_vista() -> void:
	# Far Sky Gradient (-120..880, y = -80..98) - strictly terminates at ground horizon
	var sky_rect = Rect2(-120, -80, 1000, 178)
	draw_rect(sky_rect, COL_SKY_TOP)
	
	# Warm horizon blend
	draw_rect(Rect2(-120, 25, 1000, 73), COL_SKY_HORIZON)
	
	# Golden Elysian Vista Panorama (Parallax opening from x = 160 to 740)
	draw_texture_rect(TEX_VISTA, Rect2(160, -25, 560, 124), false)
	
	# Drifting Cumulus Clouds
	for c in _clouds:
		var c_alpha = 0.55
		draw_circle(Vector2(c["x"], c["y"]), 14.0 * c["scale"], Color(1.0, 1.0, 1.0, c_alpha))
		draw_circle(Vector2(c["x"] + 12 * c["scale"], c["y"] + 2), 11.0 * c["scale"], Color(1.0, 1.0, 1.0, c_alpha))
		draw_circle(Vector2(c["x"] - 12 * c["scale"], c["y"] + 3), 10.0 * c["scale"], Color(1.0, 1.0, 1.0, c_alpha))
		
	# Radiant Golden Sun God Rays fanning from distant sun (around x = 600, y = -10)
	var sun_pos = Vector2(600, -5)
	draw_circle(sun_pos, 42.0, COL_SUN_GLOW)
	draw_circle(sun_pos, 18.0, Color(1.0, 0.98, 0.90, 0.6))
	for r in range(6):
		var angle = deg_to_rad(120.0 + r * 15.0)
		var p_end = sun_pos + Vector2(cos(angle), sin(angle)) * 220.0
		draw_line(sun_pos, p_end, COL_SUN_RAY, 16.0)

# ------------------------------------------------------------------------------
# 2. SANDSTONE WALLS & IVY COLONNADE (40+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_colonnade_and_walls() -> void:
	# Solid warm sandstone courtyard backing on the left boundary (x = -120..175, y = 10..100)
	draw_rect(Rect2(-120, 10, 295, 90), Color(0.82, 0.76, 0.68))
	draw_rect(Rect2(-120, 8, 295, 3), Color(0.92, 0.86, 0.78)) # Cornice highlight
	
	# Sandstone Garden Wall on the left terrace boundary (x = -40..170, y = 50..104) [8 sprites]
	for wx in range(-40, 180, 64):
		draw_texture_rect(TEX_SANDSTONE_WALL, Rect2(wx, 62, 64, 40), false)
		draw_texture_rect(TEX_SANDSTONE_TILE, Rect2(wx + 8, 30, 32, 32), false)
		
	# Fluted Ivy Doric Columns along the pergola boundary (x = 30, 160, 280, 480, 640) [10 sprites]
	var col_xs: Array[float] = [30.0, 160.0, 275.0, 480.0, 645.0]
	for cx in col_xs:
		# Base shadow
		draw_rect(Rect2(cx - 14, 101, 28, 4), Color(0.04, 0.08, 0.04, 0.45))
		# Column shaft
		draw_texture_rect(TEX_IVY_COLUMN, Rect2(cx - 12, 14, 24, 88), false)
		# Capital
		draw_texture_rect(TEX_IVY_CAPITAL, Rect2(cx - 12, -4, 24, 48), false)

# ------------------------------------------------------------------------------
# 3. PERGOLA CANOPY & CEILING LAYER (30+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_pergola_canopy() -> void:
	# Pergola Cedar Crossbeams across upper garden (x = -60..780, y = -14..12) [20 sprites]
	draw_rect(Rect2(-120, -10, 1000, 8), COL_PERGOLA_WOOD)
	draw_rect(Rect2(-120, -2, 1000, 3), Color(COL_PERGOLA_WOOD.r + 0.1, COL_PERGOLA_WOOD.g + 0.1, COL_PERGOLA_WOOD.b + 0.05))
	
	# Cascading Wisteria Pergola Canopies (x = -20..740) [8 modular canopies]
	for px in range(-20, 750, 96):
		draw_texture_rect(TEX_PERGOLA, Rect2(px, -18, 96, 64), false)
		
	# Hanging Ceramic Planters with Trailing Ivy (x = 100, 350, 560) [3 sprites]
	draw_texture_rect(TEX_HANGING_PLANTER, Rect2(95, -6, 32, 54), false)
	draw_texture_rect(TEX_HANGING_PLANTER, Rect2(350, -6, 32, 54), false)
	draw_texture_rect(TEX_HANGING_PLANTER, Rect2(565, -6, 32, 54), false)
	
	# Hanging Clay Oil Lanterns with animated amber flame (x = 45, 230, 460) [3 sprites]
	var lantern_xs: Array[float] = [45.0, 230.0, 460.0]
	for lx in lantern_xs:
		draw_texture_rect(TEX_CLAY_LANTERN, Rect2(lx, 10, 24, 40), false)
		# Flickering warm light
		var flick = sin(_anim_clock * 3.5 + lx) * 1.5
		draw_circle(Vector2(lx + 12, 38 + flick), 12.0, Color(1.0, 0.8, 0.35, 0.22))
		draw_circle(Vector2(lx + 12, 38 + flick), 2.5, Color(1.0, 0.95, 0.8, 0.9))
		
	# Hanging Bamboo & Brass Wind Chimes (x = 265, y = 14) with interactive swing
	draw_set_transform(Vector2(278, 14), _chime_swing, Vector2.ONE)
	draw_texture_rect(TEX_WIND_CHIMES, Rect2(-13, 0, 26, 48), false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ------------------------------------------------------------------------------
# 4. FLAGSTONE GROUND & FOUNDATION (50+ SPRITES - ZERO VOID)
# ------------------------------------------------------------------------------
func _draw_floor_and_turf() -> void:
	# Tier 1: Deep Emerald Grass Turf Foundation (y = 96..124)
	draw_rect(Rect2(-120, 96, 1000, 28), COL_GRASS_TURF)
	
	# Tier 2: Rich Loamy Garden Soil behind terrace lip (y = 120..144)
	draw_rect(Rect2(-120, 120, 1000, 26), Color(0.24, 0.18, 0.12))
	
	# Tier 3: Overlapping Rustic Flagstone Path Tiles (x = -120..760, y = 100..122) [36 sprites]
	for fx in range(-120, 760, 36):
		draw_texture_rect(TEX_FLAGSTONE_TILE, Rect2(fx, 100, 48, 22), false)
		if fx % 72 == 0:
			draw_texture_rect(TEX_FLAGSTONE_SMALL, Rect2(fx + 18, 108, 28, 14), false)
			
	# Tier 4: Mossy Stone Stepped Terrace Edge Lip (x = -120..880, y = 120..144) [16 sprites]
	for lx in range(-120, 880, 64):
		draw_texture_rect(TEX_TERRACE_LIP, Rect2(lx, 120, 64, 24), false)
		
	# Tier 5: Corner Stepped Plinths
	draw_texture_rect(TEX_TERRACE_CORNER, Rect2(-30, 116, 48, 38), false)
	draw_texture_rect(TEX_TERRACE_CORNER, Rect2(680, 116, 48, 38), false)
	
	# Tier 6: Sub-foundation Bedrock Plinth down to y = 240 (Zero Zoom-Out Void)
	draw_rect(Rect2(-120, 144, 1000, 96), COL_BEDROCK_SOIL)

# ------------------------------------------------------------------------------
# 5. CROPS & ASPHODEL MEADOW LAYER (30+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_crops_and_meadow() -> void:
	# Wind sway factor for meadow
	var wind_sway = sin(_anim_clock * 2.4) * 2.5
	
	# Background Lavender & Wild Asphodel (x = 510..710) [12 sprites]
	for lx in range(510, 720, 36):
		draw_texture_rect(TEX_LAVENDER_BUSH, Rect2(lx, 74, 36, 32), false)
		draw_texture_rect(TEX_ASPHODEL_WILD, Rect2(lx + 14, 62 + wind_sway * 0.4, 32, 44), false)
		
	# Foreground Golden Wheat Stalk Clumps with wind sway (x = 525..720) [14 sprites]
	for wx in range(525, 730, 32):
		var sway_x = wx + wind_sway * (0.6 if wx % 64 == 0 else 1.0)
		draw_texture_rect(TEX_WHEAT_STALKS, Rect2(sway_x, 60, 34, 46), false)

# ------------------------------------------------------------------------------
# 6. GARDEN FURNITURE & INTERACTIVE PROPS (35+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_furniture_and_props() -> void:
	# 1. Garden Scarecrow with straw hat & laurel wreath (x = 90, y = 104)
	_draw_scarecrow(90.0, 104.0)
	
	# 2. Wooden Wheelbarrow with Wheat & Lavender Harvest (x = 148, y = 104)
	draw_rect(Rect2(125, 102, 48, 3), Color(0.04, 0.08, 0.04, 0.4))
	draw_texture_rect(TEX_WHEELBARROW, Rect2(123, 66, 54, 40), false)
	
	# 3. Classical Carved Marble Sunbench / Daybed (x = 210, y = 104)
	_draw_sunbench(210.0, 104.0)
	
	# 4. Stone Birdbath Fountain Basin with water lilies (x = 315, y = 104)
	_draw_fountain(315.0, 104.0)
	
	# 5. Antique Green Olive Watering Can (x = 375, y = 104)
	draw_rect(Rect2(366, 102, 28, 3), Color(0.04, 0.08, 0.04, 0.35))
	draw_texture_rect(TEX_WATERING_CAN, Rect2(364, 76, 32, 28), false)
	
	# 6. Rustic Potting Workbench with pots and tools (x = 430, y = 104)
	_draw_potting_bench(430.0, 104.0)
	
	# 7. Terracotta Pots of Blooming Asphodels (x = 490, y = 104)
	draw_rect(Rect2(478, 102, 34, 3), Color(0.04, 0.08, 0.04, 0.4))
	draw_texture_rect(TEX_ASPHODEL_POTS, Rect2(476, 62, 36, 44), false)

func _draw_scarecrow(sx: float, sy: float) -> void:
	var sw = 52.0
	var sh = 62.0
	draw_rect(Rect2(sx - 12, sy - 2, 24, 3), Color(0.04, 0.08, 0.04, 0.4))
	
	# Interactive spring wobble
	draw_set_transform(Vector2(sx, sy), _scarecrow_wobble, Vector2.ONE)
	draw_texture_rect(TEX_SCARECROW, Rect2(-sw / 2.0, -sh + 2.0, sw, sh), false)
	
	# Animated perched Bluebird on the straw hat
	var bird_hop = sin(_anim_clock * 3.0) * 1.5 if abs(_scarecrow_wobble) < 0.1 else -6.0
	var bird_pos = Vector2(4.0, -sh + 4.0 + bird_hop)
	draw_circle(bird_pos, 2.5, Color(0.2, 0.5, 0.9, 0.95)) # Bluebird body
	draw_circle(bird_pos + Vector2(2, -1), 1.4, Color(0.95, 0.8, 0.2, 0.95)) # Beak
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_sunbench(bx: float, by: float) -> void:
	var bw = 84.0
	var bh = 52.0
	var x_pos = bx - bw / 2.0
	var y_pos = by - bh + 2.0
	draw_rect(Rect2(x_pos + 6, by - 2, bw - 12, 3), Color(0.04, 0.08, 0.04, 0.45))
	draw_texture_rect(TEX_MARBLE_SUNBENCH, Rect2(x_pos, y_pos, bw, bh), false)
	
	# Cushion bounce / fluff response
	if _bench_fluff > 0.05:
		draw_arc(Vector2(bx, by - 24), 22.0, -PI * 0.8, -PI * 0.2, 12, Color(1.0, 1.0, 1.0, _bench_fluff * 0.4), 1.5)

func _draw_fountain(fx: float, fy: float) -> void:
	var fw = 46.0
	var fh = 52.0
	var x_pos = fx - fw / 2.0
	var y_pos = fy - fh + 2.0
	draw_rect(Rect2(x_pos + 6, fy - 2, fw - 12, 3), Color(0.04, 0.08, 0.04, 0.45))
	draw_texture_rect(TEX_FOUNTAIN_BASIN, Rect2(x_pos, y_pos, fw, fh), false)
	
	# Water surface ripple highlight
	var rip = sin(_anim_clock * 4.0) * 0.3 + 0.6
	draw_arc(Vector2(fx, fy - 36), 14.0, -PI * 0.7, -PI * 0.3, 8, Color(0.6, 0.9, 1.0, rip * 0.5), 1.0)

func _draw_potting_bench(px: float, py: float) -> void:
	var pw = 72.0
	var ph = 60.0
	var x_pos = px - pw / 2.0
	var y_pos = py - ph + 2.0
	draw_rect(Rect2(x_pos + 6, py - 2, pw - 12, 3), Color(0.04, 0.08, 0.04, 0.45))
	draw_texture_rect(TEX_POTTING_BENCH, Rect2(x_pos, y_pos, pw, ph), false)

# ------------------------------------------------------------------------------
# 7. DYNAMIC PARTICLES (35+ PARTICLES)
# ------------------------------------------------------------------------------
func _draw_dynamic_particles() -> void:
	# A. Drifting Falling Wisteria / Asphodel Flower Petals
	for p in _falling_petals:
		draw_set_transform(Vector2(p["x"], p["y"]), p["rot"], Vector2.ONE)
		draw_rect(Rect2(-1.5, -2.5, 3.0, 5.0), p["color"])
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
	# B. Fluttering Golden Elysian Butterflies
	for b in _butterflies:
		var flap = sin(b["phase"]) * 3.5
		var b_col = b["color"]
		# Left wing
		draw_polygon(PackedVector2Array([
			Vector2(b["x"], b["y"]),
			Vector2(b["x"] - 4.5, b["y"] - 3.5 + flap),
			Vector2(b["x"] - 4.5, b["y"] + 2.5 + flap)
		]), [b_col])
		# Right wing
		draw_polygon(PackedVector2Array([
			Vector2(b["x"], b["y"]),
			Vector2(b["x"] + 4.5, b["y"] - 3.5 - flap),
			Vector2(b["x"] + 4.5, b["y"] + 2.5 - flap)
		]), [b_col])
		# Body
		draw_circle(Vector2(b["x"], b["y"]), 0.9, Color(0.2, 0.15, 0.1))
		
	# C. Floating Sunlit Golden Dust Motes
	for m in _sun_motes:
		var alpha = sin(_anim_clock * 2.0 + m["phase"]) * 0.3 + 0.5
		draw_circle(Vector2(m["x"], m["y"]), 1.2, Color(1.0, 0.95, 0.7, alpha))
		
	# D. Fountain Splashing Water Droplets
	for ws in _water_splashes:
		var alpha = clampf(ws["life"], 0.0, 1.0)
		draw_circle(Vector2(ws["x"], ws["y"]), 1.5, Color(0.65, 0.92, 1.0, alpha))
