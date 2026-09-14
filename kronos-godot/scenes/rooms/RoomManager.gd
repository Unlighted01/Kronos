extends Control
class_name RoomManager

## Room Manager Singleton & Viewport Controller for Kronos.
## Seamlessly manages active room switching (Bedroom, Living Room, Library, Kitchen, Greenhouse),
## coordinates smooth fade transitions, handles locked room feedback, and manages the multi-pet household.

# ==============================================================================
# 📦 ROOM SCENE REGISTRY
# ==============================================================================
const ROOM_SCENES: Dictionary = {
	"room_bedroom": preload("res://scenes/rooms/Bedroom.tscn"),
	"room_livingroom": preload("res://scenes/rooms/LivingRoom.tscn"),
	"room_library": preload("res://scenes/rooms/Library.tscn"),
	"room_kitchen": preload("res://scenes/rooms/Kitchen.tscn"),
	"room_greenhouse": preload("res://scenes/rooms/Greenhouse.tscn")
}

const PET_SCENE: PackedScene = preload("res://scenes/pet/PetCompanion.tscn")
const DELIVERY_BOX_SCENE: PackedScene = preload("res://scenes/pet/PetDeliveryBox.tscn")

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var room_container: Node2D = $SubViewportContainer/SubViewport/RoomContainer
@onready var pet_layer: Node2D = $SubViewportContainer/SubViewport/PetLayer
@onready var transition_overlay: ColorRect = $TransitionOverlay
@onready var room_title_badge: Label = $HUDOverlay/RoomTitleBadge
@onready var sub_viewport: SubViewport = $SubViewportContainer/SubViewport

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var current_room_node: BaseRoom = null
var current_room_id: String = ""
var spawned_pets: Array[PetBrain] = []
var is_transitioning: bool = false

# Camera / Scrolling State
var room_camera: Camera2D = null
var current_room_width: float = 240.0
var _is_dragging_cam: bool = false
var _drag_start_x: float = 0.0
var _cam_start_x: float = 0.0
var _expedition_poll_timer: float = 0.0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	custom_minimum_size = Vector2(240, 140)
	clip_contents = true
	
	# Setup Camera
	room_camera = Camera2D.new()
	room_camera.position = Vector2(120, 70)
	sub_viewport.add_child(room_camera)
	
	if transition_overlay:
		transition_overlay.color = Color(0.04, 0.05, 0.09, 1.0)
		transition_overlay.modulate.a = 0.0
		transition_overlay.visible = false
		
	# Connect to EventBus
	EventBus.room_change_requested.connect(_on_room_change_requested)
	EventBus.room_changed.connect(_on_room_changed)
	EventBus.pet_room_changed.connect(_on_pet_room_changed)
	EventBus.pet_called.connect(_on_pet_called)
	EventBus.pet_list_changed.connect(_on_pet_list_changed)
	EventBus.pet_delivery_box_spawned.connect(_on_pet_delivery_box_spawned)
	EventBus.timer_state_changed.connect(_on_timer_state_changed)
	EventBus.pet_fetch_started.connect(_on_pet_fetch_started)
	
	$SubViewportContainer.gui_input.connect(_on_viewport_gui_input)
	
	# Load initial room from GameState
	var init_room = GameState.active_view_room if (GameState and GameState.active_view_room != "") else "room_bedroom"
	_load_room_instant(init_room)

func _process(delta: float) -> void:
	_expedition_poll_timer += delta
	if _expedition_poll_timer >= 1.0:
		_expedition_poll_timer = 0.0
		_check_matured_expeditions()

func _on_viewport_gui_input(event: InputEvent) -> void:
	if current_room_width <= 240.0:
		return # No need to scroll
		
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging_cam = true
				_drag_start_x = event.global_position.x
				_cam_start_x = room_camera.position.x
			else:
				_is_dragging_cam = false
	elif event is InputEventMouseMotion and _is_dragging_cam:
		var dx = event.global_position.x - _drag_start_x
		# Moving mouse right should move camera left
		var target_x = _cam_start_x - dx
		# Clamp camera
		target_x = clampf(target_x, 120.0, current_room_width - 120.0)
		room_camera.position.x = target_x

