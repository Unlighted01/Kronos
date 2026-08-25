@tool
extends BaseRoom
class_name LivingRoom

## Hearth of Hestia - Premium Mythological Domain (720px wide).
## Features a parallax sunset of Olympus, dynamic mystical fire offerings, and Hestia's Ember.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
# Background / Parallax
const COL_SKY_TOP: Color = Color(0.12, 0.08, 0.15, 1.0)
const COL_SKY_BOT: Color = Color(0.85, 0.35, 0.20, 1.0)
const COL_MOUNTAIN_FAR: Color = Color(0.15, 0.10, 0.12, 1.0)
const COL_MOUNTAIN_NEAR: Color = Color(0.20, 0.15, 0.15, 1.0)

const COL_WALL_BACK: Color = Color(0.18, 0.15, 0.16, 1.0)
const COL_FLOOR_BASE: Color = Color(0.20, 0.18, 0.20, 1.0)
const COL_FLOOR_MOSAIC: Color = Color(0.45, 0.35, 0.25, 1.0)

# Fire & Hearth (Base Colors)
const COL_HEARTH_STONE: Color = Color(0.25, 0.22, 0.24, 1.0)
const COL_HEARTH_EDGE: Color = Color(0.35, 0.32, 0.34, 1.0)
const COL_ASH: Color = Color(0.15, 0.12, 0.14, 1.0)

# Sacred Fire target palettes
const FIRE_PALETTES = [
	# Default Warm
	{ "core": Color(1.0, 0.90, 0.40, 1.0), "mid": Color(1.0, 0.55, 0.15, 1.0), "edge": Color(0.85, 0.20, 0.10, 1.0) },
	# Mystic Green (Olive branch offering)
	{ "core": Color(0.70, 1.0, 0.40, 1.0), "mid": Color(0.20, 0.85, 0.30, 1.0), "edge": Color(0.10, 0.50, 0.20, 1.0) },
	# Arcane Purple (Lavender offering)
	{ "core": Color(0.90, 0.70, 1.0, 1.0), "mid": Color(0.60, 0.30, 0.90, 1.0), "edge": Color(0.30, 0.10, 0.60, 1.0) },
	# Divine Blue (Lotus offering)
	{ "core": Color(0.60, 0.90, 1.0, 1.0), "mid": Color(0.20, 0.55, 1.0, 1.0), "edge": Color(0.10, 0.20, 0.80, 1.0) }
]

const COL_MARBLE: Color = Color(0.92, 0.94, 0.95, 1.0)
const COL_MARBLE_SHADE: Color = Color(0.75, 0.78, 0.82, 1.0)

# Furniture & Decor
const COL_PELT: Color = Color(0.85, 0.78, 0.70, 1.0)
const COL_PELT_SHADOW: Color = Color(0.65, 0.55, 0.48, 1.0)
const COL_BRONZE: Color = Color(0.65, 0.45, 0.25, 1.0)
const COL_SCROLL: Color = Color(0.90, 0.85, 0.75, 1.0)
const COL_WOOD: Color = Color(0.35, 0.22, 0.15, 1.0)
const COL_OIL_FLAME: Color = Color(0.95, 0.85, 0.40, 1.0)
const COL_WATER: Color = Color(0.40, 0.80, 0.95, 0.8)

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _anim_clock: float = 0.0
var _sparks: Array[Dictionary] = []
var _water_drops: Array[Dictionary] = []

# Interaction state
var is_hearth_lit: bool = true

# Fire Color Interpolation
var cur_fire_core: Color = FIRE_PALETTES[0].core
var cur_fire_mid: Color = FIRE_PALETTES[0].mid
var cur_fire_edge: Color = FIRE_PALETTES[0].edge
var target_fire_idx: int = 0

# Hestia's Ember (Passive Entity)
var ember_x: float = 360.0
var ember_y: float = 80.0
var ember_base_x: float = 360.0
var ember_base_y: float = 80.0
var ember_phase: float = 0.0

