extends Control
class_name DTRStudioTab

## 📊 Widescreen DTR (Daily Time Record) Analytics Studio for Kronos.
## Features:
## 1. 60-Day Interactive GitHub-style Focus Heatmap with hover tooltips and day filtering.
## 2. Daily Goal Progress Tracker & Category Time Distribution Charts.
## 3. Comprehensive Session CRUD Table with inline editing, deletion, and search filtering.
## 4. 1-Click Markdown Standup Generator (Slack/Discord/Notion) and CSV Exporter.

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
# Top Goal & Action Bar
@onready var goal_progress_bar: ProgressBar = $Scroll/ContentVBox/StatsRow/GoalCard/VBox/HBox/GoalProgressBar
@onready var goal_value_label: Label = $Scroll/ContentVBox/StatsRow/GoalCard/VBox/HBox/GoalValueLabel
@onready var streak_badge_label: Label = $Scroll/ContentVBox/StatsRow/BadgesCard/HBox/StreakLabel
@onready var total_hours_label: Label = $Scroll/ContentVBox/StatsRow/BadgesCard/HBox/TotalHoursLabel
@onready var sprints_count_label: Label = $Scroll/ContentVBox/StatsRow/BadgesCard/HBox/SprintsLabel
@onready var btn_copy_standup: Button = $Scroll/ContentVBox/StatsRow/ActionsHBox/BtnCopyStandup
@onready var btn_export_csv: Button = $Scroll/ContentVBox/StatsRow/ActionsHBox/BtnExportCsv
@onready var btn_add_session: Button = $Scroll/ContentVBox/StatsRow/ActionsHBox/BtnAddSession

# 60-Day Heatmap
@onready var heatmap_grid: GridContainer = $Scroll/ContentVBox/ChartsRow/HeatmapCard/VBox/HeatmapGrid
@onready var selected_day_label: Label = $Scroll/ContentVBox/ChartsRow/HeatmapCard/VBox/SelectedDayLabel
@onready var btn_clear_day_filter: Button = $Scroll/ContentVBox/ChartsRow/HeatmapCard/VBox/HeaderHBox/BtnClearDayFilter

# Category Breakdown
@onready var category_timeframe_option: OptionButton = $Scroll/ContentVBox/ChartsRow/CategoryCard/VBox/HeaderHBox/TimeframeOption
@onready var category_bars_vbox: VBoxContainer = $Scroll/ContentVBox/ChartsRow/CategoryCard/VBox/CategoryBarsVBox

# Session CRUD Table
@onready var search_input: LineEdit = $Scroll/ContentVBox/TableCard/VBox/TableHeader/SearchInput
@onready var filter_status_label: Label = $Scroll/ContentVBox/TableCard/VBox/TableHeader/FilterStatusLabel
@onready var btn_reset_table_filter: Button = $Scroll/ContentVBox/TableCard/VBox/TableHeader/BtnResetFilter
@onready var record_count_label: Label = $Scroll/ContentVBox/TableCard/VBox/TableHeader/RecordCountLabel
@onready var sessions_list_vbox: VBoxContainer = $Scroll/ContentVBox/TableCard/VBox/TableScroll/SessionsListVBox

# Modal Dialog
@onready var modal_overlay: PanelContainer = $ModalOverlay
@onready var modal_title: Label = $ModalOverlay/Center/Card/VBox/ModalTitle
@onready var modal_task_input: LineEdit = $ModalOverlay/Center/Card/VBox/TaskInput
@onready var modal_cat_option: OptionButton = $ModalOverlay/Center/Card/VBox/CategoryOption
@onready var modal_date_input: LineEdit = $ModalOverlay/Center/Card/VBox/DateInput
@onready var modal_duration_spin: SpinBox = $ModalOverlay/Center/Card/VBox/DurationSpin
@onready var modal_save_btn: Button = $ModalOverlay/Center/Card/VBox/BtnRow/SaveBtn
@onready var modal_delete_btn: Button = $ModalOverlay/Center/Card/VBox/BtnRow/DeleteBtn
@onready var modal_cancel_btn: Button = $ModalOverlay/Center/Card/VBox/BtnRow/CancelBtn

# Internal Filter State
var _active_date_filter: String = ""
var _active_search_query: String = ""
var _editing_session_unix: int = 0
var _is_new_session: bool = false

