extends Control
class_name RoomManager

## Room Manager Singleton & Viewport Controller for Kronos.
## Seamlessly manages active room switching (Bedroom, Living Room, Library, Kitchen, Greenhouse),
## coordinates smooth fade transitions, and anchors the PetCompanion within each environment.

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
var pet_companion: PetBrain = null
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
	
	# Instantiate pet companion first
	_spawn_pet_companion()
	
	# Load initial room from GameState
	var init_room = GameState.active_view_room if (GameState and GameState.active_view_room != "") else "room_bedroom"
	if GameState:
		# Sync pet to view room on startup if unassigned
		if GameState.pet_room == "" or GameState.pet_room == null:
			GameState.pet_room = init_room
	_load_room_instant(init_room)
	_update_pet_visibility_and_anchors()

func _spawn_pet_companion() -> void:
	if pet_companion != null:
		return
		
	pet_companion = PET_SCENE.instantiate() as PetBrain
	pet_companion.position = Vector2(120.0, 115.0)
	pet_companion.modulate = Color(1.0, 1.0, 1.0, 1.0)
	pet_companion.visible = true
	if pet_layer:
		pet_layer.add_child(pet_companion)
	else:
		add_child(pet_companion)

# ==============================================================================
# 🚪 ROOM SWITCHING & TRANSITIONS
# ==============================================================================
func _on_room_change_requested(target_room: String) -> void:
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
		
	_update_pet_visibility_and_anchors()
		
	# Update UI Badge
	_show_room_badge(current_room_node.room_name)

func _load_room_instant(room_id: String) -> void:
	if not ROOM_SCENES.has(room_id):
		room_id = "room_bedroom"
		
	var room_packed: PackedScene = ROOM_SCENES[room_id]
	current_room_node = room_packed.instantiate() as BaseRoom
	room_container.add_child(current_room_node)
	current_room_id = room_id
	
	_update_pet_visibility_and_anchors()
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
# 🐾 PET VISIBILITY & LOCATION HANDLING
# ==============================================================================
func _update_pet_visibility_and_anchors() -> void:
	var is_pet_here: bool = (GameState.pet_room == current_room_id) if GameState else true
	
	if pet_companion:
		pet_companion.visible = is_pet_here
		if pet_companion.click_area:
			pet_companion.click_area.monitoring = is_pet_here
			pet_companion.click_area.monitorable = is_pet_here
			
		if is_pet_here and current_room_node:
			var anchors = current_room_node.get_navigation_anchors()
			pet_companion.set_room_anchors(
				anchors.get("min_x", 35.0),
				anchors.get("max_x", 205.0),
				anchors.get("desk_x", 75.0),
				anchors.get("nap_x", 175.0),
				anchors.get("drink_x", 120.0),
				anchors.get("floor_y", 115.0)
			)

func _on_room_changed(room_id: String) -> void:
	if room_id != current_room_id and not is_transitioning:
		switch_to_room(room_id)
	else:
		_update_pet_visibility_and_anchors()

func _on_pet_room_changed(_new_pet_room: String) -> void:
	_update_pet_visibility_and_anchors()

func _on_pet_called(_target_room: String) -> void:
	_update_pet_visibility_and_anchors()

func _get_room_display_name(r_id: String) -> String:
	match r_id:
		"room_bedroom": return "Study Bedroom"
		"room_livingroom": return "Living Room Lounge"
		"room_library": return "Attic Library"
		"room_kitchen": return "Bakery Kitchen"
		"room_greenhouse": return "Conservatory"
		_: return r_id.replace("room_", "").capitalize()