# Bounding Boxes
const RECT_HEARTH: Rect2 = Rect2(150, 70, 60, 50)
const RECT_DESK: Rect2 = Rect2(380, 80, 140, 40)
const RECT_AMPHORA: Rect2 = Rect2(410, 70, 30, 40)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_livingroom"
	room_name = "Cozy Living Room"
	room_width = 720.0
	min_x = 120.0
	max_x = 680.0
	desk_x = 450.0 # Feasting table
	nap_x = 200.0  # Fur pelts by the left hearth
	drink_x = 420.0 # Amphora on table
	
	if GameState:
		is_hearth_lit = GameState.get_object_state("hestia_hearth_lit", true)
		
	# Global drifting embers
	for i in range(25):
		_spawn_spark(true)

func _spawn_spark(random_y: bool = false) -> void:
	_sparks.append({
		"x": randf_range(120, 250), # Spawn near the left hearth
		"y": randf_range(0, 140) if random_y else randf_range(90, 110),
		"vx": randf_range(5.0, 35.0), # Blow to the right
		"vy": randf_range(-10.0, -30.0),
		"life": randf_range(0.5, 1.0)
	})

func _spawn_hearth_burst() -> void:
	for i in range(30):
		_sparks.append({
			"x": randf_range(150, 220),
			"y": randf_range(70, 90),
			"vx": randf_range(-20.0, 80.0),
			"vy": randf_range(-50.0, -120.0),
			"life": 1.0
		})

func _process(delta: float) -> void:
	_anim_clock += delta * 2.0
	var tp = FIRE_PALETTES[target_fire_idx]
	cur_fire_core = cur_fire_core.lerp(tp.core, delta * 3.0)
	cur_fire_mid = cur_fire_mid.lerp(tp.mid, delta * 3.0)
	cur_fire_edge = cur_fire_edge.lerp(tp.edge, delta * 3.0)
	
	if is_hearth_lit:
		for i in range(_sparks.size() - 1, -1, -1):
			var s = _sparks[i]
			s["x"] += (s["vx"] + sin(_anim_clock * 3.0 + s["y"]) * 5.0) * delta
			s["y"] += s["vy"] * delta
			s["life"] -= delta * 0.5 # Fades out over ~2 seconds
			
			if s["life"] <= 0:
				# Respawn tightly at the hearth center (x=180, y=105)
				s["y"] = randf_range(100, 105)
				s["x"] = randf_range(170, 190)
				s["vx"] = randf_range(-15.0, 15.0)
				s["vy"] = randf_range(-20.0, -50.0)
				s["life"] = randf_range(0.5, 1.5)
				
		ember_phase += delta
		var orbit_r = 50.0 + sin(ember_phase * 0.5) * 30.0
		ember_base_x = 200.0 + sin(ember_phase * 0.8) * orbit_r
		ember_base_y = 70.0 + cos(ember_phase * 1.2) * (orbit_r * 0.5)
		
		ember_x = lerpf(ember_x, ember_base_x, delta * 4.0)
		ember_y = lerpf(ember_y, ember_base_y, delta * 4.0)
		
		if randf() < 0.2:
			_sparks.append({
				"x": ember_x, "y": ember_y,
				"vx": randf_range(-5.0, 5.0), "vy": randf_range(-10.0, 0.0),
				"life": 1.0
			})
			
	for i in range(_water_drops.size() - 1, -1, -1):
		var d = _water_drops[i]
		d["vy"] += 200.0 * delta
		d["x"] += d["vx"] * delta
		d["y"] += d["vy"] * delta
		if d["y"] > 110.0:
			_water_drops.remove_at(i)
			
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
		var pos: Vector2 = mb.position + Vector2(cam_x, 0)
		
		if RECT_HEARTH.has_point(pos):
			is_hearth_lit = not is_hearth_lit
			if EventBus: EventBus.object_state_changed.emit("hearth_toggled", is_hearth_lit)
			get_viewport().set_input_as_handled()
			return
			
		if RECT_DESK.has_point(pos) and is_hearth_lit:
			target_fire_idx = (target_fire_idx + 1) % FIRE_PALETTES.size()
			# Burst of sparks
			for i in range(15):
				_sparks.append({
					"x": ember_x, "y": ember_y,
					"vx": randf_range(-40.0, 40.0), "vy": randf_range(-60.0, -10.0),
					"life": 1.5
				})
			if EventBus: EventBus.object_state_changed.emit("hearth_offering_burned", true)
			get_viewport().set_input_as_handled()
			return
			
		if RECT_AMPHORA.has_point(pos):
			for i in range(12):
				_water_drops.append({
					"x": randf_range(415, 425),
					"y": 90.0,
					"vx": randf_range(-30.0, 30.0),
					"vy": randf_range(-70.0, -20.0)
				})
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 DRAWING PIPELINE
# ==============================================================================
func _draw() -> void:
	_draw_parallax_background()
	_draw_temple_structure()
	_draw_floor()
	_draw_embers()
	
	# Left Zone: Huge Chimney & Cozy Lounging Couch
	_draw_massive_hearth(180, 105)
	_draw_lounging_couch(240, 105)
	
	# Center Zone: Feasting Table
	_draw_feasting_table(450, 105)
	
	_draw_amphora(420, 90)
	for d in _water_drops:
		draw_circle(Vector2(d["x"], d["y"]), 1.5, COL_WATER)
	
	_draw_hestias_ember()

