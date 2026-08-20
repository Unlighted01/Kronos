extends CharacterBody2D
class_name PetBrain

## Autonomous Pet AI & State Machine for Kronos.
## Controls the Shiba Inu companion physics, elevation hopping onto furniture (Beds, Sofas, Chairs),
## autonomous room wandering, context-aware prop interactions, and instant response to user clicks.

enum State {
	IDLE,
	WANDER,
	WALK_TO_TARGET,
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
	CHEF_SNIFF,
	EXITING_ROOM
}

# ==============================================================================
# 🏠 HOUSE TOPOLOGY FOR AUTONOMOUS ROAMING
# ==============================================================================
const HOUSE_TOPOLOGY: Dictionary = {
	"room_bedroom": ["room_livingroom"],
	"room_livingroom": ["room_bedroom", "room_library", "room_kitchen"],
	"room_library": ["room_livingroom"],
	"room_kitchen": ["room_livingroom", "room_greenhouse"],
	"room_greenhouse": ["room_kitchen"]
}

# Door / Ladder coordinates for animated transitions
const ROOM_EXITS: Dictionary = {
	"room_bedroom": { "room_livingroom": 224.0 },
	"room_livingroom": { "room_bedroom": 16.0, "room_library": 92.0, "room_kitchen": 226.0 },
	"room_library": { "room_livingroom": 118.0 },
	"room_kitchen": { "room_livingroom": 16.0, "room_greenhouse": 224.0 },
	"room_greenhouse": { "room_kitchen": 16.0 }
}

const ROOM_ENTRIES: Dictionary = {
	"room_bedroom": { "room_livingroom": 210.0 },
	"room_livingroom": { "room_bedroom": 28.0, "room_library": 92.0, "room_kitchen": 212.0 },
	"room_library": { "room_livingroom": 118.0 },
	"room_kitchen": { "room_livingroom": 28.0, "room_greenhouse": 210.0 },
	"room_greenhouse": { "room_kitchen": 28.0 }
}

# ==============================================================================
# 🐾 EXPORT CONFIGURATION & ROOM BOUNDS
# ==============================================================================
@export_group("Room Bounds & Anchors")
@export var min_x: float = 40.0
@export var max_x: float = 200.0
@export var floor_y: float = 115.0
@export var desk_x: float = 75.0
@export var nap_x: float = 175.0
@export var drink_x: float = 120.0

@export_group("Movement Physics")
@export var walk_speed: float = 42.0
@export var arrival_tolerance: float = 3.0

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var renderer: PetRenderer = $PetRenderer
@onready var cosmetic_layer: CosmeticLayer = $CosmeticLayer
@onready var thought_bubble: ThoughtBubble = $ThoughtBubble
@onready var click_area: Area2D = $ClickArea

# ==============================================================================
# 📊 INTERNAL STATE MACHINE & PATIENCE
# ==============================================================================
var current_state: State = State.IDLE
var target_x: float = 120.0
var current_target_y: float = 115.0
var post_target_y: float = 115.0
var state_timer: float = 0.0
var post_target_state: State = State.IDLE

# Previous state cache for interruptions (like petting)
var _previous_state: State = State.IDLE
var _petted_duration: float = 2.5
var _victory_duration: float = 3.0
var _periodic_thought_timer: float = 0.0

# Focus Work Patience (2-4 minutes attention span before naturally taking a break)
var _work_patience_timer: float = 0.0
var _work_patience_duration: float = 180.0

# Petting Spam & Annoyance State
var _pet_click_count: int = 0
var _pet_spam_timer: float = 0.0

# Autonomous Room Roaming State
var _roam_timer: float = 0.0
var _next_roam_interval: float = 50.0
var _pending_target_room: String = ""

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	position.x = 120.0
	target_x = 120.0
	current_target_y = floor_y
	post_target_y = floor_y
	position.y = floor_y
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	visible = true
	_reset_roam_timer()
	_work_patience_duration = randf_range(120.0, 240.0)
	
	_connect_event_bus()
	
	if click_area:
		click_area.input_event.connect(_on_click_area_input_event)
		
	_sync_initial_state()
	_update_visibility_from_room_state()

func _connect_event_bus() -> void:
	EventBus.timer_state_changed.connect(_on_timer_state_changed)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.session_completed.connect(_on_session_completed)
	EventBus.session_skipped.connect(_on_session_skipped)
	EventBus.pet_interacted.connect(_on_pet_interacted)
	EventBus.item_used.connect(_on_item_used)
	EventBus.room_changed.connect(_on_room_changed)
	EventBus.pet_room_changed.connect(_on_pet_room_changed)
	EventBus.pet_called.connect(_on_pet_called)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.object_state_changed.connect(_on_object_state_changed)

