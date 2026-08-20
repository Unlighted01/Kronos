@tool
extends BaseRoom
class_name Greenhouse

## Botanical Conservatory & Plant Growth Engine for Kronos.
## Features interactive watering can, 4-stage botanical growth (Sprout -> Foliage -> Bud -> Majestic Bloom),
## falling cherry blossom petals, rustling monsteras, and greenhouse ambient day/night glass lighting.

# ==============================================================================
# 🎨 COLOR PALETTE
# ==============================================================================
const COL_GLASS_SKY: Color = Color(0.35, 0.62, 0.78, 1.0)
const COL_GLASS_FRAME: Color = Color(0.92, 0.94, 0.96, 0.85)
const COL_GLASS_SHINE: Color = Color(1.0, 1.0, 1.0, 0.30)
const COL_STONE_WALL: Color = Color(0.30, 0.36, 0.32, 1.0)
const COL_TERRACOTTA_FLOOR: Color = Color(0.72, 0.38, 0.28, 1.0)
const COL_FLOOR_GROUT: Color = Color(0.58, 0.28, 0.20, 1.0)

# Plants & Foliage
const COL_LEAF_DARK: Color = Color(0.12, 0.38, 0.20, 1.0)
const COL_LEAF_MID: Color = Color(0.22, 0.58, 0.32, 1.0)
const COL_LEAF_LIGHT: Color = Color(0.42, 0.78, 0.45, 1.0)
const COL_POT_TERRACOTTA: Color = Color(0.78, 0.42, 0.28, 1.0)
const COL_POT_SHADOW: Color = Color(0.58, 0.30, 0.18, 1.0)
const COL_SOIL_DARK: Color = Color(0.26, 0.18, 0.14, 1.0)
const COL_SOIL_WET: Color = Color(0.18, 0.12, 0.08, 1.0)

# Sakura Bonsai & Flowers
const COL_BLOSSOM_PINK: Color = Color(0.98, 0.68, 0.78, 1.0)
const COL_BLOSSOM_LIGHT: Color = Color(1.0, 0.85, 0.90, 1.0)
const COL_BLOSSOM_CORE: Color = Color(0.85, 0.35, 0.55, 1.0)
const COL_ORCHID_GOLD: Color = Color(0.98, 0.85, 0.30, 1.0)
const COL_ORCHID_ORANGE: Color = Color(0.95, 0.55, 0.20, 1.0)
const COL_HYDRANGEA_BLUE: Color = Color(0.40, 0.65, 0.95, 1.0)
const COL_HYDRANGEA_PURPLE: Color = Color(0.65, 0.45, 0.90, 1.0)
const COL_TRUNK_WOOD: Color = Color(0.38, 0.24, 0.16, 1.0)

# Furniture & Tools
const COL_BENCH_WOOD: Color = Color(0.55, 0.40, 0.28, 1.0)
const COL_BENCH_SHADOW: Color = Color(0.40, 0.28, 0.18, 1.0)
const COL_WATERING_CAN: Color = Color(0.35, 0.68, 0.85, 0.95)
const COL_WATER_DROP: Color = Color(0.45, 0.80, 1.0, 0.85)

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var sakura_particles: CPUParticles2D = $SakuraPetals

# ==============================================================================
# 📊 BOTANICAL GROWTH & INTERACTION STATE
# ==============================================================================
# Plant growth stages: 0 = Sprout, 1 = Small Leaf, 2 = Budding, 3 = Majestic Bloom
var plant_1_stage: int = 1 # Golden Orchid
var plant_2_stage: int = 2 # Azure Hydrangea
var monstera_stage: int = 2 # Giant Monstera

var is_watering: bool = false
var _watering_target_x: float = 160.0
var _watering_timer: float = 0.0

var _bonsai_shake_timer: float = 0.0
var _monstera_rustle_timer: float = 0.0
var _anim_clock: float = 0.0