# ==============================================================================
# 🚪 ROOM SWITCHING & TRANSITIONS
# ==============================================================================
func _on_room_change_requested(target_room: String) -> void:
	if GameState and not GameState.is_room_unlocked(target_room):
		var def = GameState.ITEM_DEFINITIONS.get(target_room, null)
		var r_name: String = def.get("name", "Room") if def else target_room
		var req_lvl: int = int(def.get("unlock_level", 1)) if def else 1
		var price: int = int(def.get("price", 0)) if def else 0
		_show_room_badge("🔒 %s (Shop Lv. %d, %d G)" % [r_name, req_lvl, price])
		if AudioManager:
			AudioManager.play_sfx("thud")
		return
		
	switch_to_room(target_room)

## Switches to target room with smooth fade transition
func switch_to_room(target_room_id: String) -> void:
	if is_transitioning or target_room_id == current_room_id:
		return
		
	if not ROOM_SCENES.has(target_room_id):
		push_warning("[RoomManager] Room '%s' not recognized in registry." % target_room_id)
		return
		
	is_transitioning = true
	var dir: int = GameState.get_room_direction(current_room_id, target_room_id) if GameState else 0
	
	if dir != 0:
		_perform_directional_slide(target_room_id, dir)
	else:
		_perform_fade_transition(target_room_id)

func _perform_directional_slide(target_room_id: String, dir: int) -> void:
	var room_packed: PackedScene = ROOM_SCENES[target_room_id]
	var next_room_node: BaseRoom = room_packed.instantiate() as BaseRoom
	next_room_node.position.x = 240.0 * float(dir)
	room_container.add_child(next_room_node)
	
	var old_room_node = current_room_node
	
	var tween: Tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if old_room_node and is_instance_valid(old_room_node):
		tween.tween_property(old_room_node, "position:x", -240.0 * float(dir), 0.28)
	tween.tween_property(next_room_node, "position:x", 0.0, 0.28)
	
	tween.chain().tween_callback(func():
		if old_room_node and is_instance_valid(old_room_node):
			old_room_node.queue_free()
		current_room_node = next_room_node
		current_room_id = target_room_id
		
		if room_camera:
			current_room_width = current_room_node.room_width
			room_camera.position.x = 120.0
			
		if GameState:
			GameState.set_view_room(target_room_id)
			
		_sync_pets_for_current_room(dir)
		_show_room_badge(current_room_node.room_name)
		is_transitioning = false
	)

func _perform_fade_transition(target_room_id: String) -> void:
	if transition_overlay:
		transition_overlay.visible = true
		transition_overlay.modulate.a = 0.0
		var tween: Tween = create_tween()
		tween.tween_property(transition_overlay, "modulate:a", 1.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_callback(func(): _perform_room_swap(target_room_id))
		tween.tween_property(transition_overlay, "modulate:a", 0.0, 0.22).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(func():
			if transition_overlay:
				transition_overlay.visible = false
				transition_overlay.modulate.a = 0.0
			is_transitioning = false
		)
	else:
		_perform_room_swap(target_room_id)
		is_transitioning = false

func _perform_room_swap(target_room_id: String) -> void:
	# Unload old room
	if current_room_node and is_instance_valid(current_room_node):
		current_room_node.queue_free()
		current_room_node = null
		
	# Instantiate new room
	var room_packed: PackedScene = ROOM_SCENES[target_room_id]
	current_room_node = room_packed.instantiate() as BaseRoom
	room_container.add_child(current_room_node)
	current_room_id = target_room_id
	
	if room_camera:
		current_room_width = current_room_node.room_width
		room_camera.position.x = 120.0
	
	# Update GameState view room
	if GameState:
		GameState.set_view_room(target_room_id)
		
	_sync_pets_for_current_room(0)
	_show_room_badge(current_room_node.room_name)

func _load_room_instant(room_id: String) -> void:
	if not ROOM_SCENES.has(room_id):
		room_id = "room_bedroom"
		
	var room_packed: PackedScene = ROOM_SCENES[room_id]
	current_room_node = room_packed.instantiate() as BaseRoom
	room_container.add_child(current_room_node)
	current_room_id = room_id
	
	if room_camera:
		current_room_width = current_room_node.room_width
		room_camera.position.x = 120.0
	
	_sync_pets_for_current_room(0)
	_show_room_badge(current_room_node.room_name)

func _show_room_badge(r_name: String) -> void:
	if not room_title_badge:
		return
		
	room_title_badge.text = r_name
	room_title_badge.visible = true
	
	var tween: Tween = create_tween()
	room_title_badge.modulate.a = 0.0
	tween.tween_property(room_title_badge, "modulate:a", 1.0, 0.2)
	tween.tween_interval(1.8)
	tween.tween_property(room_title_badge, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): room_title_badge.visible = false)

