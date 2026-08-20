extends Control
class_name WindowController

## Frameless Desktop Window & Layout Controller for Kronos.
## Manages borderless dragging, 1x/1.25x/1.5x scaling, screen-edge clamping,
## and dynamic 3-panel workspace layouts (LeftPanel, MiddlePanel, RightPanel).

# ==============================================================================
# 📐 CONSTANTS & BASE DIMENSIONS (1x scale)
# ==============================================================================
const BASE_MIDDLE_WIDTH: int = 240
const BASE_LEFT_WIDTH: int = 235
const BASE_RIGHT_WIDTH: int = 200
const BASE_HEIGHT: int = 320

const SCALE_PRESETS: Array[float] = [1.0, 1.25, 1.5]
const SCALE_LABELS: Array[String] = ["1x", "1.25x", "1.5x"]

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var main_container: HBoxContainer = $MainContainer
@onready var left_panel_container: Control = $MainContainer/LeftPanel
@onready var middle_panel_container: PanelContainer = $MainContainer/MiddlePanel
@onready var right_panel_container: Control = $MainContainer/RightPanel

# Middle Panel Header UI
@onready var drag_header: PanelContainer = $MainContainer/MiddlePanel/VBox/HeaderBar
@onready var toggle_left_btn: Button = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/ToggleLeftButton
@onready var toggle_right_btn: Button = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/ToggleRightButton
@onready var level_label: Label = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/LevelLabel
@onready var title_label: Label = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/TitleLabel
@onready var scale_btn: Button = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/ScaleButton
@onready var pin_btn: Button = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/PinButton
@onready var close_btn: Button = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/CloseButton

# HUD Stats
@onready var coins_label: Label = $MainContainer/MiddlePanel/VBox/HUD/HBox/CoinsLabel
@onready var room_label: Label = $MainContainer/MiddlePanel/VBox/HUD/HBox/RoomStatusContainer/RoomLabel
@onready var call_pet_btn: Button = $MainContainer/MiddlePanel/VBox/HUD/HBox/RoomStatusContainer/CallPetButton
@onready var energy_bar: ProgressBar = $MainContainer/MiddlePanel/VBox/HUD/HBox/EnergyBar
@onready var joy_bar: ProgressBar = $MainContainer/MiddlePanel/VBox/HUD/HBox/JoyBar

# Timer Dock References
@onready var work_tab_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/PhaseTabBar/WorkTabBtn
@onready var short_break_tab_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/PhaseTabBar/ShortBreakTabBtn
@onready var long_break_tab_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/PhaseTabBar/LongBreakTabBtn
@onready var active_task_label: Label = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/ActiveTaskLabel
@onready var timer_label: Label = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/TimerLabel
@onready var play_pause_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/ActionControls/PlayPauseButton
@onready var minigame_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/ActionControls/MinigameButton
@onready var reset_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/ActionControls/ResetButton
@onready var pet_slot: Control = $MainContainer/MiddlePanel/VBox/PetSlot

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var current_scale_index: int = 0 # 0 -> 1.0x, 1 -> 1.25x, 2 -> 1.5x
var is_pinned: bool = false
var is_position_locked: bool = false
var is_left_open: bool = false
var is_right_open: bool = false

# Dragging state
var is_dragging: bool = false
var drag_start_mouse_pos: Vector2i = Vector2i.ZERO
var drag_start_window_pos: Vector2i = Vector2i.ZERO

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	_setup_window()
	_connect_signals()
	_connect_event_bus()
	_update_layout()
	_refresh_ui_from_state()

func _notification(_what: int) -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		var cur_mouse_pos: Vector2i = DisplayServer.mouse_get_position()
		var delta_pos: Vector2i = cur_mouse_pos - drag_start_mouse_pos
		var new_pos: Vector2i = drag_start_window_pos + delta_pos
		var cur_size: Vector2i = DisplayServer.window_get_size(0)
		var clamped: Vector2i = _clamp_to_screen_bounds(new_pos, cur_size)
		DisplayServer.window_set_position(clamped, 0)

