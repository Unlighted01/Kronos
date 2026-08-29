extends Control
class_name DTRStudioTab

## 📊 Widescreen DTR (Daily Time Record) Analytics Studio for Kronos.
## Architecture:
## 1. 100% Automated Biometric Punching from real focus sessions.
## 2. Immutable Timestamps: Date, Start Time, End Time, and Duration are locked biometric ground truth.
## 3. Work Accomplishment Reflection: Users enrich punches with Task Name, Category, and "What did I do today?" notes.
## 4. 60-Day Interactive Consistency Heatmap & 24-Hour Chronotype / Peak Flow Histogram.
## 5. Multi-Format Exporter Suite: Daily Standup, Weekly Retrospective, CSV, and JSON Backup.

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
# Top Goal & Action Bar
@onready var goal_target_option: OptionButton = $Scroll/ContentVBox/GoalAndActionsRow/GoalCard/VBox/HeaderHBox/GoalTargetOption
@onready var goal_progress_bar: ProgressBar = $Scroll/ContentVBox/GoalAndActionsRow/GoalCard/VBox/HBox/GoalProgressBar
@onready var goal_value_label: Label = $Scroll/ContentVBox/GoalAndActionsRow/GoalCard/VBox/HBox/GoalValueLabel

@onready var btn_copy_standup: Button = $Scroll/ContentVBox/GoalAndActionsRow/ActionsCard/HBox/BtnCopyStandup
@onready var btn_copy_retro: Button = $Scroll/ContentVBox/GoalAndActionsRow/ActionsCard/HBox/BtnCopyRetro
@onready var btn_export_csv: Button = $Scroll/ContentVBox/GoalAndActionsRow/ActionsCard/HBox/BtnExportCsv
@onready var btn_backup_json: Button = $Scroll/ContentVBox/GoalAndActionsRow/ActionsCard/HBox/BtnBackupJson
@onready var btn_focus_now: Button = $Scroll/ContentVBox/GoalAndActionsRow/ActionsCard/HBox/BtnFocusNow

# Insights & Stats Bar
@onready var streak_badge_label: Label = $Scroll/ContentVBox/BadgesCard/HBox/StreakLabel
@onready var weekly_velocity_label: Label = $Scroll/ContentVBox/BadgesCard/HBox/WeeklyVelocityLabel
@onready var peak_flow_label: Label = $Scroll/ContentVBox/BadgesCard/HBox/PeakFlowLabel
@onready var total_hours_label: Label = $Scroll/ContentVBox/BadgesCard/HBox/TotalHoursLabel
@onready var sprints_count_label: Label = $Scroll/ContentVBox/BadgesCard/HBox/SprintsLabel

# Dual Visualizations (2 Columns)
@onready var heatmap_grid: GridContainer = $Scroll/ContentVBox/ChartsRow/HeatmapCard/VBox/HeatmapGrid
@onready var selected_day_label: Label = $Scroll/ContentVBox/ChartsRow/HeatmapCard/VBox/SelectedDayLabel
@onready var btn_clear_day_filter: Button = $Scroll/ContentVBox/ChartsRow/HeatmapCard/VBox/HeaderHBox/BtnClearDayFilter

@onready var category_timeframe_option: OptionButton = $Scroll/ContentVBox/ChartsRow/RightChartsCard/VBox/HeaderHBox/TimeframeOption
@onready var category_bars_vbox: VBoxContainer = $Scroll/ContentVBox/ChartsRow/RightChartsCard/VBox/CategoryBarsVBox
@onready var hourly_bars_hbox: HBoxContainer = $Scroll/ContentVBox/ChartsRow/RightChartsCard/VBox/HourlySubVBox/HourlyBarsHBox