# Bounding boxes for click areas
const RECT_BONSAI: Rect2 = Rect2(55, 48, 48, 48)
const RECT_MONSTERA: Rect2 = Rect2(115, 66, 32, 42)
const RECT_POT_1: Rect2 = Rect2(154, 68, 14, 20)
const RECT_POT_2: Rect2 = Rect2(168, 68, 14, 20)
const RECT_WATERING_CAN: Rect2 = Rect2(182, 68, 16, 20)
const RECT_LIGHT_SWITCH: Rect2 = Rect2(28, 70, 16, 22)

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	super._ready()
	room_id = "room_greenhouse"
	room_name = "Botanical Conservatory"
	desk_x = 85.0
	nap_x = 165.0
	drink_x = 85.0
	
	if GameState:
		plant_1_stage = GameState.get_object_state("greenhouse_plant_1", 1)
		plant_2_stage = GameState.get_object_state("greenhouse_plant_2", 2)
		monstera_stage = GameState.get_object_state("greenhouse_monstera", 2)

func _process(delta: float) -> void:
	_anim_clock += delta * 3.0
	
	if _bonsai_shake_timer > 0.0:
		_bonsai_shake_timer -= delta
		
	if _monstera_rustle_timer > 0.0:
		_monstera_rustle_timer -= delta
		
	if is_watering:
		_watering_timer -= delta
		if _watering_timer <= 0.0:
			is_watering = false
			
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
			
		# 2. Click Sakura Bonsai (Shake branches & burst cherry blossom petals)
		if RECT_BONSAI.has_point(pos):
			_bonsai_shake_timer = 0.8
			if sakura_particles:
				sakura_particles.amount = 40
				sakura_particles.restart()
			if GameState:
				GameState.add_joy(3.0)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 3. Click Monstera Pot (Rustle broad leaves & dew droplets)
		if RECT_MONSTERA.has_point(pos):
			_monstera_rustle_timer = 1.6
			monstera_stage = (monstera_stage + 1) % 4
			if GameState:
				GameState.set_object_state("greenhouse_monstera", monstera_stage)
				GameState.add_joy(2.0)
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 4. Click Plant Pot 1 (Golden Orchid) or Watering Can
		if RECT_POT_1.has_point(pos) or (RECT_WATERING_CAN.has_point(pos) and not is_watering):
			_start_watering(160.0)
			plant_1_stage = (plant_1_stage + 1) % 4
			if GameState:
				GameState.set_object_state("greenhouse_plant_1", plant_1_stage)
				GameState.add_joy(5.0)
				GameState.add_coins(2, "Plant Care")
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		# 5. Click Plant Pot 2 (Azure Hydrangea)
		if RECT_POT_2.has_point(pos):
			_start_watering(174.0)
			plant_2_stage = (plant_2_stage + 1) % 4
			if GameState:
				GameState.set_object_state("greenhouse_plant_2", plant_2_stage)
				GameState.add_joy(5.0)
				GameState.add_coins(2, "Plant Care")
			queue_redraw()
			get_viewport().set_input_as_handled()
			return

func _start_watering(target_x_pos: float) -> void:
	is_watering = true
	_watering_target_x = target_x_pos
	_watering_timer = 2.5

