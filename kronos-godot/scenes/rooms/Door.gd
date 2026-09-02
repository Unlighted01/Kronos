@tool
extends Node2D
class_name InteractiveDoor

## Interactive Room Door for Kronos.
## Provides visual hover indicator and click trigger to switch rooms via EventBus.

# ==============================================================================
# 🚪 EXPORT CONFIGURATION
# ==============================================================================
@export var target_room: String = "room_livingroom":
	set(value):
		target_room = value
		queue_redraw()

@export var door_label: String = "Living Room":
	set(value):
		door_label = value
		_update_label_text()

@export_enum("left", "right") var door_direction: String = "right":
	set(value):
		door_direction = value
		_update_direction()

@export var is_locked: bool = false

# ==============================================================================
# 🎨 COLOR PALETTE (Door Art)
# ==============================================================================
const COL_FRAME_WOOD: Color = Color(0.35, 0.22, 0.15, 1.0)
const COL_FRAME_SHADOW: Color = Color(0.24, 0.14, 0.09, 1.0)
const COL_DOOR_PANEL: Color = Color(0.48, 0.32, 0.22, 1.0)
const COL_DOOR_LIGHT: Color = Color(0.58, 0.40, 0.28, 1.0)
const COL_HANDLE_BRASS: Color = Color(0.95, 0.78, 0.25, 1.0)
const COL_THRESHOLD_GLOW: Color = Color(1.0, 0.88, 0.45, 0.6)
const COL_HOVER_BORDER: Color = Color(0.45, 0.85, 1.0, 0.9)

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var indicator_container: Control = $IndicatorContainer
@onready var indicator_label: Label = $IndicatorContainer/Panel/Label
@onready var click_area: Area2D = $ClickArea
@onready var door_button: Button = $DoorButton

# Hover animation state
var _is_hovered: bool = false
var _hover_timer: float = 0.0
var _pulse_scale: float = 1.0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	_update_label_text()
	_update_direction()
	
	if indicator_container:
		indicator_container.visible = false
		indicator_container.modulate.a = 0.0
		
	if door_button and not Engine.is_editor_hint():
		door_button.mouse_entered.connect(_on_mouse_entered)
		door_button.mouse_exited.connect(_on_mouse_exited)
		door_button.pressed.connect(_trigger_door_transition)
		
	if click_area and not Engine.is_editor_hint():
		click_area.mouse_entered.connect(_on_mouse_entered)
		click_area.mouse_exited.connect(_on_mouse_exited)
		click_area.input_event.connect(_on_input_event)

func _process(delta: float) -> void:
	if _is_hovered:
		_hover_timer += delta * 4.0
		var bounce: float = sin(_hover_timer) * 2.0
		if indicator_container:
			indicator_container.position.y = -44.0 + bounce

func _update_label_text() -> void:
	if indicator_label:
		var arrow: String = " ➔" if door_direction == "right" else " ⬅"
		indicator_label.text = "%s%s" % [door_label, arrow]

func _update_direction() -> void:
	_update_label_text()
	queue_redraw()

# ==============================================================================
# 🎨 CUSTOM CANVAS DRAWING (Invisible Threshold)
# ==============================================================================
func _draw() -> void:
	# Doors are visually invisible to keep room aesthetics clean and uncluttered.
	# The node serves as an invisible interaction & pet teleportation boundary.
	pass

# ==============================================================================
# 🖱️ INTERACTION & HOVER EVENTS
# ==============================================================================
func _on_mouse_entered() -> void:
	_is_hovered = true
	_hover_timer = 0.0
	_animate_indicator(true)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	_is_hovered = false
	_animate_indicator(false)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _animate_indicator(show: bool) -> void:
	if not indicator_container:
		return
		
	var tween: Tween = create_tween().set_parallel(true)
	if show:
		indicator_container.visible = true
		tween.tween_property(indicator_container, "modulate:a", 1.0, 0.15)
		tween.tween_property(indicator_container, "scale", Vector2.ONE, 0.15).from(Vector2(0.6, 0.6))
	else:
		tween.tween_property(indicator_container, "modulate:a", 0.0, 0.12)
		tween.tween_property(indicator_container, "scale", Vector2(0.7, 0.7), 0.12)
		tween.chain().tween_callback(func(): indicator_container.visible = false)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			_trigger_door_transition()

func _trigger_door_transition() -> void:
	if is_locked:
		return
		
	# Play click pulse
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.15, 0.88), 0.08).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)
	
	# Request room change via EventBus
	EventBus.room_change_requested.emit(target_room)