# Session CRUD Table
@onready var table_category_filter: OptionButton = $Scroll/ContentVBox/TableCard/VBox/TableHeader/CategoryFilterOption
@onready var search_input: LineEdit = $Scroll/ContentVBox/TableCard/VBox/TableHeader/SearchInput
@onready var filter_status_label: Label = $Scroll/ContentVBox/TableCard/VBox/TableHeader/FilterStatusLabel
@onready var btn_reset_table_filter: Button = $Scroll/ContentVBox/TableCard/VBox/TableHeader/BtnResetFilter
@onready var record_count_label: Label = $Scroll/ContentVBox/TableCard/VBox/TableHeader/RecordCountLabel
@onready var sessions_list_vbox: VBoxContainer = $Scroll/ContentVBox/TableCard/VBox/TableScroll/SessionsListVBox

# Modal Dialog (Biometric Accomplishment & Reflection Editor)
@onready var modal_overlay: PanelContainer = $ModalOverlay
@onready var modal_title: Label = $ModalOverlay/Center/Card/VBox/ModalTitle
@onready var punch_badge_label: Label = $ModalOverlay/Center/Card/VBox/PunchCard/VBox/PunchBadgeLabel
@onready var punch_time_label: Label = $ModalOverlay/Center/Card/VBox/PunchCard/VBox/PunchTimeLabel
@onready var punch_rewards_label: Label = $ModalOverlay/Center/Card/VBox/PunchCard/VBox/PunchRewardsLabel

@onready var modal_task_input: LineEdit = $ModalOverlay/Center/Card/VBox/TaskInput
@onready var modal_notes_input: TextEdit = $ModalOverlay/Center/Card/VBox/NotesTextEdit
@onready var modal_cat_option: OptionButton = $ModalOverlay/Center/Card/VBox/CategoryOption

@onready var btn_bullet_dot: Button = $ModalOverlay/Center/Card/VBox/ShortcutsRow/BtnDot
@onready var btn_bullet_feat: Button = $ModalOverlay/Center/Card/VBox/ShortcutsRow/BtnFeat
@onready var btn_bullet_fix: Button = $ModalOverlay/Center/Card/VBox/ShortcutsRow/BtnFix
@onready var btn_bullet_learn: Button = $ModalOverlay/Center/Card/VBox/ShortcutsRow/BtnLearn

@onready var modal_save_btn: Button = $ModalOverlay/Center/Card/VBox/BtnRow/SaveBtn
@onready var modal_delete_btn: Button = $ModalOverlay/Center/Card/VBox/BtnRow/DeleteBtn
@onready var modal_cancel_btn: Button = $ModalOverlay/Center/Card/VBox/BtnRow/CancelBtn

# Internal Filter & Goal State
var _active_date_filter: String = ""
var _active_category_filter: String = "all"
var _active_search_query: String = ""
var _editing_session_unix: int = 0
var _daily_goal_minutes: float = 240.0 # Default 4.0h

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
	_init_dropdown_options()
	_connect_signals()
	refresh_all()

func _connect_signals() -> void:
	if EventBus:
		EventBus.dtr_updated.connect(refresh_all)
		EventBus.session_completed.connect(func(_t, _c, _x, _s): refresh_all())
		
	if goal_target_option:
		goal_target_option.item_selected.connect(_on_goal_target_selected)
		
	if btn_copy_standup:
		btn_copy_standup.pressed.connect(_on_copy_standup_pressed)
	if btn_copy_retro:
		btn_copy_retro.pressed.connect(_on_copy_retrospective_pressed)
	if btn_export_csv:
		btn_export_csv.pressed.connect(_on_export_csv_pressed)
	if btn_backup_json:
		btn_backup_json.pressed.connect(_on_backup_json_pressed)
	if btn_focus_now:
		btn_focus_now.pressed.connect(_on_focus_now_pressed)
	if btn_clear_day_filter:
		btn_clear_day_filter.pressed.connect(_clear_filters)
	if btn_reset_table_filter:
		btn_reset_table_filter.pressed.connect(_clear_filters)
		
	if category_timeframe_option:
		category_timeframe_option.item_selected.connect(func(_idx): _refresh_category_distribution())
		
	if table_category_filter:
		table_category_filter.item_selected.connect(_on_table_category_filter_selected)
		
	if search_input:
		search_input.text_changed.connect(_on_search_text_changed)
		
	# Bullet Shortcut Helpers
	if btn_bullet_dot:
		btn_bullet_dot.pressed.connect(func(): _insert_bullet_prefix("• "))
	if btn_bullet_feat:
		btn_bullet_feat.pressed.connect(func(): _insert_bullet_prefix("✨ [Feature] "))
	if btn_bullet_fix:
		btn_bullet_fix.pressed.connect(func(): _insert_bullet_prefix("🐛 [Fix] "))
	if btn_bullet_learn:
		btn_bullet_learn.pressed.connect(func(): _insert_bullet_prefix("📚 [Learned] "))
		
	# Modal signals
	if modal_save_btn:
		modal_save_btn.pressed.connect(_on_modal_save_pressed)
	if modal_delete_btn:
		modal_delete_btn.pressed.connect(_on_modal_delete_pressed)
	if modal_cancel_btn:
		modal_cancel_btn.pressed.connect(_close_modal)

