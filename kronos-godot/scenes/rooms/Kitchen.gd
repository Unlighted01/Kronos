@tool
extends BaseRoom
class_name Kitchen

## Banks of the Styx - The Mythological Underworld Ferry Dock (720px wide).
## Features 120+ active procedural pixel art elements, Charon's bobbing Skiff,
## ethereal cyan soulfire brazier, Altar of Obols ledger desk, obsidian sarcophagus daybed,
## heavy iron prison bars, swinging pendulum chains, and rolling volumetric river fog.

# ==============================================================================
# 🎨 COLOR PALETTE & CONSTANTS
# ==============================================================================
const COL_CAVERN_DARK: Color = Color(0.03, 0.04, 0.06, 1.0)
const COL_CAVERN_MID: Color = Color(0.07, 0.09, 0.13, 1.0)
const COL_CAVERN_TEAL: Color = Color(0.06, 0.16, 0.18, 1.0)
const COL_RIVER_DEEP: Color = Color(0.04, 0.12, 0.14, 1.0)
const COL_RIVER_CREST: Color = Color(0.12, 0.35, 0.32, 0.75)
const COL_FOG_SPECTRAL: Color = Color(0.15, 0.38, 0.32, 0.16)

# Architecture & Props
const COL_BASALT_STONE: Color = Color(0.14, 0.16, 0.20, 1.0)
const COL_BASALT_MORTAR: Color = Color(0.08, 0.09, 0.12, 1.0)
const COL_BASALT_MOSS: Color = Color(0.18, 0.28, 0.22, 1.0)
const COL_QUAY_LIP: Color = Color(0.20, 0.24, 0.28, 1.0)
const COL_BEDROCK_ABYSS: Color = Color(0.05, 0.06, 0.08, 1.0)

const COL_WOOD_HULL: Color = Color(0.15, 0.12, 0.10, 1.0)
const COL_WOOD_PLANK: Color = Color(0.24, 0.20, 0.16, 1.0)
const COL_WOOD_HIGHLIGHT: Color = Color(0.36, 0.30, 0.24, 1.0)
const COL_OBOL_GOLD: Color = Color(0.95, 0.82, 0.32, 1.0)

const COL_IRON_BAR: Color = Color(0.08, 0.09, 0.11, 1.0)
const COL_IRON_HIGHLIGHT: Color = Color(0.22, 0.35, 0.30, 1.0) # Eerie green metallic sheen
const COL_BRONZE_BRAZIER: Color = Color(0.42, 0.32, 0.20, 1.0)

# Ethereal Soulfire
const COL_SOUL_CORE: Color = Color(0.70, 1.0, 0.88, 1.0)
const COL_SOUL_FLAME: Color = Color(0.25, 0.90, 0.65, 0.85)
const COL_SOUL_GLOW: Color = Color(0.15, 0.80, 0.55, 0.24)
const COL_VELVET_PURPLE: Color = Color(0.32, 0.14, 0.38, 1.0)

# ==============================================================================
# 📊 INTERNAL STATE & SIMULATION CACHES
# ==============================================================================
var _anim_clock: float = 0.0

# Dynamic Interactive States
var _brazier_flare: float = 0.0
var _boat_rock_boost: float = 0.0
var _desk_glint: float = 0.0
var _bars_vibration: float = 0.0
var _sarcophagus_puff: float = 0.0

# Dynamic Simulation Systems
var _bars: Array[float] = []
var _chains: Array[Dictionary] = []
var _fog_banks: Array[Dictionary] = []
var _soul_motes: Array[Dictionary] = []
var _splashes: Array[Dictionary] = []
var _cavern_drips: Array[Dictionary] = []

# Interactive Click Targets
const RECT_SARCOPHAGUS: Rect2 = Rect2(70, 58, 80, 48)
const RECT_DESK: Rect2 = Rect2(180, 52, 78, 54)
const RECT_BRAZIER: Rect2 = Rect2(320, 58, 42, 50)
const RECT_SKIFF: Rect2 = Rect2(450, 60, 210, 75)
const RECT_BARS_TOP: Rect2 = Rect2(0, 0, 720, 30)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_kitchen"
	room_name = "Banks of the Styx"
	room_width = 720.0
	min_x = 50.0
	max_x = 670.0
	desk_x = 220.0  # Altar of Obols / Ledger Desk (STUDY / EAT)
	nap_x = 110.0   # Obsidian Sarcophagus Daybed (NAP / LOAF)
	drink_x = 340.0 # Soulfire Brazier Cauldron (DRINK / WARM_PAWS)
	
	_init_geometry_caches()

