@tool
extends BaseRoom
class_name TempleOfMorpheus

## Temple of Morpheus - Premium Mythological Domain (720px wide).
## Features the Font of Lethe waterfall, Starlight Weaver moth, and Interactive Dreamcatcher Chimes.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_SKY_DEEP: Color = Color(0.04, 0.05, 0.10, 1.0)
const COL_SKY_MID: Color = Color(0.08, 0.12, 0.20, 1.0)
const COL_TEMPLE_BG: Color = Color(0.12, 0.10, 0.16, 1.0)
const COL_TEMPLE_FG: Color = Color(0.18, 0.16, 0.22, 1.0)
const COL_FLOOR: Color = Color(0.15, 0.12, 0.18, 1.0)

const COL_LETHE_WATER: Color = Color(0.40, 0.85, 0.95, 0.8)
const COL_LETHE_FOAM: Color = Color(0.80, 0.95, 1.0, 0.9)
const COL_LETHE_GLOW: Color = Color(0.20, 0.65, 0.95, 0.4)

const COL_MARBLE: Color = Color(0.85, 0.80, 0.85, 1.0)
const COL_MARBLE_SHADE: Color = Color(0.65, 0.60, 0.70, 1.0)
const COL_VINE: Color = Color(0.15, 0.25, 0.20, 1.0)
const COL_MOONFLOWER: Color = Color(0.95, 0.95, 1.0, 1.0)

const COL_BED_CANOPY: Color = Color(0.15, 0.25, 0.45, 0.8)
const COL_BED_PILLOW: Color = Color(0.70, 0.85, 0.95, 1.0)
const COL_BED_SHEET: Color = Color(0.25, 0.35, 0.55, 1.0)
const COL_WOOD_SILVER: Color = Color(0.45, 0.50, 0.60, 1.0)

const COL_SAND: Color = Color(0.95, 0.80, 0.45, 1.0)
const COL_HOURGLASS_GLASS: Color = Color(0.70, 0.90, 0.95, 0.3)
const COL_CHIME_BRONZE: Color = Color(0.65, 0.45, 0.25, 1.0)

const COL_MOTH_WING: Color = Color(0.60, 0.85, 1.0, 0.6)
const COL_MOTH_GLOW: Color = Color(0.40, 0.75, 1.0, 0.3)

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _anim_clock: float = 0.0
var _stars: Array[Dictionary] = []
var _dreams: Array[Dictionary] = []

# Interactables
var is_waterfall_flowing: bool = true
var _chime_swing: float = 0.0
var _hourglass_magic_time: float = 0.0
var _lethe_ripple_time: float = 0.0
var _chime_vel: float = 0.0

# The Starlight Weaver (Moth)
var moth_x: float = -100.0
var moth_y: float = 40.0
var moth_active: bool = false
var moth_timer: float = 0.0

var _floor_cache: Array[Dictionary] = []

# Bounding Boxes
const RECT_CHIMES: Rect2 = Rect2(400, -20, 40, 100)
const RECT_MOTH: Rect2 = Rect2(0, 0, 40, 40)
const RECT_WATERFALL: Rect2 = Rect2(530, 80, 80, 100)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_bedroom"
	room_name = "Study Bedroom"
	room_width = 720.0
	min_x = 50.0
	max_x = 500.0  # Cannot walk past the waterfall edge
	desk_x = 100.0 # Altar
	nap_x = 220.0  # Bed
	drink_x = 490.0 # Font of Lethe (at waterfall pool edge)
	
	# Initial star field
	for i in range(50):
		_stars.append({
			"x": randf_range(0, 720),
			"y": randf_range(0, 90),
			"size": randf_range(1, 3),
			"phase": randf_range(0, PI * 2)
		})
	
	_generate_floor_cache()
		
	# Ambient Dream Orbs
	for i in range(15):
		_spawn_dream_orb(randf_range(0, 720), randf_range(40, 120))
		
	if EventBus:
		EventBus.object_state_changed.connect(_on_object_state_changed)

