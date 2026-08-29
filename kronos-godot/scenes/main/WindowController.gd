extends Control
class_name WindowController

## Frameless Desktop Window & Layout Controller for Kronos.
## Manages borderless dragging, 1x/1.25x/1.5x scaling, screen-edge clamping,
## and dynamic 3-panel workspace layouts (LeftPanel, MiddlePanel, RightPanel).

# ==============================================================================
# 📐 CONSTANTS & BASE DIMENSIONS (1x scale)
# ==============================================================================
const BASE_MIDDLE_WIDTH: int = 270
const BASE_LEFT_WIDTH: int = 235
const BASE_RIGHT_WIDTH: int = 200
const BASE_HEIGHT: int = 320

const SCALE_PRESETS: Array[float] = [1.25, 1.5, 2.0]
const SCALE_LABELS: Array[String] = ["1.25x", "1.5x", "2x"]

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
@onready var studio_btn: Button = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/StudioButton
@onready var pin_btn: Button = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/PinButton
@onready var min_btn: Button = $MainContainer/MiddlePanel/VBox/HeaderBar/HBox/MinimizeButton
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
@onready var sprint_progress_bar: ProgressBar = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/SprintProgressBar
@onready var timer_label: Label = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/TimerLabel
@onready var play_pause_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/ActionControls/PlayPauseButton
@onready var preset_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/ActionControls/PresetButton
@onready var minigame_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/ActionControls/MinigameButton
@onready var reset_btn: Button = $MainContainer/MiddlePanel/VBox/TimerDock/DockVBox/ActionControls/ResetButton
@onready var pet_slot: Control = $MainContainer/MiddlePanel/VBox/PetSlot

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var studio_window: Window = null
var current_scale_index: int = 0 # 0 -> 1.25x (Default), 1 -> 1.5x, 2 -> 2.0x
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
	_spawn_splash_intro()

func _spawn_splash_intro() -> void:
	var splash_scene = load("res://scenes/main/SplashIntro.tscn")
	if splash_scene:
		var splash_inst = splash_scene.instantiate()
		add_child(splash_inst)

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
		
	# Productivity Studio Window is created lazily on first open

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
	if studio_btn:
		studio_btn.pressed.connect(func(): toggle_productivity_studio("dtr"))
	if pin_btn:
		pin_btn.pressed.connect(toggle_always_on_top)
	if min_btn:
		min_btn.pressed.connect(_on_minimize_pressed)
	if close_btn:
		close_btn.pressed.connect(func(): get_tree().quit())
		
	# Call Pet HUD Button
	if call_pet_btn:
		call_pet_btn.pressed.connect(_on_call_pet_pressed)
		
	# Phase Tab Buttons (Disabled manual switching to prevent bypassing focus requirements)
	if work_tab_btn:
		pass # work_tab_btn.pressed.connect(func(): TimerEngine.switch_to_phase_by_name("work"))
	if short_break_tab_btn:
		pass # short_break_tab_btn.pressed.connect(func(): TimerEngine.switch_to_phase_by_name("short_break"))
	if long_break_tab_btn:
		pass # long_break_tab_btn.pressed.connect(func(): TimerEngine.switch_to_phase_by_name("long_break"))

	# Action Controls
	if play_pause_btn:
		play_pause_btn.pressed.connect(func(): TimerEngine.toggle_timer())
	if preset_btn:
		preset_btn.pressed.connect(func():
			if TimerEngine:
				TimerEngine.cycle_preset()
		)
	if minigame_btn:
		minigame_btn.pressed.connect(_on_minigame_pressed)
	if reset_btn:
		reset_btn.pressed.connect(func():
			if TimerEngine.current_mode == TimerEngine.TimerMode.FLOWMODORO and TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
				TimerEngine.finish_flowmodoro_session()
			else:
				TimerEngine.stop_timer()
		)

func _connect_event_bus() -> void:
	EventBus.timer_tick.connect(_on_timer_tick)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.timer_state_changed.connect(_on_timer_state_changed)
	EventBus.timer_preset_changed.connect(_on_timer_preset_changed)
	EventBus.productivity_studio_requested.connect(open_productivity_studio)
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
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)
	if NotificationManager:
		NotificationManager.toast_requested.connect(_on_toast_requested)