func _setup_window() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true, 0)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true, 0)
	
	if middle_panel_container:
		middle_panel_container.visible = true
	if left_panel_container:
		left_panel_container.visible = is_left_open
	if right_panel_container:
		right_panel_container.visible = is_right_open

func _connect_signals() -> void:
	# Header Dragging on HeaderBar and Title Label
	if drag_header:
		drag_header.gui_input.connect(_on_header_gui_input)
	if title_label:
		title_label.gui_input.connect(_on_header_gui_input)
		
	# Window Header Action Buttons
	if toggle_left_btn:
		toggle_left_btn.pressed.connect(toggle_left_panel)
	if toggle_right_btn:
		toggle_right_btn.pressed.connect(toggle_right_panel)
	if scale_btn:
		scale_btn.pressed.connect(cycle_window_scale)
	if pin_btn:
		pin_btn.pressed.connect(toggle_position_lock)
	if close_btn:
		close_btn.pressed.connect(func(): get_tree().quit())
		
	# Call Pet HUD Button
	if call_pet_btn:
		call_pet_btn.pressed.connect(_on_call_pet_pressed)
		
	# Action Controls
	if play_pause_btn:
		play_pause_btn.pressed.connect(func(): TimerEngine.toggle_timer())
	if minigame_btn:
		minigame_btn.pressed.connect(_on_minigame_pressed)
	if reset_btn:
		reset_btn.pressed.connect(func(): TimerEngine.stop_timer())

func _connect_event_bus() -> void:
	EventBus.timer_tick.connect(_on_timer_tick)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.timer_state_changed.connect(_on_timer_state_changed)
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.joy_changed.connect(_on_joy_changed)
	EventBus.streak_changed.connect(_on_streak_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.room_changed.connect(_on_room_changed)
	EventBus.pet_room_changed.connect(_on_pet_room_changed)
	EventBus.pet_called.connect(_on_pet_called)
	EventBus.panel_visibility_changed.connect(_on_panel_visibility_changed)
	EventBus.window_pin_toggled.connect(_on_window_pin_toggled)
	EventBus.active_task_selected.connect(func(_id, title): _update_active_task_display(title))

func _refresh_ui_from_state() -> void:
	if GameState:
		if coins_label:
			coins_label.text = "🪙 %d G" % GameState.coins
		if level_label:
			level_label.text = "Lv.%d" % GameState.level
		if energy_bar:
			energy_bar.value = GameState.energy
		if joy_bar:
			joy_bar.value = GameState.joy
		_update_room_and_pet_hud()
		_update_active_task_display(GameState.get_active_task_title())
			
	if TimerEngine:
		if timer_label:
			timer_label.text = TimerEngine.get_formatted_time()
		_update_phase_tab_styles(TimerEngine.get_phase_string())
		
	if pin_btn:
		pin_btn.modulate = Color(1.0, 0.84, 0.0, 1.0) if is_pinned else Color(1.0, 1.0, 1.0, 0.6)
		pin_btn.text = "📌" if is_pinned else "📍"

func _update_active_task_display(task_title: String) -> void:
	if active_task_label:
		active_task_label.text = "🎯 Focus: " + task_title

# ==============================================================================
# 🖱️ WINDOW DRAGGING
# ==============================================================================
func _on_header_gui_input(event: InputEvent) -> void:
	if is_position_locked:
		return
		
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				is_dragging = true
				drag_start_mouse_pos = DisplayServer.mouse_get_position()
				drag_start_window_pos = DisplayServer.window_get_position(0)
			else:
				is_dragging = false
				if is_pinned:
					_apply_always_on_top(true)
	elif event is InputEventMouseMotion and is_dragging:
		var cur_mouse_pos: Vector2i = DisplayServer.mouse_get_position()
		var delta_pos: Vector2i = cur_mouse_pos - drag_start_mouse_pos
		var new_pos: Vector2i = drag_start_window_pos + delta_pos
		var cur_size: Vector2i = DisplayServer.window_get_size(0)
		var clamped: Vector2i = _clamp_to_screen_bounds(new_pos, cur_size)
		DisplayServer.window_set_position(clamped, 0)

func _clamp_to_screen_bounds(target_pos: Vector2i, window_size: Vector2i) -> Vector2i:
	var screen_id: int = DisplayServer.get_primary_screen()
	var usable_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen_id)
	
	var clamped_x: int = clampi(target_pos.x, usable_rect.position.x, usable_rect.position.x + usable_rect.size.x - window_size.x)
	var clamped_y: int = clampi(target_pos.y, usable_rect.position.y, usable_rect.position.y + usable_rect.size.y - window_size.y)
	
	return Vector2i(clamped_x, clamped_y)