func _generate_floor_cache() -> void:
	_floor_cache.clear()
	var cx = 0.0
	while cx < 550.0:
		var tw = randf_range(30, 80)
		var cracks = []
		if randf() > 0.4:
			var crack_x = cx + randf_range(5, tw - 5)
			cracks.append([crack_x, 100, crack_x + randf_range(-5, 5), 115])
			cracks.append([crack_x + randf_range(-5, 5), 115, crack_x + randf_range(-10, 10), 140])
		
		_floor_cache.append({
			"x": cx,
			"w": tw,
			"shade": randf_range(-0.05, 0.05),
			"cracks": cracks
		})
		cx += tw

func _on_object_state_changed(key: String, val: Variant) -> void:
	if key == "lethe_paw_dip":
		# Paw dipped! Spawn a dream orb at the font!
		_spawn_dream_orb(180.0, 100.0)
		# Flash water glow
		is_waterfall_flowing = true
		queue_redraw()

func _spawn_dream_orb(px: float, py: float) -> void:
	_dreams.append({
		"x": px,
		"y": py,
		"vx": randf_range(-10.0, 10.0),
		"vy": randf_range(-5.0, -20.0),
		"phase": randf_range(0, PI * 2),
		"scale": randf_range(0.5, 1.5)
	})

func _process(delta: float) -> void:
	_anim_clock += delta * 1.5
	
	# Chime physics (damped pendulum)
	_chime_vel -= _chime_swing * 20.0 * delta
	_chime_vel *= 0.95 # Damping
	_chime_swing += _chime_vel * delta
	
	# Update Dream Orbs
	for i in range(_dreams.size() - 1, -1, -1):
		var d = _dreams[i]
		d["x"] += (d["vx"] + sin(_anim_clock + d["phase"]) * 10.0) * delta
		d["y"] += d["vy"] * delta
		if d["y"] < -20:
			if _dreams.size() > 15:
				_dreams.remove_at(i)
			else:
				# Recycle orb
				d["y"] = randf_range(130, 140)
				d["x"] = randf_range(0, 720)
			
	if _hourglass_magic_time > 0.0:
		_hourglass_magic_time -= delta
	if _lethe_ripple_time > 0.0:
		_lethe_ripple_time -= delta
		
	# Update Starlight Weaver (Moth)
	if moth_active:
		moth_x += (40.0 + sin(_anim_clock * 1.5) * 20.0) * delta
		moth_y = 40.0 + sin(_anim_clock * 2.0) * 25.0 + cos(_anim_clock * 4.3) * 15.0
		# Drop dream dust
		if randf() < 0.05 and _dreams.size() < 40:
			_spawn_dream_orb(moth_x, moth_y)
			if EventBus: EventBus.object_state_changed.emit("weaver_dropped_dust", moth_x)
		if moth_x > 800.0:
			moth_active = false
			moth_timer = 0.0
	else:
		moth_timer += delta
		if moth_timer > 15.0 and randf() < 0.01: # Spawn occasionally
			moth_active = true
			moth_x = -50.0
			
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
		var pos: Vector2 = mb.position + Vector2(cam_x, 0)
		
		# Click Chimes
		if RECT_CHIMES.has_point(pos):
			_chime_vel += 5.0 # Strike the chime
			for i in range(5):
				_spawn_dream_orb(460, 40)
			# Boost Joy if GameState exists
			if GameState:
				GameState.joy = minf(GameState.MAX_JOY, GameState.joy + 5.0)
				EventBus.object_state_changed.emit("chimes_struck", true)
			get_viewport().set_input_as_handled()
			return
			
		# Click Font of Lethe
		if RECT_WATERFALL.has_point(pos):
			is_waterfall_flowing = not is_waterfall_flowing
			if EventBus: EventBus.object_state_changed.emit("lethe_toggled", is_waterfall_flowing)
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 DRAWING PIPELINE
# ==============================================================================
func _draw() -> void:
	# 1. Deep Parallax Background (Sky & Arches)
	_draw_parallax_background()
	
	# 2. Floor Architecture (Stops at x=550 for the cliff)
	_draw_floor()
	
	# 3. Fluted Columns & Moonflower Vines
	for cx in [40, 320]:
		_draw_fluted_column(cx, 0, 100)
	
	# 4. Far Left: Hourglass Altar
	_draw_hourglass_altar(100, 100)
	
	# 5. Left Zone: Ethereal Canopy Bed
	_draw_canopy_bed(220, 100)
	
	# 6. Center Zone: Broken Moon Dial & Chimes
	_draw_chimes(420, 0)
	
	# 7. Far Right Cliff: The Font of Lethe Waterfall
	_draw_lethe_waterfall(550, 100)
	
	# 8. Foreground Entities
	_draw_starlight_weaver()
	
	for d in _dreams:
		var alpha = sin(_anim_clock * 2.0 + d["phase"]) * 0.3 + 0.5
		var c = Color(0.6, 0.8, 1.0, alpha)
		draw_circle(Vector2(d["x"], d["y"]), 3.0 * d["scale"], c)
		draw_circle(Vector2(d["x"], d["y"]), 1.5 * d["scale"], Color(1.0, 1.0, 1.0, alpha))