func _physics_process(delta: float) -> void:
	state_timer += delta
	_periodic_thought_timer += delta
	
	if _pet_spam_timer > 0.0:
		_pet_spam_timer -= delta
		if _pet_spam_timer <= 0.0:
			_pet_click_count = 0
			
	# Process autonomous roaming across connected rooms
	_process_autonomous_room_roaming(delta)
	
	# Random periodic thoughts strictly matched to the active activity
	_process_periodic_thoughts()
	
	# Execute active state logic
	match current_state:
		State.IDLE:
			_process_idle_state(delta)
		State.WANDER, State.WALK_TO_TARGET:
			_process_walk_state(delta)
		State.TYPE:
			_process_type_state(delta)
		State.DRINK:
			_process_drink_state(delta)
		State.NAP:
			_process_nap_state(delta)
		State.PETTED:
			_process_petted_state(delta)
		State.VICTORY:
			_process_victory_state(delta)
		State.WATCH_TV:
			_process_watch_tv_state(delta)
		State.WARM_PAWS:
			_process_warm_paws_state(delta)
		State.STUDY:
			_process_study_state(delta)
		State.WINDOW_GAZE:
			_process_window_gaze_state(delta)
		State.TUCKED_IN:
			_process_tucked_in_state(delta)
		State.CHEF_SNIFF:
			_process_chef_sniff_state(delta)
		State.EXITING_ROOM:
			_process_exiting_room_state(delta)
			
	# Enforce room boundaries & target y level
	position.x = clampf(position.x, min_x - 5.0, max_x + 5.0)
	if current_state == State.WALK_TO_TARGET:
		position.y = move_toward(position.y, floor_y, delta * 60.0)
	else:
		position.y = move_toward(position.y, current_target_y, delta * 60.0)

# ==============================================================================
# ⏰ DIURNAL PROFILE (REAL-TIME DAY / NIGHT)
# ==============================================================================
func _get_time_profile() -> Dictionary:
	var hour: int = Time.get_time_dict_from_system().get("hour", 12)
	var is_night: bool = (hour >= 20 or hour < 6)
	return {
		"hour": hour,
		"is_night": is_night,
		"roam_interval_min": 75.0 if is_night else 35.0,
		"roam_interval_max": 130.0 if is_night else 65.0,
		"nap_bias": 0.50 if is_night else 0.15
	}

func _reset_roam_timer() -> void:
	var profile: Dictionary = _get_time_profile()
	_next_roam_interval = randf_range(profile.roam_interval_min, profile.roam_interval_max)
	_roam_timer = 0.0

# ==============================================================================
# 🔄 CONTEXTUAL STATE HANDLERS
# ==============================================================================
func _process_idle_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.IDLE)
	
	var profile: Dictionary = _get_time_profile()
	var cur_room: String = GameState.pet_room if GameState else "room_bedroom"
	var is_working: bool = (TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.RUNNING and TimerEngine.current_phase == TimerEngine.TimerPhase.WORK)
	
	# Decide next action after a few seconds of idle
	if state_timer >= randf_range(4.0, 8.0):
		state_timer = 0.0
		
		# 1. Check for Work Opportunity in current room
		if is_working and cur_room == "room_bedroom" and randf() < 0.40:
			_work_patience_timer = 0.0
			_work_patience_duration = randf_range(120.0, 240.0)
			if thought_bubble and visible:
				thought_bubble.show_random_thought("work_join", 3.0)
			walk_to(72.0, State.TYPE, floor_y)
			return
			
		# 2. Context-Aware Room Prop Behaviors
		if _try_room_specific_activity(cur_room, profile):
			return
			
		# 3. Standard autonomous decision roll
		var roll: float = randf()
		if roll < 0.60:
			# Wander around room floor
			walk_to(randf_range(min_x, max_x), State.IDLE, floor_y)
		elif roll < 0.80:
			# Change facing direction
			if renderer:
				renderer.facing_right = not renderer.facing_right
		elif roll < 0.90:
			# Quick nap
			if thought_bubble and visible:
				thought_bubble.show_random_thought("go_to_sleep", 3.0)
			walk_to(nap_x, State.NAP, floor_y)
		else:
			# Drink/snack
			if thought_bubble and visible:
				thought_bubble.show_random_thought("drink", 3.0)
			walk_to(drink_x, State.DRINK, floor_y)