func _init_dropdown_options() -> void:
	if goal_target_option:
		goal_target_option.clear()
		goal_target_option.add_item("2.0h / d", 0)
		goal_target_option.add_item("3.0h / d", 1)
		goal_target_option.add_item("4.0h / d", 2)
		goal_target_option.add_item("6.0h / d", 3)
		goal_target_option.add_item("8.0h / d", 4)
		goal_target_option.selected = 2 # Default 4.0h
		
	if category_timeframe_option:
		category_timeframe_option.clear()
		category_timeframe_option.add_item("All Time", 0)
		category_timeframe_option.add_item("This Week", 1)
		category_timeframe_option.add_item("Today", 2)
		category_timeframe_option.selected = 0
		
	if table_category_filter:
		table_category_filter.clear()
		table_category_filter.add_item("All Categories", 0)
		table_category_filter.add_item("💻 Dev", 1)
		table_category_filter.add_item("📚 Study", 2)
		table_category_filter.add_item("✍️ Writing", 3)
		table_category_filter.add_item("🎨 Design", 4)
		table_category_filter.add_item("📋 Admin", 5)
		table_category_filter.add_item("🎮 Gaming", 6)
		table_category_filter.add_item("🎯 General", 7)
		table_category_filter.selected = 0
		
	if modal_cat_option:
		modal_cat_option.clear()
		modal_cat_option.add_item("💻 Development", 0)
		modal_cat_option.add_item("📚 Study / SRS", 1)
		modal_cat_option.add_item("✍️ Writing / Notes", 2)
		modal_cat_option.add_item("🎨 Art / Design", 3)
		modal_cat_option.add_item("📋 Admin / Planning", 4)
		modal_cat_option.add_item("🎮 Gaming / Rest", 5)
		modal_cat_option.add_item("🎯 General Focus", 6)

func _on_goal_target_selected(idx: int) -> void:
	match idx:
		0: _daily_goal_minutes = 120.0
		1: _daily_goal_minutes = 180.0
		2: _daily_goal_minutes = 240.0
		3: _daily_goal_minutes = 360.0
		4: _daily_goal_minutes = 480.0
		_: _daily_goal_minutes = 240.0
	_refresh_top_metrics()

func _on_focus_now_pressed() -> void:
	if NotificationManager:
		NotificationManager.show_toast("⏱️ Focus session punches automatically log upon timer completion!", NotificationManager.ToastType.INFO)

func _insert_bullet_prefix(prefix: String) -> void:
	if not modal_notes_input:
		return
	var cur_text: String = modal_notes_input.text
	if cur_text.is_empty():
		modal_notes_input.text = prefix
	elif cur_text.ends_with("\n"):
		modal_notes_input.text = cur_text + prefix
	else:
		modal_notes_input.text = cur_text + "\n" + prefix
	modal_notes_input.set_caret_line(modal_notes_input.get_line_count() - 1)
	modal_notes_input.set_caret_column(modal_notes_input.get_line(modal_notes_input.get_line_count() - 1).length())