# ==============================================================================
# 🎨 DRAWING PIPELINE (240x140 CANVAS)
# ==============================================================================
func _draw() -> void:
	# 1. Glass Conservatory Ceiling & Sky (240x70)
	var hour: int = Time.get_time_dict_from_system().get("hour", 12)
	var sky_col = COL_GLASS_SKY
	var is_night: bool = (hour < 6 or hour >= 20)
	var is_sunset: bool = (hour >= 16 and hour < 20)
	
	if is_night:
		sky_col = Color(0.08, 0.10, 0.20, 1.0)
	elif is_sunset:
		sky_col = Color(0.85, 0.52, 0.42, 1.0)
		
	draw_rect(Rect2(0, 0, 240, 70), sky_col)
	
	# Celestial Moon / Sunbeams
	if is_night:
		draw_rect(Rect2(180, 15, 6, 6), Color(0.95, 0.98, 1.0))
		draw_rect(Rect2(178, 15, 4, 6), sky_col) # Crescent
		draw_rect(Rect2(60, 20, 1, 1), Color(1.0, 1.0, 1.0, 0.8))
		draw_rect(Rect2(110, 12, 1, 1), Color(1.0, 1.0, 1.0, 0.8))
	else:
		draw_circle(Vector2(190, 22), 6.0, Color(1.0, 0.92, 0.55, 0.9))
		
	# Glass Roof Arch Trusses & Steel Mullions
	for gx in range(0, 240, 40):
		draw_line(Vector2(gx, 0), Vector2(gx, 70), COL_GLASS_FRAME, 2.0)
		draw_line(Vector2(gx, 0), Vector2(gx + 20, 35), COL_GLASS_FRAME, 1.0)
		draw_line(Vector2(gx + 40, 0), Vector2(gx + 20, 35), COL_GLASS_FRAME, 1.0)
	draw_line(Vector2(0, 35), Vector2(240, 35), COL_GLASS_FRAME, 2.0)
	draw_line(Vector2(0, 70), Vector2(240, 70), COL_GLASS_FRAME, 3.0)
	
	# Glass Panel Shimmer Glare
	draw_line(Vector2(20, 10), Vector2(35, 30), COL_GLASS_SHINE, 1.0)
	draw_line(Vector2(100, 15), Vector2(115, 32), COL_GLASS_SHINE, 1.0)
	draw_line(Vector2(180, 12), Vector2(195, 28), COL_GLASS_SHINE, 1.0)
	
	# Hanging Botanical Baskets from Ceiling
	_draw_hanging_plant(45, 15)
	_draw_hanging_plant(120, 10)
	_draw_hanging_plant(195, 15)
	
	# 2. Lower Weathered Moss Stone Wall (y=70 to 98)
	draw_rect(Rect2(0, 70, 240, 28), COL_STONE_WALL)
	draw_line(Vector2(0, 96), Vector2(240, 96), COL_STONE_WALL.darkened(0.25), 2.0)
	# Moss patches
	draw_rect(Rect2(40, 74, 12, 3), COL_LEAF_DARK)
	draw_rect(Rect2(150, 78, 16, 4), COL_LEAF_DARK)
	
	# 3. Terracotta Paver Floor (y=98 to 140)
	draw_rect(Rect2(0, 98, 240, 42), COL_TERRACOTTA_FLOOR)
	for fy in range(98, 140, 12):
		draw_line(Vector2(0, fy), Vector2(240, fy), COL_FLOOR_GROUT, 1.0)
	for fx in range(0, 240, 24):
		draw_line(Vector2(fx, 98), Vector2(fx, 110), COL_FLOOR_GROUT, 1.0)
		draw_line(Vector2(fx + 12, 110), Vector2(fx + 12, 122), COL_FLOOR_GROUT, 1.0)
		draw_line(Vector2(fx, 122), Vector2(fx, 134), COL_FLOOR_GROUT, 1.0)
		draw_line(Vector2(fx + 12, 134), Vector2(fx + 12, 140), COL_FLOOR_GROUT, 1.0)
		
	# 4. Blossoming Sakura Bonsai Tree on Wooden Bench (x=55 to 105)
	_draw_sakura_bonsai(58, 56)
	
	# 5. Lush Potted Monstera (x=115 to 145)
	_draw_monstera_pot(118, 72)
	
	# 6. Potting Bench with Growing Plants & Watering Can (x=152 to 205)
	_draw_potting_bench(152, 74)
	
	# 7. Animated Pouring Water Droplets if watering
	if is_watering:
		_draw_watering_action(_watering_target_x)
		
	# 8. Wall Light Switch (x=32, y=74 - beside the left door)
	var is_light_on: bool = GameState.is_room_light_on(room_id) if GameState else false
	draw_light_switch(32, 74, is_light_on)
	
	# 9. Placed Room Decorations
	_draw_placed_decorations()