## Evaluates room props and initiates special activities
func _try_room_specific_activity(room: String, profile: Dictionary) -> bool:
	if not GameState:
		return false
		
	match room:
		"room_bedroom":
			var is_bed_open: bool = GameState.get_object_state("bedroom_blanket_folded", false)
			var is_win_open: bool = GameState.get_object_state("bedroom_window_open", false)
			
			# Night or Sleep: Sleep cozily by the bed!
			if (profile.is_night or randf() < 0.35) and is_bed_open:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("bedroom_tucked", 3.5)
				walk_to(168.0, State.NAP, floor_y)
				return true
				
			# If window is open, sit and gaze at breeze
			if is_win_open and randf() < 0.40:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("window_gaze", 3.5)
				walk_to(122.0, State.WINDOW_GAZE, floor_y)
				return true
				
		"room_livingroom":
			var is_tv_on: bool = GameState.get_object_state("livingroom_tv_on", false)
			var is_fire_lit: bool = GameState.get_object_state("livingroom_fireplace_lit", true)
			var is_win_open: bool = GameState.get_object_state("livingroom_window_open", false)
			
			# If TV is ON: high priority to sit on couch and watch!
			if is_tv_on and randf() < 0.75:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("watch_tv", 3.5)
				walk_to(138.0, State.WATCH_TV, 88.0)
				return true
				
			# If Fireplace is lit: toasting paws on rug
			if is_fire_lit and randf() < 0.45:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("warm_paws", 3.5)
				walk_to(64.0, State.WARM_PAWS, 112.0)
				return true
				
			# If window open in living room
			if is_win_open and randf() < 0.30:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("window_gaze", 3.5)
				walk_to(138.0, State.WINDOW_GAZE, 88.0)
				return true
				
		"room_library":
			var is_book_open: bool = GameState.get_object_state("attic_book_open", true)
			
			# Sit in new study chair and study grimoire
			if is_book_open and randf() < 0.55:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("attic_study", 3.5)
				walk_to(134.0, State.STUDY, 92.0)
				return true
			elif randf() < 0.40:
				# Rest in emerald armchair
				if thought_bubble and visible:
					thought_bubble.show_random_thought("attic_armchair", 3.5)
				walk_to(72.0, State.NAP, 88.0)
				return true
				
		"room_kitchen":
			var is_stove_on: bool = GameState.get_object_state("kitchen_stove_cooking", false)
			var is_oven_open: bool = GameState.get_object_state("kitchen_oven_open", false)
			
			# Sniff simmering pot at stove
			if is_stove_on and randf() < 0.50:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("kitchen_stove", 3.5)
				walk_to(106.0, State.CHEF_SNIFF, 112.0)
				return true
			# Wait by open oven for pastries
			elif is_oven_open and randf() < 0.50:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("kitchen_oven", 3.5)
				walk_to(112.0, State.CHEF_SNIFF, 112.0)
				return true
			# Espresso drink
			elif randf() < 0.35:
				if thought_bubble and visible:
					thought_bubble.show_random_thought("kitchen_coffee", 3.5)
				walk_to(55.0, State.DRINK, 112.0)
				return true
				
		"room_greenhouse":
			var roll: float = randf()
			if roll < 0.40:
				# Gaze at Sakura Bonsai & catch falling petals
				if thought_bubble and visible:
					thought_bubble.show_random_thought("greenhouse", 3.5)
				walk_to(75.0, State.WINDOW_GAZE, floor_y)
				return true
			elif roll < 0.70:
				# Sniff freshly bloomed flowers on potting bench
				if thought_bubble and visible:
					thought_bubble.show_thought("Sweet floral fragrance! 🌸🌿", 3.5)
				walk_to(165.0, State.CHEF_SNIFF, floor_y)
				return true
			elif roll < 0.90:
				# Rest in the shade of the Monstera umbrella
				if thought_bubble and visible:
					thought_bubble.show_thought("Cozy nap under the big leaves~ 🍃", 3.5)
				walk_to(125.0, State.NAP, floor_y)
				return true
				
	return false