const DAILY_GOAL_MINUTES: float = 240.0 # 4.0 Hours default goal

const CATEGORY_COLORS: Dictionary = {
	"Development": Color(0.31, 0.82, 0.91, 1.0), # Cyan
	"Dev": Color(0.31, 0.82, 0.91, 1.0),
	"Study": Color(0.40, 0.70, 1.0, 1.0),       # Blue
	"Writing": Color(0.85, 0.60, 1.0, 1.0),     # Violet
	"Design": Color(0.96, 0.45, 0.75, 1.0),     # Pink
	"Admin": Color(0.70, 0.75, 0.85, 1.0),      # Slate
	"Gaming": Color(0.96, 0.75, 0.20, 1.0),     # Gold
	"General": Color(0.30, 0.80, 0.60, 1.0)     # Emerald
}

# ==============================================================================
# ⚙️ LIFECYCLE & SIGNALS
# ==============================================================================
func _ready() -> void:
	_init_category_options()
	_connect_signals()
	refresh_all()

func _connect_signals() -> void:
	if EventBus:
		EventBus.dtr_updated.connect(refresh_all)
		EventBus.session_completed.connect(func(_t, _c, _x, _s): refresh_all())
		
	if btn_copy_standup:
		btn_copy_standup.pressed.connect(_on_copy_standup_pressed)
	if btn_export_csv:
		btn_export_csv.pressed.connect(_on_export_csv_pressed)
	if btn_add_session:
		btn_add_session.pressed.connect(_open_add_session_modal)
	if btn_clear_day_filter:
		btn_clear_day_filter.pressed.connect(_clear_filters)
	if btn_reset_table_filter:
		btn_reset_table_filter.pressed.connect(_clear_filters)
		
	if category_timeframe_option:
		category_timeframe_option.item_selected.connect(func(_idx): _refresh_category_distribution())
		
	if search_input:
		search_input.text_changed.connect(_on_search_text_changed)
		
	# Modal signals
	if modal_save_btn:
		modal_save_btn.pressed.connect(_on_modal_save_pressed)
	if modal_delete_btn:
		modal_delete_btn.pressed.connect(_on_modal_delete_pressed)
	if modal_cancel_btn:
		modal_cancel_btn.pressed.connect(_close_modal)

func _init_category_options() -> void:
	if category_timeframe_option:
		category_timeframe_option.clear()
		category_timeframe_option.add_item("📅 All Time", 0)
		category_timeframe_option.add_item("🗓️ This Week", 1)
		category_timeframe_option.add_item("🎯 Today", 2)
		category_timeframe_option.selected = 0
		
	if modal_cat_option:
		modal_cat_option.clear()
		modal_cat_option.add_item("💻 Development", 0)
		modal_cat_option.add_item("📚 Study / SRS", 1)
		modal_cat_option.add_item("✍️ Writing / Notes", 2)
		modal_cat_option.add_item("🎨 Art / Design", 3)
		modal_cat_option.add_item("📋 Admin / Planning", 4)
		modal_cat_option.add_item("🎯 General Focus", 5)

# ==============================================================================
# 🔄 REFRESH CONTROLLER
# ==============================================================================
func refresh_all() -> void:
	_refresh_top_metrics()
	_refresh_heatmap()
	_refresh_category_distribution()
	_refresh_session_table()

func refresh_tab() -> void:
	refresh_all()

# ==============================================================================
# 🎯 SECTION 1: TOP METRICS & GOALS
# ==============================================================================
func _refresh_top_metrics() -> void:
	if not DatabaseManager:
		return
		
	var today_mins: int = DatabaseManager.get_today_focus_minutes()
	var goal_pct: float = clampf(float(today_mins) / DAILY_GOAL_MINUTES, 0.0, 1.0)
	
	if goal_progress_bar:
		goal_progress_bar.value = goal_pct * 100.0
		
	if goal_value_label:
		var today_hours: float = float(today_mins) / 60.0
		var goal_hours: float = DAILY_GOAL_MINUTES / 60.0
		goal_value_label.text = "%.1fh / %.1fh (%d%%)" % [today_hours, goal_hours, int(goal_pct * 100.0)]
		
	var stats: Dictionary = DatabaseManager.get_lifetime_dtr_stats()
	var streak: int = GameState.streak if GameState else 0
	
	if streak_badge_label:
		streak_badge_label.text = "🔥 %d Days" % streak
	if total_hours_label:
		total_hours_label.text = "⏱️ %.1fh Total" % stats.get("total_hours", 0.0)
	if sprints_count_label:
		sprints_count_label.text = "⚡ %d Sprints" % stats.get("total_sprints", 0)

