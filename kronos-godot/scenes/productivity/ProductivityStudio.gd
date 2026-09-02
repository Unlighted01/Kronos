extends Window
class_name ProductivityStudio

## 📊 Widescreen Pop-Out Productivity Studio for Kronos.
## Houses DTR & Analytics Studio, SRS Study Deck, and Sprint Tasks Command Board.
## Features:
## 1. 3 Scale Presets: 1.25x (780x500), 1.5x (936x600), 2.0x (1248x800).
## 2. Desktop coordinate drag handling with screen boundary clamping.
## 3. 100% reactive state synchronization via EventBus and GameState singleton.

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var title_label: Label = $RootPanel/VBox/HeaderBar/HBox/TitleLabel
@onready var btn_tab_dtr: Button = $RootPanel/VBox/HeaderBar/HBox/TabBar/BtnDTR
@onready var btn_tab_deck: Button = $RootPanel/VBox/HeaderBar/HBox/TabBar/BtnDeck
@onready var btn_tab_tasks: Button = $RootPanel/VBox/HeaderBar/HBox/TabBar/BtnTasks

# Scale Presets
@onready var btn_scale_125: Button = $RootPanel/VBox/HeaderBar/HBox/ScaleHBox/BtnScale125
@onready var btn_scale_150: Button = $RootPanel/VBox/HeaderBar/HBox/ScaleHBox/BtnScale150
@onready var btn_scale_200: Button = $RootPanel/VBox/HeaderBar/HBox/ScaleHBox/BtnScale200
@onready var btn_close: Button = $RootPanel/VBox/HeaderBar/HBox/CloseButton

@onready var tab_container: TabContainer = $RootPanel/VBox/ContentArea/TabContainer

# Status Bar
@onready var sprint_status_label: Label = $RootPanel/VBox/StatusBar/HBox/SprintStatusLabel
@onready var stats_badge_label: Label = $RootPanel/VBox/StatusBar/HBox/StatsBadgeLabel
@onready var timer_status_label: Label = $RootPanel/VBox/StatusBar/HBox/TimerStatusLabel

# Internal Active Tab & Scale tracking
var current_tab_id: String = "dtr"
var current_scale_preset: float = 1.25

const SCALE_SIZES: Dictionary = {
	1.25: Vector2i(780, 500),
	1.50: Vector2i(936, 600),
	2.00: Vector2i(1248, 800)
}

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
	size = SCALE_SIZES[1.25]
	min_size = Vector2i(720, 460)
	content_scale_size = Vector2i(780, 500)
	content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	unresizable = true
	borderless = true
	transparent = true
	visible = false
	
	close_requested.connect(_on_close_requested)
	_connect_ui_signals()
	_connect_event_bus()
	
	# Initial scale highlight & tab selection
	_update_scale_buttons_highlight(1.25)
	switch_tab("dtr")

func _connect_ui_signals() -> void:
	if header_bar:
		header_bar.gui_input.connect(_on_header_gui_input)
	if title_label:
		title_label.gui_input.connect(_on_header_gui_input)
		title_label.mouse_filter = Control.MOUSE_FILTER_PASS
	var spacer = get_node_or_null("RootPanel/VBox/HeaderBar/HBox/Spacer")
	if spacer:
		spacer.gui_input.connect(_on_header_gui_input)
		spacer.mouse_filter = Control.MOUSE_FILTER_PASS
		
	if btn_tab_dtr:
		btn_tab_dtr.pressed.connect(func(): switch_tab("dtr"))
	if btn_tab_deck:
		btn_tab_deck.pressed.connect(func(): switch_tab("deck"))
	if btn_tab_tasks:
		btn_tab_tasks.pressed.connect(func(): switch_tab("tasks"))
		
	# Scale buttons
	if btn_scale_125:
		btn_scale_125.pressed.connect(func(): set_studio_scale(1.25))
	if btn_scale_150:
		btn_scale_150.pressed.connect(func(): set_studio_scale(1.50))
	if btn_scale_200:
		btn_scale_200.pressed.connect(func(): set_studio_scale(2.00))
		
	if btn_close:
		btn_close.pressed.connect(_on_close_requested)
		
	if tab_container:
		tab_container.tab_changed.connect(_on_tab_container_tab_changed)

func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				is_dragging = true
				drag_start_mouse_pos = DisplayServer.mouse_get_position()
				drag_start_window_pos = position
			else:
				is_dragging = false

func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseMotion:
		var cur_mouse: Vector2i = DisplayServer.mouse_get_position()
		var delta: Vector2i = cur_mouse - drag_start_mouse_pos
		var target_pos: Vector2i = drag_start_window_pos + delta
		
		# Clamp within screen bounds
		var screen_id: int = DisplayServer.window_get_current_screen(0)
		var screen_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen_id)
		
		var max_x: int = screen_rect.position.x + screen_rect.size.x - size.x
		var max_y: int = screen_rect.position.y + screen_rect.size.y - size.y
		
		position = Vector2i(
			clampi(target_pos.x, screen_rect.position.x, max_x),
			clampi(target_pos.y, screen_rect.position.y, max_y)
		)
	elif event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			is_dragging = false

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
# 🔍 SCALE MANAGEMENT (1.25x, 1.5x, 2.0x)
# ==============================================================================
func set_studio_scale(scale_factor: float) -> void:
	if not SCALE_SIZES.has(scale_factor):
		scale_factor = 1.25
		
	current_scale_preset = scale_factor
	var target_size: Vector2i = SCALE_SIZES[scale_factor]
	size = target_size
	
	# Clamp position so it stays fully visible on current screen
	var screen_id: int = DisplayServer.window_get_current_screen(0)
	var screen_rect: Rect2i = DisplayServer.screen_get_usable_rect(screen_id)
	var max_x: int = screen_rect.position.x + screen_rect.size.x - size.x
	var max_y: int = screen_rect.position.y + screen_rect.size.y - size.y
	
	position = Vector2i(
		clampi(position.x, screen_rect.position.x, max_x),
		clampi(position.y, screen_rect.position.y, max_y)
	)
	
	_update_scale_buttons_highlight(scale_factor)
	
	if AudioManager:
		AudioManager.play_sfx("click")

