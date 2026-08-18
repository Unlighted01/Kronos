extends CharacterBody2D
class_name PetBrain

## Autonomous Pet AI & State Machine for Kronos.
## Controls the Shiba Inu companion physics, autonomous room wandering,
## Pomodoro timer reactions (typing at desk, break napping, victory dance), and interactions.

enum State {
	IDLE,
	WANDER,
	WALK_TO_TARGET,
	TYPE,
	DRINK,
	NAP,
	PETTED,
	VICTORY
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
@export var walk_speed: float = 38.0
@export var arrival_tolerance: float = 3.0

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var renderer: PetRenderer = $PetRenderer
@onready var cosmetic_layer: CosmeticLayer = $CosmeticLayer
@onready var thought_bubble: ThoughtBubble = $ThoughtBubble
@onready var click_area: Area2D = $ClickArea

# ==============================================================================
# 📊 INTERNAL STATE MACHINE
# ==============================================================================
var current_state: State = State.IDLE
var target_x: float = 120.0
var state_timer: float = 0.0
var post_target_state: State = State.IDLE

# Previous state cache for interruptions (like petting)
var _previous_state: State = State.IDLE
var _petted_duration: float = 2.5
var _victory_duration: float = 3.0
var _periodic_thought_timer: float = 0.0

# Autonomous Room Roaming State
var _roam_timer: float = 0.0
var _next_roam_interval: float = 60.0 # Random 45.0 - 75.0s

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	# Position at initial floor level
	position.y = floor_y
	target_x = position.x
	_next_roam_interval = randf_range(45.0, 75.0)
	
	# Connect to EventBus
	_connect_event_bus()
	
	# Connect click interaction
	if click_area:
		click_area.input_event.connect(_on_click_area_input_event)
		
	# Sync initial state based on TimerEngine
	_sync_initial_state()
	
	# Update visibility according to current room state
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

func _physics_process(delta: float) -> void:
	state_timer += delta
	_periodic_thought_timer += delta
	
	# Process autonomous roaming across connected rooms
	_process_autonomous_room_roaming(delta)
	
	# Random periodic thoughts when idle or working
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
			
	# Enforce room boundaries & floor level
	position.x = clampf(position.x, min_x - 5.0, max_x + 5.0)
	position.y = floor_y

# ==============================================================================
# 🔄 STATE HANDLERS
# ==============================================================================
func _process_idle_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.IDLE)
	
	# If timer is running in work phase, head to desk
	if TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.RUNNING and TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
		walk_to(desk_x, State.TYPE)
		return
		
	# Random autonomous wander decision
	if state_timer >= randf_range(3.5, 7.0):
		state_timer = 0.0
		# Decide next action: wander somewhere or take a nap/drink
		var roll = randf()
		if roll < 0.6:
			var random_dest: float = randf_range(min_x, max_x)
			walk_to(random_dest, State.IDLE)
		elif roll < 0.8:
			_set_renderer_state(PetRenderer.AnimState.IDLE)
		else:
			# Look around
			if renderer:
				renderer.facing_right = not renderer.facing_right

func _process_walk_state(_delta: float) -> void:
	_set_renderer_state(PetRenderer.AnimState.WALK)
	var diff: float = target_x - position.x
	
	if absf(diff) <= arrival_tolerance:
		# Arrived at destination
		velocity.x = 0.0
		position.x = target_x
		current_state = post_target_state
		state_timer = 0.0
	else:
		var dir: float = signf(diff)
		velocity.x = dir * walk_speed
		if renderer:
			renderer.facing_right = (dir > 0)
		move_and_slide()

func _process_type_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.TYPE)
	if renderer:
		renderer.facing_right = true # Face towards desk/laptop

func _process_drink_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.DRINK)
	
	# Return to idle after drinking for a while unless in break
	if state_timer >= 6.0:
		if not (TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.RUNNING):
			current_state = State.IDLE
			state_timer = 0.0

func _process_nap_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.NAP)

func _process_petted_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.PETTED)
	
	if state_timer >= _petted_duration:
		state_timer = 0.0
		current_state = _previous_state
		if current_state == State.WALK_TO_TARGET or current_state == State.WANDER:
			current_state = State.IDLE