# ==============================================================================
# 🐾 MULTI-PET HOUSEHOLD LOCATION & SPAWNING
# ==============================================================================
func _sync_pets_for_current_room(entry_direction: int = 0) -> void:
	# Clean up previous spawned pets
	for p in spawned_pets:
		if is_instance_valid(p):
			p.queue_free()
	spawned_pets.clear()
	
	if not GameState or not pet_layer or not current_room_node:
		return
		
	var anchors = current_room_node.get_navigation_anchors()
	var room_pets: Array[Dictionary] = []
	
	for pet_info in GameState.active_pets:
		if pet_info.get("is_outside", false) == true:
			continue # Do not spawn companions who are currently outdoors on an expedition!
		var p_room: String = pet_info.get("room", "room_bedroom")
		if p_room.is_empty():
			p_room = "room_bedroom"
			pet_info["room"] = "room_bedroom"
		# Only spawn pets that are actually in this specific room
		if p_room == current_room_id:
			room_pets.append(pet_info)
		
	# Spawn each pet companion with properly bounded starting X positions
	for i in range(room_pets.size()):
		var p_info: Dictionary = room_pets[i]
		var pet_inst: PetBrain = PET_SCENE.instantiate() as PetBrain
		var global_idx: int = GameState.active_pets.find(p_info)
		if global_idx == -1:
			global_idx = i
		pet_inst.pet_index = global_idx
		
		var a_min: float = float(anchors.get("min_x", 40.0))
		var a_max: float = float(anchors.get("max_x", 200.0))
		var a_desk: float = float(anchors.get("desk_x", (a_min + a_max) * 0.5))
		var a_nap: float = float(anchors.get("nap_x", a_min + 30.0))
		var a_drink: float = float(anchors.get("drink_x", a_max - 30.0))
		var a_floor: float = float(anchors.get("floor_y", 115.0))
		
		var mid_x: float = (a_min + a_max) * 0.5
		var count_offset: float = (float(i) - float(room_pets.size() - 1) * 0.5) * 24.0
		var start_x: float = clampf(mid_x + count_offset, a_min + 5.0, a_max - 5.0)
		
		pet_inst.position = Vector2(start_x, a_floor)
		pet_layer.add_child(pet_inst)
		pet_inst.setup_pet(p_info)
		pet_inst.set_room_anchors(a_min, a_max, a_desk, a_nap, a_drink, a_floor)
		
		if entry_direction != 0 and pet_inst.has_method("walk_in_from_door"):
			pet_inst.walk_in_from_door(entry_direction)
			
		spawned_pets.append(pet_inst)

func _on_pet_delivery_box_spawned(p_data: Dictionary, spawn_pos: Vector2) -> void:
	if not pet_layer:
		return
		
	# Hide the newly spawned pet so it doesn't clip through the closed box!
	for p in spawned_pets:
		if is_instance_valid(p) and p.pet_id == p_data.get("id", ""):
			p.visible = false
			
	var box_inst = DELIVERY_BOX_SCENE.instantiate()
	pet_layer.add_child(box_inst)
	if box_inst.has_method("setup"):
		box_inst.setup(p_data, spawn_pos.x, spawn_pos.y)
	if box_inst.has_signal("unboxing_finished"):
		box_inst.unboxing_finished.connect(func(unboxed_data):
			_sync_pets_for_current_room()
			# Make the newly unboxed pet visible and do a celebratory bounce!
			for p in spawned_pets:
				if is_instance_valid(p) and p.pet_id == unboxed_data.get("id", ""):
					p.visible = true
					p.trigger_victory()
					break
		)