func _update_scale_buttons_highlight(active_scale: float) -> void:
	if btn_scale_125:
		btn_scale_125.modulate = Color(0.31, 0.82, 0.91) if is_equal_approx(active_scale, 1.25) else Color(0.7, 0.7, 0.7, 0.8)
	if btn_scale_150:
		btn_scale_150.modulate = Color(0.31, 0.82, 0.91) if is_equal_approx(active_scale, 1.50) else Color(0.7, 0.7, 0.7, 0.8)
	if btn_scale_200:
		btn_scale_200.modulate = Color(0.31, 0.82, 0.91) if is_equal_approx(active_scale, 2.00) else Color(0.7, 0.7, 0.7, 0.8)

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
	var tabs: Array[Button] = [btn_tab_dtr, btn_tab_deck, btn_tab_tasks]
	for i in range(tabs.size()):
		var btn: Button = tabs[i]
		if btn:
			if i == active_idx:
				btn.modulate = Color(0.31, 0.82, 0.91, 1.0)
			else:
				btn.modulate = Color(0.65, 0.70, 0.82, 0.85)

func _refresh_active_tab_view() -> void:
	if not visible:
		return
	match current_tab_id:
		"dtr", "analytics":
			var dtr_node = get_node_or_null("RootPanel/VBox/ContentArea/TabContainer/DTRTab/DTRStudioTab")
			if dtr_node and dtr_node.has_method("refresh_tab"):
				dtr_node.refresh_tab()
		"deck", "cards", "srs":
			var deck_node = get_node_or_null("RootPanel/VBox/ContentArea/TabContainer/DeckTab/DeckStudioTab")
			if deck_node and deck_node.has_method("refresh_tab"):
				deck_node.refresh_tab()
		"tasks", "board", "forecast":
			var tasks_node = get_node_or_null("RootPanel/VBox/ContentArea/TabContainer/TasksTab/TasksStudioTab")
			if tasks_node and tasks_node.has_method("refresh_tab"):
				tasks_node.refresh_tab()
	_refresh_status_bar()

func _refresh_all() -> void:
	_refresh_active_tab_view()
	_refresh_status_bar()

# ==============================================================================
# 📊 STATUS BAR & REACTIVE UPDATES
# ==============================================================================
func _refresh_status_bar() -> void:
	if not visible or not GameState:
		return
		
	# 1. Level & Coins Badge
	if stats_badge_label:
		stats_badge_label.text = "👑 LVL %d  •  🪙 %d G  •  ⭐ %d KP" % [
			GameState.level,
			GameState.coins,
			GameState.knowledge_points
		]
		
	# 2. Timer & Phase Status
	if timer_status_label and TimerEngine:
		var phase_str: String = "FOCUS"
		var phase_col: Color = Color(0.31, 0.82, 0.91)
		match TimerEngine.current_phase:
			TimerEngine.TimerPhase.WORK:
				phase_str = "FOCUS"
				phase_col = Color(0.31, 0.82, 0.91)
			TimerEngine.TimerPhase.SHORT_BREAK:
				phase_str = "BREAK"
				phase_col = Color(0.3, 0.85, 0.45)
			TimerEngine.TimerPhase.LONG_BREAK:
				phase_str = "LONG BREAK"
				phase_col = Color(0.9, 0.4, 0.9)
				
		var running_str: String = "RUNNING" if TimerEngine.status == TimerEngine.TimerStatus.RUNNING else "STOPPED"
		timer_status_label.text = "⏱️ %s: %s (%s)" % [phase_str, TimerEngine.get_formatted_time(), running_str]
		timer_status_label.modulate = phase_col
		
	# 3. Active Task & Category
	if sprint_status_label and TimerEngine:
		var t_name: String = TimerEngine.active_task_name if not TimerEngine.active_task_name.is_empty() else "General Deep Work"
		var c_name: String = TimerEngine.active_category if not TimerEngine.active_category.is_empty() else "Development"
		sprint_status_label.text = "🎯 %s [%s]" % [t_name, c_name]

# ==============================================================================
# 📡 EVENT BUS HANDLERS
# ==============================================================================
func _on_timer_tick(_time_left: float, _total_duration: float, _phase_key: String) -> void:
	if visible:
		_refresh_status_bar()

func _on_phase_changed(_new_phase: String, _duration: float) -> void:
	if visible:
		_refresh_status_bar()

func _on_timer_state_changed(_is_running: bool, _is_paused: bool) -> void:
	if visible:
		_refresh_status_bar()

func _on_active_task_selected(_task_name: String, _category: String) -> void:
	if visible:
		_refresh_status_bar()
