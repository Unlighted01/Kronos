@tool
extends Node2D
class_name PetRenderer

## Custom Pixel-Art Renderer for the Shiba Inu Companion in Kronos.
## Renders crisp, pixel-perfect 2D animations (Idle, Walk, Type, Drink, Nap, Petted, Victory).

enum AnimState {
	IDLE,
	WALK,
	TYPE,
	DRINK,
	NAP,
	PETTED,
	VICTORY,
	WATCH_TV,
	WARM_PAWS,
	STUDY,
	WINDOW_GAZE,
	TUCKED_IN,
	CHEF_SNIFF
}

# ==============================================================================
# 🎨 COLOR PALETTE (Shiba Inu & Props)
# ==============================================================================
const COL_FUR_MAIN: Color = Color(0.91, 0.58, 0.24, 1.0)     # #E8943D Golden Tan
const COL_FUR_SHADOW: Color = Color(0.76, 0.42, 0.15, 1.0)   # #C26B26 Fur Shadow
const COL_FUR_CREAM: Color = Color(0.99, 0.96, 0.89, 1.0)    # #FDF5E3 Cream White
const COL_EAR_PINK: Color = Color(0.96, 0.72, 0.75, 1.0)     # #F5B8BF Inner Ear
const COL_DARK_EYE: Color = Color(0.15, 0.11, 0.10, 1.0)     # #261C1A Dark Espresso
const COL_EYE_SHINE: Color = Color(1.0, 1.0, 1.0, 1.0)       # #FFFFFF White Shine
const COL_CHEEK_BLUSH: Color = Color(0.98, 0.52, 0.61, 0.7)  # #FA849C Pink Blush
const COL_TONGUE: Color = Color(0.98, 0.45, 0.56, 1.0)       # #FA738F Pink Tongue

# Props Colors
const COL_LAPTOP_BODY: Color = Color(0.45, 0.48, 0.54, 1.0)  # Silver/Grey
const COL_LAPTOP_SCREEN: Color = Color(0.24, 0.56, 0.85, 1.0)# Glowing Blue
const COL_SCREEN_CODE: Color = Color(0.70, 0.90, 1.0, 1.0)   # Code Highlights
const COL_MUG_BODY: Color = Color(0.92, 0.93, 0.95, 1.0)     # White Ceramic
const COL_COFFEE: Color = Color(0.38, 0.24, 0.18, 1.0)       # Dark Roast
const COL_STEAM: Color = Color(0.95, 0.95, 0.95, 0.6)        # Translucent Steam
const COL_HEART_PINK: Color = Color(0.98, 0.25, 0.52, 0.9)   # Pink Heart
const COL_STAR_GOLD: Color = Color(1.0, 0.84, 0.0, 0.9)      # Golden Star
const COL_ZZZ_BLUE: Color = Color(0.55, 0.75, 0.98, 0.85)    # Sleep Zzz

# ==============================================================================
# ⏱️ ANIMATION STATE & TIMERS
# ==============================================================================
@export var species: String = "shiba":
	set(value):
		if species != value:
			species = value
			queue_redraw()

@export var current_state: AnimState = AnimState.IDLE:
	set(value):
		if current_state != value:
			current_state = value
			anim_frame = 0
			anim_timer = 0.0
			queue_redraw()

@export var facing_right: bool = true:
	set(value):
		if facing_right != value:
			facing_right = value
			queue_redraw()

func _get_fur_main() -> Color:
	match species:
		"cat": return Color(0.96, 0.96, 0.98) # Calico White
		"bunny": return Color(0.98, 0.98, 1.0) # Snow White
		"penguin": return Color(0.12, 0.16, 0.24) # Navy Tuxedo
		"fox": return Color(0.92, 0.44, 0.12) # Amber Fox
		_: return COL_FUR_MAIN

func _get_fur_shadow() -> Color:
	match species:
		"cat": return Color(0.85, 0.85, 0.88)
		"bunny": return Color(0.88, 0.88, 0.92)
		"penguin": return Color(0.08, 0.10, 0.16)
		"fox": return Color(0.74, 0.32, 0.08)
		_: return COL_FUR_SHADOW

func _get_fur_cream() -> Color:
	match species:
		"cat": return Color(0.90, 0.55, 0.20) # Ginger Patch
		"bunny": return Color(0.98, 0.98, 1.0)
		"penguin": return Color(0.99, 0.99, 1.0) # White Belly
		"fox": return Color(0.99, 0.96, 0.89) # Cream chest
		_: return COL_FUR_CREAM

var anim_frame: int = 0
var anim_timer: float = 0.0
var frame_duration: float = 0.15

# Floating particle tracking (hearts, steam, Zzz, stars)
var _particles: Array[Dictionary] = []
var _particle_timer: float = 0.0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _process(delta: float) -> void:
	anim_timer += delta
	_update_animation_frame()
	_update_particles(delta)
	queue_redraw()

func _update_animation_frame() -> void:
	var max_frames: int = _get_frame_count_for_state(current_state)
	var speed: float = _get_frame_speed_for_state(current_state)
	
	if anim_timer >= speed:
		anim_timer = 0.0
		anim_frame = (anim_frame + 1) % max_frames

