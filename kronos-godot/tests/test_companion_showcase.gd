extends Control

const SPECIES_LIST = [
	{"id": "shiba", "name": "Kronos", "title": "Shiba Inu", "desc": "Loyal, focused terminal typist"},
	{"id": "cat", "name": "Mochi", "title": "Calico Cat", "desc": "Gentle screen watcher & groomer"},
	{"id": "bunny", "name": "Boba", "title": "Snowy Bunny", "desc": "Tea sip & bouncy ear hops"},
	{"id": "penguin", "name": "Pippin", "title": "Chubby Penguin", "desc": "Waddle slide & flipper tap"},
	{"id": "fox", "name": "Kitsune", "title": "Amber Fox", "desc": "Sleek pounce & grimoire scholar"},
	{"id": "redpanda", "name": "Rory", "title": "Red Panda", "desc": "Striped ringtail & bamboo snack"},
	{"id": "capybara", "name": "Cappy", "title": "Zen Capybara", "desc": "Yuzu fruit balance & onsen soak"},
	{"id": "owl", "name": "Barnaby", "title": "Scholar Owl", "desc": "Facial disc & ancient grimoire"}
]

const STATES = [
	{"name": "IDLE", "state": PetRenderer.AnimState.IDLE},
	{"name": "WALK", "state": PetRenderer.AnimState.WALK},
	{"name": "NAP", "state": PetRenderer.AnimState.NAP},
	{"name": "VICTORY", "state": PetRenderer.AnimState.VICTORY}
]

var current_state_idx: int = 0
var auto_cycle: bool = true
var cycle_timer: float = 0.0
var cycle_interval: float = 3.5

var pet_renderers: Array[PetRenderer] = []
var state_labels: Array[Label] = []
var status_banner: Label

func _ready() -> void:
	# Configure window for clear desktop inspection
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_title("🐾 Kronos — 8-Companion 32x32 Authentic Pixel Art Showcase")
	DisplayServer.window_set_size(Vector2i(980, 640))
	
	_build_ui()
	_update_all_states()
	
	# Schedule an automated screenshot capture after 1.0 second
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(_capture_preview_screenshot)

func _process(delta: float) -> void:
	if auto_cycle:
		cycle_timer += delta
		if cycle_timer >= cycle_interval:
			cycle_timer = 0.0
			current_state_idx = (current_state_idx + 1) % STATES.size()
			_update_all_states()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				current_state_idx = 0
				auto_cycle = false
				_update_all_states()
			KEY_2:
				current_state_idx = 1
				auto_cycle = false
				_update_all_states()
			KEY_3:
				current_state_idx = 2
				auto_cycle = false
				_update_all_states()
			KEY_4:
				current_state_idx = 3
				auto_cycle = false
				_update_all_states()
			KEY_SPACE:
				auto_cycle = not auto_cycle
				cycle_timer = 0.0
				_update_status_banner()
			KEY_F:
				for pr in pet_renderers:
					pr.facing_right = not pr.facing_right
			KEY_ESCAPE:
				get_tree().quit(0)

func _update_all_states() -> void:
	var state_info = STATES[current_state_idx]
	for pr in pet_renderers:
		pr.current_state = state_info["state"]
	
	for i in range(state_labels.size()):
		state_labels[i].text = "[%s]" % state_info["name"]
		
	_update_status_banner()

func _update_status_banner() -> void:
	if status_banner:
		var mode_str = "AUTO-CYCLE (3.5s)" if auto_cycle else "MANUAL LOCKED"
		var cur_name = STATES[current_state_idx]["name"]
		status_banner.text = "Current State: %s  |  Mode: %s  |  Keys: [1] Idle  [2] Walk  [3] Nap  [4] Victory  |  [Space] Toggle Auto  [F] Flip  [Esc] Exit" % [cur_name, mode_str]

func _build_ui() -> void:
	# Root dark background
	var bg = ColorRect.new()
	bg.color = Color(0.06, 0.07, 0.11, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.add_theme_constant_override("separation", 10)
	main_vbox.offset_left = 16
	main_vbox.offset_top = 14
	main_vbox.offset_right = -16
	main_vbox.offset_bottom = -14
	add_child(main_vbox)
	
	# Header
	var title_lbl = Label.new()
	title_lbl.text = "🐾 KRONOS COMPANION OVERHAUL GALLERY — 32×32 AUTHENTIC PIXEL ART"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 16)
	title_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.35))
	main_vbox.add_child(title_lbl)
	
	status_banner = Label.new()
	status_banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_banner.add_theme_font_size_override("font_size", 11)
	status_banner.add_theme_color_override("font_color", Color(0.65, 0.72, 0.85))
	main_vbox.add_child(status_banner)
	
	# 8-Pet Grid Container (4 columns x 2 rows)
	var grid = GridContainer.new()
	grid.columns = 4
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	main_vbox.add_child(grid)
	
	for sp in SPECIES_LIST:
		var card = _create_pet_card(sp)
		grid.add_child(card)

func _create_pet_card(sp_data: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	# Card styling
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.12, 0.18, 0.95)
	style.border_color = Color(0.24, 0.28, 0.40, 1.0)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_left = 8
	style.content_margin_top = 8
	style.content_margin_right = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	panel.add_child(vbox)
	
	# Name & Title
	var header_hbox = HBoxContainer.new()
	var name_lbl = Label.new()
	name_lbl.text = "%s (%s)" % [sp_data["name"], sp_data["title"]]
	name_lbl.add_theme_font_size_override("font_size", 12)
	name_lbl.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(name_lbl)
	
	var state_badge = Label.new()
	state_badge.text = "[IDLE]"
	state_badge.add_theme_font_size_override("font_size", 10)
	state_badge.add_theme_color_override("font_color", Color(0.35, 0.85, 0.55))
	header_hbox.add_child(state_badge)
	state_labels.append(state_badge)
	vbox.add_child(header_hbox)
	
	# Viewport container for crisp nearest-neighbor scaled pet
	var viewport_box = Control.new()
	viewport_box.custom_minimum_size = Vector2(100, 120)
	viewport_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(viewport_box)
	
	# Shadow floor graphic
	var shadow = ColorRect.new()
	shadow.color = Color(0.04, 0.05, 0.08, 0.6)
	shadow.size = Vector2(80, 16)
	shadow.position = Vector2(60, 95)
	viewport_box.add_child(shadow)
	
	# Scaled Pet Node
	var renderer = PetRenderer.new()
	renderer.species = sp_data["id"]
	renderer.current_state = PetRenderer.AnimState.IDLE
	renderer.scale = Vector2(3.2, 3.2) # 3.2x crisp zoom
	renderer.position = Vector2(100, 100) # center of box
	renderer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	viewport_box.add_child(renderer)
	pet_renderers.append(renderer)
	
	# Subtitle / description
	var desc_lbl = Label.new()
	desc_lbl.text = sp_data["desc"]
	desc_lbl.add_theme_font_size_override("font_size", 9)
	desc_lbl.add_theme_color_override("font_color", Color(0.55, 0.60, 0.75))
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_lbl)
	
	return panel

func _capture_preview_screenshot() -> void:
	var vp = get_viewport()
	if vp:
		var tex = vp.get_texture()
		if tex:
			var image = tex.get_image()
			if image:
				var target_path = "res://tests/companion_showcase_preview.png"
				var abs_target = ProjectSettings.globalize_path(target_path)
				image.save_png(abs_target)
				print("📸 Companion Showcase Preview captured -> %s" % abs_target)
