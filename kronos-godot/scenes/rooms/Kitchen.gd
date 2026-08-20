@tool
extends BaseRoom
class_name Kitchen

## Pixel Cafe & Kitchen environment for Kronos.
## Features interactive espresso machine brewing, toggleable stove burner with bubbling stew pot,
## openable oven door with slide-out baking tray, and interactive table vegetable chopping.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_WALL_TILES: Color = Color(0.85, 0.88, 0.90, 1.0) # Subway Tile Backsplash
const COL_TILE_GROUT: Color = Color(0.72, 0.76, 0.80, 1.0)
const COL_WALL_TOP: Color = Color(0.25, 0.35, 0.38, 1.0)
const COL_CHECKER_A: Color = Color(0.92, 0.90, 0.85, 1.0)  # Checkered Floor Light
const COL_CHECKER_B: Color = Color(0.20, 0.22, 0.28, 1.0)  # Checkered Floor Dark

# Cabinets & Counter
const COL_CABINET_WOOD: Color = Color(0.48, 0.34, 0.24, 1.0)
const COL_CABINET_SHADOW: Color = Color(0.35, 0.24, 0.16, 1.0)
const COL_COUNTER_MARBLE: Color = Color(0.94, 0.95, 0.96, 1.0)
const COL_COUNTER_EDGE: Color = Color(0.78, 0.80, 0.84, 1.0)

# Espresso Machine & Appliances
const COL_STEEL: Color = Color(0.70, 0.74, 0.80, 1.0)
const COL_STEEL_DARK: Color = Color(0.45, 0.48, 0.55, 1.0)
const COL_ESPRESSO_RED: Color = Color(0.85, 0.22, 0.22, 1.0)
const COL_OVEN_BODY: Color = Color(0.30, 0.32, 0.38, 1.0)
const COL_OVEN_GLASS: Color = Color(0.18, 0.19, 0.24, 1.0)
const COL_OVEN_GLOW: Color = Color(1.0, 0.65, 0.20, 0.45)
const COL_CROISSANT_GOLD: Color = Color(0.92, 0.65, 0.25, 1.0)
const COL_CROISSANT_CRUST: Color = Color(0.98, 0.78, 0.35, 1.0)
const COL_GAS_BLUE: Color = Color(0.25, 0.65, 1.0, 0.85)
const COL_GAS_ORANGE: Color = Color(1.0, 0.55, 0.15, 0.9)

# Chopping & Food
const COL_BOARD_WOOD: Color = Color(0.68, 0.48, 0.32, 1.0)
const COL_CARROT_ORANGE: Color = Color(0.95, 0.45, 0.15, 1.0)
const COL_HERB_GREEN: Color = Color(0.25, 0.75, 0.35, 1.0)
const COL_KNIFE_BLADE: Color = Color(0.90, 0.92, 0.96, 1.0)

# ==============================================================================
# 📊 INTERACTION STATE
# ==============================================================================
var is_stove_cooking: bool = false
var is_oven_open: bool = false
var is_brewing: bool = false
var is_chopping: bool = false

var _brew_timer: float = 0.0
var _chopping_timer: float = 0.0
var _stove_timer: float = 0.0
var _oven_timer: float = 0.0
var _anim_timer: float = 0.0

# Bounding boxes for click areas
const RECT_ESPRESSO: Rect2 = Rect2(42, 64, 46, 46)
const RECT_STOVE: Rect2 = Rect2(96, 66, 38, 16)
const RECT_OVEN: Rect2 = Rect2(96, 82, 38, 30)
const RECT_ISLAND: Rect2 = Rect2(144, 70, 52, 42)
const RECT_LIGHT_SWITCH: Rect2 = Rect2(28, 70, 16, 22)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_kitchen"
	room_name = "Pixel Cafe & Kitchen"
	desk_x = 65.0
	nap_x = 165.0
	drink_x = 65.0
	
	# All timed appliances start completely idle/dormant
	is_brewing = false
	is_chopping = false
	is_stove_cooking = false
	is_oven_open = false
	_brew_timer = 0.0
	_chopping_timer = 0.0
	_stove_timer = 0.0
	_oven_timer = 0.0
	
	EventBus.object_state_changed.connect(_on_object_state_changed)