func _on_timer_state_changed(status_name: String, _remaining: int) -> void:
	if status_name == "RUNNING" and room_camera and current_room_node and current_room_width > 240.0:
		var desk_x = current_room_node.desk_x
		var target_x = clampf(desk_x, 120.0, current_room_width - 120.0)
		
		# Smoothly pan to the desk area where the pet will be working
		var tween = create_tween()
		tween.tween_property(room_camera, "position:x", target_x, 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)

func _on_room_changed(room_id: String) -> void:
	if room_id != current_room_id and not is_transitioning:
		switch_to_room(room_id)
	else:
		_sync_pets_for_current_room()

func _on_pet_room_changed(_new_pet_room: String) -> void:
	# Primary pet moved rooms — sync the view
	pass

func _on_pet_called(_target_room: String) -> void:
	# GameState already updated all active_pets[].room to the current view room.
	# Respawn them all here with a greeting bounce.
	_sync_pets_for_current_room()
	for p in spawned_pets:
		if is_instance_valid(p):
			p._play_summon_bounce()

func _on_pet_list_changed(_active_pets: Array) -> void:
	_sync_pets_for_current_room()

# ==============================================================================
# 🐾 EXPEDITION & FETCH EVENT HANDLERS
# ==============================================================================
func _check_matured_expeditions() -> void:
	if not GameState or not pet_layer or is_transitioning:
		return
	var cur_unix: int = int(Time.get_unix_time_from_system())
	for i in range(GameState.active_pets.size()):
		var p: Dictionary = GameState.active_pets[i]
		if p.get("is_outside", false) == true:
			var end_t: int = int(p.get("expedition_end_unix", 0))
			if cur_unix >= end_t:
				_handle_expedition_return(i)
				break # Handle one at a time for clear presentation

func _handle_expedition_return(pet_idx: int) -> void:
	var souvenir: Dictionary = GameState.complete_pet_expedition(pet_idx)
	var p_info: Dictionary = GameState.active_pets[pet_idx]
	var p_room: String = p_info.get("room", "room_bedroom")
	
	if p_room == current_room_id:
		var pet_inst: PetBrain = PET_SCENE.instantiate() as PetBrain
		pet_inst.pet_index = pet_idx
		var anchors = current_room_node.get_navigation_anchors() if current_room_node else {}
		var a_min: float = float(anchors.get("min_x", 40.0))
		var a_max: float = float(anchors.get("max_x", 200.0))
		var a_desk: float = float(anchors.get("desk_x", (a_min + a_max) * 0.5))
		var a_nap: float = float(anchors.get("nap_x", a_min + 30.0))
		var a_drink: float = float(anchors.get("drink_x", a_max - 30.0))
		var a_floor: float = float(anchors.get("floor_y", 115.0))
		
		pet_inst.position = Vector2(a_min - 12.0, a_floor)
		pet_layer.add_child(pet_inst)
		pet_inst.setup_pet(p_info)
		pet_inst.set_room_anchors(a_min, a_max, a_desk, a_nap, a_drink, a_floor)
		spawned_pets.append(pet_inst)
		
		pet_inst.walk_in_from_door(1)
		
		var timer = get_tree().create_timer(0.6)
		timer.timeout.connect(func():
			if is_instance_valid(pet_inst):
				if pet_inst.thought_bubble:
					var s_name = souvenir.get("name", "a surprise gift")
					pet_inst.thought_bubble.show_expedition_return(s_name)
				if pet_inst.renderer:
					for s in range(3):
						pet_inst.renderer._spawn_particle("star")
				pet_inst._play_happy_hop_tween()
		)
	else:
		_sync_pets_for_current_room()

func _on_pet_fetch_started(fetcher_idx: int, target_idx: int) -> void:
	# Fetcher departed to find companion; both arrive in the active room after 2.5s
	var timer = get_tree().create_timer(2.5)
	timer.timeout.connect(func():
		if not is_inside_tree() or is_transitioning:
			return
		_sync_pets_for_current_room()
		for p in spawned_pets:
			if is_instance_valid(p) and (p.pet_index == fetcher_idx or p.pet_index == target_idx):
				p.walk_in_from_door(1)
				if p.pet_index == fetcher_idx and p.thought_bubble:
					var t_name = GameState.active_pets[target_idx].get("name", "friend") if GameState and target_idx < GameState.active_pets.size() else "friend"
					p.thought_bubble.show_fetch_return(t_name)
				p._play_happy_hop_tween()
	)

