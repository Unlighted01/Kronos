extends Node2D
class_name PetDeliveryBox

## 📦 Pet Delivery Parcel Box for Kronos.
## Handles the joyful delivery unboxing animation when adopting a new companion!

signal unboxing_finished(pet_data: Dictionary)

# ==============================================================================
# 📊 ANIMATION STATES
# ==============================================================================
enum DeliveryState { FALLING, BOUNCING, WIGGLING, POPPING_OPEN, FINISHED }

var current_state: DeliveryState = DeliveryState.FALLING
var pet_data: Dictionary = {}

var box_x: float = 120.0
var box_y: float = 20.0
var target_y: float = 110.0
var vy: float = 0.0
var gravity: float = 400.0

var bounce_count: int = 0
var wiggle_timer: float = 0.0
var state_timer: float = 0.0

var lid_offset_y: float = 0.0
var lid_vy: float = -120.0
var lid_vx: float = 40.0
var lid_x: float = 0.0
var lid_rot: float = 0.0

var squash_x: float = 1.0
var squash_y: float = 1.0

var _particles: Array[Dictionary] = []

func setup(p_data: Dictionary, spawn_x: float = 120.0, floor_y: float = 110.0) -> void:
	pet_data = p_data
	box_x = spawn_x
	target_y = floor_y
	box_y = floor_y - 70.0
	position = Vector2(box_x, box_y)
	current_state = DeliveryState.FALLING
	vy = 0.0
	bounce_count = 0
	state_timer = 0.0
	_particles.clear()
	queue_redraw()

func _process(delta: float) -> void:
	match current_state:
		DeliveryState.FALLING:
			vy += gravity * delta
			box_y += vy * delta
			if box_y >= target_y:
				box_y = target_y
				vy = -vy * 0.45 # Bounce dampening
				bounce_count += 1
				squash_x = 1.3
				squash_y = 0.7
				if AudioManager:
					AudioManager.play_sfx("thud")
				if bounce_count >= 2:
					current_state = DeliveryState.BOUNCING
					state_timer = 0.35
					
		DeliveryState.BOUNCING:
			squash_x = lerpf(squash_x, 1.0, 10.0 * delta)
			squash_y = lerpf(squash_y, 1.0, 10.0 * delta)
			state_timer -= delta
			if state_timer <= 0.0:
				current_state = DeliveryState.WIGGLING
				state_timer = 0.8
				if AudioManager:
					AudioManager.play_sfx("chirp")
					
		DeliveryState.WIGGLING:
			wiggle_timer += delta * 18.0
			squash_x = 1.0 + sin(wiggle_timer) * 0.12
			state_timer -= delta
			if state_timer <= 0.0:
				_trigger_pop_open()
				
		DeliveryState.POPPING_OPEN:
			lid_vy += gravity * 0.6 * delta
			lid_offset_y += lid_vy * delta
			lid_x += lid_vx * delta
			lid_rot += 4.0 * delta
			
			state_timer -= delta
			if state_timer <= 0.0:
				current_state = DeliveryState.FINISHED
				unboxing_finished.emit(pet_data)
				queue_free()
				
	# Animate confetti & sparkle particles
	for i in range(_particles.size() - 1, -1, -1):
		var p: Dictionary = _particles[i]
		p["x"] += p["vx"] * delta
		p["y"] += p["vy"] * delta
		p["vy"] += 60.0 * delta # Slight gravity on confetti
		p["alpha"] -= 1.0 * delta
		if p["alpha"] <= 0.0:
			_particles.remove_at(i)
			
	position = Vector2(box_x, box_y)
	queue_redraw()

func _trigger_pop_open() -> void:
	current_state = DeliveryState.POPPING_OPEN
	state_timer = 1.2
	if AudioManager:
		AudioManager.play_sfx("chime")
		
	# Spawn bursting celebratory confetti particles
	var colors: Array[Color] = [
		Color(0.98, 0.4, 0.5),  # Pink
		Color(1.0, 0.85, 0.2),  # Gold
		Color(0.35, 0.85, 0.95),# Cyan
		Color(0.45, 0.95, 0.45),# Green
		Color(0.85, 0.55, 0.95) # Purple
	]
	
	for i in range(24):
		var ang: float = randf_range(-PI, 0.0) # Upward burst
		var spd: float = randf_range(50.0, 110.0)
		_particles.append({
			"x": 0.0,
			"y": -12.0,
			"vx": cos(ang) * spd,
			"vy": sin(ang) * spd,
			"color": colors[i % colors.size()],
			"alpha": 1.0,
			"size": randf_range(2.0, 4.0)
		})

func _draw() -> void:
	# 1. Soft parcel shadow
	draw_circle(Vector2(0, 8), 16.0 * squash_x, Color(0, 0, 0, 0.25))
	
	# 2. Cardboard Box Body
	var bw: float = 28.0 * squash_x
	var bh: float = 22.0 * squash_y
	var bx: float = -bw * 0.5
	var by: float = -bh
	
	# Box base: Warm Kraft Cardboard (#c28d59)
	draw_rect(Rect2(bx, by, bw, bh), Color(0.76, 0.55, 0.35))
	# Box shading
	draw_rect(Rect2(bx + bw - 4, by, 4, bh), Color(0.62, 0.43, 0.26))
	# Box outline
	draw_rect(Rect2(bx, by, bw, bh), Color(0.38, 0.24, 0.14), false, 1.0)
	
	# Red parcel ribbon string
	draw_rect(Rect2(-2, by, 4, bh), Color(0.88, 0.24, 0.28))
	draw_rect(Rect2(bx, by + bh * 0.5 - 2, bw, 4), Color(0.88, 0.24, 0.28))
	
	# Postal Stamp Sticker (Cream with cute paw/heart)
	draw_rect(Rect2(bx + 3, by + 3, 7, 6), Color(0.98, 0.96, 0.90))
	draw_circle(Vector2(bx + 6.5, by + 6.0), 1.5, Color(0.9, 0.3, 0.3))
	
	# 3. Box Lid
	if current_state != DeliveryState.POPPING_OPEN and current_state != DeliveryState.FINISHED:
		var lw: float = 32.0 * squash_x
		var lh: float = 6.0
		var lx: float = -lw * 0.5
		var ly: float = by - 3.0
		draw_rect(Rect2(lx, ly, lw, lh), Color(0.82, 0.60, 0.40))
		draw_rect(Rect2(lx, ly, lw, lh), Color(0.38, 0.24, 0.14), false, 1.0)
		# Red Ribbon Bow Knot
		draw_circle(Vector2(0, ly), 2.5, Color(0.95, 0.2, 0.25))
	elif current_state == DeliveryState.POPPING_OPEN:
		# Draw flying lid
		draw_set_transform(Vector2(lid_x, by - 4.0 + lid_offset_y), lid_rot, Vector2.ONE)
		draw_rect(Rect2(-16, -3, 32, 6), Color(0.82, 0.60, 0.40))
		draw_rect(Rect2(-16, -3, 32, 6), Color(0.38, 0.24, 0.14), false, 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		
	# 4. Draw Confetti Particles
	for p in _particles:
		var col: Color = p["color"]
		col.a = p["alpha"]
		draw_rect(Rect2(p["x"], p["y"], p["size"], p["size"]), col)