func _get_frame_count_for_state(state: AnimState) -> int:
	match state:
		AnimState.IDLE: return 4
		AnimState.WALK: return 4
		AnimState.TYPE: return 4
		AnimState.DRINK: return 4
		AnimState.NAP: return 4
		AnimState.PETTED: return 4
		AnimState.VICTORY: return 6
		AnimState.WATCH_TV: return 4
		AnimState.WARM_PAWS: return 4
		AnimState.STUDY: return 4
		AnimState.WINDOW_GAZE: return 4
		AnimState.TUCKED_IN: return 4
		AnimState.CHEF_SNIFF: return 4
	return 4

func _get_frame_speed_for_state(state: AnimState) -> float:
	match state:
		AnimState.IDLE: return 0.25
		AnimState.WALK: return 0.14
		AnimState.TYPE: return 0.12
		AnimState.DRINK: return 0.28
		AnimState.NAP: return 0.40
		AnimState.PETTED: return 0.15
		AnimState.VICTORY: return 0.12
		AnimState.WATCH_TV: return 0.30
		AnimState.WARM_PAWS: return 0.35
		AnimState.STUDY: return 0.25
		AnimState.WINDOW_GAZE: return 0.30
		AnimState.TUCKED_IN: return 0.45
		AnimState.CHEF_SNIFF: return 0.20
	return 0.20

# ==============================================================================
# 🌟 FLOATING PARTICLES (Hearts, Steam, Zzz, Stars)
# ==============================================================================
func _update_particles(delta: float) -> void:
	_particle_timer += delta
	
	# Spawn particles based on state
	if current_state == AnimState.PETTED and _particle_timer >= 0.25:
		_particle_timer = 0.0
		_spawn_particle("heart", Vector2(randf_range(-10, 10), -12))
	elif current_state == AnimState.WARM_PAWS and _particle_timer >= 0.45:
		_particle_timer = 0.0
		_spawn_particle("heart", Vector2(randf_range(2, 10), -8))
	elif (current_state == AnimState.DRINK or current_state == AnimState.CHEF_SNIFF) and _particle_timer >= 0.35:
		_particle_timer = 0.0
		_spawn_particle("steam", Vector2(8 if facing_right else -8, -4))
	elif (current_state == AnimState.NAP or current_state == AnimState.TUCKED_IN) and _particle_timer >= 0.6:
		_particle_timer = 0.0
		_spawn_particle("zzz", Vector2(randf_range(2, 10), -10))
	elif (current_state == AnimState.VICTORY or current_state == AnimState.STUDY or current_state == AnimState.WATCH_TV) and _particle_timer >= 0.30:
		_particle_timer = 0.0
		_spawn_particle("star", Vector2(randf_range(-10, 10), randf_range(-18, -8)))
		
	# Update active particles
	for i in range(_particles.size() - 1, -1, -1):
		var p: Dictionary = _particles[i]
		p["life"] -= delta
		p["pos"] += p["vel"] * delta
		p["alpha"] = clampf(p["life"] / p["max_life"], 0.0, 1.0)
		if p["life"] <= 0.0:
			_particles.remove_at(i)

func _spawn_particle(type: String, origin: Vector2 = Vector2.ZERO) -> void:
	var max_life: float = randf_range(0.8, 1.4)
	var vel: Vector2 = Vector2(randf_range(-4, 4), randf_range(-14, -8))
	if type == "zzz":
		vel = Vector2(randf_range(3, 8), randf_range(-10, -6))
		max_life = 1.6
	elif type == "star":
		vel = Vector2(randf_range(-10, 10), randf_range(-18, -10))
		max_life = 0.9
		
	_particles.append({
		"type": type,
		"pos": origin,
		"vel": vel,
		"life": max_life,
		"max_life": max_life,
		"alpha": 1.0,
		"scale": randf_range(0.8, 1.2)
	})

# ==============================================================================
# 🎨 CUSTOM CANVAS DRAWING
# ==============================================================================
func _draw() -> void:
	var flip: float = 1.0 if facing_right else -1.0
	
	# Draw shadow beneath pet
	_draw_pet_shadow()
	
	# Save canvas state for pet flip
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(flip, 1.0))
	
	match current_state:
		AnimState.IDLE:
			_draw_idle_anim()
		AnimState.WALK:
			_draw_walk_anim()
		AnimState.TYPE:
			_draw_type_anim()
		AnimState.DRINK:
			_draw_drink_anim()
		AnimState.NAP:
			_draw_nap_anim()
		AnimState.PETTED:
			_draw_petted_anim()
		AnimState.VICTORY:
			_draw_victory_anim()
		AnimState.WATCH_TV:
			_draw_watch_tv_anim()
		AnimState.WARM_PAWS:
			_draw_warm_paws_anim()
		AnimState.STUDY:
			_draw_study_anim()
		AnimState.WINDOW_GAZE:
			_draw_window_gaze_anim()
		AnimState.TUCKED_IN:
			_draw_tucked_in_anim()
		AnimState.CHEF_SNIFF:
			_draw_chef_sniff_anim()
			
	# Reset transform for world-space particle drawing
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_draw_all_particles()

# ==============================================================================
# 🐕 PET ANATOMY PIXEL DRAW HELPERS
# ==============================================================================
func _draw_pet_shadow() -> void:
	var shadow_w: float = 20.0
	var shadow_h: float = 6.0
	var shadow_y: float = 2.0
	if current_state == AnimState.NAP:
		shadow_w = 24.0
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(-shadow_w * 0.5, shadow_y),
			Vector2(0, shadow_y - shadow_h * 0.5),
			Vector2(shadow_w * 0.5, shadow_y),
			Vector2(0, shadow_y + shadow_h * 0.5)
		]),
		Color(0.0, 0.0, 0.0, 0.25)
	)