# ------------------------------------------------------------------------------
# 1. PARALLAX BACKGROUND
# ------------------------------------------------------------------------------
func _draw_parallax_background() -> void:
	# Sky gradient
	draw_rect(Rect2(0, 0, 720, 100), COL_SKY_DEEP)
	for y in range(0, 100, 5):
		var lerp_val = y / 100.0
		draw_rect(Rect2(0, y, 720, 5), COL_SKY_DEEP.lerp(COL_SKY_MID, lerp_val))
		
	var cam_x: float = get_viewport().get_camera_2d().position.x - 120.0 if get_viewport().get_camera_2d() else 0.0
	var p_offset = cam_x * 0.2
	
	# Massive True Crescent Moon (Deep Background)
	var moon_x = 450.0 - (cam_x * 0.05)
	var moon_y = 40.0
	
	draw_circle(Vector2(moon_x, moon_y), 80.0, Color(1.0, 0.95, 0.9, 0.1)) # Glow
	
	# Draw crescent using a polygon (outer arc + inner arc)
	var c_pts = PackedVector2Array()
	var outer_r = 60.0
	var inner_r = 50.0
	var offset = Vector2(-15, -10)
	for i in range(21):
		var a = -PI/2.0 + (PI/20.0)*i
		c_pts.append(Vector2(moon_x + cos(a)*outer_r, moon_y + sin(a)*outer_r))
	for i in range(20, -1, -1):
		var a = -PI/2.0 + (PI/20.0)*i
		c_pts.append(Vector2(moon_x + offset.x + cos(a)*inner_r, moon_y + offset.y + sin(a)*inner_r))
	
	draw_colored_polygon(c_pts, Color(1.0, 0.95, 0.9, 0.8))
	
	# Stars
	for s in _stars:
		var sx = fmod(s["x"] - p_offset, 720.0)
		if sx < 0: sx += 720.0
		var flicker = sin(_anim_clock * 1.5 + s["phase"]) * 0.5 + 0.5
		draw_rect(Rect2(sx, s["y"], s["size"], s["size"]), Color(1.0, 0.95, 0.9, 0.2 + 0.6 * flicker))
		
	# Ruined Temple Arches
	var a_offset = cam_x * 0.1
	for ax in range(-100, 820, 160):
		var x = ax - a_offset
		# Break the arch over the moon
		if abs(x - 400) > 100:
			draw_rect(Rect2(x, 20, 16, 80), COL_TEMPLE_BG)
			draw_rect(Rect2(x + 100, 20, 16, 80), COL_TEMPLE_BG)
			draw_arc(Vector2(x + 58, 20), 50.0, PI, PI*2, 16, COL_TEMPLE_BG, 16.0)
		else:
			# Shattered arch columns
			draw_rect(Rect2(x, 60, 16, 40), COL_TEMPLE_BG)
			draw_rect(Rect2(x + 100, 50, 16, 50), COL_TEMPLE_BG)

