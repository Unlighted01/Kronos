@tool
extends Node2D
class_name CosmeticLayer

## Cosmetic Accessory Renderer for Kronos Pet Companion.
## Dynamically layers pixel-art accessories (Crown, Sunglasses, Wizard Hat, Bowtie)
## aligned to the pet's active animation state and head/neck anchors.

# ==============================================================================
# 🎨 COLOR PALETTE (Accessories)
# ==============================================================================
# 👑 Golden Crown
const COL_GOLD_MAIN: Color = Color(1.0, 0.84, 0.0, 1.0)      # Sparkling Gold
const COL_GOLD_SHADOW: Color = Color(0.85, 0.65, 0.0, 1.0)   # Gold Shadow
const COL_RUBY_RED: Color = Color(0.92, 0.15, 0.25, 1.0)     # Crown Gem
const COL_SHINE_WHITE: Color = Color(1.0, 1.0, 1.0, 0.9)     # Highlight

# 🕶️ Sunglasses
const COL_SHADES_FRAME: Color = Color(0.10, 0.10, 0.12, 1.0) # Dark Frame
const COL_SHADES_LENS: Color = Color(0.20, 0.22, 0.28, 0.95) # Dark Tinted Lens
const COL_SHADES_GLARE: Color = Color(1.0, 1.0, 1.0, 0.8)    # White Glare Streak

# 🧙 Wizard Hat
const COL_WIZARD_FABRIC: Color = Color(0.32, 0.20, 0.55, 1.0)# Mystic Purple
const COL_WIZARD_DARK: Color = Color(0.22, 0.12, 0.40, 1.0)  # Deep Shadow
const COL_WIZARD_BAND: Color = Color(0.95, 0.78, 0.20, 1.0)  # Gold Buckle Band
const COL_WIZARD_STAR: Color = Color(0.45, 0.85, 1.0, 1.0)   # Magic Star

# 🎀 Red Bowtie
const COL_BOW_MAIN: Color = Color(0.88, 0.18, 0.26, 1.0)     # Satin Red
const COL_BOW_SHADOW: Color = Color(0.65, 0.10, 0.18, 1.0)   # Bow Shadow
const COL_BOW_KNOT: Color = Color(0.95, 0.28, 0.35, 1.0)     # Center Knot Highlight

# ==============================================================================
# 🎛️ REFERENCES & STATE
# ==============================================================================
@export var pet_renderer: PetRenderer

# Active equipped cosmetics (by slot or ID)
var equipped_items: Dictionary = {} # {"head": "cosmetic_crown", "face": "cosmetic_shades", "neck": "cosmetic_bow"}

# Sparkle animation timer for crown / wizard hat
var _sparkle_timer: float = 0.0
var _sparkle_frame: int = 0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	# Connect to EventBus signals
	if not Engine.is_editor_hint():
		EventBus.cosmetic_equipped.connect(_on_cosmetic_equipped)
		EventBus.cosmetic_unequipped.connect(_on_cosmetic_unequipped)
		_sync_from_game_state()
		
	if not pet_renderer:
		pet_renderer = get_parent().get_node_or_null("PetRenderer")

func _process(delta: float) -> void:
	_sparkle_timer += delta
	if _sparkle_timer >= 0.3:
		_sparkle_timer = 0.0
		_sparkle_frame = (_sparkle_frame + 1) % 4
	queue_redraw()

func _sync_from_game_state() -> void:
	if not GameState:
		return
	equipped_items.clear()
	for slot in GameState.equipped_cosmetics:
		equipped_items[slot] = GameState.equipped_cosmetics[slot]
		
	# Check legacy single slot
	if GameState.equipped_cosmetic != "" and not equipped_items.values().has(GameState.equipped_cosmetic):
		var item_def = GameState.ITEM_DEFINITIONS.get(GameState.equipped_cosmetic, {})
		var slot = item_def.get("slot", "head")
		equipped_items[slot] = GameState.equipped_cosmetic
		
	queue_redraw()

func _on_cosmetic_equipped(slot: String, cosmetic_id: String) -> void:
	equipped_items[slot] = cosmetic_id
	queue_redraw()