func _draw_placed_decorations() -> void:
	if not GameState:
		return
		
	# 🌿 Geometric Glass Terrarium on Stone Wall Ledge (x=104, y=78)
	if GameState.is_decor_placed("decor_terrarium"):
		var tx: float = 104.0
		var ty: float = 78.0
		# Brass Faceted Frame
		draw_rect(Rect2(tx - 5, ty, 10, 8), Color(0.85, 0.70, 0.25))
		draw_rect(Rect2(tx - 4, ty + 1, 8, 6), Color(0.80, 0.95, 1.0, 0.45)) # Glass
		# Miniature Micro-Succulent & Moss
		draw_rect(Rect2(tx - 3, ty + 5, 6, 2), Color(0.35, 0.25, 0.15)) # Soil bed
		draw_rect(Rect2(tx - 2, ty + 3, 4, 3), Color(0.20, 0.75, 0.40)) # Lush moss
		draw_rect(Rect2(tx, ty + 2, 2, 2), Color(0.40, 0.90, 0.55))     # Sprout
		
	# 💡 Hanging Solar Fairy Lantern from Arch (x=160, y=28)
	if GameState.is_decor_placed("decor_fairy_lantern"):
		var lx: float = 160.0
		var ly: float = 28.0
		# Braided Copper Chain
		draw_line(Vector2(lx, 0), Vector2(lx, ly), Color(0.75, 0.45, 0.25), 1.0)
		# Brass Cap & Base
		draw_rect(Rect2(lx - 4, ly, 8, 2), Color(0.90, 0.75, 0.25))
		draw_rect(Rect2(lx - 4, ly + 8, 8, 2), Color(0.90, 0.75, 0.25))
		# Blown Glass Cylinder
		draw_rect(Rect2(lx - 3, ly + 2, 6, 6), Color(1.0, 0.95, 0.60, 0.50))
		# Glowing Fairy Firefly Core (sinusoidal pulse)
		var core_alpha: float = 0.65 + sin(_anim_clock * 4.0) * 0.30
		draw_rect(Rect2(lx - 1, ly + 4, 2, 2), Color(1.0, 1.0, 0.8, core_alpha))
		# Radiant Fairy Light Glow
		draw_circle(Vector2(lx, ly + 5), 14.0, Color(1.0, 0.90, 0.40, 0.20 * core_alpha))

# ==============================================================================
# 🌿 BOTANICAL DRAWING HELPERS
# ==============================================================================
func _draw_hanging_plant(hx: float, hy: float) -> void:
	# Hemp Rope
	draw_line(Vector2(hx, 0), Vector2(hx, hy + 6), Color(0.65, 0.55, 0.40), 1.0)
	# Terracotta Hanging Pot
	draw_rect(Rect2(hx - 6, hy + 6, 12, 5), COL_POT_TERRACOTTA)
	# Cascading Trailing Leaves
	var sway = sin(_anim_clock + hx) * 1.5
	draw_circle(Vector2(hx + sway, hy + 6), 6.0, COL_LEAF_MID)
	draw_circle(Vector2(hx - 4 + sway, hy + 12), 4.0, COL_LEAF_DARK)
	draw_circle(Vector2(hx + 3 + sway, hy + 14), 4.0, COL_LEAF_LIGHT)
	draw_line(Vector2(hx - 2, hy + 8), Vector2(hx - 4 + sway, hy + 20), COL_LEAF_MID, 2.0)
	draw_line(Vector2(hx + 3, hy + 8), Vector2(hx + 5 + sway, hy + 18), COL_LEAF_LIGHT, 2.0)

func _draw_sakura_bonsai(bx: float, by: float) -> void:
	var shake: float = sin(_anim_clock * 8.0) * 2.0 if _bonsai_shake_timer > 0.0 else 0.0
	
	# Wooden Stand Table
	draw_rect(Rect2(bx, by + 34, 42, 4), COL_BENCH_WOOD)
	draw_rect(Rect2(bx, by + 37, 42, 2), COL_BENCH_SHADOW)
	draw_rect(Rect2(bx + 3, by + 38, 3, 16), COL_BENCH_WOOD)
	draw_rect(Rect2(bx + 36, by + 38, 3, 16), COL_BENCH_WOOD)
	
	# Ceramic Bonsai Tray
	draw_rect(Rect2(bx + 6, by + 28, 30, 6), Color(0.22, 0.35, 0.40))
	draw_rect(Rect2(bx + 8, by + 26, 26, 3), COL_SOIL_DARK)
	
	# Gnarled Bonsai Trunk
	draw_line(Vector2(bx + 20, by + 26), Vector2(bx + 16 + shake * 0.5, by + 14), COL_TRUNK_WOOD, 4.0)
	draw_line(Vector2(bx + 16 + shake * 0.5, by + 14), Vector2(bx + 9 + shake, by + 6), COL_TRUNK_WOOD, 3.0)
	draw_line(Vector2(bx + 16 + shake * 0.5, by + 14), Vector2(bx + 28 + shake, by + 8), COL_TRUNK_WOOD, 3.0)
	
	# Blossom Canopy Clouds
	draw_circle(Vector2(bx + 8 + shake, by + 4), 10.0, COL_BLOSSOM_PINK)
	draw_circle(Vector2(bx + 26 + shake, by + 6), 11.0, COL_BLOSSOM_PINK)
	draw_circle(Vector2(bx + 17 + shake, by - 2), 9.0, COL_BLOSSOM_LIGHT)
	# Blossom Highlights & Core Petals
	draw_circle(Vector2(bx + 10 + shake, by + 3), 4.0, COL_BLOSSOM_LIGHT)
	draw_circle(Vector2(bx + 24 + shake, by + 5), 5.0, Color(1.0, 1.0, 1.0, 0.9))
	draw_rect(Rect2(bx + 16 + shake, by + 1, 3, 3), COL_BLOSSOM_CORE)