# ==============================================================================
# 🔄 REFRESH CONTROLLER
# ==============================================================================
func refresh_all() -> void:
	_refresh_top_metrics()
	_refresh_heatmap()
	_refresh_chronotype_histogram()
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
	var goal_pct: float = clampf(float(today_mins) / _daily_goal_minutes, 0.0, 1.0)
	
	if goal_progress_bar:
		goal_progress_bar.value = goal_pct * 100.0
		
	if goal_value_label:
		var today_hours: float = float(today_mins) / 60.0
		var goal_hours: float = _daily_goal_minutes / 60.0
		goal_value_label.text = "%.1fh / %.1fh (%d%%)" % [today_hours, goal_hours, int(goal_pct * 100.0)]
		
	var stats: Dictionary = DatabaseManager.get_lifetime_dtr_stats()
	var velocity: Dictionary = DatabaseManager.get_weekly_velocity_stats()
	var hourly: Dictionary = DatabaseManager.get_hourly_focus_distribution(30)
	var streak: int = GameState.streak if GameState else 0
	
	if streak_badge_label:
		streak_badge_label.text = "🔥 %d Days" % streak
	if weekly_velocity_label:
		var pct = velocity.get("pct_change", 0.0)
		var sign_str = "+" if pct >= 0 else ""
		weekly_velocity_label.text = "⚡ %.1fh (%s%.0f%% vs lw)" % [velocity.get("this_week_hours", 0.0), sign_str, pct]
	if peak_flow_label:
		peak_flow_label.text = "🕒 %s" % hourly.get("peak_label", "Balanced Flow")
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
		cell_btn.custom_minimum_size = Vector2(15, 15)
		cell_btn.focus_mode = Control.FOCUS_NONE
		cell_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		
		var cell_color: Color = _get_heatmap_color(mins)
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = cell_color
		style.corner_radius_top_left = 2
		style.corner_radius_top_right = 2
		style.corner_radius_bottom_right = 2
		style.corner_radius_bottom_left = 2
		
		if date_key == _active_date_filter:
			style.border_width_left = 1
			style.border_width_top = 1
			style.border_width_right = 1
			style.border_width_bottom = 1
			style.border_color = Color(1.0, 0.84, 0.0, 1.0) # Gold
			
		cell_btn.add_theme_stylebox_override("normal", style)
		cell_btn.add_theme_stylebox_override("hover", style)
		cell_btn.add_theme_stylebox_override("pressed", style)
		
		cell_btn.tooltip_text = "📅 %s\n⏱️ %d mins (%d Sprints)" % [date_key, mins, sprints]
		
		var captured_date: String = date_key
		cell_btn.pressed.connect(func(): _on_heatmap_cell_clicked(captured_date, mins, sprints))
		
		heatmap_grid.add_child(cell_btn)
		
	if btn_clear_day_filter:
		btn_clear_day_filter.visible = not _active_date_filter.is_empty()

func _get_heatmap_color(minutes: int) -> Color:
	if minutes <= 0:
		return Color(0.10, 0.11, 0.18, 0.9) # Dark Void
	elif minutes < 30:
		return Color(0.12, 0.35, 0.35, 1.0) # Soft Mint
	elif minutes < 90:
		return Color(0.08, 0.55, 0.38, 1.0) # Emerald
	elif minutes < 180:
		return Color(0.20, 0.78, 0.52, 1.0) # Bright Mint
	else:
		return Color(0.96, 0.75, 0.20, 1.0) # Radiant Gold

func _on_heatmap_cell_clicked(date_key: String, minutes: int, sprints: int) -> void:
	if _active_date_filter == date_key:
		_active_date_filter = ""
		if selected_day_label:
			selected_day_label.text = "💡 Click any square above to filter sessions for that date."
	else:
		_active_date_filter = date_key
		if selected_day_label:
			selected_day_label.text = "📅 Filtered: %s • %d mins (%d Sprints)" % [date_key, minutes, sprints]
			
	_refresh_heatmap()
	_refresh_session_table()