# ------------------------------------------------------------------------------
# 2. ARCHITECTURE & FLOOR
# ------------------------------------------------------------------------------
func _draw_floor() -> void:
	# Base Floor (Ends at 550)
	draw_rect(Rect2(0, 100, 550, 40), COL_FLOOR)
	draw_line(Vector2(0, 100), Vector2(550, 100), COL_MARBLE_SHADE, 2.0)
	
	# Draw Cached Tiles & Cracks
	for t in _floor_cache:
		var tx = t["x"]
		var tw = t["w"]
		var shade = COL_FLOOR.darkened(t["shade"])
		draw_rect(Rect2(tx, 100, tw, 40), shade)
		draw_line(Vector2(tx + tw, 100), Vector2(tx + tw, 140), COL_MARBLE_SHADE.darkened(0.2), 1.0)
		
		# Draw unique cracks
		for c in t["cracks"]:
			draw_line(Vector2(c[0], c[1]), Vector2(c[2], c[3]), COL_MARBLE_SHADE.darkened(0.2), 1.0)
			
	# Grand Temple Rug under the bed
	_draw_rug(160, 105, 140)
	
	# Broken cliff edge going down into the abyss
	var cliff_pts = PackedVector2Array([
		Vector2(550, 100), Vector2(560, 105), Vector2(555, 120), Vector2(565, 140), Vector2(550, 140)
	])
	draw_colored_polygon(cliff_pts, COL_FLOOR)
	draw_line(Vector2(550, 100), Vector2(560, 105), COL_MARBLE_SHADE, 1.0)
	draw_line(Vector2(560, 105), Vector2(555, 120), COL_MARBLE_SHADE, 1.0)
	draw_line(Vector2(555, 120), Vector2(565, 140), COL_MARBLE_SHADE, 1.0)

func _draw_rug(rx: float, ry: float, rw: float) -> void:
	# Rich ornamental rug
	draw_rect(Rect2(rx, ry, rw, 25), Color(0.2, 0.1, 0.15))
	draw_rect(Rect2(rx + 4, ry + 4, rw - 8, 17), COL_FLOOR.darkened(0.2)) # Inner pattern
	
	# Golden tassels and trim
	draw_line(Vector2(rx, ry + 25), Vector2(rx + rw, ry + 25), Color(0.8, 0.6, 0.2), 2.0)
	for tx in range(int(rx) + 2, int(rx + rw), 6):
		draw_line(Vector2(tx, ry + 25), Vector2(tx, ry + 28), Color(0.8, 0.6, 0.2), 1.0)

func _draw_fluted_column(cx: float, cy: float, ch: float, is_bedpost: bool = false) -> void:
	# Base & Capital
	draw_rect(Rect2(cx - 20, cy + ch - 5, 40, 5), COL_MARBLE_SHADE)
	draw_rect(Rect2(cx - 20, cy, 40, 8), COL_MARBLE_SHADE)
	
	# Pillar Body
	draw_rect(Rect2(cx - 15, cy + 8, 30, ch - 13), COL_MARBLE)
	draw_rect(Rect2(cx - 15, cy + 8, 8, ch - 13), COL_MARBLE_SHADE) # Left shadow
	
	# Fluting lines
	for i in range(4):
		var lx = cx - 10 + i * 6
		draw_line(Vector2(lx, cy + 8), Vector2(lx, cy + ch - 5), COL_MARBLE_SHADE.darkened(0.2), 1.0)
		
	# Moonflower Vines (Only on architectural columns, not furniture)
	if not is_bedpost:
		for vy in range(int(cy + ch), int(cy), -30):
			var p1 = Vector2(cx - 15, vy - 5)
			var p2 = Vector2(cx + 15, vy - 20)
			draw_line(p1, p2, COL_MOONFLOWER.darkened(0.4), 2.0)
			draw_circle(p1 + Vector2(5, -5), 3.0, COL_MOONFLOWER)
			draw_circle(p1 + Vector2(5, -5), 6.0, Color(COL_MOONFLOWER.r, COL_MOONFLOWER.g, COL_MOONFLOWER.b, 0.3))