func _on_achievement_unlocked(_ach_id: String, ach_def: Dictionary) -> void:
	var popup_scene = load("res://scenes/main/AchievementPopup.tscn")
	if popup_scene:
		var popup_inst = popup_scene.instantiate()
		add_child(popup_inst)
		if popup_inst.has_method("display_achievement"):
			popup_inst.display_achievement(ach_def)

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
		_update_minigame_button_state()
		_update_preset_button_display()
		if sprint_progress_bar:
			sprint_progress_bar.value = TimerEngine.get_progress() * 100.0
		
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
	
	# Godot 4 WINDOW_FLAG_ALWAYS_ON_TOP doesn't work correctly with borderless+transparent on Windows
	# We MUST use our custom C++ Win32 Helper to force SetWindowPos HWND_TOPMOST
	var hwnd: int = DisplayServer.window_get_native_handle(DisplayServer.WINDOW_HANDLE, 0)
	if hwnd != 0:
		var exe_path = ProjectSettings.globalize_path("res://bin/kronos_pinner.exe")
		var state_str = "1" if pinned else "0"
		OS.create_process(exe_path, [str(hwnd), state_str])
		
	if pin_btn:
		pin_btn.modulate = Color(1.0, 0.84, 0.0, 1.0) if is_pinned else Color(1.0, 1.0, 1.0, 0.6)
		pin_btn.text = "📌" if is_pinned else "📍" 

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
	var any_pet_missing: bool = false
	var missing_loc: String = ""
	for p in GameState.active_pets:
		var p_room = p.get("room", "room_bedroom")
		if p_room != GameState.active_view_room:
			any_pet_missing = true
			missing_loc = _get_room_display_name(p_room)
			break
			
	if not any_pet_missing:
		room_label.text = "%s • HERE" % r_name
		room_label.add_theme_color_override("font_color", Color(0.35, 0.85, 0.55, 1.0))
		if call_pet_btn:
			call_pet_btn.visible = false
	else:
		room_label.text = "%s" % r_name
		room_label.add_theme_color_override("font_color", Color(0.95, 0.70, 0.35, 1.0))
		if call_pet_btn:
			call_pet_btn.visible = true
			call_pet_btn.text = "Call Pets"
			call_pet_btn.tooltip_text = "Some pets are away in %s\nClick to call everyone here!" % missing_loc

func _get_room_display_name(room_id: String) -> String:
	match room_id:
		"room_bedroom":
			return "TEMPLE OF MORPHEUS"
		"room_livingroom":
			return "HEARTH OF HESTIA"
		"room_library":
			return "TOWER OF URANIA"
		"room_kitchen":
			return "BANKS OF THE STYX"
		"room_greenhouse":
			return "DOMAIN ELYSIAN"
		_:
			return room_id.replace("room_", "").to_upper()

func _on_timer_tick(time_left_sec: float, _total_sec: float, _phase: String) -> void:
	if timer_label:
		if TimerEngine and TimerEngine.status == TimerEngine.TimerStatus.ALARMING:
			timer_label.text = "00:00"
			timer_label.modulate = Color(1.0, 0.84, 0.0, 1.0) # Pulsating gold
		else:
			var phase_str = TimerEngine.get_phase_string() if TimerEngine else "work"
			match phase_str:
				"work":
					timer_label.modulate = Color(0.31, 0.82, 0.91, 1.0) # Crisp cyan-mint
				"short_break":
					timer_label.modulate = Color(0.40, 1.0, 0.60, 1.0) # Emerald break
				"long_break":
					timer_label.modulate = Color(0.85, 0.60, 1.0, 1.0) # Dream violet
				_:
					timer_label.modulate = Color(1.0, 1.0, 1.0, 1.0)
					
			var mins: int = int(time_left_sec) / 60
			var secs: int = int(time_left_sec) % 60
			timer_label.text = "%02d:%02d" % [mins, secs]
			
	if sprint_progress_bar and TimerEngine:
		sprint_progress_bar.value = TimerEngine.get_progress() * 100.0

func _on_timer_preset_changed(_preset_id: String, _preset_def: Dictionary) -> void:
	_update_preset_button_display()
	_refresh_ui_from_state()

func _update_preset_button_display() -> void:
	if not preset_btn or not TimerEngine:
		return
	var preset = TimerEngine.get_active_preset() if TimerEngine.has_method("get_active_preset") else {"short_name": "25/5"}
	var short_name = preset.get("short_name", "25/5")
	preset_btn.text = "⚙ %s" % short_name

func _ensure_studio_window() -> void:
	if studio_window:
		return
	var studio_scene = load("res://scenes/productivity/ProductivityStudio.tscn")
	if studio_scene:
		studio_window = studio_scene.instantiate() as Window
		add_child(studio_window)

func toggle_productivity_studio(tab: String = "dtr") -> void:
	_ensure_studio_window()
	if not studio_window:
		return
	if studio_window.visible:
		studio_window.close_studio()
	else:
		open_productivity_studio(tab)

