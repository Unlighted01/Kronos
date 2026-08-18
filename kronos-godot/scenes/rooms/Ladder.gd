@tool
extends Node2D
class_name InteractiveLadder

## Dedicated Pixel Art Wooden Ladder & Floor Trapdoor Prop for Kronos.
## Compact and rustic design:
## - Ladder (direction = "up"): 14px width (rails at x = -6 and 6, rungs from -5 to 5),
##   height from floor y = 0 up to ceiling y = -48, 5 slim rungs (2px each) with warm wood tones
##   (#784c28, #543218, #94643c), warm golden light beam from ceiling hatch (rgba(255, 230, 140, 0.15)),
##   and compact hover indicator badge [ 🪜 Attic Library ➔ ].
## - Trapdoor hatch (direction = "down"): 30px width compact floor trapdoor with open wooden lid.

# ==============================================================================
# 🪜 EXPORT CONFIGURATION
# ==============================================================================
@export var target_room: String = "room_library":
	set(value):
		target_room = value
		queue_redraw()

@export var ladder_label: String = "Attic Library":
	set(value):
		ladder_label = value
		_update_indicator_text()

@export var indicator_text: String = "":
	set(value):
		indicator_text = value
		_update_indicator_text()

@export_enum("up", "down") var direction: String = "up":
	set(value):
		direction = value
		is_trapdoor_hatch = (value == "down")
		_update_indicator_text()
		_update_collider_shape()
		queue_redraw()

@export var is_trapdoor_hatch: bool = false:
	set(value):
		is_trapdoor_hatch = value
		direction = "down" if value else "up"
		_update_indicator_text()
		_update_collider_shape()
		queue_redraw()

@export var is_locked: bool = false

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
# Warm wood tones
const COL_WOOD_MAIN: Color = Color("784c28")       # #784c28
const COL_WOOD_SHADOW: Color = Color("543218")     # #543218
const COL_WOOD_HIGHLIGHT: Color = Color("94643c")  # #94643c
const COL_BRASS_STUD: Color = Color(0.92, 0.76, 0.28, 1.0)
const COL_IRON_HINGE: Color = Color(0.30, 0.32, 0.38, 1.0)

# Golden Light Beam from Attic Hatch (rgba(255, 230, 140, 0.15))
const COL_BEAM: Color = Color(1.0, 0.902, 0.549, 0.15)
const COL_BEAM_CORE: Color = Color(1.0, 0.94, 0.65, 0.22)
const COL_BEAM_FLOOR_GLOW: Color = Color(1.0, 0.88, 0.45, 0.28)
const COL_HOVER_BORDER: Color = Color(0.45, 0.85, 1.0, 0.9)

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var indicator_container: Control = $IndicatorContainer
@onready var indicator_label: Label = $IndicatorContainer/Panel/Label
@onready var click_area: Area2D = $ClickArea
@onready var collision_shape: CollisionShape2D = $ClickArea/CollisionShape2D
@onready var ladder_button: Button = $LadderButton

# Hover animation state
var _is_hovered: bool = false
var _hover_timer: float = 0.0
var _beam_shimmer_timer: float = 0.0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	z_index = 1
	_update_indicator_text()
	_update_collider_shape()
	
	if indicator_container:
		indicator_container.visible = false
		indicator_container.modulate.a = 0.0
		var base_y: float = -24.0 if (is_trapdoor_hatch or direction == "down") else -114.0
		indicator_container.position.y = base_y
		
	if ladder_button and not Engine.is_editor_hint():
		ladder_button.mouse_entered.connect(_on_mouse_entered)
		ladder_button.mouse_exited.connect(_on_mouse_exited)
		ladder_button.pressed.connect(_trigger_ladder_transition)
		
	if click_area and not Engine.is_editor_hint():
		click_area.mouse_entered.connect(_on_mouse_entered)
		click_area.mouse_exited.connect(_on_mouse_exited)
		click_area.input_event.connect(_on_input_event)

func _process(delta: float) -> void:
	_beam_shimmer_timer += delta * 3.0
	if _is_hovered:
		_hover_timer += delta * 4.0
		var bounce: float = sin(_hover_timer) * 2.0
		if indicator_container:
			var base_y: float = -24.0 if (is_trapdoor_hatch or direction == "down") else -114.0
			indicator_container.position.y = base_y + bounce
	queue_redraw()