func _on_cosmetic_unequipped(slot: String) -> void:
	equipped_items.erase(slot)
	queue_redraw()

# ==============================================================================
# 🎨 CUSTOM CANVAS DRAWING
# ==============================================================================
func _draw() -> void:
	if not pet_renderer:
		return
		
	var state = pet_renderer.current_state
	var frame = pet_renderer.anim_frame
	var facing_right = pet_renderer.facing_right
	var flip: float = 1.0 if facing_right else -1.0
	
	# Compute dynamic anchor points based on pet animation
	var head_pos: Vector2 = _get_head_anchor(state, frame)
	var neck_pos: Vector2 = _get_neck_anchor(state, frame)
	
	# Apply flip transform
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(flip, 1.0))
	
	# Render equipped cosmetics
	for slot in equipped_items:
		var item_id: String = equipped_items[slot]
		match item_id:
			"cosmetic_crown":
				_draw_golden_crown(head_pos, state)
			"cosmetic_wizard":
				_draw_wizard_hat(head_pos, state)
			"cosmetic_beanie":
				_draw_slouch_beanie(head_pos, state)
			"cosmetic_chef":
				_draw_chef_hat(head_pos, state)
			"cosmetic_cap":
				_draw_baseball_cap(head_pos, state)
			"cosmetic_shades":
				_draw_cool_sunglasses(head_pos, state)
			"cosmetic_glasses":
				_draw_round_glasses(head_pos, state)
			"cosmetic_monocle":
				_draw_brass_monocle(head_pos, state)
			"cosmetic_bow":
				_draw_red_bowtie(neck_pos, state)
			"cosmetic_scarf":
				_draw_plaid_scarf(neck_pos, state)
			"cosmetic_bell":
				_draw_bell_collar(neck_pos, state)
			"cosmetic_laurel_wreath":
				_draw_laurel_wreath(head_pos, state)

# ==============================================================================
# 📍 DYNAMIC ANCHOR POSITIONS
# ==============================================================================
func _get_head_anchor(state: PetRenderer.AnimState, frame: int) -> Vector2:
	match state:
		PetRenderer.AnimState.IDLE:
			var bob: float = -1.0 if (frame == 1 or frame == 2) else 0.0
			return Vector2(2, -14 + bob)
		PetRenderer.AnimState.WALK:
			var bob: float = -2.0 if (frame == 1 or frame == 3) else 0.0
			return Vector2(3, -14 + bob)
		PetRenderer.AnimState.TYPE:
			return Vector2(0, -13)
		PetRenderer.AnimState.DRINK:
			return Vector2(0, -13)
		PetRenderer.AnimState.NAP:
			return Vector2(6, -8)
		PetRenderer.AnimState.PETTED:
			var bob: float = -1.0 if (frame % 2 == 1) else 0.0
			return Vector2(2, -15 + bob)
		PetRenderer.AnimState.VICTORY:
			var hop: float = -6.0 if (frame == 1 or frame == 2 or frame == 4) else 0.0
			return Vector2(0, -17 + hop)
	return Vector2(2, -14)

func _get_neck_anchor(state: PetRenderer.AnimState, frame: int) -> Vector2:
	match state:
		PetRenderer.AnimState.IDLE:
			var bob: float = -1.0 if (frame == 1 or frame == 2) else 0.0
			return Vector2(2, -6 + bob)
		PetRenderer.AnimState.WALK:
			var bob: float = -2.0 if (frame == 1 or frame == 3) else 0.0
			return Vector2(3, -6 + bob)
		PetRenderer.AnimState.TYPE:
			return Vector2(0, -5)
		PetRenderer.AnimState.DRINK:
			return Vector2(0, -5)
		PetRenderer.AnimState.NAP:
			return Vector2(4, -3)
		PetRenderer.AnimState.PETTED:
			var bob: float = -1.0 if (frame % 2 == 1) else 0.0
			return Vector2(2, -7 + bob)
		PetRenderer.AnimState.VICTORY:
			var hop: float = -6.0 if (frame == 1 or frame == 2 or frame == 4) else 0.0
			return Vector2(0, -9 + hop)
	return Vector2(2, -6)

