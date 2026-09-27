@tool
extends BaseRoom
class_name TempleOfMorpheus

## Temple of Morpheus - Ultra-Detailed Mythological Sanctuary (720px wide).
## Features over 120+ active sprites & decor elements, nocturnal Greek temple architecture,
## Font of Lethe water fountain, Starlight Luna Moth, Dream Sand Hourglass, and Canopy Daybed.

# ==============================================================================
# 🎨 COLOR PALETTES
# ==============================================================================
const COL_SKY_TOP: Color = Color(0.04, 0.05, 0.12, 1.0) # Deep midnight indigo
const COL_SKY_BOT: Color = Color(0.18, 0.12, 0.30, 1.0) # Ethereal twilight violet
const COL_LETHE_WATER: Color = Color(0.35, 0.85, 0.98, 0.85)
const COL_LETHE_FOAM: Color = Color(0.85, 0.96, 1.0, 0.9)
const COL_SILVER: Color = Color(0.88, 0.90, 0.96, 1.0)
const COL_BLUE_FLAME: Color = Color(0.35, 0.75, 1.0, 1.0)
const COL_DREAM_SAND: Color = Color(0.40, 0.92, 0.98, 0.9)

# ==============================================================================
# 📦 16-BIT HANDCRAFTED SPRITE ASSET SUITE
# ==============================================================================
# Architectural Foundations
const TEX_FLOOR: Texture2D = preload("res://assets/sprites/rooms/bedroom/floor_tile.png")
const TEX_FLOOR_LIP: Texture2D = preload("res://assets/sprites/rooms/bedroom/floor_lip.png")
const TEX_WALL_STONE: Texture2D = preload("res://assets/sprites/rooms/bedroom/wall_stone.png")
const TEX_WALL_FRIEZE: Texture2D = preload("res://assets/sprites/rooms/bedroom/wall_frieze.png")
const TEX_COLUMN: Texture2D = preload("res://assets/sprites/rooms/bedroom/column.png")
const TEX_CEILING: Texture2D = preload("res://assets/sprites/rooms/bedroom/ceiling_tile.png")
const TEX_BALUSTRADE: Texture2D = preload("res://assets/sprites/rooms/bedroom/balustrade.png")
const TEX_VISTA_NIGHT: Texture2D = preload("res://assets/sprites/rooms/bedroom/vista_olympus_night.png")

# Furniture & Interactive Props
const TEX_CANOPY_BED: Texture2D = preload("res://assets/sprites/rooms/bedroom/canopy_bed.png")
const TEX_STUDY_ALTAR: Texture2D = preload("res://assets/sprites/rooms/bedroom/study_altar.png")
const TEX_DREAM_HOURGLASS: Texture2D = preload("res://assets/sprites/rooms/bedroom/dream_hourglass.png")
const TEX_CANDELABRA: Texture2D = preload("res://assets/sprites/rooms/bedroom/candelabra.png")
const TEX_LETHE_FOUNTAIN: Texture2D = preload("res://assets/sprites/rooms/bedroom/lethe_fountain.png")
const TEX_WIND_CHIMES: Texture2D = preload("res://assets/sprites/rooms/bedroom/wind_chimes.png")
const TEX_MOON_RUG: Texture2D = preload("res://assets/sprites/rooms/bedroom/moon_rug.png")
const TEX_MOONFLOWER_URN: Texture2D = preload("res://assets/sprites/rooms/bedroom/moonflower_urn.png")

# Expansion Temple Decor
const TEX_STAR_LANTERN: Texture2D = preload("res://assets/sprites/rooms/bedroom/star_lantern.png")
const TEX_SCONCE: Texture2D = preload("res://assets/sprites/rooms/bedroom/sconce_blue.png")
const TEX_ASTROLABE: Texture2D = preload("res://assets/sprites/rooms/bedroom/astrolabe.png")
const TEX_COLUMN_DRAPES: Texture2D = preload("res://assets/sprites/rooms/bedroom/column_drapes.png")
const TEX_GRIMOIRE_STAND: Texture2D = preload("res://assets/sprites/rooms/bedroom/grimoire_stand.png")
const TEX_MOONFLOWER_VINES: Texture2D = preload("res://assets/sprites/rooms/bedroom/moonflower_vines.png")
const TEX_STARLIGHT_MOTH: Texture2D = preload("res://assets/sprites/rooms/bedroom/starlight_moth.png")