func _process(delta: float) -> void:
	_anim_timer += delta * 4.0
	
	if is_brewing:
		_brew_timer -= delta
		if _brew_timer <= 0.0:
			is_brewing = false
			_brew_timer = 0.0
			
	if is_chopping:
		_chopping_timer -= delta
		if _chopping_timer <= 0.0:
			is_chopping = false
			_chopping_timer = 0.0
			
	if is_stove_cooking:
		_stove_timer -= delta
		if _stove_timer <= 0.0:
			is_stove_cooking = false
			_stove_timer = 0.0
			
	if is_oven_open:
		_oven_timer -= delta
		if _oven_timer <= 0.0:
			is_oven_open = false
			_oven_timer = 0.0
			
	queue_redraw()

func _on_object_state_changed(key: String, val: Variant) -> void:
	if key == "kitchen_stove" and val == true:
		is_stove_cooking = true
		_stove_timer = 4.0
		queue_redraw()
	elif key == "kitchen_oven" and val == true:
		is_oven_open = true
		_oven_timer = 4.0
		queue_redraw()
	elif key == "kitchen_espresso" and val == true:
		is_brewing = true
		_brew_timer = 3.5
		queue_redraw()
	elif key == "kitchen_chopping" and val == true:
		is_chopping = true
		_chopping_timer = 3.5
		queue_redraw()

# ==============================================================================
# 🖱️ INTERACTION HANDLING
# ==============================================================================
func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	var mb: InputEventMouseButton = event as InputEventMouseButton
	if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
		var pos: Vector2 = mb.position
		
		# 1. Click Light Switch
		if RECT_LIGHT_SWITCH.has_point(pos):
			if GameState:
				GameState.toggle_room_light(room_id)
			get_viewport().set_input_as_handled()
			return
			
		# 2. Click Espresso Bar (Start 3.5s Brewing)
		if RECT_ESPRESSO.has_point(pos):
			is_brewing = true
			_brew_timer = 3.5
			EventBus.object_state_changed.emit("kitchen_espresso", true)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 3. Click Stove Burner Top (Start 4.0s Cooking Simmer)
		if RECT_STOVE.has_point(pos):
			is_stove_cooking = true
			_stove_timer = 4.0
			EventBus.object_state_changed.emit("kitchen_stove", true)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 4. Click Oven Door (Open Oven for 4.0s with Croissants)
		if RECT_OVEN.has_point(pos):
			is_oven_open = true
			_oven_timer = 4.0
			EventBus.object_state_changed.emit("kitchen_oven", true)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 5. Click Prep Island (Start 3.5s Vegetable Chopping)
		if RECT_ISLAND.has_point(pos):
			is_chopping = true
			_chopping_timer = 3.5
			EventBus.object_state_changed.emit("kitchen_chopping", true)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return