# ==============================================================================
# 👑 1. GOLDEN CROWN
# ==============================================================================
func _draw_golden_crown(head_pos: Vector2, state: PetRenderer.AnimState) -> void:
	if state == PetRenderer.AnimState.NAP:
		# Resting sideways when sleeping
		_draw_crown_sideways(head_pos)
		return
		
	var cx: float = head_pos.x - 2
	var cy: float = head_pos.y - 7
	
	# Crown Base Band
	draw_rect(Rect2(cx - 4, cy + 2, 10, 2), COL_GOLD_MAIN)
	draw_rect(Rect2(cx - 4, cy + 3, 10, 1), COL_GOLD_SHADOW)
	
	# 3 Crown Peaks
	draw_rect(Rect2(cx - 4, cy - 1, 2, 3), COL_GOLD_MAIN) # Left peak
	draw_rect(Rect2(cx, cy - 3, 2, 5), COL_GOLD_MAIN)     # Center tall peak
	draw_rect(Rect2(cx + 4, cy - 1, 2, 3), COL_GOLD_MAIN) # Right peak
	
	# Center Ruby Gem
	draw_rect(Rect2(cx, cy + 1, 2, 2), COL_RUBY_RED)
	
	# Sparkle highlight
	if _sparkle_frame == 0 or _sparkle_frame == 1:
		draw_rect(Rect2(cx + 1, cy - 4, 1, 1), COL_SHINE_WHITE)

func _draw_crown_sideways(pos: Vector2) -> void:
	# Tilted crown resting beside sleeping shiba
	var cx: float = pos.x + 3
	var cy: float = pos.y - 5
	draw_rect(Rect2(cx, cy, 6, 2), COL_GOLD_MAIN)
	draw_rect(Rect2(cx + 1, cy - 2, 2, 2), COL_GOLD_MAIN)
	draw_rect(Rect2(cx + 4, cy - 2, 2, 2), COL_GOLD_MAIN)
	draw_rect(Rect2(cx + 2, cy + 1, 2, 1), COL_RUBY_RED)

# ==============================================================================
# 🕶️ 2. COOL SUNGLASSES
# ==============================================================================
func _draw_cool_sunglasses(head_pos: Vector2, state: PetRenderer.AnimState) -> void:
	if state == PetRenderer.AnimState.NAP:
		return # Hidden when eyes are closed in sleep
		
	var sx: float = head_pos.x
	var sy: float = head_pos.y
	
	# Left Lens & Frame
	draw_rect(Rect2(sx - 3, sy - 2, 5, 4), COL_SHADES_FRAME)
	draw_rect(Rect2(sx - 2, sy - 1, 3, 2), COL_SHADES_LENS)
	draw_rect(Rect2(sx - 2, sy - 1, 1, 2), COL_SHADES_GLARE) # White glare
	
	# Bridge
	draw_rect(Rect2(sx + 2, sy - 1, 2, 1), COL_SHADES_FRAME)
	
	# Right Lens & Frame
	draw_rect(Rect2(sx + 3, sy - 2, 5, 4), COL_SHADES_FRAME)
	draw_rect(Rect2(sx + 4, sy - 1, 3, 2), COL_SHADES_LENS)
	draw_rect(Rect2(sx + 4, sy - 1, 1, 2), COL_SHADES_GLARE) # White glare
	
	# Frame Arms
	draw_rect(Rect2(sx - 6, sy - 2, 3, 1), COL_SHADES_FRAME)

