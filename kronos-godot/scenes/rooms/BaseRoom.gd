extends Node2D
class_name BaseRoom

## Base Class for all Kronos Room Environments (240x140 pixel canvas).
## Provides room bounds, interactive anchors (desk, bed/nap, coffee/snack),
## dynamic Day/Night atmospheric lighting, and ambient particle management.

# ==============================================================================
# 🏠 ROOM CONFIGURATION & ANCHORS
# ==============================================================================
@export var room_id: String = "room_base"
@export var room_name: String = "Base Room"

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
const AMBIENT_NIGHT: Color = Color(0.55, 0.58, 0.78, 1.0)       # 21:00 - 06:00
const AMBIENT_DAWN: Color = Color(0.92, 0.82, 0.85, 1.0)        # 06:00 - 10:00

@onready var ambient_modulate: CanvasModulate = $AmbientModulate

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	_update_ambient_lighting()

func _process(_delta: float) -> void:
	pass

## Updates room lighting based on local time
func _update_ambient_lighting() -> void:
	if not ambient_modulate:
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
		
	ambient_modulate.color = target_col

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