func _process_victory_state(_delta: float) -> void:
	velocity.x = 0.0
	_set_renderer_state(PetRenderer.AnimState.VICTORY)
	
	if state_timer >= _victory_duration:
		state_timer = 0.0
		# Transition to break state
		_start_break_behavior()

# ==============================================================================
# 🚶 NAVIGATION & COMMANDS
# ==============================================================================
## Commands the pet to walk to a specific horizontal coordinate and enter next_state on arrival
func walk_to(dest_x: float, next_state: State = State.IDLE) -> void:
	target_x = clampf(dest_x, min_x, max_x)
	post_target_state = next_state
	current_state = State.WALK_TO_TARGET
	state_timer = 0.0

## Sets room navigation anchors and boundaries
func set_room_anchors(p_min_x: float, p_max_x: float, p_desk_x: float, p_nap_x: float, p_drink_x: float, p_floor_y: float = 115.0) -> void:
	min_x = p_min_x
	max_x = p_max_x
	desk_x = p_desk_x
	nap_x = p_nap_x
	drink_x = p_drink_x
	floor_y = p_floor_y
	position.y = floor_y
	
	# Clamp position
	position.x = clampf(position.x, min_x, max_x)

# ==============================================================================
# 🐾 AUTONOMOUS ROAMING & SUMMONING
# ==============================================================================
func _process_autonomous_room_roaming(delta: float) -> void:
	_roam_timer += delta
	if _roam_timer < _next_roam_interval:
		return
		
	_roam_timer = 0.0
	_next_roam_interval = randf_range(45.0, 75.0)
	
	# Check if in WORK/FOCUS mode
	var is_work_mode: bool = (TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.RUNNING and TimerEngine.current_phase == TimerEngine.TimerPhase.WORK)
	if is_work_mode:
		# When in WORK/FOCUS mode, pet stays with work desk in Bedroom
		if GameState and GameState.pet_room != "room_bedroom":
			GameState.set_pet_room("room_bedroom")
		return
		
	# During IDLE or BREAK phases, every 45-75 seconds, pet has a 35% chance to wander to an adjacent connected room
	if randf() <= 0.35:
		var cur_room: String = GameState.pet_room if GameState else "room_bedroom"
		var neighbors: Array = HOUSE_TOPOLOGY.get(cur_room, [])
		if neighbors.size() > 0:
			var next_room: String = neighbors[randi() % neighbors.size()]
			if GameState:
				if GameState.is_pet_in_current_view() and thought_bubble and not thought_bubble._is_showing:
					thought_bubble.show_thought("Exploring next door! 🐾", 2.5)
				GameState.set_pet_room(next_room)

func _on_pet_called(_target_room: String) -> void:
	_update_visibility_from_room_state()
	
	# Position pet nicely within current room bounds
	position.x = clampf((min_x + max_x) * 0.5, min_x + 10.0, max_x - 10.0)
	target_x = position.x
	
	# Happy bounce and heart thought bubble
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
	# Reset target clamp and keep wandering
	position.x = clampf(position.x, min_x, max_x)
	if current_state == State.TYPE and (not TimerEngine or TimerEngine.status != TimerEngine.TimerStatus.RUNNING):
		current_state = State.IDLE

func _update_visibility_from_room_state() -> void:
	var is_in_view: bool = GameState.is_pet_in_current_view() if GameState else true
	visible = is_in_view
	if click_area:
		click_area.monitoring = is_in_view
		click_area.monitorable = is_in_view

# ==============================================================================
# ⏱️ EVENT BUS HANDLERS
# ==============================================================================
func _sync_initial_state() -> void:
	if not TimerEngine:
		return
	if TimerEngine.status == TimerEngine.TimerStatus.RUNNING:
		if TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
			if GameState and GameState.pet_room != "room_bedroom":
				GameState.set_pet_room("room_bedroom")
			position.x = desk_x
			current_state = State.TYPE
		else:
			_start_break_behavior()
	else:
		current_state = State.IDLE