func open_productivity_studio(tab: String = "dtr") -> void:
	_ensure_studio_window()
	if not studio_window:
		return
	if not studio_window.visible:
		var screen_id: int = DisplayServer.window_get_current_screen(0)
		var screen_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen_id)
		var win_pos = screen_rect.position + (screen_rect.size - studio_window.size) / 2
		studio_window.position = win_pos
	studio_window.open_studio(tab)

func _on_phase_changed(new_phase: String, _duration: float) -> void:
	_update_phase_tab_styles(new_phase)
	_update_play_pause_button_text()
	_update_minigame_button_state()

func _update_phase_tab_styles(current_phase_name: String) -> void:
	if work_tab_btn:
		work_tab_btn.modulate = Color(0.4, 0.8, 1.0, 1.0) if current_phase_name == "work" else Color(0.6, 0.6, 0.7, 0.6)
	if short_break_tab_btn:
		short_break_tab_btn.modulate = Color(0.4, 1.0, 0.6, 1.0) if current_phase_name == "short_break" else Color(0.6, 0.6, 0.7, 0.6)
	if long_break_tab_btn:
		long_break_tab_btn.modulate = Color(1.0, 0.8, 0.3, 1.0) if current_phase_name == "long_break" else Color(0.6, 0.6, 0.7, 0.6)

func _update_minigame_button_state() -> void:
	if not minigame_btn or not TimerEngine:
		return
	var is_break: bool = (TimerEngine.current_phase == TimerEngine.TimerPhase.SHORT_BREAK or TimerEngine.current_phase == TimerEngine.TimerPhase.LONG_BREAK)
	
	minigame_btn.disabled = not is_break
	if is_break:
		minigame_btn.modulate = Color(1.0, 0.85, 0.2, 1.0)
		minigame_btn.tooltip_text = "🎮 Break Time! Play Arcade Minigames"
	else:
		minigame_btn.modulate = Color(0.6, 0.6, 0.7, 0.35)
		minigame_btn.tooltip_text = "☕ Minigames unlock during Break Time!"
		
		if pet_slot:
			for m_name in ["MinigameHub", "SnackCatchGame", "PlantBloomGame", "MemoryMatchGame"]:
				if pet_slot.has_node(m_name):
					pet_slot.get_node(m_name).queue_free()

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
		play_pause_btn.text = "▶  Resume"
		play_pause_btn.modulate = Color(0.4, 0.8, 1.0, 1.0)
	else:
		if TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
			play_pause_btn.text = "▶  Start Focus"
		else:
			play_pause_btn.text = "▶  Start Break"
		play_pause_btn.modulate = Color(0.35, 0.75, 1.0, 1.0)
		
	if reset_btn:
		if TimerEngine.current_mode == TimerEngine.TimerMode.FLOWMODORO and TimerEngine.current_phase == TimerEngine.TimerPhase.WORK:
			reset_btn.text = "Finish & Break"
			reset_btn.modulate = Color(0.3, 1.0, 0.5)
		else:
			reset_btn.text = "Stop"
			reset_btn.modulate = Color(1.0, 1.0, 1.0)

func _on_timer_state_changed(_is_running: bool, _is_paused: bool) -> void:
	_update_play_pause_button_text()
	_update_minigame_button_state()

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
	if not TimerEngine:
		return
	var is_break: bool = (TimerEngine.current_phase == TimerEngine.TimerPhase.SHORT_BREAK or TimerEngine.current_phase == TimerEngine.TimerPhase.LONG_BREAK)
	if not is_break:
		return
		
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
		hub_instance.custom_minimum_size = Vector2(236, 140)
		hub_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		pet_slot.add_child(hub_instance)

func _on_minimize_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("click")
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED, 0)