func _process_walk_state(_delta: float) -> void:
	_set_renderer_state(PetRenderer.AnimState.WALK)
	var diff: float = target_x - position.x
	
	if absf(diff) <= arrival_tolerance:
		# Arrived at destination horizontal coordinate
		velocity.x = 0.0
		position.x = target_x
		current_state = post_target_state
		current_target_y = post_target_y
		state_timer = 0.0
		
		# If target is on elevated furniture, play cute hop jump!
		if post_target_y < floor_y - 2.0:
			var hop_tween: Tween = create_tween()
			hop_tween.tween_property(self, "position:y", post_target_y - 8.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			hop_tween.tween_property(self, "position:y", post_target_y, 0.12).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		else:
			position.y = post_target_y
			
		# Specific arrival facing logic
		if current_state == State.WATCH_TV or current_state == State.STUDY or current_state == State.TYPE:
			if renderer:
				renderer.facing_right = true
		elif current_state == State.WARM_PAWS:
			if renderer:
				renderer.facing_right = false
		elif current_state == State.EXITING_ROOM:
			_execute_room_transition_fade(_pending_target_room)
	else:
		var dir: float = signf(diff)
		velocity.x = dir * walk_speed
		if renderer:
			renderer.facing_right = (dir > 0)
		move_and_slide()

func _process_type_state(delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.TYPE)
	if renderer:
		renderer.facing_right = true
		
	_work_patience_timer += delta
	if _work_patience_timer >= _work_patience_duration:
		_work_patience_timer = 0.0
		var exit_roll: float = randf()
		if exit_roll < 0.40:
			if thought_bubble and visible:
				thought_bubble.show_random_thought("go_to_sleep", 3.0)
			walk_to(nap_x, State.NAP, floor_y)
		elif exit_roll < 0.70:
			if thought_bubble and visible:
				thought_bubble.show_random_thought("stretch_wander", 3.0)
			walk_to(randf_range(min_x, max_x), State.IDLE, floor_y)
		else:
			if thought_bubble and visible:
				thought_bubble.show_random_thought("drink", 3.0)
			walk_to(drink_x, State.DRINK, floor_y)

func _process_drink_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.DRINK)
	if state_timer >= 6.0:
		current_state = State.IDLE
		state_timer = 0.0

func _process_nap_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.NAP)
	var profile: Dictionary = _get_time_profile()
	var nap_limit: float = randf_range(35.0, 65.0) if profile.is_night else randf_range(14.0, 28.0)
	if state_timer >= nap_limit:
		state_timer = 0.0
		current_state = State.IDLE

func _process_tucked_in_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.TUCKED_IN)
	var profile: Dictionary = _get_time_profile()
	var nap_limit: float = randf_range(45.0, 90.0) if profile.is_night else randf_range(20.0, 40.0)
	if state_timer >= nap_limit:
		state_timer = 0.0
		current_state = State.IDLE

func _process_watch_tv_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.WATCH_TV)
	if renderer:
		renderer.facing_right = true
	# Binge-watch for 20-40 seconds
	if state_timer >= randf_range(20.0, 40.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_warm_paws_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.WARM_PAWS)
	if renderer:
		renderer.facing_right = false
	if state_timer >= randf_range(16.0, 32.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_study_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.STUDY)
	if renderer:
		renderer.facing_right = true
	if state_timer >= randf_range(18.0, 36.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_window_gaze_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.WINDOW_GAZE)
	if state_timer >= randf_range(12.0, 24.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_chef_sniff_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.CHEF_SNIFF)
	if state_timer >= randf_range(8.0, 16.0):
		state_timer = 0.0
		current_state = State.IDLE

func _process_petted_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.PETTED)
	if state_timer >= _petted_duration:
		state_timer = 0.0
		current_state = _previous_state
		if current_state == State.WALK_TO_TARGET or current_state == State.WANDER or current_state == State.EXITING_ROOM:
			current_state = State.IDLE

func _process_victory_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.VICTORY)
	if state_timer >= _victory_duration:
		state_timer = 0.0
		_start_break_behavior()

func _process_exiting_room_state(_delta: float) -> void:
	velocity.x = 0.0
	# Held during exit tween

# ==============================================================================
# 🚶 NAVIGATION & COMMANDS
# ==============================================================================
func walk_to(dest_x: float, next_state: State = State.IDLE, dest_y: float = 115.0) -> void:
	target_x = clampf(dest_x, min_x, max_x)
	post_target_state = next_state
	post_target_y = dest_y
	current_state = State.WALK_TO_TARGET
	state_timer = 0.0

func set_room_anchors(p_min_x: float, p_max_x: float, p_desk_x: float, p_nap_x: float, p_drink_x: float, p_floor_y: float = 115.0) -> void:
	min_x = p_min_x
	max_x = p_max_x
	desk_x = p_desk_x
	nap_x = p_nap_x
	drink_x = p_drink_x
	floor_y = p_floor_y
	current_target_y = floor_y
	post_target_y = floor_y
	position.y = floor_y
	position.x = clampf(position.x, min_x, max_x)