func _draw_pixel_rect(rect: Rect2, col: Color) -> void:
	draw_rect(rect, col)

# ------------------------------------------------------------------------------
# 1. IDLE ANIMATION (Gentle breath, tail wag, ear twitch)
# ------------------------------------------------------------------------------
func _draw_idle_anim() -> void:
	var bob: float = -1.0 if (anim_frame == 1 or anim_frame == 2) else 0.0
	var tail_wag: float = 1.0 if (anim_frame == 1 or anim_frame == 3) else -1.0
	var ear_twitch: float = -1.0 if anim_frame == 2 else 0.0
	var fur_main: Color = _get_fur_main()
	var fur_shadow: Color = _get_fur_shadow()
	var fur_cream: Color = _get_fur_cream()
	
	# Curled Tail
	_draw_curled_tail(Vector2(-10, -6 + bob), tail_wag)
	
	# Hind Paws / Legs
	_draw_pixel_rect(Rect2(-8, -2, 5, 4), fur_shadow)
	_draw_pixel_rect(Rect2(-8, 0, 5, 2), fur_cream)
	
	# Main Body
	_draw_pixel_rect(Rect2(-7, -10 + bob, 14, 10), fur_main)
	_draw_pixel_rect(Rect2(-3, -7 + bob, 8, 7), fur_cream) # Cream belly
	
	# Front Paws
	_draw_pixel_rect(Rect2(2, -2, 4, 4), fur_main)
	_draw_pixel_rect(Rect2(2, 0, 4, 2), fur_cream)
	_draw_pixel_rect(Rect2(-3, -2, 4, 4), fur_main)
	_draw_pixel_rect(Rect2(-3, 0, 4, 2), fur_cream)
	
	# Head
	_draw_shiba_head(Vector2(2, -14 + bob), ear_twitch, false, false)

# ------------------------------------------------------------------------------
# 2. WALK ANIMATION (Cute 4-frame waddle with alternating paws)
# ------------------------------------------------------------------------------
func _draw_walk_anim() -> void:
	var bob: float = -2.0 if (anim_frame == 1 or anim_frame == 3) else 0.0
	var paw_offset: float = 3.0 if anim_frame == 1 else (-3.0 if anim_frame == 3 else 0.0)
	var tail_wag: float = 2.0 if (anim_frame % 2 == 1) else -2.0
	var fur_main: Color = _get_fur_main()
	var fur_shadow: Color = _get_fur_shadow()
	var fur_cream: Color = _get_fur_cream()
	
	# Curled Tail
	_draw_curled_tail(Vector2(-10, -6 + bob), tail_wag)
	
	# Back paws
	_draw_pixel_rect(Rect2(-8 - paw_offset, -2, 4, 4), fur_shadow)
	_draw_pixel_rect(Rect2(-8 - paw_offset, 0, 4, 2), fur_cream)
	
	# Main Body
	_draw_pixel_rect(Rect2(-7, -10 + bob, 14, 10), fur_main)
	_draw_pixel_rect(Rect2(-3, -7 + bob, 8, 7), fur_cream)
	
	# Front paws
	_draw_pixel_rect(Rect2(2 + paw_offset, -2, 4, 4), fur_main)
	_draw_pixel_rect(Rect2(2 + paw_offset, 0, 4, 2), fur_cream)
	_draw_pixel_rect(Rect2(-2 - paw_offset, -2, 4, 4), fur_main)
	_draw_pixel_rect(Rect2(-2 - paw_offset, 0, 4, 2), fur_cream)
	
	# Head
	_draw_shiba_head(Vector2(3, -14 + bob), 0.0, false, false)

# ------------------------------------------------------------------------------
# 3. TYPE LAPTOP ANIMATION (Sitting with mini laptop, rapid typing)
# ------------------------------------------------------------------------------
func _draw_type_anim() -> void:
	var tap_left: bool = (anim_frame % 2 == 0)
	var screen_flicker: bool = (anim_frame % 2 == 1)
	var fur_main: Color = _get_fur_main()
	var fur_shadow: Color = _get_fur_shadow()
	var fur_cream: Color = _get_fur_cream()
	
	# Tail resting
	_draw_curled_tail(Vector2(-9, -5), 0.0)
	
	# Sitting Body
	_draw_pixel_rect(Rect2(-7, -8, 12, 9), fur_main)
	_draw_pixel_rect(Rect2(-2, -6, 7, 7), fur_cream)
	
	# Back foot tucked
	_draw_pixel_rect(Rect2(-8, -1, 5, 3), fur_shadow)
	_draw_pixel_rect(Rect2(-8, 0, 5, 2), fur_cream)
	
	# Laptop Stand / Base
	_draw_pixel_rect(Rect2(5, 0, 11, 2), COL_LAPTOP_BODY)
	
	# Laptop Screen (Angled)
	_draw_pixel_rect(Rect2(12, -10, 2, 10), COL_LAPTOP_BODY)
	_draw_pixel_rect(Rect2(10, -9, 2, 8), COL_LAPTOP_SCREEN)
	if screen_flicker:
		_draw_pixel_rect(Rect2(10, -8, 2, 2), COL_SCREEN_CODE)
		_draw_pixel_rect(Rect2(10, -4, 2, 2), COL_SCREEN_CODE)
	else:
		_draw_pixel_rect(Rect2(10, -6, 2, 3), COL_SCREEN_CODE)
		
	# Front Paws typing on keyboard
	var l_paw_y: float = -1.0 if tap_left else -3.0
	var r_paw_y: float = -3.0 if tap_left else -1.0
	_draw_pixel_rect(Rect2(5, l_paw_y, 3, 3), fur_cream)
	_draw_pixel_rect(Rect2(8, r_paw_y, 3, 3), fur_cream)
	
	# Focused Head (Concentrated eyes)
	_draw_shiba_head(Vector2(0, -13), 0.0, true, false)