func _draw_parallax_background() -> void:
	for y in range(0, 100, 4):
		var lerp_val = y / 100.0
		draw_rect(Rect2(0, y, 720, 4), COL_SKY_TOP.lerp(COL_SKY_BOT, lerp_val))
		
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	# Distant Mountains (Heightmap via vertical slices)
	var m_offset_far = cam_x * 0.1
	for mx in range(0, 720, 4):
		var world_x = mx + m_offset_far
		var height = 50.0 + sin(world_x * 0.02) * 15.0 + cos(world_x * 0.05) * 10.0 + sin(world_x * 0.01) * 20.0
		if height < 100:
			draw_rect(Rect2(mx, height, 4, 100 - height), COL_MOUNTAIN_FAR)
	
	# Near Mountains (Heightmap via vertical slices)
	var m_offset_near = cam_x * 0.2
	for mx in range(0, 720, 4):
		var world_x = mx + m_offset_near
		var height = 65.0 + cos(world_x * 0.03 + 2.0) * 12.0 + sin(world_x * 0.07) * 8.0 + sin(world_x * 0.015 + 1.0) * 25.0
		if height < 100:
			draw_rect(Rect2(mx, height, 4, 100 - height), COL_MOUNTAIN_NEAR)

func _draw_temple_structure() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var a_offset = cam_x * 0.3
	
	draw_rect(Rect2(0, 85, 720, 15), COL_WALL_BACK)
	
	# Massive Chimney structure on the left (parallaxes slightly)
	var cx = 100 - a_offset
	draw_rect(Rect2(cx, 0, 160, 100), COL_HEARTH_STONE)
	draw_rect(Rect2(cx - 10, 0, 10, 100), COL_WALL_BACK)
	draw_rect(Rect2(cx + 160, 0, 10, 100), COL_WALL_BACK)
	
	# Open arches on the right
	for ax in range(400, 850, 160):
		var x = ax - a_offset
		# Pillar Body
		draw_rect(Rect2(x, 0, 30, 100), COL_WALL_BACK)
		
		# Architectural Fluting
		for fx in range(int(x) + 5, int(x) + 26, 6):
			draw_line(Vector2(fx, 0), Vector2(fx, 100), COL_HEARTH_EDGE, 1.0)
			
		# Carved Capital (Top)
		draw_rect(Rect2(x - 5, 20, 40, 10), COL_HEARTH_STONE)
		# Stepped Base (Bottom)
		draw_rect(Rect2(x - 5, 85, 40, 5), COL_HEARTH_STONE)
		draw_rect(Rect2(x - 10, 90, 50, 10), COL_HEARTH_STONE.darkened(0.2))
		
		# Center is at x + 95 (midway between x+15 and x+175)
		# Radius 80 to span between centers of 30px thick pillars
		draw_arc(Vector2(x + 95, 20), 80.0, PI, PI*2, 24, COL_WALL_BACK, 30.0)

