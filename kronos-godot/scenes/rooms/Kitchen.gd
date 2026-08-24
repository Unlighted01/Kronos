@tool
extends BaseRoom
class_name Kitchen

## Banks of the Styx - A Moody Underworld Prison (720px wide).
## Features heavy prison bars, Charon's Skiff, hanging chains, and a rolling fog river.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_SKY: Color = Color(0.04, 0.05, 0.08, 1.0)
const COL_RIVER: Color = Color(0.05, 0.15, 0.15, 1.0)
const COL_FOG: Color = Color(0.20, 0.40, 0.35, 0.15) # Sickly translucent green-grey

const COL_WOOD_DARK: Color = Color(0.12, 0.10, 0.08, 1.0)
const COL_WOOD_LIT: Color = Color(0.20, 0.18, 0.15, 1.0)

const COL_IRON: Color = Color(0.05, 0.05, 0.05, 1.0)
const COL_IRON_HIGHLIGHT: Color = Color(0.15, 0.25, 0.20, 1.0) # Sickly green reflection

const COL_LANTERN_GLOW: Color = Color(0.20, 0.90, 0.40, 0.6)
const COL_LANTERN_CORE: Color = Color(0.60, 1.0, 0.70, 1.0)

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _anim_clock: float = 0.0

var _bars: Array[float] = []
var _chains: Array[Dictionary] = []
var _fog_banks: Array[Dictionary] = []
var _splashes: Array[Dictionary] = []

# Bounding Boxes
const RECT_SKIFF: Rect2 = Rect2(200, 70, 150, 70)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_kitchen"
	room_name = "Banks of the Styx"
	room_width = 720.0
	min_x = 220.0 # Skiff deck edge
	max_x = 340.0 # Skiff deck edge
	desk_x = 280.0  # Center of Skiff
	nap_x = 250.0   
	drink_x = 310.0 
	
	_generate_geometry_caches()

func _generate_geometry_caches() -> void:
	# Cache Iron Prison Bars
	var bx = -20.0
	while bx < 750.0:
		_bars.append(bx)
		# Semi-random spacing so the prison feels warped and ancient
		bx += 90.0 + randf_range(-15.0, 15.0)
		
	# Cache Hanging Chains
	for i in range(8):
		_chains.append({
			"x": randf_range(20.0, 700.0),
			"len": randf_range(40.0, 110.0),
			"phase": randf_range(0.0, PI * 2)
		})
		
	# Cache Fog Banks
	for i in range(16):
		_fog_banks.append({
			"x": randf_range(0, 720),
			"y": randf_range(110, 150),
			"rx": randf_range(60, 130), # Radius X
			"ry": randf_range(15, 30),  # Radius Y
			"speed": randf_range(5.0, 15.0)
		})

func _process(delta: float) -> void:
	_anim_clock += delta
	
	# Bobbing for Pet Sync
	var bob_offset = sin(_anim_clock * 1.5) * 3.0
	if EventBus and EventBus.has_signal("floor_y_offset_changed"):
		EventBus.floor_y_offset_changed.emit(bob_offset)
	
	# Update Fog Drift
	for f in _fog_banks:
		f["x"] += f["speed"] * delta
		if f["x"] - f["rx"] > 720.0:
			f["x"] = -f["rx"]
			f["y"] = randf_range(110, 150)
			
	# Update Splashes
	for i in range(_splashes.size() - 1, -1, -1):
		var s = _splashes[i]
		s["r"] += 20.0 * delta
		s["life"] -= delta
		if s["life"] <= 0:
			_splashes.remove_at(i)
			
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
		var pos: Vector2 = mb.position + Vector2(cam_x, 0)
		
		# Splash the water near the Skiff
		if RECT_SKIFF.has_point(pos):
			_splashes.append({
				"x": pos.x,
				"y": pos.y,
				"r": 5.0,
				"life": 1.0
			})
			if EventBus: EventBus.object_state_changed.emit("styx_splashed", true)
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 DRAWING PIPELINE
# ==============================================================================
func _draw() -> void:
	# 1. Background Sky
	draw_rect(Rect2(0, 0, 720, 100), COL_SKY)
	
	# 2. The River of Souls & Fog
	_draw_river_and_fog()
	
	# 3. Charon's Skiff (Signature Object)
	_draw_charon_skiff(280, 115)
	
	# 4. Foreground: Hanging Chains & Prison Bars
	_draw_hanging_chains()
	_draw_prison_bars()
	
	# 5. Splash Effects
	for s in _splashes:
		draw_arc(Vector2(s["x"], s["y"]), s["r"], 0, PI*2, 16, Color(COL_LANTERN_CORE.r, COL_LANTERN_CORE.g, COL_LANTERN_CORE.b, s["life"]), 2.0)