# ==============================================================================
# 🗓️ SECTION 2A: 60-DAY INTERACTIVE HEATMAP
# ==============================================================================
func _refresh_heatmap() -> void:
	if not heatmap_grid or not DatabaseManager:
		return
		
	# Clear old heatmap buttons
	for child in heatmap_grid.get_children():
		child.queue_free()
		
	var heatmap_data: Dictionary = DatabaseManager.get_heatmap_data(60)
	var sorted_dates: Array = heatmap_data.keys()
	sorted_dates.sort() # Chronological: past -> present
	
	for date_key in sorted_dates:
		var day_info: Dictionary = heatmap_data[date_key]
		var mins: int = day_info.get("minutes", 0)
		var sprints: int = day_info.get("sprints", 0)
		
		var cell_btn: Button = Button.new()
		cell_btn.custom_minimum_size = Vector2(18, 18)
		cell_btn.focus_mode = Control.FOCUS_NONE
		cell_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		# Color Grading based on intensity
		var cell_color: Color = _get_heatmap_color(mins)
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = cell_color
		style.corner_radius_top_left = 2
		style.corner_radius_top_right = 2
		style.corner_radius_bottom_right = 2
		style.corner_radius_bottom_left = 2
		
		# Selected outline if currently filtered
		if date_key == _active_date_filter:
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = Color(1.0, 0.84, 0.0, 1.0) # Gold outline
			
		cell_btn.add_theme_stylebox_override("normal", style)
		cell_btn.add_theme_stylebox_override("hover", style)
		cell_btn.add_theme_stylebox_override("pressed", style)
		
		# Tooltip showing exact stats
		cell_btn.tooltip_text = "📅 %s\n⏱️ %d mins (%d Sprints)" % [date_key, mins, sprints]
		
		# Click to filter session table to this day
		var captured_date: String = date_key
		cell_btn.pressed.connect(func(): _on_heatmap_cell_clicked(captured_date, mins, sprints))
		
		heatmap_grid.add_child(cell_btn)
		
	if btn_clear_day_filter:
		btn_clear_day_filter.visible = not _active_date_filter.is_empty()

func _get_heatmap_color(minutes: int) -> Color:
	if minutes <= 0:
		return Color(0.12, 0.14, 0.22, 0.9) # Dark Slate Void
	elif minutes < 30:
		return Color(0.12, 0.40, 0.40, 1.0) # Soft Mint
	elif minutes < 90:
		return Color(0.08, 0.65, 0.45, 1.0) # Emerald
	elif minutes < 180:
		return Color(0.22, 0.90, 0.60, 1.0) # Bright Mint
	else:
		return Color(0.96, 0.75, 0.20, 1.0) # Radiant Gold (4+ Sprints)

func _on_heatmap_cell_clicked(date_key: String, minutes: int, sprints: int) -> void:
	if _active_date_filter == date_key:
		_active_date_filter = "" # Toggle off
		if selected_day_label:
			selected_day_label.text = "💡 Click any square above to filter sessions for that date."
	else:
		_active_date_filter = date_key
		if selected_day_label:
			selected_day_label.text = "📅 Filtered: %s • %d mins (%d Sprints)" % [date_key, minutes, sprints]
			
	_refresh_heatmap()
	_refresh_session_table()