# ==============================================================================
# 🎨 DRAWING PIPELINE (240x140 CANVAS)
# ==============================================================================
func _draw() -> void:
	# 1. Background Wall Top & Subway Tiles (240x140)
	draw_rect(Rect2(0, 0, 240, 30), COL_WALL_TOP)
	
	# Subway Tile Backsplash (y=30 to 98)
	draw_rect(Rect2(0, 30, 240, 68), COL_WALL_TILES)
	for ty in range(30, 98, 8):
		draw_line(Vector2(0, ty), Vector2(240, ty), COL_TILE_GROUT, 1.0)
	for ty in range(30, 98, 16):
		for tx in range(0, 240, 16):
			draw_line(Vector2(tx, ty), Vector2(tx, ty + 8), COL_TILE_GROUT, 1.0)
			draw_line(Vector2(tx + 8, ty + 8), Vector2(tx + 8, ty + 16), COL_TILE_GROUT, 1.0)
			
	# Hanging Utensils Rack (x=95..145, y=36)
	draw_line(Vector2(95, 36), Vector2(145, 36), COL_STEEL, 2.0)
	draw_rect(Rect2(100, 38, 2, 8), COL_STEEL_DARK)
	draw_circle(Vector2(101, 48), 4.0, COL_STEEL_DARK) # Ladle
	draw_rect(Rect2(118, 38, 2, 10), COL_STEEL_DARK)
	draw_rect(Rect2(116, 48, 6, 6), Color(0.85, 0.4, 0.3)) # Copper pan
	draw_rect(Rect2(136, 38, 2, 7), COL_STEEL_DARK)
	draw_circle(Vector2(137, 46), 3.0, COL_STEEL_DARK) # Strainer
	
	# 2. Checkered Floor (y=98 to 140)
	var tile_size: int = 14
	for fy in range(98, 140, tile_size):
		for fx in range(0, 240, tile_size):
			var is_even: bool = ((fx / tile_size) + (fy / tile_size)) % 2 == 0
			var col = COL_CHECKER_A if is_even else COL_CHECKER_B
			draw_rect(Rect2(fx, fy, tile_size, tile_size), col)
			
	# 3. Espresso Coffee Bar (x=44, y=66)
	_draw_coffee_bar(44, 66)
	
	# 4. Stove Oven (x=98, y=68)
	_draw_oven_stove(98, 68)
	
	# 5. Snack Island & Prep Counter (x=146, y=70)
	_draw_snack_counter(146, 70)
	
	# 6. Wall Light Switch (x=32, y=74 - beside the left door)
	var is_light_on: bool = GameState.is_room_light_on(room_id) if GameState else false
	draw_light_switch(32, 74, is_light_on)
	
	# 7. Placed Room Decorations
	_draw_placed_decorations()

func _draw_placed_decorations() -> void:
	if not GameState:
		return
		
	# 🧂 Artisan Spice Rack on Tile Backsplash (x=74, y=42)
	if GameState.is_decor_placed("decor_spice_rack"):
		var sx: float = 74.0
		var sy: float = 42.0
		# Wooden Shelves
		draw_rect(Rect2(sx, sy, 18, 2), Color(0.48, 0.32, 0.20))
		draw_rect(Rect2(sx, sy + 7, 18, 2), Color(0.48, 0.32, 0.20))
		# Top Tier Jars
		draw_rect(Rect2(sx + 2, sy - 4, 3, 4), Color(0.85, 0.25, 0.20, 0.9)) # Paprika
		draw_rect(Rect2(sx + 7, sy - 4, 3, 4), Color(0.95, 0.80, 0.20, 0.9)) # Saffron
		draw_rect(Rect2(sx + 12, sy - 4, 3, 4), Color(0.25, 0.65, 0.30, 0.9)) # Rosemary
		# Bottom Tier Jars
		draw_rect(Rect2(sx + 2, sy + 3, 3, 4), Color(0.60, 0.35, 0.18, 0.9)) # Cinnamon
		draw_rect(Rect2(sx + 7, sy + 3, 3, 4), Color(0.95, 0.95, 0.98, 0.9)) # Sea Salt
		draw_rect(Rect2(sx + 12, sy + 3, 3, 4), Color(0.18, 0.18, 0.22, 0.9)) # Black Pepper
		
	# 🧁 Glass Pastry Cloche on Island Counter (x=175, y=74)
	if GameState.is_decor_placed("decor_pastry_dome"):
		var px: float = 175.0
		var py: float = 74.0
		# Wooden Cake Stand
		draw_rect(Rect2(px - 6, py + 9, 14, 2), Color(0.55, 0.38, 0.24))
		draw_rect(Rect2(px - 1, py + 11, 4, 3), Color(0.45, 0.30, 0.18))
		# Pastries Inside (Golden Croissant / Muffin)
		draw_rect(Rect2(px - 3, py + 5, 8, 4), Color(0.92, 0.65, 0.25))
		draw_rect(Rect2(px - 1, py + 4, 4, 2), Color(0.35, 0.20, 0.50)) # Blueberry top
		# Crystal Glass Dome Cloche
		draw_rect(Rect2(px - 5, py + 1, 12, 8), Color(0.80, 0.92, 1.0, 0.40))
		draw_rect(Rect2(px - 3, py - 1, 8, 2), Color(0.80, 0.92, 1.0, 0.40))
		draw_rect(Rect2(px, py - 3, 2, 2), Color(0.85, 0.95, 1.0, 0.80)) # Glass knob handle
		draw_line(Vector2(px - 4, py + 2), Vector2(px - 2, py + 7), Color(1.0, 1.0, 1.0, 0.65), 1.0) # Shine