func _on_timer_state_changed(is_running: bool, is_paused: bool) -> void:
	if is_running:
		if TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
			if GameState and GameState.pet_room != "room_bedroom":
				GameState.set_pet_room("room_bedroom")
			walk_to(desk_x, State.TYPE)
			if thought_bubble and visible:
				thought_bubble.show_random_thought("work_start", 3.0)
		else:
			_start_break_behavior()
	elif is_paused:
		if current_state == State.TYPE:
			_set_renderer_state(PetRenderer.AnimState.IDLE)
	else:
		# Timer stopped
		current_state = State.IDLE

func _on_phase_changed(new_phase: String, _duration: float) -> void:
	if new_phase == "work":
		if GameState and GameState.pet_room != "room_bedroom":
			GameState.set_pet_room("room_bedroom")
		if TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.RUNNING:
			walk_to(desk_x, State.TYPE)
	else:
		_start_break_behavior()

func _on_session_completed(session_type: String, _coins: int, _xp: int, _streak: int) -> void:
	if session_type == "work":
		# Start victory celebration
		current_state = State.VICTORY
		state_timer = 0.0
		if thought_bubble and visible:
			if GameState.streak >= 2:
				thought_bubble.show_random_thought("streak", 3.5)
			else:
				thought_bubble.show_thought("Work session complete! 🎉", 3.5)
	else:
		# Break completed
		if thought_bubble and visible:
			thought_bubble.show_thought("Refreshed & ready! 🚀", 3.0)
		current_state = State.IDLE

func _on_session_skipped(_session_type: String) -> void:
	current_state = State.IDLE
	if thought_bubble and visible:
		thought_bubble.show_thought("Taking a breather~", 2.5)

func _start_break_behavior() -> void:
	# Choose between napping on bed/cushion or drinking coffee
	var roll: float = randf()
	if roll < 0.5:
		walk_to(nap_x, State.NAP)
		if thought_bubble and visible:
			thought_bubble.show_thought("Zzz... Power nap time 💤", 3.0)
	else:
		walk_to(drink_x, State.DRINK)
		if thought_bubble and visible:
			thought_bubble.show_thought("Need a cozy coffee ☕", 3.0)

func _on_pet_interacted(interaction_type: String) -> void:
	if current_state != State.PETTED:
		_previous_state = current_state
	current_state = State.PETTED
	state_timer = 0.0
	
	if thought_bubble and visible:
		thought_bubble.show_random_thought("petted", 2.5)

func _on_item_used(item_id: String, _item_data: Dictionary) -> void:
	if item_id == "snack_coffee":
		walk_to(drink_x, State.DRINK)
		if thought_bubble and visible:
			thought_bubble.show_thought("Delicious espresso! ☕ +25⚡", 3.5)
	elif item_id.begins_with("snack_"):
		if thought_bubble and visible:
			thought_bubble.show_thought("Yum! So tasty! 🥐", 3.0)
		if current_state != State.PETTED and current_state != State.TYPE:
			current_state = State.PETTED
			state_timer = 0.0

func _on_energy_changed(new_energy: float, _max: float, _is_buffed: bool) -> void:
	if new_energy <= 20.0 and current_state == State.IDLE and randf() < 0.3:
		if thought_bubble and visible:
			thought_bubble.show_random_thought("low_energy", 3.0)

# ==============================================================================
# 🖱️ INPUT & INTERACTION
# ==============================================================================
func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			# Pet the shiba!
			GameState.add_joy(5.0)
			EventBus.pet_interacted.emit("pet")

func _process_periodic_thoughts() -> void:
	if _periodic_thought_timer >= 25.0:
		_periodic_thought_timer = 0.0
		if not visible:
			return
		if thought_bubble and not thought_bubble._is_showing:
			if current_state == State.TYPE:
				thought_bubble.show_random_thought("working", 3.0)
			elif current_state == State.IDLE and randf() < 0.4:
				thought_bubble.show_thought("Exploring the room! 🐾", 3.0)

func _set_renderer_state(anim_state: PetRenderer.AnimState) -> void:
	if renderer and renderer.current_state != anim_state:
		renderer.current_state = anim_state