func _update_indicator_text() -> void:
	if indicator_label:
		if indicator_text != "":
			indicator_label.text = indicator_text
		else:
			if is_trapdoor_hatch or direction == "down":
				indicator_label.text = "[ 🪜 %s ⬇ ]" % ladder_label
			else:
				indicator_label.text = "[ 🪜 %s ➔ ]" % ladder_label

func _update_collider_shape() -> void:
	if not collision_shape or not collision_shape.shape:
		return
	if is_trapdoor_hatch or direction == "down":
		if collision_shape.shape is RectangleShape2D:
			(collision_shape.shape as RectangleShape2D).size = Vector2(30, 20)
			collision_shape.position = Vector2(0, -8)
		if ladder_button:
			ladder_button.offset_left = -15
			ladder_button.offset_top = -18
			ladder_button.offset_right = 15
			ladder_button.offset_bottom = 2
	else:
		if collision_shape.shape is RectangleShape2D:
			(collision_shape.shape as RectangleShape2D).size = Vector2(18, 106)
			collision_shape.position = Vector2(0, -53)
		if ladder_button:
			ladder_button.offset_left = -10
			ladder_button.offset_top = -106
			ladder_button.offset_right = 10
			ladder_button.offset_bottom = 1

# ==============================================================================
# 🎨 CUSTOM CANVAS DRAWING
# ==============================================================================
func _draw() -> void:
	if is_trapdoor_hatch or direction == "down":
		_draw_trapdoor_hatch()
	else:
		_draw_wooden_ladder_prop()

## Draws the full wall-mounted Wooden Ladder leading up into ceiling trapdoor hatch
func _draw_wooden_ladder_prop() -> void:
	var shimmer: float = sin(_beam_shimmer_timer) * 0.03
	var rail_top: float = -105.0
	var rail_h: float = 105.0
	
	# 1. Warm Golden Light Beam from ceiling hatch down to floor
	var beam_outer: PackedVector2Array = PackedVector2Array([
		Vector2(-6, rail_top),
		Vector2(6, rail_top),
		Vector2(14, 0),
		Vector2(-14, 0)
	])
	var col_beam: Color = COL_BEAM
	col_beam.a = clampf(0.14 + shimmer, 0.08, 0.20)
	draw_colored_polygon(beam_outer, col_beam)
	
	# Inner bright beam core
	var beam_inner: PackedVector2Array = PackedVector2Array([
		Vector2(-3, rail_top),
		Vector2(3, rail_top),
		Vector2(7, 0),
		Vector2(-7, 0)
	])
	var col_core: Color = COL_BEAM_CORE
	col_core.a = clampf(0.20 + shimmer * 1.5, 0.12, 0.28)
	draw_colored_polygon(beam_inner, col_core)
	
	# Warm Light Splash on Floor
	draw_rect(Rect2(-12, 0, 24, 2), COL_BEAM_FLOOR_GLOW)
	draw_rect(Rect2(-7, 0, 14, 1), COL_BEAM_CORE)
	
	# 2. Ceiling Hatch Opening at Top (y = -105)
	draw_rect(Rect2(-9, rail_top - 4, 18, 5), COL_WOOD_SHADOW)
	draw_rect(Rect2(-7, rail_top - 3, 14, 4), Color(1.0, 0.90, 0.55, 0.75)) # Glowing portal
	draw_rect(Rect2(-10, rail_top - 5, 20, 2), COL_WOOD_MAIN)               # Ceiling frame trim
	draw_rect(Rect2(-10, rail_top - 5, 20, 1), COL_WOOD_HIGHLIGHT)          # Molding highlight
	# Propped open wooden hatch flap at top right
	draw_rect(Rect2(7, rail_top - 8, 3, 6), COL_WOOD_MAIN)
	draw_rect(Rect2(8, rail_top - 8, 1, 6), COL_WOOD_HIGHLIGHT)
	draw_rect(Rect2(6, rail_top - 5, 2, 2), COL_BRASS_STUD)
	
	# 3. Wall Mounting Brackets (securing ladder to wall)
	var bracket_y_positions: Array[float] = [-35.0, -75.0]
	for by in bracket_y_positions:
		draw_rect(Rect2(-9, by, 3, 2), COL_IRON_HINGE)
		draw_rect(Rect2(6, by, 3, 2), COL_IRON_HINGE)
	
	# 4. Wooden Side Rails (ladder width: 14px, rails at x = -6 and x = 6)
	# Left Rail (spans x = -7 to -5)
	draw_rect(Rect2(-7, rail_top, 2, rail_h), COL_WOOD_SHADOW)
	draw_rect(Rect2(-6, rail_top, 1, rail_h), COL_WOOD_MAIN)
	draw_rect(Rect2(-7, rail_top, 1, rail_h), COL_WOOD_HIGHLIGHT)
	
	# Right Rail (spans x = 5 to 7)
	draw_rect(Rect2(5, rail_top, 2, rail_h), COL_WOOD_SHADOW)
	draw_rect(Rect2(6, rail_top, 1, rail_h), COL_WOOD_MAIN)
	draw_rect(Rect2(5, rail_top, 1, rail_h), COL_WOOD_HIGHLIGHT)
	
	# 5. Seven Wooden Rungs (evenly spaced from ceiling to floor)
	var rung_y_positions: Array[float] = [-92.0, -77.0, -62.0, -47.0, -32.0, -17.0, -4.0]
	for ry in rung_y_positions:
		# Shadow underline
		draw_rect(Rect2(-5, ry + 1, 10, 1), COL_WOOD_SHADOW)
		# Main rung body
		draw_rect(Rect2(-5, ry, 10, 2), COL_WOOD_MAIN)
		# Top highlight line
		draw_rect(Rect2(-5, ry, 10, 1), COL_WOOD_HIGHLIGHT)
		# Brass fastener pins
		draw_rect(Rect2(-7, ry, 1, 2), COL_BRASS_STUD)
		draw_rect(Rect2(6, ry, 1, 2), COL_BRASS_STUD)
	
	# 6. Interactive Hover Outline Glow
	if _is_hovered:
		draw_rect(Rect2(-9, rail_top - 5, 18, rail_h + 6), COL_HOVER_BORDER, false, 1.0)