func _draw_coffee_bar(cx: float, cy: float) -> void:
	# Wooden Counter Base
	draw_rect(Rect2(cx, cy + 18, 42, 30), COL_CABINET_WOOD)
	draw_rect(Rect2(cx, cy + 18, 42, 3), COL_CABINET_SHADOW)
	draw_rect(Rect2(cx + 3, cy + 24, 16, 20), COL_CABINET_SHADOW)
	draw_rect(Rect2(cx + 23, cy + 24, 16, 20), COL_CABINET_SHADOW)
	
	# Marble Countertop
	draw_rect(Rect2(cx - 2, cy + 14, 46, 5), COL_COUNTER_MARBLE)
	draw_rect(Rect2(cx - 2, cy + 17, 46, 2), COL_COUNTER_EDGE)
	
	# Retro Espresso Machine
	draw_rect(Rect2(cx + 6, cy + 2, 18, 13), COL_ESPRESSO_RED)
	draw_rect(Rect2(cx + 7, cy + 3, 16, 2), COL_STEEL) # Chrome top
	
	# Pressure Gauge
	var gauge_flick = (sin(_anim_timer * 6.0) * 1.0) if is_brewing else 0.0
	draw_circle(Vector2(cx + 20, cy + 6), 2.5, Color(0.95, 0.95, 0.95))
	draw_line(Vector2(cx + 20, cy + 6), Vector2(cx + 20 + gauge_flick, cy + 4.5), Color(0.8, 0.1, 0.1), 1.0)
	
	# Portafilter grouphead
	draw_rect(Rect2(cx + 8, cy + 8, 5, 4), COL_STEEL)
	
	# Porcelain Espresso Cup
	draw_rect(Rect2(cx + 9, cy + 12, 6, 3), Color(0.95, 0.95, 0.95))
	draw_rect(Rect2(cx + 10, cy + 12, 4, 1), Color(0.35, 0.22, 0.15)) # Crema layer
	
	if is_brewing:
		# Active coffee drips streaming into cup
		draw_line(Vector2(cx + 10.5, cy + 9), Vector2(cx + 10.5, cy + 12), Color(0.30, 0.18, 0.10), 1.0)
		# Rising steam swirls
		var steam_ox = sin(_brew_timer * 10.0) * 1.5
		draw_rect(Rect2(cx + 11 + steam_ox, cy + 7, 1, 2), Color(1.0, 1.0, 1.0, 0.6))
		draw_rect(Rect2(cx + 12 - steam_ox, cy + 4, 1, 2), Color(1.0, 1.0, 1.0, 0.4))
		
	# Coffee Bean Grinder & Hopper
	draw_rect(Rect2(cx + 28, cy + 2, 8, 13), COL_STEEL_DARK)
	draw_rect(Rect2(cx + 29, cy - 2, 6, 5), Color(0.35, 0.22, 0.15, 0.8)) # Glass hopper with beans
	
	# Menu Chalkboard on Wall
	draw_rect(Rect2(cx + 4, cy - 22, 24, 16), COL_CHECKER_B)
	draw_rect(Rect2(cx + 3, cy - 23, 26, 18), COL_CABINET_WOOD, false, 1.0)
	draw_rect(Rect2(cx + 6, cy - 18, 12, 1), Color(1.0, 1.0, 0.8))
	draw_rect(Rect2(cx + 6, cy - 14, 16, 1), Color(0.8, 0.8, 0.8))
	draw_rect(Rect2(cx + 6, cy - 10, 14, 1), Color(0.8, 0.8, 0.8))