# ------------------------------------------------------------------------------
# 3. INTERACTIVE LETHE WATERFALL
# ------------------------------------------------------------------------------
func _draw_lethe_waterfall(fx: float, fy: float) -> void:
	# Asymmetrical rugged rocky outcrop at the cliff edge
	var crag1 = PackedVector2Array([
		Vector2(fx - 10, fy + 10), Vector2(fx + 35, fy - 5),
		Vector2(fx + 45, fy + 15), Vector2(fx + 20, fy + 35),
		Vector2(fx - 10, fy + 40)
	])
	draw_colored_polygon(crag1, COL_MARBLE_SHADE.darkened(0.2))
	
	var crag2 = PackedVector2Array([
		Vector2(fx - 5, fy - 10), Vector2(fx + 25, fy - 20),
		Vector2(fx + 35, fy + 5), Vector2(fx + 10, fy + 15),
		Vector2(fx - 5, fy + 10)
	])
	draw_colored_polygon(crag2, COL_MARBLE_SHADE.darkened(0.1))
	
	var crag3 = PackedVector2Array([
		Vector2(fx - 20, fy - 15), Vector2(fx + 15, fy - 25),
		Vector2(fx + 20, fy - 5), Vector2(fx, fy + 5),
		Vector2(fx - 20, fy)
	])
	draw_colored_polygon(crag3, COL_MARBLE_SHADE)
	
	if is_waterfall_flowing:
		var fall_y_start = fy - 10
		var fall_height = 300.0
		
		# Main Flow
		draw_rect(Rect2(fx + 5, fall_y_start, 35, fall_height), COL_LETHE_WATER.darkened(0.2))
		draw_rect(Rect2(fx + 10, fall_y_start, 25, fall_height), COL_LETHE_WATER)
		draw_rect(Rect2(fx + 15, fall_y_start, 12, fall_height), COL_LETHE_WATER.lightened(0.2))
		
		# Animated Cascade Lines
		for i in range(10):
			var lx = fx + 8 + i * 2.5
			var speed = 100.0 + (i % 4) * 30.0
			var ly = fall_y_start + fmod(_anim_clock * speed + i * 37.0, fall_height)
			draw_line(Vector2(lx, ly), Vector2(lx, ly + 25), COL_LETHE_FOAM, 2.0)
			
		# Water Ripples & Splash Enhancements
		if _lethe_ripple_time > 0.0:
			for r in range(4):
				var r_time = _anim_clock * 3.0 + r * 1.5
				var r_width = 15.0 + fmod(r_time * 20.0, 50.0)
				var r_alpha = minf(1.0, _lethe_ripple_time) * (1.0 - (fmod(r_time * 20.0, 50.0) / 50.0))
				var r_col = Color(COL_LETHE_FOAM.r, COL_LETHE_FOAM.g, COL_LETHE_FOAM.b, r_alpha)
				draw_arc(Vector2(fx + 20, fall_y_start), r_width, 0, PI*2, 16, r_col, 2.0)
				
		# Animated Foam Splash
		for i in range(12):
			var splash_x = fx + 5 + i * 3
			var splash_y = fall_y_start - 2 + sin(_anim_clock * 10.0 + i) * 3.0
			draw_line(Vector2(splash_x, splash_y), Vector2(splash_x, splash_y - 8), COL_LETHE_FOAM, 1.0)
			if i % 3 == 0:
				var sp_y2 = fall_y_start - 10 - fmod(_anim_clock * 40.0 + i * 15.0, 20.0)
				var sp_a = 1.0 - (fmod(_anim_clock * 40.0 + i * 15.0, 20.0) / 20.0)
				draw_circle(Vector2(splash_x, sp_y2), 1.5, Color(COL_LETHE_FOAM.r, COL_LETHE_FOAM.g, COL_LETHE_FOAM.b, sp_a))
			draw_arc(Vector2(splash_x + 3, splash_y + 4), 6.0, PI, PI*2, 8, COL_LETHE_FOAM, 2.0)
		
		# Magical glow radiating from the fall
		draw_circle(Vector2(fx + 15, fy + 20), 45.0, COL_LETHE_GLOW)