# ==============================================================================
# ⚡ SECTION 2B: 24-HOUR CHRONOTYPE / PEAK FLOW HISTOGRAM
# ==============================================================================
func _refresh_chronotype_histogram() -> void:
	if not hourly_bars_hbox or not DatabaseManager:
		return
		
	for child in hourly_bars_hbox.get_children():
		child.queue_free()
		
	var hourly_data: Dictionary = DatabaseManager.get_hourly_focus_distribution(30)
	var hours: Array = hourly_data.get("hours", [])
	var peak_m: int = hourly_data.get("peak_minutes", 1)
	if peak_m <= 0:
		peak_m = 1
		
	for h in range(24):
		var m: int = hours[h] if h < hours.size() else 0
		var pct: float = float(m) / float(peak_m)
		
		var col_vbox: VBoxContainer = VBoxContainer.new()
		col_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		col_vbox.alignment = BoxContainer.ALIGNMENT_END
		col_vbox.add_theme_constant_override("separation", 1)
		
		var bar_panel: Panel = Panel.new()
		var bar_height: int = clampi(int(pct * 20.0), 2, 20)
		bar_panel.custom_minimum_size = Vector2(0, bar_height)
		bar_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var style: StyleBoxFlat = StyleBoxFlat.new()
		if m <= 0:
			style.bg_color = Color(0.10, 0.11, 0.18, 0.6)
		elif pct >= 0.8:
			style.bg_color = Color(0.96, 0.75, 0.20, 1.0) # Gold
		elif pct >= 0.4:
			style.bg_color = Color(0.31, 0.82, 0.91, 1.0) # Cyan
		else:
			style.bg_color = Color(0.18, 0.65, 0.50, 1.0) # Emerald
			
		style.corner_radius_top_left = 1
		style.corner_radius_top_right = 1
		bar_panel.add_theme_stylebox_override("panel", style)
		bar_panel.tooltip_text = "%02d:00 - %02d:00\n⏱️ %d mins" % [h, (h + 1) % 24, m]
		
		col_vbox.add_child(bar_panel)
		
		if h % 4 == 0:
			var h_lbl: Label = Label.new()
			h_lbl.text = "%02d" % h
			h_lbl.add_theme_font_size_override("font_size", 7)
			h_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			h_lbl.modulate = Color(0.55, 0.60, 0.70)
			col_vbox.add_child(h_lbl)
		else:
			var spacer: Control = Control.new()
			spacer.custom_minimum_size = Vector2(0, 8)
			col_vbox.add_child(spacer)
			
		hourly_bars_hbox.add_child(col_vbox)