func _draw_floor() -> void:
	# Floor stops at x=680 (Balcony edge)
	draw_rect(Rect2(0, 100, 680, 40), COL_FLOOR_BASE)
	draw_line(Vector2(0, 100), Vector2(680, 100), COL_HEARTH_EDGE, 2.0)
	
	# Balcony railing
	draw_rect(Rect2(675, 80, 10, 60), COL_HEARTH_STONE)
	draw_rect(Rect2(670, 75, 20, 5), COL_HEARTH_EDGE)
	
	if is_hearth_lit:
		var flicker = sin(_anim_clock * 3.0) * 0.1 + 0.9
		draw_circle(Vector2(180, 110), 220.0, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, 0.1 * flicker))
		draw_circle(Vector2(180, 110), 110.0, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, 0.2 * flicker))
	
	for mx in range(20, 660, 40):
		for my in range(105, 135, 10):
			if (mx + my) % 3 == 0:
				draw_rect(Rect2(mx, my, 8, 4), COL_FLOOR_MOSAIC)

func _draw_embers() -> void:
	if not is_hearth_lit: return
	for s in _sparks:
		var alpha = clampf(s.get("life", 1.0), 0.0, 1.0)
		draw_rect(Rect2(s["x"], s["y"], 1.5, 1.5), Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, alpha))

func _draw_lounging_couch(cx: float, cy: float) -> void:
	var w = 80.0
	var h = 15.0
	
	# Dark carved wood base
	draw_rect(Rect2(cx - w/2, cy, w, h), Color(0.2, 0.15, 0.1))
	draw_rect(Rect2(cx - w/2, cy, w, 4), Color(0.15, 0.1, 0.05)) # Shadow under cushion
	
	# Stout wooden legs
	draw_rect(Rect2(cx - w/2 + 5, cy + h, 8, 10), Color(0.15, 0.1, 0.05))
	draw_rect(Rect2(cx + w/2 - 13, cy + h, 8, 10), Color(0.15, 0.1, 0.05))
	
	# Plush Tufted Cushions (Warm Red/Orange to match Hearth)
	var c_col = Color(0.5, 0.15, 0.1)
	draw_rect(Rect2(cx - w/2 + 2, cy - 12, w - 4, 12), c_col)
	draw_rect(Rect2(cx - w/2 + 2, cy - 12, w - 4, 4), c_col.lightened(0.2)) # Highlight
	
	# Tufting / Stitch lines
	for tx in range(int(cx - w/2) + 18, int(cx + w/2), 16):
		draw_line(Vector2(tx, cy - 12), Vector2(tx, cy), c_col.darkened(0.3), 2.0)
		# Little tuft buttons
		draw_circle(Vector2(tx, cy - 6), 2.0, c_col.darkened(0.5))

