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

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var current_room_node: BaseRoom = null
var current_room_id: String = ""
var spawned_pets: Array[PetBrain] = []
var is_transitioning: bool = false

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	custom_minimum_size = Vector2(240, 140)
	clip_contents = true
	
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
	
	# Load initial room from GameState
	var init_room = GameState.active_view_room if (GameState and GameState.active_view_room != "") else "room_bedroom"
	_load_room_instant(init_room)
	_sync_pets_for_current_room()

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
	
	# Update GameState view room
	if GameState:
		GameState.set_view_room(target_room_id)
		
	_sync_pets_for_current_room()
	_show_room_badge(current_room_node.room_name)

func _load_room_instant(room_id: String) -> void:
	if not ROOM_SCENES.has(room_id):
		room_id = "room_bedroom"
		
	var room_packed: PackedScene = ROOM_SCENES[room_id]
	current_room_node = room_packed.instantiate() as BaseRoom
	room_container.add_child(current_room_node)
	current_room_id = room_id
	
	_sync_pets_for_current_room()
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
func _sync_pets_for_current_room() -> void:
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
		var p_room: String = pet_info.get("room", "room_bedroom")
		# If pet has no room or matches view room, spawn here
		if p_room == current_room_id or p_room == "":
			room_pets.append(pet_info)
			
	# If no pets are explicitly in this room and active_pets has 1 pet, put them here
	if room_pets.is_empty() and GameState.active_pets.size() == 1:
		room_pets.append(GameState.active_pets[0])
		
	# Spawn each pet companion with slightly offset starting X positions
	for i in range(room_pets.size()):
		var p_info: Dictionary = room_pets[i]
		var pet_inst: PetBrain = PET_SCENE.instantiate() as PetBrain
		pet_inst.pet_index = i
		var start_x: float = clampf(70.0 + float(i) * 32.0, anchors.get("min_x", 35.0), anchors.get("max_x", 205.0))
		pet_inst.position = Vector2(start_x, anchors.get("floor_y", 115.0))
		pet_layer.add_child(pet_inst)
		pet_inst.setup_pet(p_info)
		pet_inst.set_room_anchors(
			anchors.get("min_x", 35.0),
			anchors.get("max_x", 205.0),
			anchors.get("desk_x", 75.0),
			anchors.get("nap_x", 175.0),
			anchors.get("drink_x", 120.0),
			anchors.get("floor_y", 115.0)
		)
		spawned_pets.append(pet_inst)

func _on_pet_delivery_box_spawned(p_data: Dictionary, spawn_pos: Vector2) -> void:
	if not pet_layer:
		return
	var box_inst = DELIVERY_BOX_SCENE.instantiate()
	pet_layer.add_child(box_inst)
	if box_inst.has_method("setup"):
		box_inst.setup(p_data, spawn_pos.x, spawn_pos.y)
	if box_inst.has_signal("unboxing_finished"):
		box_inst.unboxing_finished.connect(func(unboxed_data):
			_sync_pets_for_current_room()
			# Make the newly unboxed pet do a celebratory victory bounce!
			for p in spawned_pets:
				if is_instance_valid(p) and p.pet_id == unboxed_data.get("id", ""):
					p.trigger_victory()
					break
		)

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