# ==============================================================================
# 📊 SECTION 2C: CATEGORY TIME DISTRIBUTION
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
		empty_lbl.add_theme_font_size_override("font_size", 9)
		empty_lbl.modulate = Color(0.55, 0.60, 0.70)
		category_bars_vbox.add_child(empty_lbl)
		return
		
	for cat in cat_mins.keys():
		var m: int = cat_mins[cat]
		var pct: float = float(m) / float(total_min)
		var cat_color: Color = CATEGORY_COLORS.get(cat, Color(0.4, 0.7, 1.0))
		
		var row: VBoxContainer = VBoxContainer.new()
		row.add_theme_constant_override("separation", 1)
		
		var text_hbox: HBoxContainer = HBoxContainer.new()
		var name_lbl: Label = Label.new()
		name_lbl.text = cat
		name_lbl.add_theme_font_size_override("font_size", 9)
		name_lbl.modulate = cat_color
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text_hbox.add_child(name_lbl)
		
		var val_lbl: Label = Label.new()
		val_lbl.text = "%dm (%d%%)" % [m, int(pct * 100.0)]
		val_lbl.add_theme_font_size_override("font_size", 9)
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
func _on_table_category_filter_selected(idx: int) -> void:
	match idx:
		1: _active_category_filter = "dev"
		2: _active_category_filter = "study"
		3: _active_category_filter = "writing"
		4: _active_category_filter = "design"
		5: _active_category_filter = "admin"
		6: _active_category_filter = "gaming"
		7: _active_category_filter = "general"
		_: _active_category_filter = "all"
	_refresh_session_table()

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
		var match_cat: bool = true
		if _active_category_filter != "all":
			var cat_str: String = r.get("category", "").to_lower()
			match_cat = cat_str.contains(_active_category_filter)
			
		var match_search: bool = true
		if not _active_search_query.is_empty():
			var task_name: String = r.get("task_name", "").to_lower()
			var cat_name: String = r.get("category", "").to_lower()
			var notes_text: String = r.get("notes", "").to_lower()
			match_search = task_name.contains(_active_search_query) or cat_name.contains(_active_search_query) or notes_text.contains(_active_search_query)
			
		if match_date and match_cat and match_search:
			filtered.append(r)
			
	if record_count_label:
		record_count_label.text = "%d Verified Punches" % filtered.size()
		
	if filter_status_label:
		if not _active_date_filter.is_empty():
			filter_status_label.text = "📅 [%s]" % _active_date_filter
			filter_status_label.visible = true
		else:
			filter_status_label.visible = false
			
	if btn_reset_table_filter:
		btn_reset_table_filter.visible = not _active_date_filter.is_empty() or not _active_search_query.is_empty() or _active_category_filter != "all"
		
	if filtered.is_empty():
		var empty_panel: PanelContainer = PanelContainer.new()
		empty_panel.custom_minimum_size = Vector2(0, 40)
		var center: CenterContainer = CenterContainer.new()
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No focus punches match the current filter."
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
	var task_name: String = session.get("task_name", "General Deep Work")
	var category: String = session.get("category", "Development")
	var duration: int = session.get("duration_minutes", 25)
	var coins: int = session.get("coins_earned", 0)
	var xp: int = session.get("exp_earned", 0)
	var date_key: String = session.get("date_key", "")
	var start_time: String = session.get("start_time", "")
	var created_unix: int = int(session.get("created_unix", 0))
	var notes: String = session.get("notes", "").strip_edges()
	
	var time_str: String = ""
	if not start_time.is_empty() and "T" in start_time:
		var t_parts = start_time.split("T")[1].split(":")
		if t_parts.size() >= 2:
			time_str = "%s:%s" % [t_parts[0], t_parts[1]]
			
	var card: PanelContainer = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	card.add_child(vbox)
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(hbox)
	
	# 1. Date & Time Pill (Immutable Biometric Timestamp)
	var dt_lbl: Label = Label.new()
	dt_lbl.text = "🔒 %s %s" % [date_key, time_str]
	dt_lbl.add_theme_font_size_override("font_size", 8)
	dt_lbl.modulate = Color(0.55, 0.60, 0.70)
	dt_lbl.custom_minimum_size = Vector2(115, 0)
	hbox.add_child(dt_lbl)
	
	# 2. Category Badge
	var cat_color: Color = CATEGORY_COLORS.get(category, Color(0.4, 0.7, 1.0))
	var cat_badge: Label = Label.new()
	cat_badge.text = "[%s]" % category
	cat_badge.add_theme_font_size_override("font_size", 8)
	cat_badge.modulate = cat_color
	cat_badge.custom_minimum_size = Vector2(85, 0)
	hbox.add_child(cat_badge)
	
	# 3. Task Name (Expands)
	var task_lbl: Label = Label.new()
	task_lbl.text = task_name
	task_lbl.add_theme_font_size_override("font_size", 9)
	task_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	task_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	hbox.add_child(task_lbl)
	
	# 4. Duration Pill (Verified Minutes)
	var dur_lbl: Label = Label.new()
	dur_lbl.text = "⏱️ %dm" % duration
	dur_lbl.add_theme_font_size_override("font_size", 8)
	dur_lbl.modulate = Color(0.85, 0.90, 0.95)
	dur_lbl.custom_minimum_size = Vector2(48, 0)
	hbox.add_child(dur_lbl)
	
	# 5. Rewards Badge
	var rewards_lbl: Label = Label.new()
	rewards_lbl.text = "+%d🪙 +%dxp" % [coins, xp]
	rewards_lbl.add_theme_font_size_override("font_size", 8)
	rewards_lbl.modulate = Color(0.96, 0.75, 0.20)
	rewards_lbl.custom_minimum_size = Vector2(80, 0)
	hbox.add_child(rewards_lbl)
	
	# 6. Action Buttons (Edit Notes / Delete)
	var edit_btn: Button = Button.new()
	edit_btn.text = "✏️"
	edit_btn.flat = true
	edit_btn.custom_minimum_size = Vector2(22, 20)
	edit_btn.focus_mode = Control.FOCUS_NONE
	edit_btn.add_theme_font_size_override("font_size", 9)
	edit_btn.tooltip_text = "Edit Task & Standup Notes"
	edit_btn.pressed.connect(func(): _open_edit_session_modal(session))
	hbox.add_child(edit_btn)
	
	var del_btn: Button = Button.new()
	del_btn.text = "🗑️"
	del_btn.flat = true
	del_btn.custom_minimum_size = Vector2(22, 20)
	del_btn.focus_mode = Control.FOCUS_NONE
	del_btn.add_theme_font_size_override("font_size", 9)
	del_btn.tooltip_text = "Delete biometric punch"
	del_btn.pressed.connect(func(): _delete_session(created_unix))
	hbox.add_child(del_btn)
	
	# 7. Sub-Row: What did I do today? (Notes preview)
	if not notes.is_empty():
		var notes_hbox: HBoxContainer = HBoxContainer.new()
		notes_hbox.add_theme_constant_override("separation", 4)
		
		var icon_lbl: Label = Label.new()
		icon_lbl.text = "  ↳ 📝"
		icon_lbl.add_theme_font_size_override("font_size", 8)
		icon_lbl.modulate = Color(0.40, 0.70, 1.0, 0.8)
		notes_hbox.add_child(icon_lbl)
		
		var notes_lbl: Label = Label.new()
		notes_lbl.text = notes.replace("\n", " • ")
		notes_lbl.add_theme_font_size_override("font_size", 8)
		notes_lbl.modulate = Color(0.65, 0.70, 0.82, 0.9)
		notes_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		notes_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		notes_hbox.add_child(notes_lbl)
		
		vbox.add_child(notes_hbox)
	
	return card