# ------------------------------------------------------------------------------
# 4. CANOPY BED
# ------------------------------------------------------------------------------
func _draw_canopy_bed(bx: float, by: float) -> void:
	var hover = sin(_anim_clock * 2.0) * 3.0
	by += hover
	
	var fw = 100.0
	var fh = 16.0
	var fx = bx - fw/2.0
	var fy = by - fh
	
	# Bed Frame (Reskinned to be grander)
	draw_rect(Rect2(fx, fy, fw, fh), COL_MARBLE_SHADE)
	draw_rect(Rect2(fx, fy + fh, fw, 4), COL_WOOD_SILVER.darkened(0.2))
	
	# Gold filigree trim on the bed frame
	draw_line(Vector2(fx + 5, fy + 4), Vector2(fx + fw - 5, fy + 4), Color(0.8, 0.6, 0.2), 1.0)
	
	# Mattress & Sheets
	draw_rect(Rect2(fx + 6, fy - 8, fw - 12, 8), COL_BED_SHEET.darkened(0.2))
	draw_rect(Rect2(fx + 6, fy - 4, fw - 12, 12), COL_BED_SHEET)
	
	# Plump Pillows
	draw_rect(Rect2(fx + 12, fy - 16, 18, 10), COL_BED_PILLOW)
	draw_rect(Rect2(fx + 24, fy - 14, 16, 10), COL_BED_PILLOW.darkened(0.1))
	draw_rect(Rect2(fx + fw - 30, fy - 16, 18, 10), COL_BED_PILLOW)
	
	# Fluted Temple Columns as Bedposts
	var th = 75.0
	_draw_fluted_column(fx + 10, fy - th, th, true)
	_draw_fluted_column(fx + fw - 10, fy - th, th, true)
	
	# Heavy Architrave bridging the posts
	draw_rect(Rect2(fx - 10, fy - th, fw + 20, 8), COL_MARBLE_SHADE)
	draw_rect(Rect2(fx - 5, fy - th - 5, fw + 10, 5), COL_WOOD_SILVER)
	
	# Rich Drapery
	var drape_sway = sin(_anim_clock * 1.5) * 4.0
	
	var d1_pts = PackedVector2Array([
		Vector2(fx - 5, fy - th + 8), Vector2(fx + 25, fy - th + 8),
		Vector2(fx + 15 + drape_sway, fy - 15), Vector2(fx - 10 + drape_sway, fy - 15)
	])
	draw_colored_polygon(d1_pts, COL_BED_CANOPY)
	
	var d2_pts = PackedVector2Array([
		Vector2(fx + fw + 5, fy - th + 8), Vector2(fx + fw - 25, fy - th + 8),
		Vector2(fx + fw - 15 + drape_sway, fy - 15), Vector2(fx + fw + 10 + drape_sway, fy - 15)
	])
	draw_colored_polygon(d2_pts, COL_BED_CANOPY)