# ==============================================================================
# 📊 SECTION 2B: CATEGORY TIME DISTRIBUTION
# ==============================================================================
func _refresh_category_distribution() -> void:
	if not category_bars_vbox or not DatabaseManager:
		return
		
	for child in category_bars_vbox.get_children():
		child.queue_free()
		
	var timeframe: String = "all"
	if category_timeframe_option:
		match category_timeframe_option.selected:
			1: timeframe = "week"
			2: timeframe = "today"
			_: timeframe = "all"
			
	var dist: Dictionary = DatabaseManager.get_category_distribution(timeframe)
	var cat_mins: Dictionary = dist.get("categories", {})
	var total_min: int = dist.get("total_minutes", 0)
	
	if total_min <= 0 or cat_mins.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No focus records for selected timeframe."
		empty_lbl.add_theme_font_size_override("font_size", 8)
		empty_lbl.modulate = Color(0.55, 0.60, 0.70)
		category_bars_vbox.add_child(empty_lbl)
		return
		
	for cat in cat_mins.keys():
		var m: int = cat_mins[cat]
		var pct: float = float(m) / float(total_min)
		var cat_color: Color = CATEGORY_COLORS.get(cat, Color(0.4, 0.7, 1.0))
		
		var row: VBoxContainer = VBoxContainer.new()
		row.add_theme_constant_override("separation", 2)
		
		var text_hbox: HBoxContainer = HBoxContainer.new()
		var name_lbl: Label = Label.new()
		name_lbl.text = cat
		name_lbl.add_theme_font_size_override("font_size", 8)
		name_lbl.modulate = cat_color
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_hbox.add_child(name_lbl)
		
		var val_lbl: Label = Label.new()
		val_lbl.text = "%dm (%d%%)" % [m, int(pct * 100.0)]
		val_lbl.add_theme_font_size_override("font_size", 8)
		val_lbl.modulate = Color(0.85, 0.90, 0.95)
		text_hbox.add_child(val_lbl)
		row.add_child(text_hbox)
		
		var bar: ProgressBar = ProgressBar.new()
		bar.custom_minimum_size = Vector2(0, 5)
		bar.value = pct * 100.0
		bar.show_percentage = false
		
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = cat_color
		style.corner_radius_top_left = 2
		style.corner_radius_top_right = 2
		style.corner_radius_bottom_right = 2
		style.corner_radius_bottom_left = 2
		bar.add_theme_stylebox_override("fill", style)
		
		row.add_child(bar)
		category_bars_vbox.add_child(row)

# ==============================================================================
# 📝 SECTION 3: SESSION HISTORY & CRUD TABLE
# ==============================================================================
func _refresh_session_table() -> void:
	if not sessions_list_vbox or not DatabaseManager:
		return
		
	for child in sessions_list_vbox.get_children():
		child.queue_free()
		
	var records: Array[Dictionary] = DatabaseManager.get_all_records()
	var filtered: Array[Dictionary] = []
	
	for i in range(records.size() - 1, -1, -1): # Reverse chronological
		var r: Dictionary = records[i]
		var match_date: bool = _active_date_filter.is_empty() or r.get("date_key", "") == _active_date_filter
		var match_search: bool = true
		
		if not _active_search_query.is_empty():
			var task_name: String = r.get("task_name", "").to_lower()
			var cat_name: String = r.get("category", "").to_lower()
			match_search = task_name.contains(_active_search_query) or cat_name.contains(_active_search_query)
			
		if match_date and match_search:
			filtered.append(r)
			
	if record_count_label:
		record_count_label.text = "%d Sessions" % filtered.size()
		
	if filter_status_label:
		if not _active_date_filter.is_empty():
			filter_status_label.text = "📅 [%s]" % _active_date_filter
			filter_status_label.visible = true
		else:
			filter_status_label.visible = false
			
	if btn_reset_table_filter:
		btn_reset_table_filter.visible = not _active_date_filter.is_empty() or not _active_search_query.is_empty()
		
	if filtered.is_empty():
		var empty_panel: PanelContainer = PanelContainer.new()
		empty_panel.custom_minimum_size = Vector2(0, 50)
		var center: CenterContainer = CenterContainer.new()
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No sessions match the current filter."
		empty_lbl.add_theme_font_size_override("font_size", 9)
		empty_lbl.modulate = Color(0.55, 0.60, 0.70)
		center.add_child(empty_lbl)
		empty_panel.add_child(center)
		sessions_list_vbox.add_child(empty_panel)
		return
		
	for session in filtered:
		var row_card: Control = _create_session_row(session)
		sessions_list_vbox.add_child(row_card)