func _on_search_text_changed(new_text: String) -> void:
	_active_search_query = new_text.strip_edges().to_lower()
	_refresh_session_table()

func _clear_filters() -> void:
	_active_date_filter = ""
	_active_category_filter = "all"
	_active_search_query = ""
	if search_input:
		search_input.text = ""
	if table_category_filter:
		table_category_filter.selected = 0
	if selected_day_label:
		selected_day_label.text = "💡 Click any square above to filter sessions for that date."
	_refresh_heatmap()
	_refresh_session_table()

# ==============================================================================
# 📋 EXPORTER SUITE (STANDUP, RETROSPECTIVE, CSV, JSON)
# ==============================================================================
func _on_copy_standup_pressed() -> void:
	if not DatabaseManager:
		return
		
	var target_date: String = _active_date_filter if not _active_date_filter.is_empty() else Time.get_date_string_from_system()
	var markdown: String = DatabaseManager.generate_standup_markdown(target_date)
	
	DisplayServer.clipboard_set(markdown)
	if NotificationManager:
		NotificationManager.show_toast("📋 Standup Markdown copied to clipboard!", NotificationManager.ToastType.SUCCESS)

func _on_copy_retrospective_pressed() -> void:
	if not DatabaseManager:
		return
		
	var retro_md: String = DatabaseManager.generate_weekly_retrospective_markdown()
	DisplayServer.clipboard_set(retro_md)
	if NotificationManager:
		NotificationManager.show_toast("📓 Weekly Retrospective Report copied to clipboard!", NotificationManager.ToastType.SUCCESS)