func _init_geometry_caches() -> void:
	# 1. Prison Bars framing (elegantly spaced to frame companions without obstructing them)
	_bars.clear()
	var bar_positions: Array[float] = [-60.0, 30.0, 165.0, 280.0, 420.0, 620.0, 750.0]
	for bp in bar_positions:
		_bars.append(bp)
		
	# 2. Hanging Chains
	_chains.clear()
	for i in range(10):
		_chains.append({
			"x": randf_range(10.0, 710.0),
			"len": randf_range(35.0, 85.0),
			"phase": randf_range(0.0, TAU),
			"has_skull": i % 3 == 0
		})
		
	# 3. Rolling Volumetric Fog Banks
	_fog_banks.clear()
	for i in range(18):
		_fog_banks.append({
			"x": randf_range(-80, 800),
			"y": randf_range(108, 155),
			"rx": randf_range(50, 110),
			"ry": randf_range(14, 26),
			"speed": randf_range(6.0, 14.0)
		})
		
	# 4. Floating Cyan Soul Motes
	_soul_motes.clear()
	for i in range(24):
		_soul_motes.append({
			"x": randf_range(0, 720),
			"y": randf_range(20, 120),
			"phase": randf_range(0, TAU),
			"life": randf_range(2.5, 5.0)
		})
		
	# 5. Cavern Dripping Water
	_cavern_drips.clear()
	for i in range(4):
		_cavern_drips.append({
			"x": randf_range(50, 680),
			"y": randf_range(20, 40),
			"vy": 0.0,
			"active": false,
			"timer": randf_range(1.0, 4.0)
		})