# ==============================================================================
# 🧙 3. WIZARD HAT
# ==============================================================================
func _draw_wizard_hat(head_pos: Vector2, state: PetRenderer.AnimState) -> void:
	if state == PetRenderer.AnimState.NAP:
		# Resting behind pet when napping
		var hx: float = head_pos.x + 2
		var hy: float = head_pos.y - 4
		draw_rect(Rect2(hx - 6, hy, 14, 2), COL_WIZARD_FABRIC)
		draw_rect(Rect2(hx - 3, hy - 4, 7, 4), COL_WIZARD_FABRIC)
		return
		
	var wx: float = head_pos.x
	var wy: float = head_pos.y - 7
	
	# Wide Brim
	draw_rect(Rect2(wx - 7, wy + 2, 16, 2), COL_WIZARD_FABRIC)
	draw_rect(Rect2(wx - 7, wy + 3, 16, 1), COL_WIZARD_DARK)
	
	# Gold Buckle Band
	draw_rect(Rect2(wx - 4, wy + 1, 10, 2), COL_WIZARD_BAND)
	draw_rect(Rect2(wx, wy + 1, 2, 2), Color(1.0, 0.95, 0.5, 1.0))
	
	# Cone Body (Stepped pixel pyramid)
	draw_rect(Rect2(wx - 4, wy - 3, 9, 4), COL_WIZARD_FABRIC)
	draw_rect(Rect2(wx - 3, wy - 6, 7, 3), COL_WIZARD_FABRIC)
	draw_rect(Rect2(wx - 2, wy - 9, 5, 3), COL_WIZARD_FABRIC)
	draw_rect(Rect2(wx - 1, wy - 11, 3, 2), COL_WIZARD_FABRIC)
	# Crooked Hat Tip
	draw_rect(Rect2(wx - 3, wy - 13, 3, 2), COL_WIZARD_FABRIC)
	draw_rect(Rect2(wx - 4, wy - 14, 2, 2), COL_WIZARD_BAND) # Star on tip
	
	# Star on Hat
	draw_rect(Rect2(wx + 1, wy - 4, 2, 2), COL_WIZARD_STAR)

# ==============================================================================
# 🎀 4. RED BOWTIE
# ==============================================================================
func _draw_red_bowtie(neck_pos: Vector2, _state: PetRenderer.AnimState) -> void:
	var bx: float = neck_pos.x
	var by: float = neck_pos.y
	
	# Left Wing (stepped bow loop)
	draw_rect(Rect2(bx - 4, by - 2, 3, 4), COL_BOW_MAIN)
	draw_rect(Rect2(bx - 3, by - 1, 2, 2), COL_BOW_SHADOW)
	
	# Right Wing
	draw_rect(Rect2(bx + 2, by - 2, 3, 4), COL_BOW_MAIN)
	draw_rect(Rect2(bx + 2, by - 1, 2, 2), COL_BOW_SHADOW)
	
	# Center Knot
	draw_rect(Rect2(bx - 1, by - 1, 3, 3), COL_BOW_KNOT)

# ==============================================================================
# 🧶 5. SLOUCH BEANIE
# ==============================================================================
func _draw_slouch_beanie(head_pos: Vector2, state: PetRenderer.AnimState) -> void:
	if state == PetRenderer.AnimState.NAP:
		var bx: float = head_pos.x + 2
		var by: float = head_pos.y - 4
		draw_rect(Rect2(bx - 5, by, 12, 3), Color(0.85, 0.40, 0.20))
		draw_rect(Rect2(bx - 3, by - 3, 8, 3), Color(0.70, 0.30, 0.15))
		return
		
	var bx: float = head_pos.x
	var by: float = head_pos.y - 7
	
	# Folded Ribbed Brim
	draw_rect(Rect2(bx - 5, by + 1, 12, 3), Color(0.88, 0.45, 0.22))
	draw_rect(Rect2(bx - 5, by + 3, 12, 1), Color(0.68, 0.30, 0.12))
	# Slouchy Crown
	draw_rect(Rect2(bx - 6, by - 3, 11, 4), Color(0.82, 0.38, 0.18))
	draw_rect(Rect2(bx - 7, by - 6, 9, 3), Color(0.75, 0.32, 0.15))
	# Cute Pompom
	draw_rect(Rect2(bx - 9, by - 5, 3, 3), Color(0.98, 0.95, 0.90))