func _create_session_row(session: Dictionary) -> Control:
	var task_name: String = session.get("task_name", "Focus Session")
	var category: String = session.get("category", "General")
	var duration: int = session.get("duration_minutes", 25)
	var coins: int = session.get("coins_earned", 0)
	var xp: int = session.get("exp_earned", 0)
	var date_key: String = session.get("date_key", "")
	var start_time: String = session.get("start_time", "")
	var created_unix: int = int(session.get("created_unix", 0))
	
	var time_str: String = ""
	if not start_time.is_empty() and "T" in start_time:
		var t_parts = start_time.split("T")[1].split(":")
		if t_parts.size() >= 2:
			time_str = "%s:%s" % [t_parts[0], t_parts[1]]
			
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 36)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 8)
	card.add_child(hbox)
	
	# 1. Date & Time Pill
	var dt_lbl: Label = Label.new()
	dt_lbl.text = "%s %s" % [date_key, time_str]
	dt_lbl.add_theme_font_size_override("font_size", 8)
	dt_lbl.modulate = Color(0.55, 0.60, 0.70)
	dt_lbl.custom_minimum_size = Vector2(110, 0)
	hbox.add_child(dt_lbl)
	
	# 2. Category Badge
	var cat_color: Color = CATEGORY_COLORS.get(category, Color(0.4, 0.7, 1.0))
	var cat_badge: Label = Label.new()
	cat_badge.text = "[%s]" % category
	cat_badge.add_theme_font_size_override("font_size", 8)
	cat_badge.modulate = cat_color
	cat_badge.custom_minimum_size = Vector2(90, 0)
	hbox.add_child(cat_badge)
	
	# 3. Task Name (Expands)
	var task_lbl: Label = Label.new()
	task_lbl.text = task_name
	task_lbl.add_theme_font_size_override("font_size", 9)
	task_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	task_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	hbox.add_child(task_lbl)
	
	# 4. Duration Pill
	var dur_lbl: Label = Label.new()
	dur_lbl.text = "⏱️ %dm" % duration
	dur_lbl.add_theme_font_size_override("font_size", 8)
	dur_lbl.modulate = Color(0.85, 0.90, 0.95)
	dur_lbl.custom_minimum_size = Vector2(50, 0)
	hbox.add_child(dur_lbl)
	
	# 5. Rewards Badge
	var rewards_lbl: Label = Label.new()
	rewards_lbl.text = "+%d🪙 +%dxp" % [coins, xp]
	rewards_lbl.add_theme_font_size_override("font_size", 8)
	rewards_lbl.modulate = Color(0.96, 0.75, 0.20)
	rewards_lbl.custom_minimum_size = Vector2(80, 0)
	hbox.add_child(rewards_lbl)
	
	# 6. Action Buttons (Edit / Delete)
	var edit_btn: Button = Button.new()
	edit_btn.text = "✏️"
	edit_btn.flat = true
	edit_btn.custom_minimum_size = Vector2(24, 22)
	edit_btn.focus_mode = Control.FOCUS_NONE
	edit_btn.add_theme_font_size_override("font_size", 9)
	edit_btn.tooltip_text = "Edit session details"
	edit_btn.pressed.connect(func(): _open_edit_session_modal(session))
	hbox.add_child(edit_btn)
	
	var del_btn: Button = Button.new()
	del_btn.text = "🗑️"
	del_btn.flat = true
	del_btn.custom_minimum_size = Vector2(24, 22)
	del_btn.focus_mode = Control.FOCUS_NONE
	del_btn.add_theme_font_size_override("font_size", 9)
	del_btn.tooltip_text = "Delete session record"
	del_btn.pressed.connect(func(): _delete_session(created_unix))
	hbox.add_child(del_btn)
	
	return card

func _on_search_text_changed(new_text: String) -> void:
	_active_search_query = new_text.strip_edges().to_lower()
	_refresh_session_table()

func _clear_filters() -> void:
	_active_date_filter = ""
	_active_search_query = ""
	if search_input:
		search_input.text = ""
	if selected_day_label:
		selected_day_label.text = "💡 Click any square above to filter sessions for that date."
	_refresh_heatmap()
	_refresh_session_table()

# ==============================================================================
# 📋 EXPORTERS (STANDUP MARKDOWN & CSV)
# ==============================================================================
func _on_copy_standup_pressed() -> void:
	if not DatabaseManager:
		return
		
	var target_date: String = _active_date_filter if not _active_date_filter.is_empty() else Time.get_date_string_from_system()
	var markdown: String = DatabaseManager.generate_standup_markdown(target_date)
	
	DisplayServer.clipboard_set(markdown)
	if NotificationManager:
		NotificationManager.show_toast("📋 Standup Markdown copied to clipboard!", NotificationManager.ToastType.SUCCESS)