# ------------------------------------------------------------------------------
# 4. DRINK COFFEE ANIMATION (Holding mug, sipping, steam)
# ------------------------------------------------------------------------------
func _draw_drink_anim() -> void:
	var sipping: bool = (anim_frame == 1 or anim_frame == 2)
	var mug_y: float = -7.0 if sipping else -4.0
	var fur_main: Color = _get_fur_main()
	var fur_shadow: Color = _get_fur_shadow()
	var fur_cream: Color = _get_fur_cream()
	
	# Tail resting
	_draw_curled_tail(Vector2(-9, -5), 0.0)
	
	# Sitting Body
	_draw_pixel_rect(Rect2(-7, -8, 12, 9), fur_main)
	_draw_pixel_rect(Rect2(-2, -6, 7, 7), fur_cream)
	_draw_pixel_rect(Rect2(-8, -1, 5, 3), fur_shadow)
	
	# Coffee Mug
	_draw_pixel_rect(Rect2(5, mug_y, 6, 6), COL_MUG_BODY)
	_draw_pixel_rect(Rect2(6, mug_y, 4, 1), COL_COFFEE)
	_draw_pixel_rect(Rect2(11, mug_y + 1, 2, 4), COL_MUG_BODY) # Handle
	
	# Paws holding mug
	_draw_pixel_rect(Rect2(4, mug_y + 2, 3, 3), fur_cream)
	_draw_pixel_rect(Rect2(8, mug_y + 2, 3, 3), fur_cream)
	
	# Head (Happy closed eyes while sipping)
	_draw_shiba_head(Vector2(0, -13), 0.0, false, sipping)

# ------------------------------------------------------------------------------
# 5. NAP ANIMATION (Curled up in a ball, slow breathing, Zzz)
# ------------------------------------------------------------------------------
func _draw_nap_anim() -> void:
	var breath: float = 1.0 if (anim_frame == 1 or anim_frame == 2) else 0.0
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# Curled Body ball
	_draw_pixel_rect(Rect2(-11, -8 - breath, 22, 9 + breath), fur_main)
	_draw_pixel_rect(Rect2(-5, -6 - breath, 12, 7 + breath), fur_cream)
	
	# Tail
	match species:
		"bunny":
			_draw_pixel_rect(Rect2(-13, -5, 4, 4), Color(0.98, 0.98, 1.0))
		"penguin":
			_draw_pixel_rect(Rect2(-12, -4, 3, 3), Color(0.08, 0.10, 0.16))
		"fox":
			_draw_pixel_rect(Rect2(-14, -7, 6, 6), fur_main)
			_draw_pixel_rect(Rect2(-13, -9, 4, 4), fur_cream)
		_:
			_draw_pixel_rect(Rect2(-12, -6, 4, 5), fur_main)
			_draw_pixel_rect(Rect2(-10, -7, 3, 3), fur_cream)
	
	# Sleeping head tucked down
	_draw_pixel_rect(Rect2(3, -9, 9, 8), fur_main)
	_draw_pixel_rect(Rect2(5, -6, 7, 5), fur_cream)
	
	# Ear tucked
	match species:
		"bunny":
			_draw_pixel_rect(Rect2(4, -14, 3, 8), fur_main)
			_draw_pixel_rect(Rect2(5, -13, 1, 6), Color(0.96, 0.72, 0.80))
		"penguin":
			pass
		"fox":
			_draw_pixel_rect(Rect2(4, -13, 3, 4), fur_main)
			_draw_pixel_rect(Rect2(4, -13, 3, 1), Color(0.12, 0.16, 0.24))
		_:
			_draw_pixel_rect(Rect2(4, -12, 3, 3), fur_main)
			_draw_pixel_rect(Rect2(5, -11, 2, 2), COL_EAR_PINK)
	
	# Sleeping Closed Eye (Crescent arc: 3 pixels)
	_draw_pixel_rect(Rect2(6, -6, 3, 1), COL_DARK_EYE)
	
	# Black nose
	_draw_pixel_rect(Rect2(11, -5, 2, 2), COL_DARK_EYE)
	
	# Paws tucked
	_draw_pixel_rect(Rect2(0, -2, 4, 3), fur_cream)

# ------------------------------------------------------------------------------
# 6. PETTED ANIMATION (Sparkling eyes, blush, happy tail wag)
# ------------------------------------------------------------------------------
func _draw_petted_anim() -> void:
	var bob: float = -1.0 if (anim_frame % 2 == 1) else 0.0
	var tail_wag: float = 3.0 if (anim_frame % 2 == 1) else -3.0
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# Super fast tail wag
	_draw_curled_tail(Vector2(-10, -6 + bob), tail_wag)
	
	# Body
	_draw_pixel_rect(Rect2(-7, -10 + bob, 14, 10), fur_main)
	_draw_pixel_rect(Rect2(-3, -7 + bob, 8, 7), fur_cream)
	
	# Paws
	_draw_pixel_rect(Rect2(2, -2, 4, 4), fur_main)
	_draw_pixel_rect(Rect2(2, 0, 4, 2), fur_cream)
	_draw_pixel_rect(Rect2(-3, -2, 4, 4), fur_main)
	_draw_pixel_rect(Rect2(-3, 0, 4, 2), fur_cream)
	
	# Happy head with blushing cheeks and sparkling eyes
	_draw_shiba_head(Vector2(2, -15 + bob), 0.0, false, true, true)