# ==============================================================================
# 🚪 ANIMATED ROOM ROAMING TRANSITIONS
# ==============================================================================
func _process_autonomous_room_roaming(delta: float) -> void:
	_roam_timer += delta
	if _roam_timer < _next_roam_interval:
		return
		
	_reset_roam_timer()
	
	var profile: Dictionary = _get_time_profile()
	var cur_room: String = GameState.pet_room if GameState else "room_bedroom"
	var neighbors: Array = HOUSE_TOPOLOGY.get(cur_room, [])
	
	if neighbors.size() == 0 or current_state == State.TYPE or current_state == State.EXITING_ROOM:
		return
		
	# Night Roaming Logic: High tendency to seek Bedroom
	if profile.is_night:
		if cur_room == "room_bedroom":
			if randf() > 0.15:
				return
		else:
			var target_night_rooms: Array = ["room_bedroom", "room_livingroom"]
			var best_room: String = neighbors[0]
			for neighbor in neighbors:
				if neighbor in target_night_rooms:
					best_room = neighbor
					break
			_start_room_transition_walk(cur_room, best_room)
			return

	# Daytime Roaming Logic: 45% chance to roam to neighbor
	if randf() <= 0.45:
		var next_room: String = neighbors[randi() % neighbors.size()]
		_start_room_transition_walk(cur_room, next_room)

func _start_room_transition_walk(from_room: String, to_room: String) -> void:
	var exit_map: Dictionary = ROOM_EXITS.get(from_room, {})
	var exit_pos_x: float = exit_map.get(to_room, (min_x + max_x) * 0.5)
	
	_pending_target_room = to_room
	
	# Show departure thought if visible
	if GameState and GameState.is_pet_in_current_view() and thought_bubble and not thought_bubble._is_showing:
		match to_room:
			"room_kitchen": thought_bubble.show_thought("Heading to the kitchen! 🥐", 2.5)
			"room_greenhouse": thought_bubble.show_thought("Visiting the plants! 🌿", 2.5)
			"room_library": thought_bubble.show_thought("Going up to the attic! 📚", 2.5)
			"room_livingroom": thought_bubble.show_thought("Heading to the living room! 🛋️", 2.5)
			"room_bedroom": thought_bubble.show_thought("Going to the bedroom! 🛏️", 2.5)
			_: thought_bubble.show_thought("Exploring next door! 🐾", 2.5)
			
	# Walk over to door/ladder, then execute exit animation
	walk_to(exit_pos_x, State.EXITING_ROOM, floor_y)