func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed() or event.is_echo():
		return
		
	# Ignore shortcuts if user is currently typing in a text field
	var focused = get_viewport().gui_get_focus_owner()
	if focused is LineEdit or focused is TextEdit:
		return
		
	var key = event as InputEventKey
	
	# 1. Space: Toggle Start / Pause Pomodoro Focus
	if key.keycode == KEY_SPACE:
		if TimerEngine:
			if TimerEngine.status == TimerEngine.TimerStatus.RUNNING:
				TimerEngine.pause()
			elif TimerEngine.status == TimerEngine.TimerStatus.PAUSED:
				TimerEngine.resume()
			else:
				TimerEngine.start_focus()
		get_viewport().set_input_as_handled()
		return
		
	# 2. Escape: Close open modals / panels
	if key.keycode == KEY_ESCAPE:
		if _close_open_modals():
			get_viewport().set_input_as_handled()
			return
		if is_left_open or is_right_open:
			if is_left_open: toggle_left_panel()
			if is_right_open: toggle_right_panel()
			get_viewport().set_input_as_handled()
			return
			
	# 3. Ctrl + P: Toggle Always-On-Top Pin
	if key.ctrl_pressed and key.keycode == KEY_P:
		toggle_always_on_top()
		get_viewport().set_input_as_handled()
		return
		
	# 4. Ctrl + D or F1: Toggle Productivity Studio
	if (key.ctrl_pressed and key.keycode == KEY_D) or key.keycode == KEY_F1:
		toggle_productivity_studio("dtr")
		get_viewport().set_input_as_handled()
		return
		
	# 4. Ctrl + 1/2/3: Scale Factor Switching
	if key.ctrl_pressed:
		if key.keycode == KEY_1:
			set_scale_preset(0)
			get_viewport().set_input_as_handled()
			return
		elif key.keycode == KEY_2:
			set_scale_preset(1)
			get_viewport().set_input_as_handled()
			return
		elif key.keycode == KEY_3:
			set_scale_preset(2)
			get_viewport().set_input_as_handled()
			return
			
	# 5. Ctrl + Left / Right: Cycle Unlocked Rooms
	if key.ctrl_pressed:
		if key.keycode == KEY_LEFT or key.keycode == KEY_RIGHT:
			_cycle_unlocked_room(key.keycode == KEY_RIGHT)
			get_viewport().set_input_as_handled()
			return
			
	# 6. M: Quick Mute / Ambience Toggle
	if key.keycode == KEY_M and not key.ctrl_pressed and not key.alt_pressed:
		if GameState:
			var current_amb = GameState.audio_settings.get("ambience_enabled", true)
			GameState.set_audio_setting("ambience_enabled", not current_amb)
			if NotificationManager:
				var msg = "Ambience Muted 🔇" if current_amb else "Ambience Unmuted 🔊"
				NotificationManager.show_toast(msg, NotificationManager.ToastType.INFO)
		get_viewport().set_input_as_handled()
		return

func _close_open_modals() -> bool:
	if not pet_slot:
		return false
	var modal_names = ["FlashcardEngine", "MinigameHub", "SnackCatchGame", "PlantBloomGame", "MemoryMatchGame"]
	for m in modal_names:
		if pet_slot.has_node(m):
			pet_slot.get_node(m).queue_free()
			if AudioManager: AudioManager.play_sfx("click")
			return true
	return false

func _cycle_unlocked_room(next: bool) -> void:
	if not GameState or GameState.unlocked_rooms.is_empty():
		return
	var rooms = GameState.unlocked_rooms
	var cur_idx = rooms.find(GameState.active_view_room)
	if cur_idx == -1: cur_idx = 0
	var new_idx = (cur_idx + 1) % rooms.size() if next else (cur_idx - 1 + rooms.size()) % rooms.size()
	var target_room = rooms[new_idx]
	GameState.set_active_view_room(target_room)
	if AudioManager: AudioManager.play_sfx("click")
	if NotificationManager:
		var r_name = GameState.get_room_display_name(target_room)
		NotificationManager.show_toast("Domain: " + r_name, NotificationManager.ToastType.INFO)

func _on_toast_requested(msg: String, toast_type: int) -> void:
	# Spawn or update floating retro toast overlay
	var toast_node = get_node_or_null("FloatingToast")
	if toast_node:
		toast_node.queue_free()
		
	var panel: PanelContainer = PanelContainer.new()
	panel.name = "FloatingToast"
	panel.z_index = 100
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.14, 0.96)
	style.set_border_width_all(1)
	
	match toast_type:
		0: style.border_color = Color(0.31, 0.82, 0.91, 1.0) # INFO cyan
		1: style.border_color = Color(0.35, 0.85, 0.55, 1.0) # SUCCESS green
		2: style.border_color = Color(0.96, 0.62, 0.04, 1.0) # WARNING gold
		3: style.border_color = Color(0.95, 0.35, 0.35, 1.0) # ERROR red
		_: style.border_color = Color(0.31, 0.82, 0.91, 1.0)
		
	style.set_corner_radius_all(3)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	panel.add_theme_stylebox_override("panel", style)
	
	var lbl: Label = Label.new()
	lbl.text = msg
	lbl.add_theme_font_size_override("font_size", 7)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	panel.add_child(lbl)
	
	add_child(panel)
	
	# Position near top of middle panel
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	panel.position.y = 28.0
	panel.modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.15)
	tween.tween_interval(2.2)
	tween.tween_property(panel, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func():
		if is_instance_valid(panel):
			panel.queue_free()
	)