## Draws the compact floor trapdoor hatch (30px width)
func _draw_trapdoor_hatch() -> void:
	# 1. Floor cavity / dark shaft going down
	draw_rect(Rect2(-12, -4, 24, 7), Color(0.06, 0.04, 0.03, 1.0))
	
	# 2. Warm light glow emerging from living room below
	draw_rect(Rect2(-10, -3, 20, 5), Color(1.0, 0.85, 0.45, 0.35))
	
	# 3. Outer wooden hatch frame on floor (30px width: x = -15 to 15)
	draw_rect(Rect2(-15, -6, 30, 9), COL_WOOD_SHADOW, false, 1.0)
	draw_rect(Rect2(-15, -6, 30, 2), COL_WOOD_MAIN)
	draw_rect(Rect2(-14, -6, 28, 1), COL_WOOD_HIGHLIGHT)
	
	# 4. Ladder rungs descending into trapdoor shaft (rungs from -5 to 5)
	draw_rect(Rect2(-5, -3, 10, 2), COL_WOOD_MAIN)
	draw_rect(Rect2(-5, -3, 10, 1), COL_WOOD_HIGHLIGHT)
	draw_rect(Rect2(-5, 0, 10, 2), COL_WOOD_MAIN)
	draw_rect(Rect2(-5, 1, 10, 1), COL_WOOD_SHADOW)
	
	# 5. Open wooden trapdoor lid propped up on right hinge
	draw_rect(Rect2(12, -18, 4, 18), COL_WOOD_SHADOW)
	draw_rect(Rect2(12, -18, 3, 17), COL_WOOD_MAIN)
	draw_rect(Rect2(12, -18, 1, 17), COL_WOOD_HIGHLIGHT)
	# Metal strap hinges on lid
	draw_rect(Rect2(11, -14, 5, 2), COL_IRON_HINGE)
	draw_rect(Rect2(11, -3, 5, 2), COL_IRON_HINGE)
	# Pull ring / brass stud
	draw_rect(Rect2(13, -9, 2, 3), COL_BRASS_STUD)
	
	# 6. Hover glow outline
	if _is_hovered:
		draw_rect(Rect2(-16, -7, 33, 11), COL_HOVER_BORDER, false, 1.0)

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
			_trigger_ladder_transition()

func _trigger_ladder_transition() -> void:
	if is_locked:
		return
		
	# Play click pulse animation
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.12, 0.90), 0.08).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK)
	
	# Emit room change via EventBus
	EventBus.room_change_requested.emit(target_room)