# ------------------------------------------------------------------------------
# 7. VICTORY DANCE ANIMATION (Celebratory hops, open smile, stars)
# ------------------------------------------------------------------------------
func _draw_victory_anim() -> void:
	var hop_height: float = -6.0 if (anim_frame == 1 or anim_frame == 2 or anim_frame == 4) else 0.0
	var arms_up: bool = (anim_frame == 1 or anim_frame == 2 or anim_frame == 4)
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# Curled tail wagging high
	_draw_curled_tail(Vector2(-10, -8 + hop_height), 2.0)
	
	# Upright dancing body
	_draw_pixel_rect(Rect2(-6, -11 + hop_height, 12, 10), fur_main)
	_draw_pixel_rect(Rect2(-3, -8 + hop_height, 7, 7), fur_cream)
	
	# Feet
	if hop_height < 0:
		_draw_pixel_rect(Rect2(-4, -1 + hop_height, 3, 3), fur_cream)
		_draw_pixel_rect(Rect2(2, -1 + hop_height, 3, 3), fur_cream)
	else:
		_draw_pixel_rect(Rect2(-5, -2, 4, 4), fur_cream)
		_draw_pixel_rect(Rect2(2, -2, 4, 4), fur_cream)
		
	# Front paws raised in victory
	if arms_up:
		_draw_pixel_rect(Rect2(-9, -14 + hop_height, 3, 4), fur_cream)
		_draw_pixel_rect(Rect2(7, -14 + hop_height, 3, 4), fur_cream)
	else:
		_draw_pixel_rect(Rect2(-8, -8 + hop_height, 3, 4), fur_cream)
		_draw_pixel_rect(Rect2(6, -8 + hop_height, 3, 4), fur_cream)
		
	# Cheerful head with open smile
	_draw_shiba_head(Vector2(0, -17 + hop_height), 0.0, false, false, true, true)

# ------------------------------------------------------------------------------
# 8. WATCH TV ANIMATION (Sits upright facing right, sparkling eyes)
# ------------------------------------------------------------------------------
func _draw_watch_tv_anim() -> void:
	var head_tilt: float = -1.0 if anim_frame == 2 else 0.0
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# Curled Tail resting over couch
	_draw_curled_tail(Vector2(-10, -6), 0.0)
	
	# Body sitting upright
	_draw_pixel_rect(Rect2(-7, -11, 14, 11), fur_main)
	_draw_pixel_rect(Rect2(-3, -8, 8, 8), fur_cream)
	
	# Paws resting forward
	_draw_pixel_rect(Rect2(2, -2, 4, 3), fur_cream)
	_draw_pixel_rect(Rect2(-4, -2, 4, 3), fur_cream)
	
	# Attentive head with wide sparkling eyes watching TV screen
	_draw_shiba_head(Vector2(2, -15 + head_tilt), 0.0, false, false, false, false)

# ------------------------------------------------------------------------------
# 9. WARM PAWS ANIMATION (Lying on belly in front of fire, toasting paws)
# ------------------------------------------------------------------------------
func _draw_warm_paws_anim() -> void:
	var breath: float = 1.0 if (anim_frame == 1 or anim_frame == 2) else 0.0
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# Body resting flat
	_draw_pixel_rect(Rect2(-10, -7 - breath, 20, 8 + breath), fur_main)
	_draw_pixel_rect(Rect2(-4, -5 - breath, 10, 6 + breath), fur_cream)
	
	# Curled Tail
	_draw_curled_tail(Vector2(-11, -5), 1.0)
	
	# Front paws stretched forward towards fire
	_draw_pixel_rect(Rect2(7, -2, 6, 3), fur_cream)
	_draw_pixel_rect(Rect2(4, -2, 4, 3), fur_cream)
	
	# Happy cozy head with blushing cheeks and closed eyes
	_draw_shiba_head(Vector2(3, -11), 0.0, false, true, true, false)

# ------------------------------------------------------------------------------
# 10. STUDY ANIMATION (Sitting at library desk, studying open grimoire)
# ------------------------------------------------------------------------------
func _draw_study_anim() -> void:
	var look_down: float = 1.0 if (anim_frame == 1 or anim_frame == 2) else 0.0
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# Curled Tail
	_draw_curled_tail(Vector2(-10, -6), 0.0)
	
	# Body sitting upright
	_draw_pixel_rect(Rect2(-7, -10, 14, 10), fur_main)
	_draw_pixel_rect(Rect2(-3, -7, 8, 7), fur_cream)
	
	# Paws resting on desk surface
	_draw_pixel_rect(Rect2(3, -4, 4, 4), fur_cream)
	_draw_pixel_rect(Rect2(-2, -4, 4, 4), fur_cream)
	
	# Focused head looking down at book
	_draw_shiba_head(Vector2(2, -14 + look_down), 0.0, true, false, false, false)