func _on_export_csv_pressed() -> void:
	if not DatabaseManager:
		return
		
	var res: Dictionary = DatabaseManager.export_dtr_to_csv()
	if res.get("success", false):
		var path: String = res.get("path", "")
		if NotificationManager:
			NotificationManager.show_toast("📊 Exported %d sessions to CSV: %s" % [res.get("count", 0), path.get_file()], NotificationManager.ToastType.SUCCESS)

# ==============================================================================
# ✏️ MODAL CRUD OPERATIONS
# ==============================================================================
func _open_add_session_modal() -> void:
	_is_new_session = true
	_editing_session_unix = int(Time.get_unix_time_from_system())
	
	if modal_title:
		modal_title.text = "➕ Log Focus Session"
	if modal_task_input:
		modal_task_input.text = ""
	if modal_cat_option:
		modal_cat_option.selected = 0
	if modal_date_input:
		modal_date_input.text = Time.get_date_string_from_system()
	if modal_duration_spin:
		modal_duration_spin.value = 25
	if modal_delete_btn:
		modal_delete_btn.visible = false
		
	if modal_overlay:
		modal_overlay.visible = true

func _open_edit_session_modal(session: Dictionary) -> void:
	_is_new_session = false
	_editing_session_unix = int(session.get("created_unix", 0))
	
	if modal_title:
		modal_title.text = "✏️ Edit Focus Session"
	if modal_task_input:
		modal_task_input.text = session.get("task_name", "")
	if modal_date_input:
		modal_date_input.text = session.get("date_key", Time.get_date_string_from_system())
	if modal_duration_spin:
		modal_duration_spin.value = session.get("duration_minutes", 25)
		
	var cat: String = session.get("category", "Development")
	if modal_cat_option:
		for idx in range(modal_cat_option.item_count):
			if modal_cat_option.get_item_text(idx).contains(cat):
				modal_cat_option.selected = idx
				break
				
	if modal_delete_btn:
		modal_delete_btn.visible = true
		
	if modal_overlay:
		modal_overlay.visible = true

func _close_modal() -> void:
	if modal_overlay:
		modal_overlay.visible = false

func _on_modal_save_pressed() -> void:
	if not DatabaseManager:
		return
		
	var task_name: String = modal_task_input.text.strip_edges() if modal_task_input else "Focus Session"
	if task_name.is_empty():
		task_name = "General Work"
		
	var cat_text: String = modal_cat_option.get_item_text(modal_cat_option.selected) if modal_cat_option else "Development"
	var category: String = "Development"
	if "Study" in cat_text: category = "Study"
	elif "Writing" in cat_text: category = "Writing"
	elif "Design" in cat_text: category = "Design"
	elif "Admin" in cat_text: category = "Admin"
	elif "General" in cat_text: category = "General"
	
	var date_key: String = modal_date_input.text.strip_edges() if modal_date_input else Time.get_date_string_from_system()
	var duration: int = int(modal_duration_spin.value) if modal_duration_spin else 25
	
	var record: Dictionary = {
		"task_name": task_name,
		"category": category,
		"duration_minutes": duration,
		"date_key": date_key,
		"created_unix": _editing_session_unix,
		"coins_earned": int(duration * 2),
		"exp_earned": int(duration * 10),
		"status": "completed",
		"start_time": "%sT12:00:00" % date_key,
		"end_time": "%sT12:%02d:00" % [date_key, duration % 60]
	}
	
	if _is_new_session:
		DatabaseManager.log_session(record)
		if NotificationManager:
			NotificationManager.show_toast("✅ Session logged: %s (%dm)" % [task_name, duration], NotificationManager.ToastType.SUCCESS)
	else:
		DatabaseManager.update_session(_editing_session_unix, record)
		if NotificationManager:
			NotificationManager.show_toast("💾 Session updated: %s" % task_name, NotificationManager.ToastType.INFO)
			
	_close_modal()
	refresh_all()

func _on_modal_delete_pressed() -> void:
	_delete_session(_editing_session_unix)
	_close_modal()

func _delete_session(created_unix: int) -> void:
	if not DatabaseManager:
		return
	if DatabaseManager.delete_session(created_unix):
		if NotificationManager:
			NotificationManager.show_toast("🗑️ Session record deleted.", NotificationManager.ToastType.INFO)
		refresh_all()