# ==============================================================================
# 📊 INTERNAL STATE & ANIMATION SYSTEMS
# ==============================================================================
var _anim_clock: float = 0.0
var _stars: Array[Dictionary] = []
var _dreams: Array[Dictionary] = []
var _sand_grains: Array[Dictionary] = []
var _water_ripples: Array[Dictionary] = []
var _music_notes: Array[Dictionary] = []
var _starlight_dust: Array[Dictionary] = []
var _shooting_stars: Array[Dictionary] = []

# Interactive states
var is_waterfall_flowing: bool = true
var _chime_swing: float = 0.0
var _chime_vel: float = 0.0
var _lantern_swing: float = 0.0
var _candelabra_flare: float = 0.0
var _hourglass_inverted: bool = false
var _sand_flow_rate: float = 1.0

# The Starlight Weaver (Luna Moth)
var moth_x: float = -50.0
var moth_y: float = 40.0
var moth_active: bool = true
var moth_timer: float = 0.0

# Interactive Mouse Hitboxes
const RECT_CANOPY_BED: Rect2 = Rect2(185, 40, 92, 64)
const RECT_STUDY_ALTAR: Rect2 = Rect2(70, 60, 80, 44)
const RECT_HOURGLASS: Rect2 = Rect2(133, 58, 26, 46)
const RECT_CHIMES: Rect2 = Rect2(378, 8, 24, 50)
const RECT_LETHE: Rect2 = Rect2(462, 58, 56, 46)
const RECT_ASTROLABE: Rect2 = Rect2(42, 64, 26, 40)
const RECT_GRIMOIRE: Rect2 = Rect2(72, 70, 30, 34)
const RECT_BALUSTRADE: Rect2 = Rect2(550, 72, 140, 32)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_bedroom"
	room_name = "Temple of Morpheus"
	room_width = 720.0
	min_x = 50.0
	max_x = 670.0
	floor_y = 102.0
	desk_x = 100.0  # Altar of Somnus (Study / Feast)
	nap_x = 230.0   # Royal Canopy Bed (Nap / Loaf)
	drink_x = 490.0 # Font of Lethe (Drink)
	
	# Seed celestial starfield
	for i in range(50):
		_stars.append({
			"x": randf_range(-100, 850),
			"y": randf_range(-60, 85),
			"size": randf_range(1.0, 2.5),
			"phase": randf_range(0, TAU)
		})
		
	# Seed ambient floating dream orbs
	for i in range(16):
		_spawn_dream_orb(randf_range(50, 700), randf_range(30, 110))
		
	# Seed initial dream sand grains in the hourglass
	for i in range(25):
		_sand_grains.append({
			"x": randf_range(143, 149),
			"y": randf_range(80, 96),
			"vy": randf_range(10.0, 25.0)
		})
		
	if EventBus:
		EventBus.object_state_changed.connect(_on_object_state_changed)

func _on_object_state_changed(key: String, val: Variant) -> void:
	if key == "lethe_paw_dip":
		_spawn_dream_orb(490.0, 80.0)
		for i in range(6):
			_water_ripples.append({ "x": 490.0, "y": 88.0, "r": 2.0, "life": 1.5 })
		is_waterfall_flowing = true
		queue_redraw()

func _spawn_dream_orb(px: float, py: float) -> void:
	_dreams.append({
		"x": px,
		"y": py,
		"vx": randf_range(-8.0, 8.0),
		"vy": randf_range(-6.0, -18.0),
		"phase": randf_range(0, TAU),
		"scale": randf_range(0.8, 1.4),
		"life": randf_range(4.0, 8.0)
	})