# ------------------------------------------------------------------------------
# 11. WINDOW GAZE ANIMATION (Sitting peacefully watching breeze & particles)
# ------------------------------------------------------------------------------
func _draw_window_gaze_anim() -> void:
	var ear_twitch: float = -1.0 if (anim_frame == 1 or anim_frame == 3) else 0.0
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# Curled Tail with gentle sway
	_draw_curled_tail(Vector2(-10, -6), sin(anim_frame * 1.5) * 1.5)
	
	# Body sitting quietly
	_draw_pixel_rect(Rect2(-7, -10, 14, 10), fur_main)
	_draw_pixel_rect(Rect2(-3, -7, 8, 7), fur_cream)
	
	# Paws
	_draw_pixel_rect(Rect2(2, -2, 4, 4), fur_cream)
	_draw_pixel_rect(Rect2(-3, -2, 4, 4), fur_cream)
	
	# Head tilted upward gazing at sky with breezy ear twitch
	_draw_shiba_head(Vector2(2, -16), ear_twitch, false, false, false, false)

# ------------------------------------------------------------------------------
# 12. TUCKED IN BED ANIMATION (Classic cozy curled sleeping donut)
# ------------------------------------------------------------------------------
func _draw_tucked_in_anim() -> void:
	_draw_nap_anim()

# ------------------------------------------------------------------------------
# 13. CHEF SNIFF ANIMATION (Leaning forward sniffing savory steam)
# ------------------------------------------------------------------------------
func _draw_chef_sniff_anim() -> void:
	var sniff_bob: float = -1.0 if (anim_frame % 2 == 1) else 0.0
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# Curled Tail wagging
	_draw_curled_tail(Vector2(-10, -6), 2.0)
	
	# Body leaning forward
	_draw_pixel_rect(Rect2(-6, -9 + sniff_bob, 14, 9), fur_main)
	_draw_pixel_rect(Rect2(-2, -6 + sniff_bob, 8, 6), fur_cream)
	
	# Paws standing alert
	_draw_pixel_rect(Rect2(4, -2, 4, 4), fur_cream)
	_draw_pixel_rect(Rect2(-3, -2, 4, 4), fur_cream)
	
	# Sniffing head with open mouth and shiny eyes
	_draw_shiba_head(Vector2(4, -13 + sniff_bob), 0.0, false, false, false, true)