# ==============================================================================
# 📐 SCALING & PANEL TOGGLES
# ==============================================================================
func cycle_window_scale() -> void:
	current_scale_index = (current_scale_index + 1) % SCALE_PRESETS.size()
	_update_layout()

func set_scale_preset(scale_index: int) -> void:
	if scale_index >= 0 and scale_index < SCALE_PRESETS.size():
		current_scale_index = scale_index
		_update_layout()

func toggle_left_panel() -> void:
	is_left_open = not is_left_open
	if left_panel_container:
		left_panel_container.visible = is_left_open
	if toggle_left_btn:
		toggle_left_btn.text = "▶" if is_left_open else "◀"
	EventBus.panel_visibility_changed.emit("left", is_left_open)
	_update_layout()

func toggle_right_panel() -> void:
	is_right_open = not is_right_open
	if right_panel_container:
		right_panel_container.visible = is_right_open
	if toggle_right_btn:
		toggle_right_btn.text = "◀" if is_right_open else "▶"
	EventBus.panel_visibility_changed.emit("right", is_right_open)
	_update_layout()

func _on_panel_visibility_changed(panel_id: String, is_visible: bool) -> void:
	if panel_id == "left" and is_left_open != is_visible:
		is_left_open = is_visible
		if left_panel_container:
			left_panel_container.visible = is_left_open
		if toggle_left_btn:
			toggle_left_btn.text = "▶" if is_left_open else "◀"
		_update_layout()
	elif panel_id == "right" and is_right_open != is_visible:
		is_right_open = is_visible
		if right_panel_container:
			right_panel_container.visible = is_right_open
		if toggle_right_btn:
			toggle_right_btn.text = "◀" if is_right_open else "▶"
		_update_layout()

## Toggles the on-screen position lock (disables dragging)
func toggle_position_lock() -> void:
	is_position_locked = not is_position_locked
	if pin_btn:
		pin_btn.modulate = Color(1.0, 0.84, 0.0, 1.0) if is_position_locked else Color(1.0, 1.0, 1.0, 0.6)
		pin_btn.text = "📌" if is_position_locked else "📍"

## Toggles Always-on-Top pin state (called by Settings panel)
func toggle_always_on_top() -> void:
	is_pinned = not is_pinned
	_apply_always_on_top(is_pinned)
	EventBus.window_pin_toggled.emit(is_pinned)

func _apply_always_on_top(pinned: bool) -> void:
	is_pinned = pinned
	
	# Get the actual native Windows HWND integer from Godot
	var hwnd: int = DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE, 0)
	
	if hwnd != 0:
		var exe_path = ProjectSettings.globalize_path("res://bin/kronos_pinner.exe")
		var state_str = "1" if pinned else "0"
		
		# Execute our silent native Win32 helper
		OS.create_process(exe_path, [str(hwnd), state_str])

