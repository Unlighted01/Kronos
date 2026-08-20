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
	queue_redraw()

func _update_label_text() -> void:
	if indicator_label:
		var arrow: String = " ➔" if door_direction == "right" else " ⬅"
		indicator_label.text = "%s%s" % [door_label, arrow]

func _update_direction() -> void:
	_update_label_text()
	queue_redraw()

# ==============================================================================
# 🎨 CUSTOM CANVAS DRAWING (Pixel Door)
# ==============================================================================
func _draw() -> void:
	var dw: float = 18.0
	var dh: float = 46.0
	var x: float = -dw * 0.5
	var y: float = -dh
	
	# Door Threshold Glow (warm light seeping under door)
	draw_rect(Rect2(x - 2, 0, dw + 4, 3), COL_THRESHOLD_GLOW)
	
	# Outer Door Frame
	draw_rect(Rect2(x - 2, y - 2, dw + 4, dh + 2), COL_FRAME_SHADOW)
	draw_rect(Rect2(x - 1, y - 1, dw + 2, dh + 1), COL_FRAME_WOOD)
	
	# Door Leaf / Body
	draw_rect(Rect2(x, y, dw, dh), COL_DOOR_PANEL)
	
	# Upper and Lower Inset Panels
	draw_rect(Rect2(x + 2, y + 3, dw - 4, 16), COL_FRAME_SHADOW)
	draw_rect(Rect2(x + 3, y + 4, dw - 6, 14), COL_DOOR_LIGHT)
	
	draw_rect(Rect2(x + 2, y + 23, dw - 4, 18), COL_FRAME_SHADOW)
	draw_rect(Rect2(x + 3, y + 24, dw - 6, 16), COL_DOOR_LIGHT)
	
	# Brass Doorknob
	var handle_x: float = (x + dw - 4) if door_direction == "right" else (x + 2)
	draw_rect(Rect2(handle_x, y + 24, 2, 4), COL_HANDLE_BRASS)
	draw_rect(Rect2(handle_x - 1, y + 25, 4, 2), COL_HANDLE_BRASS)
	
	# Draw Padlock if Target Room is Locked in Shop
	if GameState and not GameState.is_room_unlocked(target_room):
		draw_rect(Rect2(-3, y + 8, 6, 6), Color(0.95, 0.75, 0.20)) # Brass body
		draw_rect(Rect2(-2, y + 5, 4, 3), Color(0.35, 0.40, 0.45), false, 1.0) # Shackle
		draw_rect(Rect2(-1, y + 10, 2, 2), Color(0.20, 0.15, 0.10)) # Keyhole
	
	# Hover glow outline
	if _is_hovered:
		draw_rect(Rect2(x - 3, y - 3, dw + 6, dh + 6), COL_HOVER_BORDER, false, 1.0)

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