func _draw_massive_hearth(hx: float, hy: float) -> void:
	# Built into the back chimney wall
	draw_rect(Rect2(hx - 60, hy - 20, 120, 20), COL_HEARTH_STONE.darkened(0.3))
	
	if is_hearth_lit:
		draw_rect(Rect2(hx - 40, hy - 12, 80, 14), Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, 0.4))
		
		# Soft Radiant Glow (Replaces the flat circle)
		for i in range(1, 9):
			var radius = i * 8.0
			var alpha = 0.4 * (1.0 - (float(i) / 9.0))
			draw_circle(Vector2(hx, hy - 10), radius, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, alpha))
		
		var f1 = sin(_anim_clock * 4.0) * 4.0
		var f2 = sin(_anim_clock * 5.0 + 1.0) * 6.0
		var f3 = sin(_anim_clock * 3.5 + 2.0) * 5.0
		
		draw_polygon([Vector2(hx - 25, hy+2), Vector2(hx - 10 + f1, hy - 35), Vector2(hx + 15, hy+2)], [cur_fire_edge])
		draw_polygon([Vector2(hx - 10, hy+2), Vector2(hx + 10 + f2, hy - 45), Vector2(hx + 30, hy+2)], [cur_fire_mid])
		draw_polygon([Vector2(hx - 15, hy+2), Vector2(hx + f3, hy - 35), Vector2(hx + 15, hy+2)], [cur_fire_core])
	else:
		draw_rect(Rect2(hx - 30, hy - 5, 60, 8), COL_ASH)
		draw_rect(Rect2(hx - 20, hy - 8, 40, 4), COL_HEARTH_STONE.darkened(0.5))

	# Huge Stone Hearth Base Ring
	draw_rect(Rect2(hx - 70, hy, 140, 16), COL_HEARTH_STONE)
	draw_rect(Rect2(hx - 70, hy + 16, 140, 6), COL_HEARTH_EDGE)
	for i in range(7):
		var lx = hx - 60 + i * 20
		draw_line(Vector2(lx, hy), Vector2(lx, hy + 22), COL_HEARTH_EDGE, 1.0)

func _draw_feasting_table(dx: float, dy: float) -> void:
	# Long Marble Table
	draw_rect(Rect2(dx - 60, dy + 8, 12, 16), COL_HEARTH_STONE)
	draw_rect(Rect2(dx + 48, dy + 8, 12, 16), COL_HEARTH_STONE)
	
	draw_rect(Rect2(dx - 70, dy, 140, 10), COL_MARBLE)
	draw_rect(Rect2(dx - 70, dy + 10, 140, 4), COL_MARBLE_SHADE)
	
	# Offerings and food
	draw_rect(Rect2(dx - 40, dy - 4, 20, 4), COL_SCROLL)
	draw_rect(Rect2(dx - 35, dy - 3, 10, 2), Color(0.6, 0.5, 0.4))
	
	# Green Herb Bundle
	draw_rect(Rect2(dx + 20, dy - 8, 20, 8), Color(0.3, 0.6, 0.3))
	draw_line(Vector2(dx + 30, dy - 8), Vector2(dx + 30, dy), Color(0.8, 0.8, 0.5), 2.0)
	
	# Silver Goblets
	draw_rect(Rect2(dx, dy - 8, 6, 8), Color(0.8, 0.8, 0.9))
	draw_rect(Rect2(dx + 10, dy - 6, 6, 6), Color(0.8, 0.8, 0.9))

func _draw_amphora(ax: float, ay: float) -> void:
	draw_rect(Rect2(ax - 8, ay + 15, 16, 4), COL_BRONZE.darkened(0.2))
	var pts = PackedVector2Array([
		Vector2(ax - 6, ay), Vector2(ax + 6, ay),
		Vector2(ax + 12, ay + 10), Vector2(ax + 8, ay + 15),
		Vector2(ax - 8, ay + 15), Vector2(ax - 12, ay + 10)
	])
	draw_colored_polygon(pts, COL_BRONZE)
	draw_rect(Rect2(ax - 4, ay - 6, 8, 6), COL_BRONZE)
	draw_line(Vector2(ax - 4, ay - 4), Vector2(ax - 10, ay + 5), COL_BRONZE, 1.0)
	draw_line(Vector2(ax + 4, ay - 4), Vector2(ax + 10, ay + 5), COL_BRONZE, 1.0)

func _draw_hestias_ember() -> void:
	if not is_hearth_lit: return
	var throb = sin(_anim_clock * 8.0) * 2.0
	draw_circle(Vector2(ember_x, ember_y), 4.0 + throb * 0.2, cur_fire_core)
	draw_circle(Vector2(ember_x, ember_y), 2.0, Color(1.0, 1.0, 1.0))
	draw_circle(Vector2(ember_x, ember_y), 20.0 + throb, Color(cur_fire_core.r, cur_fire_core.g, cur_fire_core.b, 0.3))