func _on_object_state_changed(key: String, val: Variant) -> void:
	if not GameState or not GameState.is_pet_in_current_view():
		return
	var cur_room: String = GameState.pet_room
	
	# ==========================================================================
	# 📺 STATE IDEMPOTENCY & TOGGLE-OFF HANDLING
	# ==========================================================================
	if current_state == State.WATCH_TV and key == "livingroom_tv_on":
		if val == true:
			if thought_bubble:
				thought_bubble.show_thought("Best part of the show! 🍿📺", 3.0)
			return
		else:
			if thought_bubble:
				thought_bubble.show_thought("Show's over~ time to stretch! 🐾", 3.0)
			current_state = State.IDLE
			return
			
	if current_state == State.STUDY and key == "attic_book_open":
		if val == true:
			if thought_bubble:
				thought_bubble.show_thought("Fascinating chapter! 📖✨", 3.0)
			return
		else:
			current_state = State.IDLE
			return
			
	if current_state == State.WARM_PAWS and key == "livingroom_fireplace_lit" and val == false:
		if thought_bubble:
			thought_bubble.show_thought("Fire went out~ brisk! ❄️", 3.0)
		current_state = State.IDLE
		return

	# ==========================================================================
	# ⚡ STARTLED REACTION ON SUDDEN LOUD UNUSED ITEMS
	# ==========================================================================
	var loud_keys: Array = [
		"attic_books_tumbled", "kitchen_stove", "kitchen_oven",
		"kitchen_espresso", "kitchen_chopping", "greenhouse_monstera"
	]
	if key in loud_keys and val == true:
		if randf() < 0.65:
			if thought_bubble:
				thought_bubble.show_random_thought("startled", 3.0)
			if renderer:
				renderer._spawn_particle("exclamation")
				
			# Mini startled bounce
			var startle_tween = create_tween()
			startle_tween.tween_property(self, "position:y", position.y - 4.0, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			startle_tween.tween_property(self, "position:y", position.y, 0.10).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			return
			
	# ==========================================================================
	# 🌱 ORGANIC IDLE ATTRACTIONS
	# ==========================================================================
	if current_state != State.IDLE:
		return
		
	if cur_room == "room_livingroom" and key == "livingroom_tv_on" and val == true:
		if randf() < 0.65:
			if thought_bubble:
				thought_bubble.show_random_thought("watch_tv", 3.0)
			walk_to(138.0, State.WATCH_TV, 88.0)
	elif cur_room == "room_livingroom" and key == "livingroom_fireplace_lit" and val == true:
		if randf() < 0.50:
			if thought_bubble:
				thought_bubble.show_random_thought("warm_paws", 3.0)
			walk_to(64.0, State.WARM_PAWS, 112.0)
	elif cur_room == "room_library" and key == "attic_book_open" and val == true:
		if randf() < 0.50:
			if thought_bubble:
				thought_bubble.show_random_thought("attic_study", 3.0)
			walk_to(134.0, State.STUDY, 92.0)

func _execute_room_transition_fade(next_room: String) -> void:
	if not GameState:
		return
		
	var from_room: String = GameState.pet_room
	var is_in_view: bool = GameState.is_pet_in_current_view()
	
	if is_in_view:
		# Play exit fade tween
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(func():
			GameState.set_pet_room(next_room)
			_position_at_entry_door(from_room, next_room)
			_update_visibility_from_room_state()
		)
	else:
		GameState.set_pet_room(next_room)
		_position_at_entry_door(from_room, next_room)
		_update_visibility_from_room_state()

func _position_at_entry_door(from_room: String, to_room: String) -> void:
	var entry_map: Dictionary = ROOM_ENTRIES.get(to_room, {})
	var spawn_x: float = entry_map.get(from_room, (min_x + max_x) * 0.5)
	position.x = clampf(spawn_x, min_x, max_x)
	target_x = position.x
	current_target_y = floor_y
	post_target_y = floor_y
	position.y = floor_y
	current_state = State.IDLE
	
	if GameState and GameState.is_pet_in_current_view():
		modulate.a = 0.0
		var in_tween: Tween = create_tween()
		in_tween.tween_property(self, "modulate:a", 1.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		modulate.a = 1.0

# ==============================================================================
# ⏱️ EVENT BUS HANDLERS
# ==============================================================================
func _sync_initial_state() -> void:
	current_state = State.IDLE
	_reset_roam_timer()

func _on_timer_state_changed(is_running: bool, is_paused: bool) -> void:
	if is_running:
		if TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
			var cur_room: String = GameState.pet_room if GameState else "room_bedroom"
			if cur_room == "room_bedroom":
				if randf() < 0.85:
					_work_patience_timer = 0.0
					_work_patience_duration = randf_range(120.0, 240.0)
					if thought_bubble and visible:
						thought_bubble.show_random_thought("work_join", 3.0)
					walk_to(72.0, State.TYPE, floor_y)
				else:
					if thought_bubble and visible:
						thought_bubble.show_thought("You got this! 💻✨", 3.0)
			else:
				if thought_bubble and visible:
					thought_bubble.show_thought("Focus mode started! 🚀", 3.0)
		else:
			_start_break_behavior()
	elif is_paused:
		if current_state == State.TYPE:
			_set_renderer_state(PetRenderer.AnimState.IDLE)
	else:
		if current_state == State.TYPE:
			current_state = State.IDLE

func _on_phase_changed(new_phase: String, _duration: float) -> void:
	if new_phase == "work":
		var cur_room: String = GameState.pet_room if GameState else "room_bedroom"
		if cur_room == "room_bedroom" and randf() < 0.85:
			_work_patience_timer = 0.0
			_work_patience_duration = randf_range(120.0, 240.0)
			if thought_bubble and visible:
				thought_bubble.show_random_thought("work_join", 3.0)
			walk_to(72.0, State.TYPE, floor_y)
	else:
		_start_break_behavior()

func _on_session_completed(session_type: String, _coins: int, _xp: int, _streak: int) -> void:
	if session_type == "work":
		current_state = State.VICTORY
		state_timer = 0.0
		if thought_bubble and visible:
			if GameState.streak >= 2:
				thought_bubble.show_random_thought("streak", 3.5)
			else:
				thought_bubble.show_thought("Work session complete! 🎉", 3.5)
	else:
		if thought_bubble and visible:
			thought_bubble.show_thought("Refreshed & ready! 🚀", 3.0)
		current_state = State.IDLE

func _on_session_skipped(_session_type: String) -> void:
	current_state = State.IDLE
	if thought_bubble and visible:
		thought_bubble.show_thought("Taking a breather~", 2.5)

func _start_break_behavior() -> void:
	var roll: float = randf()
	var cur_room = GameState.pet_room if GameState else "room_bedroom"
	if roll < 0.5:
		if thought_bubble and visible:
			thought_bubble.show_random_thought("go_to_sleep", 3.0)
		walk_to(nap_x, State.NAP, 86.0 if cur_room == "room_bedroom" else floor_y)
	else:
		if thought_bubble and visible:
			thought_bubble.show_random_thought("drink", 3.0)
		walk_to(drink_x, State.DRINK, floor_y)

func _on_pet_interacted(interaction_type: String) -> void:
	if interaction_type == "pet":
		_pet_click_count += 1
		_pet_spam_timer = 2.5
		
		# 1. Annoyed Reaction if Spam Petted (4+ rapid clicks)
		if _pet_click_count >= 4:
			_pet_click_count = 0
			if thought_bubble and visible:
				thought_bubble.show_random_thought("annoyed", 3.0)
			if renderer:
				renderer._spawn_particle("anger")
			return
			
		# Play cute purr/chirp sound
		if has_node("/root/AudioManager"):
			var am = get_node("/root/AudioManager")
			if am and am.has_method("play_sfx"):
				am.play_sfx("chirp")
				
		# 2. In-Place Petting (If resting on furniture, watching TV, sleeping, or typing)
		var in_furniture: bool = (current_state == State.WATCH_TV or current_state == State.TYPE or current_state == State.NAP or current_state == State.TUCKED_IN or current_state == State.WARM_PAWS or current_state == State.STUDY or current_state == State.WINDOW_GAZE)
		if in_furniture:
			if thought_bubble and visible:
				thought_bubble.show_random_thought("petted", 2.0)
			if renderer:
				renderer._spawn_particle("heart")
			return
			
		# 3. Regular Standing Petting Bounce
		if current_state != State.PETTED:
			_previous_state = current_state
		current_state = State.PETTED
		state_timer = 0.0
		if thought_bubble and visible:
			thought_bubble.show_random_thought("petted", 2.5)
		if renderer:
			renderer._spawn_particle("heart")

func _on_item_used(item_id: String, _item_data: Dictionary) -> void:
	if not visible:
		return
		
	match item_id:
		"snack_coffee":
			if thought_bubble:
				thought_bubble.show_thought("Delicious espresso! ☕ +25⚡", 3.5)
			walk_to(drink_x, State.DRINK, floor_y)
		"snack_matcha":
			if thought_bubble:
				thought_bubble.show_thought("Zen focus... fragrant matcha! 🍵✨", 3.5)
			walk_to(drink_x, State.DRINK, floor_y)
		"snack_boba":
			if thought_bubble:
				thought_bubble.show_thought("Tapioca pearls! Slurp~ 🧋❤️", 3.5)
			walk_to(drink_x, State.DRINK, floor_y)
		"snack_croissant":
			if thought_bubble:
				thought_bubble.show_thought("Crispy & buttery flake! 🥐💖", 3.2)
			_play_snack_bounce()
		"snack_donut":
			if thought_bubble:
				thought_bubble.show_thought("Sprinkles & strawberry glaze! 🍩✨", 3.2)
			_play_snack_bounce()
		"snack_pancake":
			if thought_bubble:
				thought_bubble.show_thought("Fluffy souffle cloud pancakes! 🥞🍯", 3.5)
			_play_snack_bounce()
		"snack_onigiri":
			if thought_bubble:
				thought_bubble.show_thought("Tasty salmon filling! 🍙🐾", 3.2)
			_play_snack_bounce()
		"snack_ramen":
			if thought_bubble:
				thought_bubble.show_thought("Steaming midnight tonkotsu! 🍜🔥", 3.5)
			_play_snack_bounce()
		"snack_bento":
			if thought_bubble:
				thought_bubble.show_thought("Deluxe feast of champions! 🍱👑", 4.0)
			_play_snack_bounce()
		_:
			if thought_bubble:
				thought_bubble.show_thought("Yum! So tasty! ❤️🐾", 3.0)
			_play_snack_bounce()

func _play_snack_bounce() -> void:
	if current_state != State.PETTED and current_state != State.TYPE:
		if current_state != State.PETTED:
			_previous_state = current_state
		current_state = State.PETTED
		state_timer = 0.0
		if renderer:
			renderer._spawn_particle("heart")

func _on_energy_changed(new_energy: float, _max: float, _is_buffed: bool) -> void:
	if new_energy <= 20.0 and current_state == State.IDLE and randf() < 0.3:
		if thought_bubble and visible:
			thought_bubble.show_random_thought("low_energy", 3.0)

func _on_pet_called(_target_room: String) -> void:
	current_state = State.IDLE
	visible = true
	modulate = Color(1.0, 1.0, 1.0, 1.0)
	position.x = clampf((min_x + max_x) * 0.5, min_x + 10.0, max_x - 10.0)
	target_x = position.x
	current_target_y = floor_y
	post_target_y = floor_y
	position.y = floor_y
	_update_visibility_from_room_state()
	_play_summon_bounce()

func _play_summon_bounce() -> void:
	if current_state != State.PETTED:
		_previous_state = current_state
	current_state = State.PETTED
	state_timer = 0.0
	_set_renderer_state(PetRenderer.AnimState.PETTED)
	
	if thought_bubble:
		thought_bubble.show_thought("I'm here! ❤️🐾", 3.0)
		
	var base_y: float = floor_y
	var bounce_tween: Tween = create_tween()
	bounce_tween.tween_property(self, "position:y", base_y - 14.0, 0.14).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "position:y", base_y, 0.14).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "position:y", base_y - 7.0, 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(self, "position:y", base_y, 0.10).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

func _on_pet_room_changed(_new_pet_room: String) -> void:
	_update_visibility_from_room_state()

func _on_room_changed(_room_id: String) -> void:
	_update_visibility_from_room_state()
	position.x = clampf(position.x, min_x, max_x)
	current_target_y = floor_y
	post_target_y = floor_y
	position.y = floor_y
	if current_state == State.TYPE and (not TimerEngine or TimerEngine.status != TimerEngine.TimerStatus.RUNNING):
		current_state = State.IDLE

func _update_visibility_from_room_state() -> void:
	var is_in_view: bool = GameState.is_pet_in_current_view() if GameState else true
	visible = is_in_view
	if is_in_view:
		modulate.a = 1.0
	if click_area:
		click_area.monitoring = is_in_view
		click_area.monitorable = is_in_view

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_perform_pet_action()

func _unhandled_input(event: InputEvent) -> void:
	if not visible or not is_inside_tree():
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			var local_pos: Vector2 = to_local(get_global_mouse_position())
			if Rect2(-24, -36, 48, 44).has_point(local_pos):
				_perform_pet_action()
				get_viewport().set_input_as_handled()

func _perform_pet_action() -> void:
	if GameState:
		GameState.add_joy(5.0)
	EventBus.pet_interacted.emit("pet")

func _process_periodic_thoughts() -> void:
	if _periodic_thought_timer >= 25.0:
		_periodic_thought_timer = 0.0
		if not visible:
			return
		if thought_bubble and not thought_bubble._is_showing:
			match current_state:
				State.TYPE: thought_bubble.show_random_thought("working", 3.0)
				State.NAP: thought_bubble.show_random_thought("napping", 3.0)
				State.TUCKED_IN: thought_bubble.show_random_thought("bedroom_tucked", 3.0)
				State.DRINK: thought_bubble.show_random_thought("drink", 3.0)
				State.WATCH_TV: thought_bubble.show_random_thought("watch_tv", 3.0)
				State.WARM_PAWS: thought_bubble.show_random_thought("warm_paws", 3.0)
				State.STUDY: thought_bubble.show_random_thought("attic_study", 3.0)
				State.WINDOW_GAZE: thought_bubble.show_random_thought("window_gaze", 3.0)
				State.CHEF_SNIFF: thought_bubble.show_random_thought("kitchen_stove", 3.0)
				State.IDLE, State.WANDER, State.WALK_TO_TARGET:
					var profile: Dictionary = _get_time_profile()
					if profile.is_night and randf() < 0.5:
						thought_bubble.show_random_thought("night", 3.0)
					elif randf() < 0.4:
						thought_bubble.show_random_thought("idle", 3.0)

func _set_renderer_state(anim_state: PetRenderer.AnimState) -> void:
	if renderer and renderer.current_state != anim_state:
		renderer.current_state = anim_state