func _draw_oven_stove(ox: float, oy: float) -> void:
	# Steel Oven Body
	draw_rect(Rect2(ox, oy + 12, 34, 34), COL_OVEN_BODY)
	draw_rect(Rect2(ox, oy + 12, 34, 3), COL_STEEL_DARK)
	
	# Stove Burners Top
	draw_rect(Rect2(ox - 1, oy + 10, 36, 4), COL_STEEL)
	draw_rect(Rect2(ox + 4, oy + 8, 10, 3), COL_STEEL_DARK)
	draw_rect(Rect2(ox + 20, oy + 8, 10, 3), COL_STEEL_DARK)
	
	# Burner Gas Flame under pot
	if is_stove_cooking:
		var flame_w = sin(_anim_timer * 8.0) * 1.0
		# Blue & orange gas flame rings
		draw_rect(Rect2(ox + 4, oy + 9, 10, 2), COL_GAS_BLUE)
		draw_rect(Rect2(ox + 6 + flame_w, oy + 8, 6, 2), COL_GAS_ORANGE)
		
	# Simmering Pot on Stove
	draw_rect(Rect2(ox + 4, oy + 2, 11, 7), Color(0.32, 0.62, 0.52)) # Teal stew pot
	draw_rect(Rect2(ox + 3, oy + 4, 13, 1), COL_STEEL_DARK)           # Pot rim
	
	if is_stove_cooking:
		# Rattling bouncing pot lid
		var lid_hop = sin(_anim_timer * 16.0) * 1.5
		draw_rect(Rect2(ox + 3, oy + 1 - lid_hop, 13, 2), COL_STEEL) # Jumping lid
		draw_rect(Rect2(ox + 8, oy - 1 - lid_hop, 3, 2), COL_STEEL_DARK) # Lid handle
		# Simmering steam puffs rising
		var st_x = sin(_anim_timer * 5.0) * 2.0
		draw_rect(Rect2(ox + 9 + st_x, oy - 5, 2, 2), Color(1.0, 1.0, 1.0, 0.6))
		draw_rect(Rect2(ox + 8 - st_x, oy - 9, 3, 2), Color(1.0, 1.0, 1.0, 0.4))
	else:
		# Closed resting lid
		draw_rect(Rect2(ox + 3, oy + 1, 13, 2), COL_STEEL)
		draw_rect(Rect2(ox + 8, oy - 1, 3, 2), COL_STEEL_DARK)
		
	# Oven Door Section (Openable)
	if is_oven_open:
		# OPEN OVEN: Door dropped down flat, slide-out wire rack with fresh pastries
		# Oven Interior cavity
		draw_rect(Rect2(ox + 3, oy + 16, 28, 22), Color(0.12, 0.10, 0.08))
		draw_rect(Rect2(ox + 3, oy + 16, 28, 22), COL_OVEN_GLOW)
		
		# Slide-out wire rack
		draw_rect(Rect2(ox + 2, oy + 24, 30, 2), COL_STEEL)
		draw_rect(Rect2(ox + 4, oy + 23, 26, 4), Color(0.20, 0.20, 0.22)) # Baking sheet
		
		# Steaming hot baked croissants on tray
		draw_rect(Rect2(ox + 7, oy + 20, 7, 3), COL_CROISSANT_GOLD)
		draw_rect(Rect2(ox + 17, oy + 20, 7, 3), COL_CROISSANT_GOLD)
		draw_rect(Rect2(ox + 8, oy + 19, 5, 1), COL_CROISSANT_CRUST)
		draw_rect(Rect2(ox + 18, oy + 19, 5, 1), COL_CROISSANT_CRUST)
		
		# Open door frame dropped horizontally
		draw_rect(Rect2(ox + 2, oy + 36, 30, 6), COL_OVEN_BODY)
		draw_rect(Rect2(ox + 4, oy + 37, 26, 4), COL_OVEN_GLASS)
	else:
		# CLOSED OVEN: Dark glass with warm internal heating glow
		draw_rect(Rect2(ox + 4, oy + 18, 26, 22), COL_OVEN_GLASS)
		draw_rect(Rect2(ox + 6, oy + 20, 22, 18), COL_OVEN_GLOW)
		# Croissant silhouettes visible through oven window
		draw_rect(Rect2(ox + 9, oy + 28, 6, 3), Color(0.75, 0.45, 0.15, 0.8))
		draw_rect(Rect2(ox + 18, oy + 28, 6, 3), Color(0.75, 0.45, 0.15, 0.8))
		# Steel handle
		draw_rect(Rect2(ox + 7, oy + 16, 20, 2), COL_STEEL)