# ------------------------------------------------------------------------------
# 2. RIVER AND FOG
# ------------------------------------------------------------------------------
func _draw_river_and_fog() -> void:
	# Base River
	draw_rect(Rect2(0, 100, 720, 100), COL_RIVER)
	
	# Distant shore / horizon line
	draw_line(Vector2(0, 100), Vector2(720, 100), COL_RIVER.lightened(0.1), 1.0)
	
	# River flow lines
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	for i in range(0, 720, 40):
		var rx = fmod(i - (cam_x * 0.1) + _anim_clock * 5.0, 720.0)
		if rx < 0: rx += 720.0
		var rw = 20.0 + sin(_anim_clock * 2.0 + i) * 10.0
		draw_line(Vector2(rx, 105), Vector2(rx + rw, 105), COL_RIVER.lightened(0.1), 1.0)
		draw_line(Vector2(rx + 20, 115), Vector2(rx + 20 + rw, 115), COL_RIVER.lightened(0.1), 1.0)
		
	# Fog Banks (Volumetric Mist)
	for f in _fog_banks:
		var fx = f["x"] - (cam_x * 0.15)
		if fx + f["rx"] > 0 and fx - f["rx"] < 720:
			# Stretched ellipses to simulate rolling mist
			var rect = Rect2(fx - f["rx"], f["y"] - f["ry"], f["rx"] * 2.0, f["ry"] * 2.0)
			# Fill an oval manually or use circle stretches. Since Godot 4 draw_circle doesn't scale,
			# we can simulate it with a very thick rounded line or custom transform.
			draw_set_transform(Vector2(fx, f["y"]), 0.0, Vector2(1.0, f["ry"]/f["rx"]))
			draw_circle(Vector2.ZERO, f["rx"], COL_FOG)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ------------------------------------------------------------------------------
# 3. CHARON'S SKIFF
# ------------------------------------------------------------------------------
func _draw_charon_skiff(cx: float, cy: float) -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var offset_x = cx - (cam_x * 0.05)
	
	# Sluggish Bobbing Animation
	var bob_y = cy + sin(_anim_clock * 1.5) * 3.0
	var bob_rot = cos(_anim_clock * 1.2) * 0.05
	
	draw_set_transform(Vector2(offset_x, bob_y), bob_rot, Vector2.ONE)
	
	# Dark Hull Polygon (sweeps up dramatically at the prow)
	var hull_pts = PackedVector2Array([
		Vector2(-70, -10),  # Back
		Vector2(-50, 5),    # Back bottom
		Vector2(40, 5),     # Front bottom
		Vector2(70, -15),   # Front prow base
		Vector2(85, -45),   # Tall curved prow tip
		Vector2(75, -45),   # Inner prow tip
		Vector2(60, -10)    # Inner deck
	])
	draw_colored_polygon(hull_pts, COL_WOOD_DARK)
	
	# Hull planking highlights
	draw_line(Vector2(-60, -5), Vector2(65, -5), COL_WOOD_LIT, 1.0)
	draw_line(Vector2(80, -45), Vector2(65, -15), COL_WOOD_LIT, 1.0)
	
	# Resting Oar
	draw_line(Vector2(10, 0), Vector2(80, 20), COL_WOOD_LIT.lightened(0.2), 2.0)
	# Oar paddle blade
	var paddle_pts = PackedVector2Array([
		Vector2(70, 15), Vector2(85, 12),
		Vector2(90, 22), Vector2(75, 25)
	])
	draw_colored_polygon(paddle_pts, COL_WOOD_LIT)
	
	# Eerie Glowing Lantern hanging from the prow tip
	var prow_tip = Vector2(80, -45)
	var lantern_pos = prow_tip + Vector2(10, 15) # Dangles down and right
	
	# Lantern Chain
	draw_line(prow_tip, lantern_pos, COL_IRON, 1.0)
	
	# Lantern Housing
	draw_rect(Rect2(lantern_pos.x - 4, lantern_pos.y, 8, 12), COL_IRON)
	draw_rect(Rect2(lantern_pos.x - 6, lantern_pos.y - 2, 12, 2), COL_IRON)
	draw_rect(Rect2(lantern_pos.x - 6, lantern_pos.y + 12, 12, 2), COL_IRON)
	
	# The Sickly Green Light
	draw_circle(lantern_pos + Vector2(0, 6), 3.0, COL_LANTERN_CORE)
	draw_circle(lantern_pos + Vector2(0, 6), 25.0, COL_LANTERN_GLOW) # Glow aura
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# ------------------------------------------------------------------------------
# 4. CHAINS & PRISON BARS
# ------------------------------------------------------------------------------
func _draw_hanging_chains() -> void:
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	for c in _chains:
		var cx = c["x"] - (cam_x * 0.2)
		# Minor swaying pendulum physics
		var sway_angle = sin(_anim_clock * 1.5 + c["phase"]) * 0.08
		
		draw_set_transform(Vector2(cx, 0), sway_angle, Vector2.ONE)
		
		# Draw alternating links down to the chain length
		var cy = 0.0
		var link_h = 10.0
		var is_vertical = true
		while cy < c["len"]:
			if is_vertical:
				# Vertical hollow oval link
				draw_rect(Rect2(-2, cy, 4, link_h), COL_IRON, false, 1.5)
			else:
				# Horizontal solid dash link bridging them
				draw_rect(Rect2(-4, cy + 2, 8, 3), COL_IRON.darkened(0.2))
				
			cy += link_h * 0.7 # Overlap links
			is_vertical = not is_vertical
			
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_prison_bars() -> void:
	# These bars frame the absolute foreground
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	
	# Thick horizontal crossbeams (Top and Bottom)
	draw_rect(Rect2(0, 0, 720, 25), COL_IRON)
	draw_rect(Rect2(0, 185, 720, 15), COL_IRON)
	
	for bx in _bars:
		var px = bx - (cam_x * 0.3)
		# Massive 12px wide iron bars
		draw_rect(Rect2(px, 0, 12, 200), COL_IRON)
		# Sickly green metallic highlight on the left edge catching the river/lantern light
		draw_line(Vector2(px + 2, 0), Vector2(px + 2, 200), COL_IRON_HIGHLIGHT, 1.5)
		
		# Welded iron studs at the crossbeams
		draw_circle(Vector2(px + 6, 12), 3.0, COL_IRON.darkened(0.5))
		draw_circle(Vector2(px + 6, 192), 3.0, COL_IRON.darkened(0.5))