# ------------------------------------------------------------------------------
# 5. HOURGLASS ALTAR
# ------------------------------------------------------------------------------
func _draw_hourglass_altar(ax: float, ay: float) -> void:
	var dw = 60.0
	var dh = 8.0
	var dx = ax - dw/2.0
	var dy = ay - 20
	
	# Reskinned to have a massive marble fluted pedestal
	draw_rect(Rect2(dx + 15, dy + dh, 30, 20), COL_MARBLE)
	draw_rect(Rect2(dx + 10, dy + dh + 15, 40, 5), COL_MARBLE_SHADE) # Base
	
	# Gold Trim on Tabletop
	draw_rect(Rect2(dx, dy, dw, dh), COL_MARBLE_SHADE)
	draw_rect(Rect2(dx, dy + dh, dw, 2), Color(0.8, 0.6, 0.2))
	
	var hx = ax
	var hy = dy - 25
	draw_rect(Rect2(hx - 15, hy - 22, 30, 4), COL_WOOD_SILVER)
	draw_rect(Rect2(hx - 15, hy + 18, 30, 4), COL_WOOD_SILVER)
	
	draw_circle(Vector2(hx, hy - 10), 12.0, COL_HOURGLASS_GLASS)
	draw_circle(Vector2(hx, hy + 10), 12.0, COL_HOURGLASS_GLASS)
	
	draw_circle(Vector2(hx, hy - 10), 8.0, COL_SAND)
	draw_line(Vector2(hx, hy), Vector2(hx, hy + 10), COL_SAND, 2.0)
	draw_circle(Vector2(hx, hy + 14), 6.0, COL_SAND)
	
	if _hourglass_magic_time > 0.0:
		for i in range(12):
			var r_time = _anim_clock * 4.0 + i * 2.0
			var p_y = hy + 10 - fmod(r_time * 15.0, 40.0)
			var p_x = hx + sin(r_time + i) * 15.0
			var p_alpha = minf(1.0, _hourglass_magic_time) * (1.0 - fmod(r_time * 15.0, 40.0) / 40.0)
			draw_circle(Vector2(p_x, p_y), 1.5, Color(COL_SAND.r, COL_SAND.g, COL_SAND.b, p_alpha))

# ------------------------------------------------------------------------------
# 6. INTERACTIVE CHIMES
# ------------------------------------------------------------------------------
func _draw_chimes(cx: float, cy: float) -> void:
	# The chime base ring
	var rx = cx + sin(_chime_swing) * 20.0
	var ry = cy + 20.0 + cos(_chime_swing) * 5.0
	
	# Ceiling string
	draw_line(Vector2(cx, cy), Vector2(rx, ry), COL_CHIME_BRONZE, 1.0)
	
	# Base ring
	draw_rect(Rect2(rx - 15, ry, 30, 3), COL_CHIME_BRONZE.darkened(0.2))
	
	# 4 Chime pipes
	for i in range(4):
		var px = rx - 10 + i * 6.5
		var pl = 15.0 + fmod(i * 7.0, 10.0) # Variable lengths
		var pipe_swing = sin(_chime_swing * 2.0 + i) * 5.0
		draw_line(Vector2(px, ry + 3), Vector2(px + pipe_swing, ry + 3 + pl), COL_CHIME_BRONZE, 2.0)
		draw_line(Vector2(px-1, ry + 3), Vector2(px-1 + pipe_swing, ry + 3 + pl), COL_CHIME_BRONZE.lightened(0.2), 1.0) # Highlight

# ------------------------------------------------------------------------------
# 7. THE STARLIGHT WEAVER
# ------------------------------------------------------------------------------
func _draw_starlight_weaver() -> void:
	if not moth_active: return
	
	var flap = sin(_anim_clock * 20.0) * 10.0
	
	# Body
	draw_circle(Vector2(moth_x, moth_y), 3.0, COL_MOONFLOWER)
	
	# Left Wing
	var lw_pts = PackedVector2Array([
		Vector2(moth_x - 2, moth_y),
		Vector2(moth_x - 15, moth_y - 10 + flap),
		Vector2(moth_x - 20, moth_y + flap),
		Vector2(moth_x - 5, moth_y + 5)
	])
	draw_colored_polygon(lw_pts, COL_MOTH_WING)
	
	# Right Wing
	var rw_pts = PackedVector2Array([
		Vector2(moth_x + 2, moth_y),
		Vector2(moth_x + 15, moth_y - 10 + flap),
		Vector2(moth_x + 20, moth_y + flap),
		Vector2(moth_x + 5, moth_y + 5)
	])
	draw_colored_polygon(rw_pts, COL_MOTH_WING)
	
	# Glow
	draw_circle(Vector2(moth_x, moth_y), 25.0, COL_MOTH_GLOW)