func _on_export_csv_pressed() -> void:
	if not DatabaseManager:
		return
		
	var res: Dictionary = DatabaseManager.export_dtr_to_csv()
	if res.get("success", false):
		var path: String = res.get("path", "")
		if NotificationManager:
			NotificationManager.show_toast("📊 Exported %d verified punches to CSV: %s" % [res.get("count", 0), path.get_file()], NotificationManager.ToastType.SUCCESS)

func _on_backup_json_pressed() -> void:
	if not DatabaseManager:
		return
		
	var json_str: String = DatabaseManager.export_dtr_json()
	DisplayServer.clipboard_set(json_str)
	if NotificationManager:
		NotificationManager.show_toast("💾 Full DTR JSON backup copied to clipboard!", NotificationManager.ToastType.INFO)

# ==============================================================================
# ✏️ BIOMETRIC ACCOMPLISHMENT & NOTE EDITOR
# ==============================================================================
func _open_edit_session_modal(session: Dictionary) -> void:
	_editing_session_unix = int(session.get("created_unix", 0))
	
	var date_key: String = session.get("date_key", "")
	var duration: int = session.get("duration_minutes", 25)
	var coins: int = session.get("coins_earned", 0)
	var xp: int = session.get("exp_earned", 0)
	var start_time: String = session.get("start_time", "")
	var end_time: String = session.get("end_time", "")
	
	var time_range: String = ""
	if "T" in start_time and "T" in end_time:
		var s_parts = start_time.split("T")[1].split(":")
		var e_parts = end_time.split("T")[1].split(":")
		if s_parts.size() >= 2 and e_parts.size() >= 2:
			time_range = "%s:%s - %s:%s" % [s_parts[0], s_parts[1], e_parts[0], e_parts[1]]
	if time_range.is_empty():
		time_range = "Sprint (%dm)" % duration
		
	if modal_title:
		modal_title.text = "📝 Session Accomplishments & Standup Notes"
	if punch_time_label:
		punch_time_label.text = "📅 Date: %s  |  ⏱️ Time: %s (%dm verified)" % [date_key, time_range, duration]
	if punch_rewards_label:
		punch_rewards_label.text = "🪙 +%d Coins  |  ✨ +%d EXP  |  🔒 Immutable Biometric Punch" % [coins, xp]
		
	if modal_task_input:
		modal_task_input.text = session.get("task_name", "")
	if modal_notes_input:
		modal_notes_input.text = session.get("notes", "")
		
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
		
	var task_name: String = modal_task_input.text.strip_edges() if modal_task_input else "General Focus"
	if task_name.is_empty():
		task_name = "General Work"
		
	var notes: String = modal_notes_input.text.strip_edges() if modal_notes_input else ""
		
	var cat_text: String = modal_cat_option.get_item_text(modal_cat_option.selected) if modal_cat_option else "Development"
	var category: String = "Development"
	if "Study" in cat_text: category = "Study"
	elif "Writing" in cat_text: category = "Writing"
	elif "Design" in cat_text: category = "Design"
	elif "Admin" in cat_text: category = "Admin"
	elif "Gaming" in cat_text: category = "Gaming"
	elif "General" in cat_text: category = "General"
	
	var update_payload: Dictionary = {
		"task_name": task_name,
		"category": category,
		"notes": notes
	}
	
	if DatabaseManager.update_session(_editing_session_unix, update_payload):
		if NotificationManager:
			NotificationManager.show_toast("💾 Session accomplishments saved: %s" % task_name, NotificationManager.ToastType.INFO)
			
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
			NotificationManager.show_toast("🗑️ Biometric punch deleted.", NotificationManager.ToastType.INFO)
		refresh_all()