## Recalculates dimensions, applies scaling, resizes OS window, and re-clamps to screen
func _update_layout() -> void:
	var scale_factor: float = SCALE_PRESETS[current_scale_index]
	
	# Calculate total base width based on active panel slots
	var total_base_w: int = BASE_MIDDLE_WIDTH
	if is_left_open:
		total_base_w += BASE_LEFT_WIDTH
	if is_right_open:
		total_base_w += BASE_RIGHT_WIDTH
		
	var target_w: int = int(round(float(total_base_w) * scale_factor))
	var target_h: int = int(round(float(BASE_HEIGHT) * scale_factor))
	var target_size: Vector2i = Vector2i(target_w, target_h)
	
	# 1. Update OS window size
	DisplayServer.window_set_size(target_size, 0)
	
	# 2. Update Godot root window size and native content scale
	var win: Window = get_window()
	if win:
		win.size = target_size
		win.content_scale_size = Vector2i(total_base_w, BASE_HEIGHT)
		win.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_IGNORE
		win.content_scale_factor = 1.0
	
	# 3. Update root Control sizing
	custom_minimum_size = Vector2(total_base_w, BASE_HEIGHT)
	
	if main_container:
		main_container.custom_minimum_size = Vector2(total_base_w, BASE_HEIGHT)
	
	# 4. Enforce exact panel dimensions
	if left_panel_container:
		left_panel_container.visible = is_left_open
		left_panel_container.custom_minimum_size = Vector2(BASE_LEFT_WIDTH, BASE_HEIGHT)
	if middle_panel_container:
		middle_panel_container.custom_minimum_size = Vector2(BASE_MIDDLE_WIDTH, BASE_HEIGHT)
	if right_panel_container:
		right_panel_container.visible = is_right_open
		right_panel_container.custom_minimum_size = Vector2(BASE_RIGHT_WIDTH, BASE_HEIGHT)
		
	# 5. Re-clamp window position to ensure it stays on screen after expanding
	var current_pos: Vector2i = DisplayServer.window_get_position(0)
	var clamped_pos: Vector2i = _clamp_to_screen_bounds(current_pos, target_size)
	DisplayServer.window_set_position(clamped_pos, 0)
	if win:
		win.position = clamped_pos
		
	if is_pinned:
		_apply_always_on_top(true)
	
	# 6. Update Scale Button label
	if scale_btn:
		scale_btn.text = SCALE_LABELS[current_scale_index]
		
	# Broadcast resize events
	EventBus.window_scale_changed.emit(scale_factor, target_size)
	EventBus.layout_resized.emit(target_size)

# ==============================================================================
# 🔔 SIGNAL HANDLERS & HUD UPDATES
# ==============================================================================
func _on_call_pet_pressed() -> void:
	if GameState:
		GameState.call_pet_to_view()

func _on_room_changed(_room_id: String) -> void:
	_update_room_and_pet_hud()

func _on_pet_room_changed(_pet_room: String) -> void:
	_update_room_and_pet_hud()

func _on_pet_called(_target_room: String) -> void:
	_update_room_and_pet_hud()

func _update_room_and_pet_hud() -> void:
	if not GameState or not room_label:
		return
		
	var r_name: String = _get_room_display_name(GameState.active_view_room)
	var is_here: bool = (GameState.pet_room == GameState.active_view_room)
	
	if is_here:
		room_label.text = "%s ● HERE" % r_name
		room_label.add_theme_color_override("font_color", Color(0.35, 0.85, 0.55, 1.0))
		if call_pet_btn:
			call_pet_btn.visible = false
	else:
		var pet_loc: String = _get_room_display_name(GameState.pet_room)
		room_label.text = "%s" % r_name
		room_label.add_theme_color_override("font_color", Color(0.95, 0.70, 0.35, 1.0))
		if call_pet_btn:
			call_pet_btn.visible = true
			call_pet_btn.text = "Call Pet"
			call_pet_btn.tooltip_text = "Kronos is in %s\nClick to call pet to this room!" % pet_loc

func _get_room_display_name(room_id: String) -> String:
	match room_id:
		"room_bedroom":
			return "BEDROOM"
		"room_livingroom":
			return "LIVING ROOM"
		"room_library":
			return "ATTIC LIBRARY"
		"room_kitchen":
			return "KITCHEN"
		"room_greenhouse":
			return "GREENHOUSE"
		_:
			return room_id.replace("room_", "").to_upper()

func _on_timer_tick(time_left_sec: float, _total_sec: float, _phase: String) -> void:
	if timer_label:
		if TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.ALARMING:
			timer_label.text = "00:00"
			timer_label.modulate = Color(1.0, 0.84, 0.0, 1.0)
		else:
			timer_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
			var mins: int = int(time_left_sec) / 60
			var secs: int = int(time_left_sec) % 60
			timer_label.text = "%02d:%02d" % [mins, secs]

