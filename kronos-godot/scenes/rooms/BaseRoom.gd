extends Node2D
class_name BaseRoom

## Base Class for all Kronos Room Environments (240x140 pixel canvas).
## Provides room bounds, interactive anchors (desk, bed/nap, coffee/snack),
## dynamic Day/Night atmospheric lighting, house light switch support, and ambient particles.

# ==============================================================================
# 🏠 ROOM CONFIGURATION & ANCHORS
# ==============================================================================
@export var room_id: String = "room_base"
@export var room_name: String = "Base Room"
@export var room_width: float = 240.0

@export_group("Navigation Anchors")
@export var min_x: float = 35.0
@export var max_x: float = 205.0
@export var floor_y: float = 115.0
@export var desk_x: float = 75.0
@export var nap_x: float = 175.0
@export var drink_x: float = 120.0

# ==============================================================================
# 🎨 TIME-OF-DAY PALETTES
# ==============================================================================
# Dynamic ambient color modulation based on real-world system hour
const AMBIENT_DAY: Color = Color(1.0, 1.0, 1.0, 1.0)           # 10:00 - 16:00
const AMBIENT_SUNSET: Color = Color(1.0, 0.85, 0.72, 1.0)      # 16:00 - 19:00
const AMBIENT_DUSK: Color = Color(0.75, 0.68, 0.88, 1.0)        # 19:00 - 21:00
const AMBIENT_NIGHT: Color = Color(0.52, 0.55, 0.76, 1.0)       # 21:00 - 06:00
const AMBIENT_DAWN: Color = Color(0.92, 0.82, 0.85, 1.0)        # 06:00 - 10:00
const AMBIENT_LIGHT_ON: Color = Color(1.0, 0.96, 0.88, 1.0)    # Light switch active

# Pixel Light Switch Colors
const COL_SWITCH_PLATE: Color = Color(0.82, 0.85, 0.90, 1.0)
const COL_SWITCH_PLATE_BORDER: Color = Color(0.25, 0.28, 0.35, 1.0)
const COL_SWITCH_LEVER: Color = Color(0.95, 0.96, 0.98, 1.0)
const COL_SWITCH_LEVER_ON: Color = Color(0.96, 0.65, 0.15, 1.0)

@onready var ambient_modulate: CanvasModulate = $AmbientModulate

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	_update_ambient_lighting()
	
	# Inject Weather Renderer
	var wr = Node2D.new()
	var wr_script = load("res://scenes/rooms/WeatherRenderer.gd")
	wr.set_script(wr_script)
	add_child(wr)
	
	if EventBus and EventBus.has_signal("floor_y_offset_changed"):
		EventBus.floor_y_offset_changed.emit(0.0)
	EventBus.room_light_toggled.connect(_on_room_light_toggled)
	EventBus.decor_placed.connect(_on_decor_placed)
	if EventBus.has_signal("weather_changed"):
		EventBus.weather_changed.connect(func(w): _update_ambient_lighting())

func _on_room_light_toggled(toggled_room_id: String, _is_on: bool) -> void:
	if toggled_room_id == room_id:
		_update_ambient_lighting()
		queue_redraw()

func _on_decor_placed(_item_id: String, toggled_room_id: String, _is_placed: bool) -> void:
	if toggled_room_id == room_id or toggled_room_id == "":
		queue_redraw()

## Updates room lighting based on local time and light switch state
func _update_ambient_lighting() -> void:
	if not ambient_modulate:
		return
		
	var is_light_on: bool = GameState.is_room_light_on(room_id) if GameState else false
	if is_light_on:
		ambient_modulate.color = AMBIENT_LIGHT_ON
		return
		
	var time_dict = Time.get_time_dict_from_system()
	var hour: int = time_dict.get("hour", 12)
	
	var target_col: Color = AMBIENT_DAY
	if hour >= 6 and hour < 10:
		target_col = AMBIENT_DAWN
	elif hour >= 10 and hour < 16:
		target_col = AMBIENT_DAY
	elif hour >= 16 and hour < 19:
		target_col = AMBIENT_SUNSET
	elif hour >= 19 and hour < 21:
		target_col = AMBIENT_DUSK
	else:
		target_col = AMBIENT_NIGHT
		
	if GameState:
		if GameState.current_weather == GameState.Weather.RAIN:
			target_col = AMBIENT_DUSK.darkened(0.2)
		elif GameState.current_weather == GameState.Weather.SNOW:
			target_col = target_col.lerp(Color(0.8, 0.85, 0.95), 0.5)
			
	ambient_modulate.color = target_col

## Helper to draw standard 1-gang pixel light switch on wall
func draw_light_switch(sx: float, sy: float, is_on: bool) -> void:
	# Plate Frame & Base
	draw_rect(Rect2(sx, sy, 8, 14), COL_SWITCH_PLATE_BORDER)
	draw_rect(Rect2(sx + 1, sy + 1, 6, 12), COL_SWITCH_PLATE)
	
	# Screws (top & bottom)
	draw_rect(Rect2(sx + 3, sy + 2, 2, 1), COL_SWITCH_PLATE_BORDER)
	draw_rect(Rect2(sx + 3, sy + 11, 2, 1), COL_SWITCH_PLATE_BORDER)
	
	# Toggle Lever Slot & Lever
	draw_rect(Rect2(sx + 2, sy + 4, 4, 6), Color(0.2, 0.22, 0.28))
	if is_on:
		# Toggle lever flipped UP
		draw_rect(Rect2(sx + 3, sy + 4, 2, 3), COL_SWITCH_LEVER_ON)
		draw_circle(Vector2(sx + 4, sy + 5), 4.0, Color(1.0, 0.9, 0.4, 0.25))
	else:
		# Toggle lever flipped DOWN
		draw_rect(Rect2(sx + 3, sy + 7, 2, 3), COL_SWITCH_LEVER)

## Returns dictionary of all room navigation anchors for PetBrain
func get_navigation_anchors() -> Dictionary:
	return {
		"min_x": min_x,
		"max_x": max_x,
		"floor_y": floor_y,
		"desk_x": desk_x,
		"nap_x": nap_x,
		"drink_x": drink_x
	}
