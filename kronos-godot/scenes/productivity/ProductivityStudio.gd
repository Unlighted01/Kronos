extends Window
class_name ProductivityStudio

## 📊 Widescreen Pop-Out Productivity Studio for Kronos (720x460).
## Houses DTR & Analytics Studio, SRS Study Deck, and Sprint Tasks Command Board.
## Features 100% reactive state synchronization via EventBus and GameState singleton.

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var title_label: Label = $RootPanel/VBox/HeaderBar/HBox/TitleLabel
@onready var btn_tab_dtr: Button = $RootPanel/VBox/HeaderBar/HBox/TabBar/BtnDTR
@onready var btn_tab_deck: Button = $RootPanel/VBox/HeaderBar/HBox/TabBar/BtnDeck
@onready var btn_tab_tasks: Button = $RootPanel/VBox/HeaderBar/HBox/TabBar/BtnTasks
@onready var btn_close: Button = $RootPanel/VBox/HeaderBar/HBox/CloseButton

@onready var tab_container: TabContainer = $RootPanel/VBox/ContentArea/TabContainer

# Status Bar
@onready var sprint_status_label: Label = $RootPanel/VBox/StatusBar/HBox/SprintStatusLabel
@onready var stats_badge_label: Label = $RootPanel/VBox/StatusBar/HBox/StatsBadgeLabel
@onready var timer_status_label: Label = $RootPanel/VBox/StatusBar/HBox/TimerStatusLabel

# Internal Active Tab tracking
var current_tab_id: String = "dtr"

# Header drag state
@onready var header_bar: PanelContainer = $RootPanel/VBox/HeaderBar
var is_dragging: bool = false
var drag_start_mouse_pos: Vector2i = Vector2i.ZERO
var drag_start_window_pos: Vector2i = Vector2i.ZERO

# ==============================================================================
# ⚙️ LIFECYCLE & SIGNALS
# ==============================================================================
func _ready() -> void:
	# Configure window properties matching Kronos pixel aesthetic
	title = "📊 Kronos Productivity Studio"
	size = Vector2i(720, 460)
	min_size = Vector2i(640, 400)
	unresizable = true
	borderless = true
	transparent = true
	visible = false
	
	close_requested.connect(_on_close_requested)
	_connect_ui_signals()
	_connect_event_bus()
	
	# Initial Tab Selection
	switch_tab("dtr")

func _connect_ui_signals() -> void:
	if header_bar:
		header_bar.gui_input.connect(_on_header_gui_input)
	if title_label:
		title_label.gui_input.connect(_on_header_gui_input)
		
	if btn_tab_dtr:
		btn_tab_dtr.pressed.connect(func(): switch_tab("dtr"))
	if btn_tab_deck:
		btn_tab_deck.pressed.connect(func(): switch_tab("deck"))
	if btn_tab_tasks:
		btn_tab_tasks.pressed.connect(func(): switch_tab("tasks"))
	if btn_close:
		btn_close.pressed.connect(_on_close_requested)
		
	if tab_container:
		tab_container.tab_changed.connect(_on_tab_container_tab_changed)

func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start_mouse_pos = DisplayServer.mouse_get_position()
			drag_start_window_pos = position
		else:
			is_dragging = false
	elif event is InputEventMouseMotion and is_dragging:
		var cur_mouse_pos: Vector2i = DisplayServer.mouse_get_position()
		var delta_pos: Vector2i = cur_mouse_pos - drag_start_mouse_pos
		position = drag_start_window_pos + delta_pos

func _connect_event_bus() -> void:
	if not EventBus:
		return
		
	EventBus.timer_tick.connect(_on_timer_tick)
	EventBus.phase_changed.connect(_on_phase_changed)
	EventBus.timer_state_changed.connect(_on_timer_state_changed)
	EventBus.active_task_selected.connect(_on_active_task_selected)
	EventBus.coins_changed.connect(func(_b, _d, _r): _refresh_status_bar())
	EventBus.exp_changed.connect(func(_c, _m, _l): _refresh_status_bar())
	EventBus.level_up.connect(func(_l): _refresh_status_bar())
	EventBus.stats_updated.connect(func(_s): _refresh_status_bar())
	EventBus.timer_preset_changed.connect(func(_id, _def): _refresh_status_bar())

# ==============================================================================
# 🎮 PUBLIC API & OPEN/CLOSE
# ==============================================================================
## Opens the Studio window, centers if necessary, and switches to initial tab
func open_studio(initial_tab: String = "dtr") -> void:
	visible = true
	grab_focus()
	switch_tab(initial_tab)
	_refresh_all()
	EventBus.productivity_studio_toggled.emit(true)