# ==============================================================================
# 🦊 MODULAR SHIBA HEAD RENDERER
# ==============================================================================
func _draw_shiba_head(pos: Vector2, ear_tilt: float, focused: bool = false, closed_eyes: bool = false, blush: bool = false, open_mouth: bool = false) -> void:
	var hx: float = pos.x
	var hy: float = pos.y
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	# 1. Ears (Species-specific)
	match species:
		"bunny":
			# Long upright floppy bunny ears
			_draw_pixel_rect(Rect2(hx - 5, hy - 14 + ear_tilt, 4, 11), fur_main)
			_draw_pixel_rect(Rect2(hx - 4, hy - 12 + ear_tilt, 2, 8), Color(0.96, 0.72, 0.80))
			_draw_pixel_rect(Rect2(hx + 3, hy - 14, 4, 11), fur_main)
			_draw_pixel_rect(Rect2(hx + 4, hy - 12, 2, 8), Color(0.96, 0.72, 0.80))
		"penguin":
			# Tuxedo head crest
			_draw_pixel_rect(Rect2(hx - 2, hy - 6, 6, 2), fur_main)
		"fox":
			# Fox pointed ears with black tips
			_draw_pixel_rect(Rect2(hx - 6, hy - 8 + ear_tilt, 4, 5), fur_main)
			_draw_pixel_rect(Rect2(hx - 6, hy - 8 + ear_tilt, 4, 2), Color(0.12, 0.16, 0.24)) # Black tips
			_draw_pixel_rect(Rect2(hx - 5, hy - 6 + ear_tilt, 2, 2), COL_EAR_PINK)
			_draw_pixel_rect(Rect2(hx + 3, hy - 8, 4, 5), fur_main)
			_draw_pixel_rect(Rect2(hx + 3, hy - 8, 4, 2), Color(0.12, 0.16, 0.24))
			_draw_pixel_rect(Rect2(hx + 4, hy - 6, 2, 2), COL_EAR_PINK)
		"cat":
			# Cat triangular ears
			_draw_pixel_rect(Rect2(hx - 6, hy - 7 + ear_tilt, 4, 4), fur_main)
			_draw_pixel_rect(Rect2(hx - 5, hy - 6 + ear_tilt, 2, 2), COL_EAR_PINK)
			_draw_pixel_rect(Rect2(hx + 3, hy - 7, 4, 4), Color(0.25, 0.25, 0.30)) # Slate patch ear
			_draw_pixel_rect(Rect2(hx + 4, hy - 6, 2, 2), COL_EAR_PINK)
		_:
			# Shiba pointed ears
			_draw_pixel_rect(Rect2(hx - 6, hy - 7 + ear_tilt, 4, 4), fur_main)
			_draw_pixel_rect(Rect2(hx - 5, hy - 6 + ear_tilt, 2, 2), COL_EAR_PINK)
			_draw_pixel_rect(Rect2(hx + 3, hy - 7, 4, 4), fur_main)
			_draw_pixel_rect(Rect2(hx + 4, hy - 6, 2, 2), COL_EAR_PINK)
	
	# 2. Head Base
	_draw_pixel_rect(Rect2(hx - 6, hy - 4, 14, 11), fur_main)
	
	# 3. Markings & Muzzle
	match species:
		"shiba":
			# White Eyebrow Dots
			_draw_pixel_rect(Rect2(hx - 3, hy - 2, 2, 2), fur_cream)
			_draw_pixel_rect(Rect2(hx + 3, hy - 2, 2, 2), fur_cream)
			_draw_pixel_rect(Rect2(hx - 3, hy + 2, 10, 5), fur_cream)
			_draw_pixel_rect(Rect2(hx + 1, hy, 6, 4), fur_cream)
		"cat":
			# Calico patches & whiskers
			_draw_pixel_rect(Rect2(hx - 6, hy - 4, 6, 5), Color(0.90, 0.55, 0.20)) # Ginger patch
			_draw_pixel_rect(Rect2(hx + 2, hy - 4, 6, 5), Color(0.25, 0.25, 0.30)) # Dark patch
			_draw_pixel_rect(Rect2(hx - 2, hy + 2, 8, 5), fur_main) # White muzzle
			# Tiny Whiskers
			_draw_pixel_rect(Rect2(hx - 8, hy + 2, 2, 1), Color(0.4, 0.4, 0.45))
			_draw_pixel_rect(Rect2(hx + 8, hy + 2, 2, 1), Color(0.4, 0.4, 0.45))
		"bunny":
			# Soft cheeks
			_draw_pixel_rect(Rect2(hx - 3, hy + 2, 9, 5), fur_main)
			_draw_pixel_rect(Rect2(hx + 6, hy + 2, 2, 2), Color(0.96, 0.72, 0.80)) # Pink nose
		"penguin":
			# White face masks & orange beak
			_draw_pixel_rect(Rect2(hx - 3, hy - 1, 9, 7), Color(0.99, 0.99, 1.0))
			_draw_pixel_rect(Rect2(hx + 5, hy + 2, 4, 3), Color(0.98, 0.60, 0.10)) # Orange beak
			# Red Scarf
			_draw_pixel_rect(Rect2(hx - 6, hy + 7, 14, 3), Color(0.88, 0.22, 0.25))
		"fox":
			# White muzzle and cheek tufts
			_draw_pixel_rect(Rect2(hx - 4, hy + 2, 11, 5), Color(0.99, 0.96, 0.89))
			_draw_pixel_rect(Rect2(hx + 7, hy + 2, 2, 2), Color(0.12, 0.16, 0.24)) # Black nose
	
	# 4. Eyes
	if closed_eyes:
		_draw_pixel_rect(Rect2(hx - 2, hy, 3, 1), COL_DARK_EYE)
		_draw_pixel_rect(Rect2(hx + 4, hy, 3, 1), COL_DARK_EYE)
	elif focused:
		_draw_pixel_rect(Rect2(hx - 2, hy, 3, 2), COL_DARK_EYE)
		_draw_pixel_rect(Rect2(hx + 4, hy, 3, 2), COL_DARK_EYE)
	else:
		_draw_pixel_rect(Rect2(hx - 2, hy - 1, 3, 3), COL_DARK_EYE)
		_draw_pixel_rect(Rect2(hx - 2, hy - 1, 1, 1), COL_EYE_SHINE)
		_draw_pixel_rect(Rect2(hx + 4, hy - 1, 3, 3), COL_DARK_EYE)
		_draw_pixel_rect(Rect2(hx + 4, hy - 1, 1, 1), COL_EYE_SHINE)
		
	# 5. Nose & Cheeks
	if species != "penguin" and species != "bunny":
		_draw_pixel_rect(Rect2(hx + 6, hy + 2, 2, 2), COL_DARK_EYE)
		
	if blush:
		_draw_pixel_rect(Rect2(hx - 4, hy + 2, 3, 2), COL_CHEEK_BLUSH)
		_draw_pixel_rect(Rect2(hx + 2, hy + 2, 3, 2), COL_CHEEK_BLUSH)
		
	# 6. Mouth / Tongue
	if species != "penguin":
		if open_mouth:
			_draw_pixel_rect(Rect2(hx + 3, hy + 4, 3, 3), COL_DARK_EYE)
			_draw_pixel_rect(Rect2(hx + 4, hy + 5, 2, 2), COL_TONGUE)
		else:
			_draw_pixel_rect(Rect2(hx + 4, hy + 4, 2, 1), COL_DARK_EYE)