func _draw_snack_counter(sx: float, sy: float) -> void:
	# Kitchen Island Cabinet Base
	draw_rect(Rect2(sx, sy + 14, 46, 32), COL_CABINET_WOOD)
	draw_rect(Rect2(sx, sy + 14, 46, 3), COL_CABINET_SHADOW)
	
	# Marble Island Countertop
	draw_rect(Rect2(sx - 2, sy + 10, 50, 5), COL_COUNTER_MARBLE)
	draw_rect(Rect2(sx - 2, sy + 13, 50, 2), COL_COUNTER_EDGE)
	
	# Wooden Chopping Board (Left side of Island)
	draw_rect(Rect2(sx + 3, sy + 6, 18, 5), COL_BOARD_WOOD)
	draw_rect(Rect2(sx + 3, sy + 6, 18, 1), Color(0.80, 0.60, 0.42))
	
	# Carrots & Herbs on Board
	draw_rect(Rect2(sx + 6, sy + 4, 8, 3), COL_CARROT_ORANGE)
	draw_rect(Rect2(sx + 13, sy + 3, 4, 2), COL_HERB_GREEN)
	
	# Interactive Chef Knife Chopping
	if is_chopping:
		var chop_y = sin(_chopping_timer * 14.0) * 3.0
		# Angled Chef Knife
		draw_line(Vector2(sx + 8, sy + 2 - chop_y), Vector2(sx + 18, sy + 5 - chop_y), COL_KNIFE_BLADE, 2.0)
		draw_rect(Rect2(sx + 18, sy + 4 - chop_y, 4, 2), COL_CABINET_SHADOW) # Knife handle
		# Bouncing diced vegetable bits
		draw_rect(Rect2(sx + 5, sy + 2, 2, 2), COL_CARROT_ORANGE)
		draw_rect(Rect2(sx + 14, sy + 1, 2, 2), COL_HERB_GREEN)
	else:
		# Resting Chef Knife on board
		draw_line(Vector2(sx + 7, sy + 3), Vector2(sx + 17, sy + 3), COL_KNIFE_BLADE, 2.0)
		draw_rect(Rect2(sx + 17, sy + 2, 4, 2), COL_CABINET_SHADOW)
		
	# Fresh Fruit Bowl on Right side of Island
	draw_rect(Rect2(sx + 26, sy + 5, 14, 6), Color(0.85, 0.90, 0.95))
	draw_circle(Vector2(sx + 29, sy + 4), 3.0, Color(0.95, 0.25, 0.25)) # Apple
	draw_circle(Vector2(sx + 35, sy + 4), 3.0, Color(0.98, 0.60, 0.15)) # Orange
	draw_circle(Vector2(sx + 32, sy + 1), 2.5, Color(0.40, 0.75, 0.30)) # Lime