func close_studio() -> void:
	visible = false
	EventBus.productivity_studio_toggled.emit(false)

func _on_close_requested() -> void:
	close_studio()

# ==============================================================================
# 🗂️ TAB SWITCHING & SYNC
# ==============================================================================
func switch_tab(tab_name: String) -> void:
	current_tab_id = tab_name
	var tab_idx: int = 0
	match tab_name:
		"dtr", "analytics":
			tab_idx = 0
		"deck", "cards", "srs":
			tab_idx = 1
		"tasks", "board", "forecast":
			tab_idx = 2
			
	if tab_container and tab_container.current_tab != tab_idx:
		tab_container.current_tab = tab_idx
		
	_update_tab_button_highlights(tab_idx)
	_refresh_active_tab_view()

func _on_tab_container_tab_changed(tab_idx: int) -> void:
	match tab_idx:
		0: current_tab_id = "dtr"
		1: current_tab_id = "deck"
		2: current_tab_id = "tasks"
	_update_tab_button_highlights(tab_idx)
	_refresh_active_tab_view()

func _update_tab_button_highlights(active_idx: int) -> void:
	if btn_tab_dtr:
		btn_tab_dtr.modulate = Color(0.3, 0.8, 0.6, 1.0) if active_idx == 0 else Color(0.8, 0.8, 0.85, 0.7)
	if btn_tab_deck:
		btn_tab_deck.modulate = Color(0.3, 0.7, 1.0, 1.0) if active_idx == 1 else Color(0.8, 0.8, 0.85, 0.7)
	if btn_tab_tasks:
		btn_tab_tasks.modulate = Color(1.0, 0.7, 0.2, 1.0) if active_idx == 2 else Color(0.8, 0.8, 0.85, 0.7)

# ==============================================================================
# 🔄 REACTIVE REFRESH
# ==============================================================================
func _refresh_all() -> void:
	_refresh_status_bar()
	_refresh_active_tab_view()

func _refresh_status_bar() -> void:
	if not GameState or not TimerEngine:
		return
		
	# 1. Active Task
	var cur_task: String = GameState.get_active_task_title() if GameState.has_method("get_active_task_title") else "General Deep Work"
	if sprint_status_label:
		sprint_status_label.text = "🎯 Active Sprint: %s" % cur_task
		
	# 2. Vitals Badge
	if stats_badge_label:
		stats_badge_label.text = "🪙 %d G  |  Lv.%d  |  Streak: %d 🔥" % [GameState.coins, GameState.level, GameState.streak]
		
	# 3. Timer & Preset
	if timer_status_label:
		var preset = TimerEngine.get_active_preset() if TimerEngine.has_method("get_active_preset") else {"short_name": "25/5"}
		var preset_name = preset.get("short_name", "25/5")
		var phase_str = TimerEngine.get_phase_string().capitalize()
		var time_str = TimerEngine.get_formatted_time()
		timer_status_label.text = "⏱️ [%s] %s: %s" % [preset_name, phase_str, time_str]

func _refresh_active_tab_view() -> void:
	if not tab_container:
		return
	var cur_child = tab_container.get_current_tab_control()
	if cur_child:
		if cur_child.has_method("refresh_tab"):
			cur_child.refresh_tab()
		elif cur_child.get_child_count() > 0:
			var inner = cur_child.get_child(0)
			if inner and inner.has_method("refresh_tab"):
				inner.refresh_tab()

# ==============================================================================
# ⏱️ EVENTBUS HANDLERS
# ==============================================================================
func _on_timer_tick(_left: float, _total: float, _phase: String) -> void:
	if visible:
		_refresh_status_bar()

func _on_phase_changed(_new_phase: String, _duration: float) -> void:
	if visible:
		_refresh_status_bar()

func _on_timer_state_changed(_is_running: bool, _is_paused: bool) -> void:
	if visible:
		_refresh_status_bar()

func _on_active_task_selected(_id: String, _title: String) -> void:
	if visible:
		_refresh_status_bar()

# ==============================================================================
# ⌨️ SHORTCUTS & INPUT
# ==============================================================================
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		var key_event: InputEventKey = event as InputEventKey
		
		# Close on Escape
		if key_event.keycode == KEY_ESCAPE:
			close_studio()
			get_viewport().set_input_as_handled()
			return
			
		# Switch tabs on Ctrl+1, Ctrl+2, Ctrl+3
		if key_event.ctrl_pressed:
			match key_event.keycode:
				KEY_1:
					switch_tab("dtr")
					get_viewport().set_input_as_handled()
				KEY_2:
					switch_tab("deck")
					get_viewport().set_input_as_handled()
				KEY_3:
					switch_tab("tasks")
					get_viewport().set_input_as_handled()