func _draw_monstera_pot(mx: float, my: float) -> void:
	var rustle: float = sin(_anim_clock * 6.0) * 2.0 if _monstera_rustle_timer > 0.0 else 0.0
	
	# Glazed Ceramic Planter
	draw_rect(Rect2(mx + 4, my + 24, 20, 14), Color(0.92, 0.94, 0.95))
	draw_rect(Rect2(mx + 2, my + 22, 24, 3), Color(0.85, 0.88, 0.90))
	draw_rect(Rect2(mx + 5, my + 23, 18, 2), COL_SOIL_DARK)
	
	# Dynamic Growth Stages of Monstera
	if monstera_stage >= 1:
		draw_circle(Vector2(mx + 5 + rustle, my + 14), 7.0, COL_LEAF_MID)
		draw_line(Vector2(mx + 12, my + 24), Vector2(mx + 5 + rustle, my + 14), COL_LEAF_DARK, 2.0)
	if monstera_stage >= 2:
		draw_circle(Vector2(mx + 20 - rustle, my + 10), 8.0, COL_LEAF_LIGHT)
		draw_line(Vector2(mx + 14, my + 24), Vector2(mx + 20 - rustle, my + 10), COL_LEAF_DARK, 2.0)
	if monstera_stage >= 3:
		# Giant Crown Umbrella Leaf
		draw_circle(Vector2(mx + 12, my + 2 + rustle), 9.0, COL_LEAF_DARK)
		draw_circle(Vector2(mx + 12, my + 2 + rustle), 7.0, COL_LEAF_LIGHT)
		draw_line(Vector2(mx + 13, my + 24), Vector2(mx + 12, my + 2 + rustle), COL_LEAF_DARK, 2.0)
		# Glossy Dew Drop
		draw_rect(Rect2(mx + 14, my + 3, 2, 2), Color(0.9, 0.98, 1.0, 0.9))

func _draw_potting_bench(px: float, py: float) -> void:
	# Wooden Work Bench
	draw_rect(Rect2(px, py + 16, 48, 4), COL_BENCH_WOOD)
	draw_rect(Rect2(px, py + 19, 48, 2), COL_BENCH_SHADOW)
	draw_rect(Rect2(px + 2, py + 20, 3, 18), COL_BENCH_WOOD)
	draw_rect(Rect2(px + 43, py + 20, 3, 18), COL_BENCH_WOOD)
	
	# Plant 1: Golden Orchid (Stage 0 to 3)
	_draw_growing_plant(px + 6, py + 10, plant_1_stage, "orchid")
	
	# Plant 2: Azure Hydrangea (Stage 0 to 3)
	_draw_growing_plant(px + 20, py + 10, plant_2_stage, "hydrangea")
	
	# Glass / Metal Watering Can
	if not is_watering:
		draw_rect(Rect2(px + 34, py + 7, 10, 9), COL_WATERING_CAN)
		draw_line(Vector2(px + 44, py + 12), Vector2(px + 49, py + 4), Color(0.35, 0.68, 0.85), 2.0)
		draw_rect(Rect2(px + 32, py + 6, 2, 8), Color(0.28, 0.55, 0.72))