# ------------------------------------------------------------------------------
# 🌀 TAIL HELPER
# ------------------------------------------------------------------------------
func _draw_curled_tail(origin: Vector2, wag: float) -> void:
	var tx: float = origin.x + wag
	var ty: float = origin.y
	var fur_main: Color = _get_fur_main()
	var fur_cream: Color = _get_fur_cream()
	
	match species:
		"cat":
			# Long slender cat tail swaying
			_draw_pixel_rect(Rect2(tx - 2, ty - 1, 3, 3), fur_main)
			_draw_pixel_rect(Rect2(tx - 4, ty - 3, 3, 3), Color(0.25, 0.25, 0.30))
			_draw_pixel_rect(Rect2(tx - 5, ty - 6, 3, 4), fur_main)
			_draw_pixel_rect(Rect2(tx - 4, ty - 8, 3, 3), Color(0.90, 0.55, 0.20))
		"bunny":
			# Cotton ball pompom tail
			_draw_pixel_rect(Rect2(tx - 2, ty - 2, 4, 4), Color(0.98, 0.98, 1.0))
			_draw_pixel_rect(Rect2(tx - 1, ty - 3, 3, 1), Color(0.95, 0.95, 0.98))
		"penguin":
			# Small tuxedo tail wedge
			_draw_pixel_rect(Rect2(tx - 2, ty - 1, 3, 3), Color(0.08, 0.10, 0.16))
		"fox":
			# Huge fluffy brush tail with white tip
			_draw_pixel_rect(Rect2(tx - 3, ty - 2, 5, 5), fur_main)
			_draw_pixel_rect(Rect2(tx - 6, ty - 5, 6, 6), fur_main)
			_draw_pixel_rect(Rect2(tx - 8, ty - 8, 6, 5), Color(0.99, 0.96, 0.89))
		_:
			# Shiba curled tail
			_draw_pixel_rect(Rect2(tx, ty, 3, 4), fur_main)
			_draw_pixel_rect(Rect2(tx - 2, ty - 3, 4, 4), fur_main)
			_draw_pixel_rect(Rect2(tx - 1, ty - 5, 4, 3), fur_cream)
			_draw_pixel_rect(Rect2(tx + 1, ty - 4, 3, 2), fur_cream)

# ==============================================================================
# ✨ PARTICLE RENDERING (Hearts, Steam, Zzz, Stars)
# ==============================================================================
func _draw_all_particles() -> void:
	for p in _particles:
		var pos: Vector2 = p["pos"]
		var alpha: float = p["alpha"]
		var type: String = p["type"]
		
		match type:
			"heart":
				_draw_pixel_heart(pos, alpha)
			"steam":
				_draw_pixel_steam(pos, alpha)
			"zzz":
				_draw_pixel_zzz(pos, alpha)
			"star":
				_draw_pixel_star(pos, alpha)
			"anger":
				_draw_pixel_anger(pos, alpha)
			"exclamation":
				_draw_pixel_exclamation(pos, alpha)

func _draw_pixel_heart(pos: Vector2, alpha: float) -> void:
	var col: Color = Color(COL_HEART_PINK.r, COL_HEART_PINK.g, COL_HEART_PINK.b, alpha)
	# 5x4 pixel heart
	_draw_pixel_rect(Rect2(pos.x - 2, pos.y - 2, 2, 1), col)
	_draw_pixel_rect(Rect2(pos.x + 1, pos.y - 2, 2, 1), col)
	_draw_pixel_rect(Rect2(pos.x - 3, pos.y - 1, 6, 2), col)
	_draw_pixel_rect(Rect2(pos.x - 2, pos.y + 1, 4, 1), col)
	_draw_pixel_rect(Rect2(pos.x - 1, pos.y + 2, 2, 1), col)

func _draw_pixel_steam(pos: Vector2, alpha: float) -> void:
	var col: Color = Color(COL_STEAM.r, COL_STEAM.g, COL_STEAM.b, alpha * 0.7)
	_draw_pixel_rect(Rect2(pos.x, pos.y, 2, 3), col)
	_draw_pixel_rect(Rect2(pos.x + 1, pos.y - 3, 2, 2), col)

func _draw_pixel_zzz(pos: Vector2, alpha: float) -> void:
	var col: Color = Color(COL_ZZZ_BLUE.r, COL_ZZZ_BLUE.g, COL_ZZZ_BLUE.b, alpha)
	# 4x4 pixel 'Z'
	_draw_pixel_rect(Rect2(pos.x - 2, pos.y - 2, 4, 1), col)
	_draw_pixel_rect(Rect2(pos.x, pos.y - 1, 2, 1), col)
	_draw_pixel_rect(Rect2(pos.x - 1, pos.y, 2, 1), col)
	_draw_pixel_rect(Rect2(pos.x - 2, pos.y + 1, 4, 1), col)

func _draw_pixel_star(pos: Vector2, alpha: float) -> void:
	var col: Color = Color(COL_STAR_GOLD.r, COL_STAR_GOLD.g, COL_STAR_GOLD.b, alpha)
	# 3x3 diamond sparkle
	_draw_pixel_rect(Rect2(pos.x, pos.y - 2, 1, 5), col)
	_draw_pixel_rect(Rect2(pos.x - 2, pos.y, 5, 1), col)
	_draw_pixel_rect(Rect2(pos.x - 1, pos.y - 1, 3, 3), Color(1.0, 1.0, 1.0, alpha))

func _draw_pixel_anger(pos: Vector2, alpha: float) -> void:
	var col: Color = Color(0.95, 0.20, 0.25, alpha)
	# 4-corner anime anger mark 💢
	_draw_pixel_rect(Rect2(pos.x - 3, pos.y - 3, 2, 2), col)
	_draw_pixel_rect(Rect2(pos.x + 2, pos.y - 3, 2, 2), col)
	_draw_pixel_rect(Rect2(pos.x - 3, pos.y + 2, 2, 2), col)
	_draw_pixel_rect(Rect2(pos.x + 2, pos.y + 2, 2, 2), col)
	_draw_pixel_rect(Rect2(pos.x - 1, pos.y - 1, 3, 3), col)

func _draw_pixel_exclamation(pos: Vector2, alpha: float) -> void:
	var col: Color = Color(1.0, 0.90, 0.20, alpha)
	# 2x6 pixel exclamation mark !
	_draw_pixel_rect(Rect2(pos.x, pos.y - 6, 2, 4), col)
	_draw_pixel_rect(Rect2(pos.x, pos.y - 1, 2, 2), col)