# ==============================================================================
# 🔄 SIMULATION & PROCESS LOOP
# ==============================================================================
func _process(delta: float) -> void:
	_anim_clock += delta * 2.0
	
	# Chime damped pendulum physics
	_chime_vel -= _chime_swing * 18.0 * delta
	_chime_vel *= 0.94
	_chime_swing += _chime_vel * delta
	
	_lantern_swing = lerpf(_lantern_swing, 0.0, delta * 2.0)
	_candelabra_flare = maxf(0.0, _candelabra_flare - delta * 1.6)
	
	# Hourglass Sand Trickle
	for s in _sand_grains:
		s["y"] += s["vy"] * delta * _sand_flow_rate
		if s["y"] > 98.0:
			s["y"] = 80.0
			s["x"] = randf_range(143, 149)
			
	# Update Dream Orbs
	for i in range(_dreams.size() - 1, -1, -1):
		var d = _dreams[i]
		d["x"] += (d["vx"] + sin(_anim_clock + d["phase"]) * 6.0) * delta
		d["y"] += d["vy"] * delta
		d["life"] -= delta
		if d["life"] <= 0 or d["y"] < -40:
			d["y"] = randf_range(95, 115)
			d["x"] = randf_range(60, 680)
			d["life"] = randf_range(4.0, 7.0)
			
	# Update Water Ripples
	for i in range(_water_ripples.size() - 1, -1, -1):
		var r = _water_ripples[i]
		r["r"] += delta * 12.0
		r["life"] -= delta
		if r["life"] <= 0:
			_water_ripples.remove_at(i)
			
	# Update Music Notes
	for i in range(_music_notes.size() - 1, -1, -1):
		var n = _music_notes[i]
		n["phase"] += delta * 4.0
		n["y"] -= 26.0 * delta
		n["x"] += sin(n["phase"]) * 10.0 * delta
		n["life"] -= delta * 0.7
		if n["life"] <= 0:
			_music_notes.remove_at(i)
			
	# Update Starlight Dust
	for i in range(_starlight_dust.size() - 1, -1, -1):
		var sd = _starlight_dust[i]
		sd["y"] += sd["vy"] * delta
		sd["x"] += sd["vx"] * delta
		sd["life"] -= delta
		if sd["life"] <= 0:
			_starlight_dust.remove_at(i)
			
	# Update Shooting Stars
	for i in range(_shooting_stars.size() - 1, -1, -1):
		var ss = _shooting_stars[i]
		ss["x"] += ss["vx"] * delta
		ss["y"] += ss["vy"] * delta
		ss["life"] -= delta * 1.5
		if ss["life"] <= 0:
			_shooting_stars.remove_at(i)
			
	# Random ambient shooting star across Olympus night vista
	if randf() < delta * 0.15 and _shooting_stars.size() < 2:
		_shooting_stars.append({
			"x": randf_range(400, 650),
			"y": randf_range(0, 30),
			"vx": randf_range(-140.0, -220.0),
			"vy": randf_range(70.0, 120.0),
			"life": 1.0
		})
			
	# Update Starlight Luna Moth
	if moth_active:
		moth_x += (42.0 + sin(_anim_clock * 1.4) * 18.0) * delta
		moth_y = 42.0 + sin(_anim_clock * 2.2) * 16.0 + cos(_anim_clock * 4.0) * 10.0
		if randf() < delta * 4.0:
			_starlight_dust.append({
				"x": moth_x + 12, "y": moth_y + 10,
				"vx": randf_range(-4.0, 4.0), "vy": randf_range(4.0, 14.0),
				"life": randf_range(1.0, 2.0)
			})
		if moth_x > 780.0:
			moth_active = false
			moth_timer = 0.0
	else:
		moth_timer += delta
		if moth_timer > 12.0 and randf() < delta * 0.5:
			moth_active = true
			moth_x = -40.0
			
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
		
		# 1. Canopy Bed Click: Soft dream ripples & sleeping zzz
		if RECT_CANOPY_BED.has_point(pos):
			for i in range(8):
				_spawn_dream_orb(randf_range(200, 260), randf_range(50, 75))
			get_viewport().set_input_as_handled()
			return
			
		# 2. Study Altar & Grimoire Click: Ethereal blue candle flare & page turn
		if RECT_STUDY_ALTAR.has_point(pos) or RECT_GRIMOIRE.has_point(pos):
			_candelabra_flare = 1.0
			for i in range(12):
				_starlight_dust.append({
					"x": randf_range(90, 130), "y": 60.0,
					"vx": randf_range(-15.0, 15.0), "vy": randf_range(-25.0, -10.0),
					"life": randf_range(1.0, 2.0)
				})
			get_viewport().set_input_as_handled()
			return
			
		# 3. Dream Sand Hourglass Click: Spin & flip sand stream
		if RECT_HOURGLASS.has_point(pos):
			_hourglass_inverted = not _hourglass_inverted
			for i in range(15):
				_sand_grains.append({
					"x": randf_range(142, 149), "y": 80.0,
					"vy": randf_range(20.0, 45.0)
				})
			get_viewport().set_input_as_handled()
			return
			
		# 4. Wind Chimes Click: Sway chimes & play celestial chords
		if RECT_CHIMES.has_point(pos):
			_chime_vel += 6.5
			var symbols = ["♪", "♫", "♬", "♩"]
			for i in range(6):
				_music_notes.append({
					"x": randf_range(384, 400), "y": 35.0 - float(i) * 5.0,
					"phase": randf_range(0, TAU), "symbol": symbols[i % symbols.size()],
					"life": randf_range(1.4, 2.2)
				})
			if GameState:
				GameState.joy = minf(GameState.MAX_JOY, GameState.joy + 5.0)
				if EventBus: EventBus.object_state_changed.emit("chimes_struck", true)
			get_viewport().set_input_as_handled()
			return
			
		# 5. Font of Lethe Fountain Click: Splash glowing ripples & toggle flow
		if RECT_LETHE.has_point(pos):
			is_waterfall_flowing = not is_waterfall_flowing
			for i in range(5):
				_water_ripples.append({ "x": 490.0, "y": 88.0, "r": 2.0 + float(i)*3.0, "life": 1.8 })
			if EventBus: EventBus.object_state_changed.emit("lethe_toggled", is_waterfall_flowing)
			get_viewport().set_input_as_handled()
			return
			
		# 6. Balustrade Terrace Click: Trigger shooting star over Olympus!
		if RECT_BALUSTRADE.has_point(pos):
			_shooting_stars.append({
				"x": randf_range(600, 680), "y": 10.0,
				"vx": randf_range(-180.0, -260.0), "vy": randf_range(80.0, 130.0),
				"life": 1.2
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
# 1. PARALLAX BACKGROUND & MIDNIGHT SKY
# ------------------------------------------------------------------------------
func _draw_parallax_background() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	# Full panoramic midnight sky gradient (-120..880, -80..102)
	for y in range(-80, 102, 4):
		var lerp_val = clampf((float(y) + 80.0) / 182.0, 0.0, 1.0)
		draw_rect(Rect2(-120, y, 1000, 4), COL_SKY_TOP.lerp(COL_SKY_BOT, lerp_val))
		
	# Seamless Midnight Olympus Vista tiled across the open terrace (x = 340..880)
	var v_offset = cam_x * 0.12
	var start_vx = 340.0 - v_offset
	for i in range(3):
		var vx_pos = start_vx + float(i) * 380.0
		draw_texture_rect(TEX_VISTA_NIGHT, Rect2(vx_pos, 12.0, 380.0, 88.0), false)
		
	# Twinkling Constellation Stars with Parallax
	var p_offset = cam_x * 0.2
	for s in _stars:
		var sx = fmod(s["x"] - p_offset + 120.0, 1000.0) - 120.0
		var flicker = sin(_anim_clock * 1.8 + s["phase"]) * 0.4 + 0.6
		draw_rect(Rect2(sx, s["y"], s["size"], s["size"]), Color(0.92, 0.95, 1.0, 0.3 + 0.6 * flicker))
		
	# Celestial Moonbeams casting down onto the terrace
	var moon_cx = 530.0 - cam_x * 0.05
	var moon_cy = 35.0
	for r in range(4):
		var angle = (r * PI / 4.0) + _anim_clock * 0.03
		var r_alpha = 0.08 + sin(_anim_clock + r) * 0.03
		var pts = PackedVector2Array([
			Vector2(moon_cx, moon_cy),
			Vector2(moon_cx + 700 * cos(angle - 0.15), moon_cy + 700 * sin(angle - 0.15)),
			Vector2(moon_cx + 700 * cos(angle + 0.15), moon_cy + 700 * sin(angle + 0.15))
		])
		draw_colored_polygon(pts, Color(0.65, 0.85, 1.0, r_alpha))

# ------------------------------------------------------------------------------
# 2. TEMPLE WALLS, CEILING, COLUMNS & DRAPES (50+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_temple_structure() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var a_offset = cam_x * 0.25
	
	# A. Ceiling Cedar Beams with Silver Studs (x = -120..880, y = -14..2) [22 sprites]
	for cx in range(-120, 880, 48):
		draw_texture_rect(TEX_CEILING, Rect2(cx, -14, 48, 16), false)
		draw_rect(Rect2(cx, 1, 48, 2), Color(0.08, 0.10, 0.16, 0.8)) # Shadow under beam
		
	# B. Hanging Star Lanterns swaying gently [4 sprites]
	for lx in [90.0, 230.0, 360.0, 620.0]:
		var swing_offset = sin(_anim_clock * 1.5 + lx * 0.01) * 2.0 + _lantern_swing * 4.0
		draw_line(Vector2(lx, 2), Vector2(lx + swing_offset, 14), COL_SILVER, 1.0)
		draw_texture_rect(TEX_STAR_LANTERN, Rect2(lx + swing_offset - 10, 14, 20, 36), false)
		# Ethereal blue light glow
		var glow_r = 18.0 + sin(_anim_clock * 3.0 + lx) * 3.0
		draw_circle(Vector2(lx + swing_offset, 32), glow_r, Color(0.4, 0.75, 1.0, 0.12))
		
	# C. Interior Ashlar Temple Wall (x = -120..360, y = 2..102) [36 sprites]
	for wx in range(-120, 360, 32):
		for wy in range(2, 102, 32):
			draw_texture_rect(TEX_WALL_STONE, Rect2(wx, wy, 32, 32), false)
			
	# D. Carved Silver Moon Phase Frieze along upper wall (x = -120..360, y = 2..18) [10 sprites]
	for fx in range(-120, 360, 48):
		draw_texture_rect(TEX_WALL_FRIEZE, Rect2(fx, 2, 48, 16), false)
		
	# Wall Shadow boundary separating interior temple from the open terrace
	draw_rect(Rect2(340, 2, 20, 100), Color(0.06, 0.08, 0.14, 0.6))
	
	# E. Blue Flame Wall Sconces [3 sprites]
	for sc_x in [75.0, 195.0, 310.0]:
		draw_texture_rect(TEX_SCONCE, Rect2(sc_x - 8, 48, 16, 34), false)
		# Blue spirit flame glow
		var flame_glow = 12.0 + sin(_anim_clock * 4.0 + sc_x) * 2.5
		draw_circle(Vector2(sc_x, 54), flame_glow, Color(0.3, 0.7, 1.0, 0.2))
		draw_circle(Vector2(sc_x, 54), 3.0, Color(0.85, 0.95, 1.0, 0.8))
		
	# F. Moonflower Vines with Bioluminescent Spores [6 sprites]
	for vx in [35.0, 155.0, 335.0, 475.0, 635.0]:
		draw_texture_rect(TEX_MOONFLOWER_VINES, Rect2(vx - 2, 12, 28, 32), false)
		# Spore glow
		var spore_alpha = sin(_anim_clock * 2.5 + vx) * 0.3 + 0.6
		draw_circle(Vector2(vx + 14, 28), 1.5, Color(0.4, 0.9, 1.0, spore_alpha))
		
	# G. Fluted Moonstone Columns with Silk Drapery [10 sprites]
	for col_x in [40.0, 160.0, 340.0, 480.0, 640.0]:
		var cx = col_x - a_offset * 0.15
		# Column drop shadow
		draw_rect(Rect2(cx - 15, 6, 30, 96), Color(0.04, 0.05, 0.10, 0.35))
		# Moonstone column
		draw_texture_rect(TEX_COLUMN, Rect2(cx - 13, 4, 26, 96), false)
		# Midnight silk column drapes
		draw_texture_rect(TEX_COLUMN_DRAPES, Rect2(cx - 10, 12, 20, 60), false)
		
	# H. Classical Marble Terrace Balustrade Railing (x = 520..740) [4 sprites]
	for bx in range(520, 740, 64):
		draw_texture_rect(TEX_BALUSTRADE, Rect2(bx, 74, 64, 28), false)

# ------------------------------------------------------------------------------
# 3. OBSIDIAN STEPPED FOUNDATION & FLOOR (40+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_floor() -> void:
	# Tier 1: Dark Obsidian Moonstone Floor Tiles (x = -120..880, y = 102..120) [32 sprites]
	for tx in range(-120, 880, 32):
		draw_texture_rect(TEX_FLOOR, Rect2(tx, 102, 32, 18), false)
		
	# Tier 2: Stepped Foundation Edge Lip with Silver Dentils (x = -120..880, y = 120..144) [16 sprites]
	for lx in range(-120, 880, 64):
		draw_texture_rect(TEX_FLOOR_LIP, Rect2(lx, 120, 64, 24), false)
		
	# Tier 3: Sub-foundation bedrock plinth fill down to y = 240 (Zero black void on zoom-out)
	draw_rect(Rect2(-120, 144, 1000, 96), Color(0.08, 0.09, 0.14, 1.0))
	
	# Polished silver edge highlight line
	draw_line(Vector2(-120, 100), Vector2(880, 100), Color(0.85, 0.90, 0.98), 1.2)
	
	# Grand Embroidered Moon Phase Velvet Rug under the canopy bed
	draw_texture_rect(TEX_MOON_RUG, Rect2(184, 98, 92, 30), false)
	
	# Scattered Glowing Moonflower Petals on Steps
	var petals = [
		Vector2(115, 106), Vector2(175, 107), Vector2(290, 106),
		Vector2(370, 108), Vector2(510, 106), Vector2(625, 107)
	]
	for p in petals:
		var p_glow = sin(_anim_clock * 2.0 + p.x) * 0.2 + 0.8
		draw_circle(p, 1.5, Color(0.85, 0.95, 1.0, 0.85 * p_glow))

# ------------------------------------------------------------------------------
# 4. LIVING FURNITURE & INTERACTIVE STATIONS (30+ SPRITES)
# ------------------------------------------------------------------------------
func _draw_props() -> void:
	# 1. Celestial Astrolabe on Pedestal (x = 55, y = 104)
	draw_rect(Rect2(47, 102, 16, 3), Color(0.04, 0.05, 0.08, 0.4))
	draw_texture_rect(TEX_ASTROLABE, Rect2(44, 66, 22, 38), false)
	
	# 2. Grimoire Bookstand & Papyrus Scroll Piles (x = 75, y = 104)
	draw_rect(Rect2(65, 102, 20, 3), Color(0.04, 0.05, 0.08, 0.4))
	draw_texture_rect(TEX_GRIMOIRE_STAND, Rect2(62, 74, 26, 30), false)
	
	# 3. Celestial Study Altar of Somnus (x = 110, y = 104)
	_draw_study_altar(110, 104)
	
	# 4. Enchanted Dream Sand Hourglass (x = 145, y = 104)
	_draw_dream_hourglass(145, 104)
	
	# 5. Grand Royal Canopy Bed of Dreams (x = 230, y = 104)
	_draw_canopy_bed(230, 104)
	
	# 6. Potted Moonflower Urn (x = 300, y = 104)
	draw_rect(Rect2(291, 102, 18, 3), Color(0.04, 0.05, 0.08, 0.4))
	draw_texture_rect(TEX_MOONFLOWER_URN, Rect2(289, 72, 22, 32), false)
	
	# 7. Hanging Dreamcatcher Wind Chimes (x = 390, y = 12)
	_draw_wind_chimes(390, 12)
	
	# 8. Font of Lethe Fountain Basin & Pool (x = 490, y = 104)
	_draw_lethe_fountain(490, 104)
	
	# 9. Starlight Luna Moth fluttering through room
	if moth_active:
		var flap = sin(_anim_clock * 16.0) * 2.0
		draw_texture_rect(TEX_STARLIGHT_MOTH, Rect2(moth_x, moth_y + flap, 24, 20), false)
		draw_circle(Vector2(moth_x + 12, moth_y + 10), 14.0, Color(0.4, 0.85, 1.0, 0.15))

func _draw_study_altar(ax: float, ay: float) -> void:
	var aw = 80.0
	var ah = 42.0
	var x_pos = ax - aw / 2.0
	var y_pos = ay - ah + 2.0
	draw_rect(Rect2(x_pos + 6, ay - 2, aw - 12, 3), Color(0.04, 0.05, 0.08, 0.5))
	draw_texture_rect(TEX_STUDY_ALTAR, Rect2(x_pos, y_pos, aw, ah), false)
	
	# Tabletop Candelabra with Blue Spirit Flames
	var cand_x = ax - 11.0
	var cand_y = y_pos - 32.0
	draw_texture_rect(TEX_CANDELABRA, Rect2(cand_x, cand_y, 22, 34), false)
	
	# Flame Glow & Click Flare
	var flare = 1.0 + _candelabra_flare * 0.8
	var flicker = sin(_anim_clock * 5.0) * 1.5
	for fx_off in [-7.0, 0.0, 7.0]:
		draw_circle(Vector2(ax + fx_off, cand_y + 6 + flicker), 6.0 * flare, Color(0.3, 0.7, 1.0, 0.25))
		draw_circle(Vector2(ax + fx_off, cand_y + 6 + flicker), 2.0, Color(0.9, 0.95, 1.0, 0.85))

func _draw_dream_hourglass(hx: float, hy: float) -> void:
	var hw = 24.0
	var hh = 44.0
	var x_pos = hx - hw / 2.0
	var y_pos = hy - hh + 2.0
	draw_rect(Rect2(x_pos + 4, hy - 2, hw - 8, 3), Color(0.04, 0.05, 0.08, 0.4))
	draw_texture_rect(TEX_DREAM_HOURGLASS, Rect2(x_pos, y_pos, hw, hh), false)
	
	# Luminescent Dream Sand Glow inside glass
	var glow_alpha = sin(_anim_clock * 3.0) * 0.15 + 0.45
	draw_circle(Vector2(hx, hy - 14), 5.0, Color(0.4, 0.9, 1.0, glow_alpha))
	
	# Falling dream sand particles inside glass
	for s in _sand_grains:
		draw_circle(Vector2(s["x"], s["y"]), 1.0, COL_DREAM_SAND)

func _draw_canopy_bed(bx: float, by: float) -> void:
	var bw = 88.0
	var bh = 68.0
	var x_pos = bx - bw / 2.0
	var y_pos = by - bh + 2.0
	draw_rect(Rect2(x_pos + 8, by - 2, bw - 16, 4), Color(0.04, 0.05, 0.08, 0.6))
	draw_texture_rect(TEX_CANOPY_BED, Rect2(x_pos, y_pos, bw, bh), false)

func _draw_wind_chimes(wx: float, wy: float) -> void:
	var ww = 20.0
	var wh = 46.0
	var swing = _chime_swing * 4.0
	draw_line(Vector2(wx, wy), Vector2(wx + swing, wy + 10), COL_SILVER, 1.0)
	draw_texture_rect(TEX_WIND_CHIMES, Rect2(wx - ww / 2.0 + swing, wy + 10, ww, wh), false)

func _draw_lethe_fountain(lx: float, ly: float) -> void:
	var lw = 52.0
	var lh = 44.0
	var x_pos = lx - lw / 2.0
	var y_pos = ly - lh + 2.0
	draw_rect(Rect2(x_pos + 6, ly - 2, lw - 12, 3), Color(0.04, 0.05, 0.08, 0.5))
	draw_texture_rect(TEX_LETHE_FOUNTAIN, Rect2(x_pos, y_pos, lw, lh), false)
	
	# Flowing waterfall & glowing water surface
	if is_waterfall_flowing:
		var water_cx = lx
		var water_cy = ly - 18.0
		var pulse = sin(_anim_clock * 3.0) * 0.15 + 0.6
		draw_circle(Vector2(water_cx, water_cy), 14.0, Color(0.3, 0.8, 1.0, 0.25 * pulse))
		
		# Animated Water Ripples
		for r in _water_ripples:
			var alpha = clampf(r["life"] / 1.8, 0.0, 1.0)
			draw_arc(Vector2(r["x"], r["y"]), r["r"], 0, TAU, 16, Color(COL_LETHE_FOAM.r, COL_LETHE_FOAM.g, COL_LETHE_FOAM.b, alpha), 1.0)

# ------------------------------------------------------------------------------
# 5. DYNAMIC PARTICLE SYSTEMS (30+ ELEMENTS)
# ------------------------------------------------------------------------------
func _draw_dynamic_particles() -> void:
	# A. Floating Luminescent Dream Orbs
	for d in _dreams:
		var alpha = sin(_anim_clock * 2.0 + d["phase"]) * 0.25 + 0.6
		var c = Color(0.55, 0.85, 1.0, alpha * 0.4)
		draw_circle(Vector2(d["x"], d["y"]), 3.5 * d["scale"], c)
		draw_circle(Vector2(d["x"], d["y"]), 1.5 * d["scale"], Color(1.0, 1.0, 1.0, alpha))
		
	# B. Starlight Moth Sparkle Trail
	for sd in _starlight_dust:
		var alpha = clampf(sd["life"] / 2.0, 0.0, 1.0)
		draw_circle(Vector2(sd["x"], sd["y"]), 1.2, Color(0.6, 0.95, 1.0, alpha))
		
	# C. Wind Chime Musical Chords
	for n in _music_notes:
		var alpha = clampf(n["life"] / 2.0, 0.0, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(n["x"], n["y"]), n["symbol"], HORIZONTAL_ALIGNMENT_CENTER, -1, 10, Color(0.85, 0.92, 1.0, alpha))
		
	# D. Streaking Shooting Stars
	for ss in _shooting_stars:
		var alpha = clampf(ss["life"], 0.0, 1.0)
		var p1 = Vector2(ss["x"], ss["y"])
		var p2 = Vector2(ss["x"] - ss["vx"] * 0.08, ss["y"] - ss["vy"] * 0.08)
		draw_line(p1, p2, Color(1.0, 1.0, 1.0, alpha), 1.5)
		draw_circle(p1, 2.0, Color(0.8, 0.95, 1.0, alpha))