func _draw_growing_plant(gx: float, gy: float, stage: int, type: String) -> void:
	# Terracotta Pot
	draw_rect(Rect2(gx, gy, 8, 6), COL_POT_TERRACOTTA)
	draw_rect(Rect2(gx - 1, gy - 1, 10, 2), COL_POT_SHADOW)
	draw_rect(Rect2(gx + 1, gy, 6, 1), COL_SOIL_DARK)
	
	match stage:
		0:
			# Tiny Green Sprout
			draw_line(Vector2(gx + 4, gy), Vector2(gx + 4, gy - 3), COL_LEAF_LIGHT, 1.0)
			draw_rect(Rect2(gx + 4, gy - 4, 2, 1), COL_LEAF_LIGHT)
		1:
			# Young Stem & 2 Leaves
			draw_line(Vector2(gx + 4, gy), Vector2(gx + 4, gy - 6), COL_LEAF_MID, 1.0)
			draw_circle(Vector2(gx + 2, gy - 4), 2.0, COL_LEAF_LIGHT)
			draw_circle(Vector2(gx + 6, gy - 5), 2.0, COL_LEAF_LIGHT)
		2:
			# Budding Foliage
			draw_line(Vector2(gx + 4, gy), Vector2(gx + 4, gy - 9), COL_LEAF_DARK, 2.0)
			draw_circle(Vector2(gx + 1, gy - 5), 3.0, COL_LEAF_MID)
			draw_circle(Vector2(gx + 7, gy - 7), 3.0, COL_LEAF_LIGHT)
			# Unopened Bud
			draw_rect(Rect2(gx + 3, gy - 11, 3, 3), COL_ORCHID_ORANGE if type == "orchid" else COL_HYDRANGEA_PURPLE)
		3:
			# FULL MAJESTIC BLOOM
			draw_line(Vector2(gx + 4, gy), Vector2(gx + 4, gy - 10), COL_LEAF_DARK, 2.0)
			draw_circle(Vector2(gx, gy - 6), 3.0, COL_LEAF_MID)
			draw_circle(Vector2(gx + 8, gy - 6), 3.0, COL_LEAF_MID)
			
			if type == "orchid":
				# Radiant Golden Orchid Petals
				draw_circle(Vector2(gx + 4, gy - 12), 4.0, COL_ORCHID_GOLD)
				draw_circle(Vector2(gx + 1, gy - 11), 3.0, COL_ORCHID_ORANGE)
				draw_circle(Vector2(gx + 7, gy - 11), 3.0, COL_ORCHID_ORANGE)
				draw_rect(Rect2(gx + 3, gy - 13, 2, 2), Color(1.0, 1.0, 1.0, 0.9))
			else:
				# Giant Azure Hydrangea Dome
				draw_circle(Vector2(gx + 4, gy - 12), 5.0, COL_HYDRANGEA_BLUE)
				draw_circle(Vector2(gx + 1, gy - 10), 3.5, COL_HYDRANGEA_PURPLE)
				draw_circle(Vector2(gx + 7, gy - 10), 3.5, COL_HYDRANGEA_BLUE)
				draw_circle(Vector2(gx + 4, gy - 14), 3.0, Color(0.85, 0.92, 1.0))

func _draw_watering_action(target_x_pos: float) -> void:
	var can_x: float = target_x_pos + 4.0
	var can_y: float = 64.0
	
	# Tilted Watering Can
	draw_rect(Rect2(can_x, can_y, 9, 8), COL_WATERING_CAN)
	draw_line(Vector2(can_x - 1, can_y + 6), Vector2(can_x - 6, can_y + 11), Color(0.35, 0.68, 0.85), 2.0)
	
	# Animated Water Stream & Pouring Droplets
	var drop_frame = int(_anim_clock * 4.0) % 3
	draw_line(Vector2(can_x - 6, can_y + 11), Vector2(target_x_pos + 4, 82.0), COL_WATER_DROP, 1.0)
	draw_rect(Rect2(target_x_pos + 2 + drop_frame, 80 + drop_frame, 2, 2), COL_WATER_DROP)
	draw_rect(Rect2(target_x_pos + 5 - drop_frame, 78 + drop_frame, 2, 2), COL_WATER_DROP)
	# Sprout Sparkles
	draw_rect(Rect2(target_x_pos + 1, 74, 2, 2), Color(0.4, 1.0, 0.6, 0.8))
	draw_rect(Rect2(target_x_pos + 7, 72, 2, 2), Color(1.0, 1.0, 0.5, 0.8))