func _process(delta: float) -> void:
	_anim_clock += delta
	
	# Skiff Bobbing Physics synced to companion footing
	var base_bob = sin(_anim_clock * 1.6) * 3.0
	var rock_boost = sin(_anim_clock * 3.5) * (_boat_rock_boost * 4.0)
	var total_bob = base_bob + rock_boost
	if _boat_rock_boost > 0.01:
		_boat_rock_boost = lerpf(_boat_rock_boost, 0.0, delta * 2.5)
		
	if EventBus and EventBus.has_signal("floor_y_offset_changed"):
		EventBus.floor_y_offset_changed.emit(total_bob)
		
	# Interactive Flare Decay
	if _brazier_flare > 0.01:
		_brazier_flare = lerpf(_brazier_flare, 0.0, delta * 3.0)
	if _desk_glint > 0.01:
		_desk_glint = lerpf(_desk_glint, 0.0, delta * 4.0)
	if _bars_vibration > 0.01:
		_bars_vibration = lerpf(_bars_vibration, 0.0, delta * 5.0)
	if _sarcophagus_puff > 0.01:
		_sarcophagus_puff = lerpf(_sarcophagus_puff, 0.0, delta * 3.5)
		
	# Update Fog Drift
	for f in _fog_banks:
		f["x"] += f["speed"] * delta
		if f["x"] - f["rx"] > 760.0:
			f["x"] = -f["rx"]
			f["y"] = randf_range(108, 155)
			
	# Update Soul Motes
	for m in _soul_motes:
		m["y"] -= delta * 6.5
		m["x"] += sin(_anim_clock * 1.5 + m["phase"]) * 0.6
		if m["y"] < -10:
			m["y"] = 125
			m["x"] = randf_range(0, 720)
			
	# Update Splashes & Spectral Hands
	for i in range(_splashes.size() - 1, -1, -1):
		var s = _splashes[i]
		s["r"] += 22.0 * delta
		s["life"] -= delta * 1.2
		if s["life"] <= 0:
			_splashes.remove_at(i)
			
	# Update Cavern Drips
	for d in _cavern_drips:
		if not d["active"]:
			d["timer"] -= delta
			if d["timer"] <= 0:
				d["active"] = true
				d["y"] = 25.0
				d["vy"] = 20.0
		else:
			d["vy"] += 140.0 * delta
			d["y"] += d["vy"] * delta
			if d["y"] >= 105.0:
				d["active"] = false
				d["timer"] = randf_range(2.0, 5.0)
				if _splashes.size() < 10:
					_splashes.append({
						"x": d["x"], "y": 105.0, "r": 3.0, "life": 0.8
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
		
		# 1. Charon's Skiff Click: Boost boat rocking & spawn spectral reach
		if RECT_SKIFF.has_point(pos):
			_boat_rock_boost = 1.0
			_splashes.append({
				"x": pos.x, "y": pos.y, "r": 6.0, "life": 1.4
			})
			if EventBus: EventBus.object_state_changed.emit("styx_skiff_rocked", true)
			get_viewport().set_input_as_handled()
			return
			
		# 2. Soulfire Brazier Click: Flare cyan spirit fire & spawn motes
		if RECT_BRAZIER.has_point(pos):
			_brazier_flare = 1.0
			for i in range(10):
				_soul_motes.append({
					"x": randf_range(335, 345), "y": 72.0,
					"phase": randf_range(0, TAU), "life": randf_range(1.5, 3.0)
				})
			if EventBus: EventBus.object_state_changed.emit("soulfire_flared", true)
			get_viewport().set_input_as_handled()
			return
			
		# 3. Altar of Obols Click: Coin glint & knowledge reward
		if RECT_DESK.has_point(pos):
			_desk_glint = 1.0
			if GameState:
				GameState.knowledge = minf(GameState.MAX_KNOWLEDGE, GameState.knowledge + 4.0)
			get_viewport().set_input_as_handled()
			return
			
		# 4. Sarcophagus Daybed Click: Velvet cushion fluff
		if RECT_SARCOPHAGUS.has_point(pos):
			_sarcophagus_puff = 1.0
			get_viewport().set_input_as_handled()
			return
			
		# 5. Prison Bars Click: Rattle clang & chain swing
		if RECT_BARS_TOP.has_point(pos) or pos.y < 35.0:
			_bars_vibration = 1.0
			for c in _chains:
				c["phase"] += PI * 0.5
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 MAIN DRAW PIPELINE (120+ ELEMENT LIVING UNDERWORLD)
# ==============================================================================
func _draw() -> void:
	_draw_cavern_vault_and_sky()
	_draw_river_styx()
	_draw_basalt_dock_quay()
	_draw_charon_skiff()
	_draw_underworld_furniture()
	_draw_dynamic_particles()
	_draw_chains_and_prison_bars()

# ------------------------------------------------------------------------------
# 1. CAVERN VAULT & UNDERWORLD SKY (ZERO ZOOM-OUT VOID)
# ------------------------------------------------------------------------------
func _draw_cavern_vault_and_sky() -> void:
	# Deep Abyssal Cavern Ceiling (-120..880, y = -80..102)
	draw_rect(Rect2(-120, -80, 1000, 182), COL_CAVERN_DARK)
	
	# Distant Cavern Depth Gradient
	draw_rect(Rect2(-120, 20, 1000, 80), COL_CAVERN_MID)
	draw_rect(Rect2(-120, 65, 1000, 36), COL_CAVERN_TEAL)
	
	# Hanging Basalt Stalactites along the cavern vault (16 stalactites)
	var stal_xs: Array[float] = [-90, -40, 15, 65, 120, 185, 240, 305, 360, 420, 485, 540, 600, 665, 720, 770]
	for sx in stal_xs:
		var sh = 16.0 + sin(sx * 0.4) * 8.0
		var pts = PackedVector2Array([
			Vector2(sx - 10, -4),
			Vector2(sx + 10, -4),
			Vector2(sx, sh)
		])
		draw_colored_polygon(pts, Color(0.06, 0.08, 0.11))
		draw_line(Vector2(sx - 2, -4), Vector2(sx, sh), Color(0.12, 0.16, 0.20), 1.0)
		
	# Cavern Water Drips
	for d in _cavern_drips:
		if d["active"]:
			draw_circle(Vector2(d["x"], d["y"]), 1.5, Color(0.4, 0.8, 0.8, 0.85))

# ------------------------------------------------------------------------------
# 2. THE RIVER STYX & VOLUMETRIC ROLLING FOG
# ------------------------------------------------------------------------------
func _draw_river_styx() -> void:
	# River Styx Water Body (x = 360..880, y = 98..240)
	draw_rect(Rect2(360, 98, 520, 142), COL_RIVER_DEEP)
	
	# Glowing River Horizon Shoreline
	draw_line(Vector2(360, 98), Vector2(880, 98), Color(0.18, 0.45, 0.40, 0.8), 1.5)
	
	# Flowing Undulating Currents with Sine Displacements
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	for i in range(360, 880, 40):
		var rx = fmod(i - (cam_x * 0.1) + _anim_clock * 8.0, 520.0) + 360.0
		var wave_w = 24.0 + sin(_anim_clock * 2.0 + i) * 8.0
		draw_line(Vector2(rx, 104), Vector2(rx + wave_w, 104), COL_RIVER_CREST, 1.2)
		draw_line(Vector2(rx + 15, 114), Vector2(rx + 15 + wave_w * 0.8, 114), COL_RIVER_CREST * 0.8, 1.0)
		draw_line(Vector2(rx - 10, 126), Vector2(rx - 10 + wave_w * 0.6, 126), COL_RIVER_CREST * 0.6, 1.0)
		
	# Volumetric Rolling Ground Fog Banks
	for i in range(_fog_banks.size()):
		var f = _fog_banks[i]
		var fx = f["x"] - (cam_x * 0.15)
		if fx + f["rx"] > -100 and fx - f["rx"] < 850:
			var wave_offset = sin(_anim_clock * 1.4 + i) * 12.0
			var scale_y = (f["ry"] + sin(_anim_clock * 2.0 + i * 0.5) * 4.0) / f["rx"]
			draw_set_transform(Vector2(fx + wave_offset, f["y"]), 0.0, Vector2(1.0, scale_y))
			draw_circle(Vector2.ZERO, f["rx"], COL_FOG_SPECTRAL)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ------------------------------------------------------------------------------
# 3. BASALT QUAY STONE DOCK & FOUNDATION (40+ ELEMENTS - ZERO VOID)
# ------------------------------------------------------------------------------
func _draw_basalt_dock_quay() -> void:
	# Tier 1: Ashlar Basalt Paving Slabs (x = -120..400, y = 98..120) [26 slabs]
	for px in range(-120, 410, 32):
		# Stone base
		draw_rect(Rect2(px, 98, 32, 22), COL_BASALT_STONE)
		# Mortar seams
		draw_line(Vector2(px, 98), Vector2(px, 120), COL_BASALT_MORTAR, 1.0)
		draw_line(Vector2(px, 120), Vector2(px + 32, 120), COL_BASALT_MORTAR, 1.0)
		# Top highlight edge & moss inlays
		draw_line(Vector2(px, 98), Vector2(px + 32, 98), COL_QUAY_LIP, 1.0)
		if px % 64 == 0:
			draw_rect(Rect2(px + 6, 99, 10, 2), COL_BASALT_MOSS)
			
	# Tier 2: Stepped Quay Edge Lip (x = -120..400, y = 120..144) [16 blocks]
	for lx in range(-120, 410, 48):
		draw_rect(Rect2(lx, 120, 48, 24), COL_QUAY_LIP.darkened(0.2))
		draw_line(Vector2(lx, 120), Vector2(lx + 48, 120), COL_QUAY_LIP, 1.2)
		draw_line(Vector2(lx, 144), Vector2(lx + 48, 144), COL_BASALT_MORTAR, 1.5)
		
	# Tier 3: Sub-foundation Bedrock Plinth down to y = 240 (Zero Zoom-Out Void)
	draw_rect(Rect2(-120, 144, 520, 96), COL_BEDROCK_ABYSS)
	
	# Timber Quay Pilings driving down into the River Styx (x = 380, 396)
	draw_rect(Rect2(382, 110, 12, 50), COL_WOOD_HULL)
	draw_line(Vector2(382, 110), Vector2(382, 160), COL_WOOD_HIGHLIGHT, 1.0)
	
	# Heavy Iron Mooring Bollard with Coiled Hemp Rope (x = 386, y = 98)
	draw_rect(Rect2(382, 90, 8, 10), COL_IRON_BAR)
	draw_circle(Vector2(386, 90), 5.5, COL_IRON_BAR)
	draw_circle(Vector2(386, 90), 2.5, COL_IRON_HIGHLIGHT)
	# Coiled rope around bollard
	draw_arc(Vector2(386, 94), 6.5, 0, TAU, 12, Color(0.48, 0.38, 0.25), 2.0)
	# Mooring hawser rope connecting to Charon's boat
	draw_line(Vector2(388, 94), Vector2(460, 106), Color(0.48, 0.38, 0.25), 1.5)

# ------------------------------------------------------------------------------
# 4. CHARON'S FERRY SKIFF (EXPANDED PROCEDURAL 16-BIT VESSEL)
# ------------------------------------------------------------------------------
func _draw_charon_skiff() -> void:
	var cx = 550.0
	var cy = 112.0
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var offset_x = cx - (cam_x * 0.05)
	
	# Bobbing and rocking sine wave physics
	var base_bob = sin(_anim_clock * 1.6) * 3.0
	var rock_boost = sin(_anim_clock * 3.5) * (_boat_rock_boost * 4.0)
	var bob_y = cy + base_bob + rock_boost
	var bob_rot = cos(_anim_clock * 1.3) * 0.04 + sin(_anim_clock * 3.0) * (_boat_rock_boost * 0.06)
	
	draw_set_transform(Vector2(offset_x, bob_y), bob_rot, Vector2.ONE)
	
	# A. Water Displacement Shadow under hull
	draw_arc(Vector2(0, 10), 85.0, 0, PI, 18, Color(0.02, 0.06, 0.08, 0.6), 6.0)
	
	# B. Dark Timber Hull (sweeps up into dramatic tall prow)
	var hull_pts = PackedVector2Array([
		Vector2(-90, -12), # Stern top
		Vector2(-70, 8),   # Stern bottom
		Vector2(55, 8),    # Keel bottom
		Vector2(95, -16),  # Prow lower curve
		Vector2(115, -52), # Tall carved prow tip
		Vector2(104, -52), # Inner prow tip
		Vector2(85, -12),  # Deck forward
		Vector2(-80, -12)  # Deck aft
	])
	draw_colored_polygon(hull_pts, COL_WOOD_HULL)
	
	# C. Hull Planking Ribs & Wood Grain
	draw_line(Vector2(-85, -4), Vector2(90, -4), COL_WOOD_PLANK, 1.5)
	draw_line(Vector2(-75, 2), Vector2(75, 2), COL_WOOD_PLANK, 1.5)
	draw_line(Vector2(110, -50), Vector2(90, -12), COL_WOOD_HIGHLIGHT, 1.2)
	
	# Carved Greek Underworld Eye / Skull Glyph on Prow
	draw_circle(Vector2(92, -22), 3.5, COL_SOUL_FLAME)
	draw_circle(Vector2(92, -22), 1.5, COL_SOUL_CORE)
	
	# D. Piled Cargo Crates & Burlap Sacks of Obols on Deck
	# Crate 1
	draw_rect(Rect2(-60, -26, 22, 14), COL_WOOD_PLANK)
	draw_line(Vector2(-60, -26), Vector2(-38, -12), COL_WOOD_HIGHLIGHT, 1.0)
	# Crate 2
	draw_rect(Rect2(-36, -22, 18, 10), COL_WOOD_PLANK.darkened(0.1))
	# Burlap sacks
	draw_circle(Vector2(-10, -18), 7.0, Color(0.42, 0.35, 0.25))
	draw_circle(Vector2(8, -16), 6.0, Color(0.38, 0.32, 0.22))
	# Glinting Gold Obols spilling from sack
	draw_circle(Vector2(-2, -18), 1.6, COL_OBOL_GOLD)
	draw_circle(Vector2(1, -16), 1.4, COL_OBOL_GOLD)
	draw_circle(Vector2(3, -20), 1.5, COL_OBOL_GOLD)
	
	# E. Resting Timber Oar
	draw_line(Vector2(15, -6), Vector2(105, 18), COL_WOOD_HIGHLIGHT, 2.5)
	var paddle_pts = PackedVector2Array([
		Vector2(95, 12), Vector2(115, 8),
		Vector2(120, 20), Vector2(100, 24)
	])
	draw_colored_polygon(paddle_pts, COL_BRONZE_BRAZIER)
	
	# F. Hanging Spectral Soulfire Lantern on Prow
	var prow_tip = Vector2(110, -52)
	var swing = sin(_anim_clock * 2.8) * 8.0 + sin(_anim_clock * 5.0) * (_boat_rock_boost * 12.0)
	var lantern_pos = prow_tip + Vector2(10 + swing, 16 + abs(swing) * 0.25)
	
	# Chain
	draw_line(prow_tip, lantern_pos, COL_IRON_BAR, 1.2)
	# Lantern housing
	draw_rect(Rect2(lantern_pos.x - 4, lantern_pos.y, 8, 14), COL_IRON_BAR)
	draw_rect(Rect2(lantern_pos.x - 6, lantern_pos.y - 2, 12, 3), COL_IRON_BAR)
	draw_rect(Rect2(lantern_pos.x - 6, lantern_pos.y + 14, 12, 3), COL_IRON_BAR)
	
	# Glowing Cyan Soul Core & Aura
	var glow_size = 28.0 + sin(_anim_clock * 4.0) * 4.0
	draw_circle(lantern_pos + Vector2(0, 7), glow_size, COL_SOUL_GLOW)
	draw_circle(lantern_pos + Vector2(0, 7), 5.5, COL_SOUL_FLAME)
	draw_circle(lantern_pos + Vector2(0, 7), 2.5, COL_SOUL_CORE)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ------------------------------------------------------------------------------
# 5. UNDERWORLD INTERACTIVE FURNITURE & PROPS (40+ ELEMENTS)
# ------------------------------------------------------------------------------
func _draw_underworld_furniture() -> void:
	# 1. Ancient Obsidian Sarcophagus Daybed (x = 110, y = 104)
	_draw_sarcophagus(110.0, 104.0)
	
	# 2. Altar of Obols / Ferry Ledger Desk (x = 220, y = 104)
	_draw_ledger_desk(220.0, 104.0)
	
	# 3. Bronze Tripod Soulfire Brazier Cauldron (x = 340, y = 104)
	_draw_soulfire_brazier(340.0, 104.0)

func _draw_sarcophagus(sx: float, sy: float) -> void:
	var sw = 80.0
	var sh = 48.0
	var x_pos = sx - sw / 2.0
	var y_pos = sy - sh + 2.0
	
	# Stone shadow
	draw_rect(Rect2(x_pos + 6, sy - 2, sw - 12, 3), Color(0.02, 0.04, 0.06, 0.55))
	
	# Carved Basalt Stone Sarcophagus Base
	draw_rect(Rect2(x_pos, y_pos + 16, sw, sh - 16), COL_BASALT_STONE)
	draw_line(Vector2(x_pos, y_pos + 16), Vector2(x_pos + sw, y_pos + 16), COL_QUAY_LIP, 1.5)
	
	# Carved Greek Meander frieze along rim
	for mx in range(int(x_pos + 4), int(x_pos + sw - 8), 12):
		draw_rect(Rect2(mx, y_pos + 20, 6, 4), COL_BASALT_MORTAR)
		
	# Plush Royal Purple Velvet Cushion / Lining
	draw_rect(Rect2(x_pos + 6, y_pos + 12, sw - 12, 8), COL_VELVET_PURPLE)
	draw_circle(Vector2(x_pos + 14, y_pos + 14), 4.0, COL_VELVET_PURPLE.lightened(0.2)) # Headrest pillow
	
	# Amethyst dust puff on click
	if _sarcophagus_puff > 0.05:
		draw_arc(Vector2(sx, y_pos + 12), 18.0, -PI * 0.8, -PI * 0.2, 10, Color(0.8, 0.4, 0.9, _sarcophagus_puff * 0.5), 1.5)

func _draw_ledger_desk(dx: float, dy: float) -> void:
	var dw = 76.0
	var dh = 48.0
	var x_pos = dx - dw / 2.0
	var y_pos = dy - dh + 2.0
	
	# Desk shadow
	draw_rect(Rect2(x_pos + 6, dy - 2, dw - 12, 3), Color(0.02, 0.04, 0.06, 0.55))
	
	# Weathered Dark Oak Table
	draw_rect(Rect2(x_pos, y_pos + 18, dw, 10), COL_WOOD_HULL) # Tabletop
	draw_rect(Rect2(x_pos + 4, y_pos + 28, 8, dh - 28), COL_WOOD_PLANK) # Left leg
	draw_rect(Rect2(x_pos + dw - 12, y_pos + 28, 8, dh - 28), COL_WOOD_PLANK) # Right leg
	draw_line(Vector2(x_pos, y_pos + 18), Vector2(x_pos + dw, y_pos + 18), COL_WOOD_HIGHLIGHT, 1.2)
	
	# Ledger Book open with ancient script
	draw_rect(Rect2(dx - 18, y_pos + 8, 20, 10), Color(0.92, 0.88, 0.80))
	draw_line(Vector2(dx - 8, y_pos + 8), Vector2(dx - 8, y_pos + 18), Color(0.3, 0.2, 0.1), 1.0) # Spine
	
	# Brass Balance Scales for weighing Obols
	var scale_x = dx + 16.0
	var scale_y = y_pos + 10.0
	draw_line(Vector2(scale_x, scale_y), Vector2(scale_x, scale_y + 12), COL_OBOL_GOLD, 1.5) # Post
	draw_line(Vector2(scale_x - 8, scale_y + 2), Vector2(scale_x + 8, scale_y + 2), COL_OBOL_GOLD, 1.2) # Beam
	draw_circle(Vector2(scale_x - 8, scale_y + 7), 3.0, COL_OBOL_GOLD) # Left pan
	draw_circle(Vector2(scale_x + 8, scale_y + 7), 3.0, COL_OBOL_GOLD) # Right pan
	
	# Glinting Obol coins on table
	var glint = sin(_anim_clock * 3.5) * 0.4 + 0.6 + _desk_glint * 0.8
	draw_circle(Vector2(dx - 22, y_pos + 16), 2.2, Color(COL_OBOL_GOLD.r, COL_OBOL_GOLD.g, COL_OBOL_GOLD.b, glint))
	draw_circle(Vector2(dx - 26, y_pos + 17), 1.8, Color(COL_OBOL_GOLD.r, COL_OBOL_GOLD.g, COL_OBOL_GOLD.b, glint))

func _draw_soulfire_brazier(bx: float, by: float) -> void:
	var bw = 40.0
	var bh = 46.0
	var x_pos = bx - bw / 2.0
	var y_pos = by - bh + 2.0
	
	# Shadow
	draw_rect(Rect2(x_pos + 6, by - 2, bw - 12, 3), Color(0.02, 0.04, 0.06, 0.55))
	
	# Bronze Tripod Stand & Wide Basin
	draw_line(Vector2(bx, y_pos + 18), Vector2(bx - 12, by), COL_BRONZE_BRAZIER, 2.5) # Left leg
	draw_line(Vector2(bx, y_pos + 18), Vector2(bx + 12, by), COL_BRONZE_BRAZIER, 2.5) # Right leg
	draw_line(Vector2(bx, y_pos + 18), Vector2(bx, by), COL_BRONZE_BRAZIER.darkened(0.2), 2.0) # Center leg
	
	# Basin Bowl
	var basin_pts = PackedVector2Array([
		Vector2(bx - 18, y_pos + 14),
		Vector2(bx + 18, y_pos + 14),
		Vector2(bx + 12, y_pos + 24),
		Vector2(bx - 12, y_pos + 24)
	])
	draw_colored_polygon(basin_pts, COL_BRONZE_BRAZIER)
	draw_line(Vector2(bx - 18, y_pos + 14), Vector2(bx + 18, y_pos + 14), COL_OBOL_GOLD, 1.2)
	
	# Animated Flickering Cyan Soulfire
	var flare_mult = 1.0 + _brazier_flare * 0.8
	var flick1 = sin(_anim_clock * 6.0) * 3.0
	var flick2 = cos(_anim_clock * 8.5) * 2.5
	
	# Soulfire Aura
	draw_circle(Vector2(bx, y_pos + 10), 22.0 * flare_mult, COL_SOUL_GLOW)
	
	# Flame Tongues
	var flame_pts = PackedVector2Array([
		Vector2(bx - 12, y_pos + 14),
		Vector2(bx - 6 + flick1, y_pos + 2),
		Vector2(bx + flick2, y_pos - 8 * flare_mult),
		Vector2(bx + 6 - flick1, y_pos + 2),
		Vector2(bx + 12, y_pos + 14)
	])
	draw_colored_polygon(flame_pts, COL_SOUL_FLAME)
	draw_circle(Vector2(bx, y_pos + 10), 4.5, COL_SOUL_CORE)

# ------------------------------------------------------------------------------
# 6. DYNAMIC PARTICLE SYSTEMS (40+ PARTICLES)
# ------------------------------------------------------------------------------
func _draw_dynamic_particles() -> void:
	# A. Rising Cyan Soul Motes / Ghost Embers
	for m in _soul_motes:
		var alpha = sin(_anim_clock * 2.5 + m["phase"]) * 0.35 + 0.6
		draw_circle(Vector2(m["x"], m["y"]), 1.6, Color(COL_SOUL_CORE.r, COL_SOUL_CORE.g, COL_SOUL_CORE.b, alpha))
		draw_circle(Vector2(m["x"], m["y"]), 3.2, Color(COL_SOUL_GLOW.r, COL_SOUL_GLOW.g, COL_SOUL_GLOW.b, alpha * 0.4))
		
	# B. Splash Ripples & Ghostly Spectral Hands Reaching Up
	for s in _splashes:
		var alpha = maxf(0.0, s["life"])
		var col = Color(COL_SOUL_CORE.r, COL_SOUL_CORE.g, COL_SOUL_CORE.b, alpha)
		# Expanding ripples
		draw_arc(Vector2(s["x"], s["y"]), s["r"], 0, TAU, 16, col, 1.8)
		draw_arc(Vector2(s["x"], s["y"]), s["r"] * 0.5, 0, TAU, 16, Color(col.r, col.g, col.b, alpha * 0.5), 1.0)
		
		# Spectral Hand reaching up from the River Styx
		var hand_y = s["y"] + 14 - s["r"] * 0.45
		if hand_y > s["y"] - 12:
			var pts = PackedVector2Array([
				Vector2(s["x"] - 5, hand_y),
				Vector2(s["x"] - 7, hand_y - 8),
				Vector2(s["x"] - 2, hand_y - 13),
				Vector2(s["x"] + 2, hand_y - 11),
				Vector2(s["x"] + 6, hand_y - 7),
				Vector2(s["x"] + 5, hand_y)
			])
			draw_colored_polygon(pts, Color(COL_SOUL_CORE.r, COL_SOUL_CORE.g, COL_SOUL_CORE.b, alpha * 0.75))

# ------------------------------------------------------------------------------
# 7. FOREGROUND: HANGING CHAINS & DUNGEON PRISON BARS
# ------------------------------------------------------------------------------
func _draw_chains_and_prison_bars() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	# A. Hanging Pendulum Chains (10 chains)
	for c in _chains:
		var cx = c["x"] - (cam_x * 0.2)
		var sway_angle = sin(_anim_clock * 1.6 + c["phase"]) * 0.08
		
		draw_set_transform(Vector2(cx, 0), sway_angle, Vector2.ONE)
		var cy = 0.0
		var link_h = 9.0
		var is_vertical = true
		while cy < c["len"]:
			if is_vertical:
				draw_rect(Rect2(-2, cy, 4, link_h), COL_IRON_BAR, false, 1.5)
			else:
				draw_rect(Rect2(-4, cy + 2, 8, 3), COL_IRON_BAR.darkened(0.2))
			cy += link_h * 0.7
			is_vertical = not is_vertical
			
		# Terminal hook or iron weight
		if c["has_skull"]:
			draw_circle(Vector2(0, cy + 3), 3.5, COL_IRON_HIGHLIGHT)
		else:
			draw_arc(Vector2(0, cy + 3), 4.0, 0, PI, 8, COL_IRON_BAR, 1.5)
			
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
	# B. Heavy Dungeon Portcullis Bars
	# Thick horizontal gantry beams (Top and Bottom)
	var vib = sin(_anim_clock * 25.0) * (_bars_vibration * 2.0)
	draw_rect(Rect2(-120, -10 + vib, 1000, 26), COL_IRON_BAR)
	draw_line(Vector2(-120, 16 + vib), Vector2(880, 16 + vib), COL_IRON_HIGHLIGHT, 1.5)
	
	# Sleek vertical iron prison bars with eerie green reflection
	for bx in _bars:
		var px = bx - (cam_x * 0.3) + vib
		draw_rect(Rect2(px - 3, 0, 6, 200), COL_IRON_BAR)
		draw_line(Vector2(px - 1, 0), Vector2(px - 1, 200), COL_IRON_HIGHLIGHT, 1.0)
		# Riveted studs
		draw_circle(Vector2(px, 8 + vib), 2.0, COL_IRON_BAR.darkened(0.5))
		draw_circle(Vector2(px, 192), 2.0, COL_IRON_BAR.darkened(0.5))