# ==============================================================================
# 👨‍🍳 6. TOQUE CHEF HAT
# ==============================================================================
func _draw_chef_hat(head_pos: Vector2, state: PetRenderer.AnimState) -> void:
	if state == PetRenderer.AnimState.NAP:
		var cx: float = head_pos.x + 3
		var cy: float = head_pos.y - 4
		draw_rect(Rect2(cx - 4, cy, 10, 3), Color(0.95, 0.96, 0.98))
		draw_rect(Rect2(cx - 3, cy - 4, 8, 4), Color(0.82, 0.85, 0.90))
		return
		
	var cx: float = head_pos.x
	var cy: float = head_pos.y - 7
	
	# Headband
	draw_rect(Rect2(cx - 4, cy + 1, 10, 3), Color(0.90, 0.92, 0.95))
	draw_rect(Rect2(cx - 4, cy + 3, 10, 1), Color(0.70, 0.74, 0.80))
	# Puffy Cloud Top
	draw_rect(Rect2(cx - 6, cy - 4, 13, 5), Color(0.98, 0.98, 1.0))
	draw_rect(Rect2(cx - 5, cy - 7, 11, 3), Color(0.95, 0.96, 0.98))
	# Pleat lines
	draw_rect(Rect2(cx - 3, cy - 3, 1, 3), Color(0.80, 0.84, 0.90))
	draw_rect(Rect2(cx + 1, cy - 3, 1, 3), Color(0.80, 0.84, 0.90))

# ==============================================================================
# 🧢 7. BASEBALL CAP
# ==============================================================================
func _draw_baseball_cap(head_pos: Vector2, state: PetRenderer.AnimState) -> void:
	if state == PetRenderer.AnimState.NAP:
		return
		
	var cx: float = head_pos.x
	var cy: float = head_pos.y - 7
	
	# Cap Dome
	draw_rect(Rect2(cx - 5, cy - 2, 11, 5), Color(0.18, 0.32, 0.65))
	draw_rect(Rect2(cx - 4, cy - 4, 9, 2), Color(0.18, 0.32, 0.65))
	# Top button
	draw_rect(Rect2(cx, cy - 5, 2, 1), Color(0.85, 0.20, 0.25))
	# Backwards Visor Bill
	draw_rect(Rect2(cx - 9, cy + 1, 5, 2), Color(0.85, 0.20, 0.25))
	draw_rect(Rect2(cx - 9, cy + 2, 5, 1), Color(0.65, 0.12, 0.18))

# ==============================================================================
# 👓 8. ROUND GLASSES
# ==============================================================================
func _draw_round_glasses(head_pos: Vector2, state: PetRenderer.AnimState) -> void:
	if state == PetRenderer.AnimState.NAP:
		return
		
	var gx: float = head_pos.x
	var gy: float = head_pos.y
	var col_gold: Color = Color(0.95, 0.80, 0.25)
	var col_shine: Color = Color(1.0, 1.0, 1.0, 0.65)
	
	# Left Frame Ring
	draw_rect(Rect2(gx - 3, gy - 2, 4, 4), col_gold)
	draw_rect(Rect2(gx - 2, gy - 1, 2, 2), Color(0.1, 0.1, 0.15, 0.2))
	draw_rect(Rect2(gx - 2, gy - 1, 1, 1), col_shine)
	
	# Bridge
	draw_rect(Rect2(gx + 1, gy - 1, 2, 1), col_gold)
	
	# Right Frame Ring
	draw_rect(Rect2(gx + 3, gy - 2, 4, 4), col_gold)
	draw_rect(Rect2(gx + 4, gy - 1, 2, 2), Color(0.1, 0.1, 0.15, 0.2))
	draw_rect(Rect2(gx + 4, gy - 1, 1, 1), col_shine)
	
	# Temples
	draw_rect(Rect2(gx - 5, gy - 1, 2, 1), col_gold)

# ==============================================================================
# 🧐 9. BRASS MONOCLE
# ==============================================================================
func _draw_brass_monocle(head_pos: Vector2, state: PetRenderer.AnimState) -> void:
	if state == PetRenderer.AnimState.NAP:
		return
		
	var mx: float = head_pos.x + 3
	var my: float = head_pos.y
	var col_brass: Color = Color(0.92, 0.72, 0.20)
	
	# Monocle Rim
	draw_rect(Rect2(mx - 1, my - 2, 5, 5), col_brass)
	draw_rect(Rect2(mx, my - 1, 3, 3), Color(0.8, 0.9, 1.0, 0.35))
	draw_rect(Rect2(mx, my - 1, 1, 1), Color(1.0, 1.0, 1.0, 0.85))
	
	# Dangling Chain
	draw_rect(Rect2(mx + 3, my + 2, 1, 3), col_brass)
	draw_rect(Rect2(mx + 2, my + 5, 1, 2), col_brass)