func _on_phase_changed(new_phase: String, _duration: float) -> void:
	_update_phase_tab_styles(new_phase)
	_update_play_pause_button_text()

func _update_phase_tab_styles(current_phase_name: String) -> void:
	if work_tab_btn:
		work_tab_btn.modulate = Color(0.4, 0.8, 1.0, 1.0) if current_phase_name == "work" else Color(0.6, 0.6, 0.7, 0.6)
	if short_break_tab_btn:
		short_break_tab_btn.modulate = Color(0.4, 1.0, 0.6, 1.0) if current_phase_name == "short_break" else Color(0.6, 0.6, 0.7, 0.6)
	if long_break_tab_btn:
		long_break_tab_btn.modulate = Color(1.0, 0.8, 0.3, 1.0) if current_phase_name == "long_break" else Color(0.6, 0.6, 0.7, 0.6)

func _update_play_pause_button_text() -> void:
	if not play_pause_btn or not TimerEngine:
		return
	if TimerEngine.status == TimerEngine.TimerStatus.ALARMING:
		play_pause_btn.text = "⏹ Stop Alarm"
		play_pause_btn.modulate = Color(1.0, 0.35, 0.35, 1.0)
	elif TimerEngine.status == TimerEngine.TimerStatus.RUNNING:
		play_pause_btn.text = "⏸ Pause"
		play_pause_btn.modulate = Color(1.0, 0.7, 0.2, 1.0)
	elif TimerEngine.status == TimerEngine.TimerStatus.PAUSED:
		play_pause_btn.text = "▶ Resume"
		play_pause_btn.modulate = Color(0.4, 0.8, 1.0, 1.0)
	else:
		if TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
			play_pause_btn.text = "▶ Start Focus"
		else:
			play_pause_btn.text = "▶ Start Break"
		play_pause_btn.modulate = Color(0.35, 0.75, 1.0, 1.0)

func _on_timer_state_changed(_is_running: bool, _is_paused: bool) -> void:
	_update_play_pause_button_text()

func _on_coins_changed(new_balance: int, _delta: int, _reason: String) -> void:
	if coins_label:
		coins_label.text = "🪙 %d G" % new_balance

func _on_energy_changed(new_energy: float, max_energy: float, is_buffed: bool) -> void:
	if energy_bar:
		energy_bar.value = (new_energy / max_energy) * 100.0
		if is_buffed:
			energy_bar.modulate = Color(0.3, 1.0, 0.4)
		else:
			energy_bar.modulate = Color(0.9, 0.7, 0.2)

func _on_joy_changed(new_joy: float, max_joy: float) -> void:
	if joy_bar:
		joy_bar.value = (new_joy / max_joy) * 100.0

func _on_streak_changed(_current_streak: int) -> void:
	pass

func _on_level_up(new_level: int) -> void:
	if level_label:
		level_label.text = "Lv.%d" % new_level

func _on_window_pin_toggled(pinned: bool) -> void:
	is_pinned = pinned
	_apply_always_on_top(is_pinned)
	if pin_btn:
		pin_btn.modulate = Color(1.0, 0.84, 0.0, 1.0) if is_pinned else Color(1.0, 1.0, 1.0, 0.6)
		pin_btn.text = "📌" if is_pinned else "📍"

func _on_minigame_pressed() -> void:
	if not pet_slot:
		return
	# If any minigame modal is open, close it
	for m_name in ["MinigameHub", "SnackCatchGame", "PlantBloomGame", "MemoryMatchGame"]:
		if pet_slot.has_node(m_name):
			pet_slot.get_node(m_name).queue_free()
			return
		
	var scene = load("res://scenes/minigames/MinigameHub.tscn")
	if scene:
		var hub_instance: Control = scene.instantiate()
		hub_instance.name = "MinigameHub"
		pet_slot.add_child(hub_instance)