# ==============================================================================
# 🧣 10. PLAID SCARF
# ==============================================================================
func _draw_plaid_scarf(neck_pos: Vector2, _state: PetRenderer.AnimState) -> void:
	var sx: float = neck_pos.x
	var sy: float = neck_pos.y
	var col_green: Color = Color(0.18, 0.48, 0.30)
	var col_gold: Color = Color(0.95, 0.78, 0.22)
	
	# Main Scarf Loop around neck
	draw_rect(Rect2(sx - 5, sy - 2, 12, 4), col_green)
	draw_rect(Rect2(sx - 3, sy - 2, 1, 4), col_gold)
	draw_rect(Rect2(sx + 2, sy - 2, 1, 4), col_gold)
	draw_rect(Rect2(sx - 5, sy - 1, 12, 1), col_gold)
	
	# Draping Scarf Tail
	draw_rect(Rect2(sx - 4, sy + 1, 4, 6), col_green)
	draw_rect(Rect2(sx - 3, sy + 1, 1, 6), col_gold)
	# Tassels
	draw_rect(Rect2(sx - 4, sy + 7, 1, 2), col_gold)
	draw_rect(Rect2(sx - 2, sy + 7, 1, 2), col_gold)

# ==============================================================================
# 🔔 11. BELL COLLAR
# ==============================================================================
func _draw_bell_collar(neck_pos: Vector2, _state: PetRenderer.AnimState) -> void:
	var bx: float = neck_pos.x
	var by: float = neck_pos.y
	var col_band: Color = Color(0.85, 0.18, 0.22)
	var col_gold: Color = Color(1.0, 0.84, 0.0)
	
	# Collar Band
	draw_rect(Rect2(bx - 4, by - 2, 10, 2), col_band)
	
	# Golden Bell
	draw_rect(Rect2(bx - 1, by, 3, 3), col_gold)
	draw_rect(Rect2(bx, by + 1, 1, 1), Color(0.3, 0.15, 0.0))
	draw_rect(Rect2(bx, by - 1, 1, 1), col_gold) # Loop

# ==============================================================================
# 🌿 12. GOLDEN LAUREL WREATH
# ==============================================================================
func _draw_laurel_wreath(head_pos: Vector2, _state: PetRenderer.AnimState) -> void:
	var lx: float = head_pos.x
	var ly: float = head_pos.y - 1
	var col_gold: Color = Color(1.0, 0.84, 0.0)
	var col_gold_light: Color = Color(1.0, 0.96, 0.5)
	var col_gold_shadow: Color = Color(0.78, 0.55, 0.0)
	
	# Circular Golden Crown Branch Band
	draw_rect(Rect2(lx - 6, ly, 12, 1), col_gold_shadow)
	
	# Left Leaves
	draw_rect(Rect2(lx - 7, ly - 2, 2, 2), col_gold)
	draw_rect(Rect2(lx - 8, ly - 1, 1, 1), col_gold_light)
	draw_rect(Rect2(lx - 5, ly - 3, 2, 2), col_gold)
	draw_rect(Rect2(lx - 4, ly - 2, 1, 1), col_gold_light)
	
	# Right Leaves
	draw_rect(Rect2(lx + 5, ly - 2, 2, 2), col_gold)
	draw_rect(Rect2(lx + 7, ly - 1, 1, 1), col_gold_light)
	draw_rect(Rect2(lx + 3, ly - 3, 2, 2), col_gold)
	draw_rect(Rect2(lx + 3, ly - 2, 1, 1), col_gold_light)
	
	# Center Gem Ribbon
	draw_rect(Rect2(lx - 1, ly - 1, 2, 2), Color(0.92, 0.15, 0.25))
