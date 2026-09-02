extends Control
class_name TasksStudioTab

## 🎯 Sprint Tasks Command Board & Pomodoro Capacity Forecaster for Kronos.
## Phase 4 Features:
## 1. 3-Column Kanban Workflow (📥 Backlog, 🎯 Today's Sprint, ✅ Done).
## 2. Daily Cognitive Capacity Meter & Focus Velocity Gauge ($N \times 25\text{m}$ blocks).
## 3. 1-Click Timer Binding ("▶️ Focus Now" syncs active task & category to TimerEngine).
## 4. Smart Shorthand Quick-Add Parser (`#Category`, `[Np]`, `!high`).
## 5. Eisenhower Priority Matrix Badges (🔥 High, ⚡ Medium, 🌱 Low).
## 6. Category Tag Filter, Priority Filter, and Search.

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
# Top Capacity Card
@onready var capacity_meter_fill: Panel = $Scroll/ContentVBox/TopRow/CapacityCard/VBox/MeterBox/FillSegment
@onready var capacity_load_lbl: Label = $Scroll/ContentVBox/TopRow/CapacityCard/VBox/LoadLabel
@onready var capacity_stats_lbl: Label = $Scroll/ContentVBox/TopRow/CapacityCard/VBox/StatsLabel

# Top Quick-Add Card
@onready var quick_add_input: LineEdit = $Scroll/ContentVBox/TopRow/QuickAddCard/VBox/InputRow/QuickAddInput
@onready var btn_quick_add: Button = $Scroll/ContentVBox/TopRow/QuickAddCard/VBox/InputRow/BtnQuickAdd
@onready var btn_chip_dev: Button = $Scroll/ContentVBox/TopRow/QuickAddCard/VBox/ChipsRow/BtnChipDev
@onready var btn_chip_study: Button = $Scroll/ContentVBox/TopRow/QuickAddCard/VBox/ChipsRow/BtnChipStudy
@onready var btn_chip_high: Button = $Scroll/ContentVBox/TopRow/QuickAddCard/VBox/ChipsRow/BtnChipHigh
@onready var btn_chip_pom: Button = $Scroll/ContentVBox/TopRow/QuickAddCard/VBox/ChipsRow/BtnChipPom
@onready var btn_open_modal_add: Button = $Scroll/ContentVBox/TopRow/QuickAddCard/VBox/ChipsRow/BtnOpenModalAdd

# Filters Row
@onready var category_filter_option: OptionButton = $Scroll/ContentVBox/FilterBarCard/HBox/CategoryFilterOption
@onready var priority_filter_option: OptionButton = $Scroll/ContentVBox/FilterBarCard/HBox/PriorityFilterOption
@onready var search_input: LineEdit = $Scroll/ContentVBox/FilterBarCard/HBox/SearchInput

# 3-Column Kanban Board
@onready var col_backlog_title: Label = $Scroll/ContentVBox/KanbanBoard/ColBacklog/VBox/HeaderHBox/Title
@onready var col_backlog_vbox: VBoxContainer = $Scroll/ContentVBox/KanbanBoard/ColBacklog/VBox/BacklogListVBox

@onready var col_sprint_title: Label = $Scroll/ContentVBox/KanbanBoard/ColSprint/VBox/HeaderHBox/Title
@onready var col_sprint_vbox: VBoxContainer = $Scroll/ContentVBox/KanbanBoard/ColSprint/VBox/SprintListVBox

@onready var col_done_title: Label = $Scroll/ContentVBox/KanbanBoard/ColDone/VBox/HeaderHBox/Title
@onready var col_done_vbox: VBoxContainer = $Scroll/ContentVBox/KanbanBoard/ColDone/VBox/DoneListVBox

# Modal Overlay & Edit Modal
@onready var modal_overlay: PanelContainer = $ModalOverlay
@onready var task_modal: PanelContainer = $ModalOverlay/Center/TaskModal
@onready var task_modal_title: Label = $ModalOverlay/Center/TaskModal/VBox/TitleLabel
@onready var task_modal_title_input: LineEdit = $ModalOverlay/Center/TaskModal/VBox/TitleInput
@onready var task_modal_cat_input: LineEdit = $ModalOverlay/Center/TaskModal/VBox/MetaRow/CategoryInput
@onready var task_modal_prio_option: OptionButton = $ModalOverlay/Center/TaskModal/VBox/MetaRow/PriorityOption
@onready var task_modal_status_option: OptionButton = $ModalOverlay/Center/TaskModal/VBox/MetaRow2/StatusOption
@onready var task_modal_poms_input: SpinBox = $ModalOverlay/Center/TaskModal/VBox/MetaRow2/PomodoroSpinBox
@onready var task_modal_notes_input: TextEdit = $ModalOverlay/Center/TaskModal/VBox/NotesInput
@onready var task_modal_save_btn: Button = $ModalOverlay/Center/TaskModal/VBox/BtnRow/SaveBtn
@onready var task_modal_cancel_btn: Button = $ModalOverlay/Center/TaskModal/VBox/BtnRow/CancelBtn

# ==============================================================================
# 🎨 COLOR PALETTES
# ==============================================================================
const CATEGORY_COLORS: Dictionary = {
	"development": Color(0.31, 0.82, 0.91), # Cyan
	"study": Color(0.38, 0.74, 1.0),       # Blue
	"design": Color(0.96, 0.45, 0.75),      # Pink
	"writing": Color(0.85, 0.60, 1.0),     # Violet
	"admin": Color(0.96, 0.78, 0.25),       # Gold
	"lore": Color(0.96, 0.62, 0.04),       # Amber
	"general": Color(0.30, 0.85, 0.50)      # Emerald
}

const PRIORITY_COLORS: Dictionary = {
	"high": Color(1.0, 0.35, 0.35),   # Red
	"medium": Color(0.31, 0.82, 0.91),# Cyan
	"low": Color(0.30, 0.85, 0.50)    # Emerald
}

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _active_category_filter: String = "all"
var _active_priority_filter: String = "all"
var _active_search_query: String = ""
var _editing_task_id: String = ""

# ==============================================================================
# ⚙️ LIFECYCLE & SIGNALS
# ==============================================================================
func _ready() -> void:
	_init_dropdowns()
	_connect_signals()
	refresh_all()

func _init_dropdowns() -> void:
	if category_filter_option:
		category_filter_option.clear()
		category_filter_option.add_item("All Categories", 0)
		category_filter_option.add_item("Development", 1)
		category_filter_option.add_item("Study", 2)
		category_filter_option.add_item("Design", 3)
		category_filter_option.add_item("Writing", 4)
		category_filter_option.add_item("Admin", 5)
		category_filter_option.add_item("General", 6)
		category_filter_option.selected = 0
		
	if priority_filter_option:
		priority_filter_option.clear()
		priority_filter_option.add_item("All Priorities", 0)
		priority_filter_option.add_item("🔥 High", 1)
		priority_filter_option.add_item("⚡ Medium", 2)
		priority_filter_option.add_item("🌱 Low", 3)
		priority_filter_option.selected = 0
		
	if task_modal_prio_option:
		task_modal_prio_option.clear()
		task_modal_prio_option.add_item("⚡ Medium", 0)
		task_modal_prio_option.add_item("🔥 High", 1)
		task_modal_prio_option.add_item("🌱 Low", 2)
		
	if task_modal_status_option:
		task_modal_status_option.clear()
		task_modal_status_option.add_item("🎯 Today's Sprint", 0)
		task_modal_status_option.add_item("📥 Backlog", 1)
		task_modal_status_option.add_item("✅ Done", 2)

func _connect_signals() -> void:
	if EventBus:
		EventBus.task_added.connect(func(_t): refresh_all())
		EventBus.task_toggled.connect(func(_id, _c): refresh_all())
		EventBus.task_deleted.connect(func(_id): refresh_all())
		EventBus.active_task_selected.connect(func(_id, _t): refresh_all())
		
	if btn_quick_add:
		btn_quick_add.pressed.connect(_on_submit_quick_add)
	if quick_add_input:
		quick_add_input.text_submitted.connect(func(_txt): _on_submit_quick_add())
		
	# Shorthand chips
	if btn_chip_dev: btn_chip_dev.pressed.connect(func(): _append_to_quick_add(" #Dev"))
	if btn_chip_study: btn_chip_study.pressed.connect(func(): _append_to_quick_add(" #Study"))
	if btn_chip_high: btn_chip_high.pressed.connect(func(): _append_to_quick_add(" !high"))
	if btn_chip_pom: btn_chip_pom.pressed.connect(func(): _append_to_quick_add(" [2p]"))
	if btn_open_modal_add: btn_open_modal_add.pressed.connect(_open_create_task_modal)
		
	if category_filter_option:
		category_filter_option.item_selected.connect(_on_category_filter_selected)
	if priority_filter_option:
		priority_filter_option.item_selected.connect(_on_priority_filter_selected)
	if search_input:
		search_input.text_changed.connect(_on_search_text_changed)
		
	# Modal buttons
	if task_modal_save_btn:
		task_modal_save_btn.pressed.connect(_save_modal_task)
	if task_modal_cancel_btn:
		task_modal_cancel_btn.pressed.connect(_close_modal)

# ==============================================================================
# 🔄 REFRESH CONTROLLER
# ==============================================================================
func refresh_all() -> void:
	_refresh_capacity_meter()
	_refresh_kanban_columns()

func refresh_tab() -> void:
	refresh_all()

# ==============================================================================
# 🔋 SECTION 1: CAPACITY & VELOCITY GAUGE
# ==============================================================================
func _refresh_capacity_meter() -> void:
	if not GameState:
		return
		
	var cap: Dictionary = GameState.get_sprint_capacity()
	var planned_poms: int = cap.get("planned_poms", 0)
	var spent_poms: int = cap.get("spent_poms", 0)
	var planned_h: float = float(cap.get("planned_minutes", 0)) / 60.0
	var spent_h: float = float(cap.get("spent_minutes", 0)) / 60.0
	var cap_limit: int = cap.get("capacity_limit_poms", 12)
	var velocity_pct: float = cap.get("velocity_pct", 0.0)
	
	if capacity_load_lbl:
		capacity_load_lbl.text = "🎯 %d🍅 Planned (%.1fh)  •  ⏱️ %d🍅 Spent (%.1fh)" % [planned_poms, planned_h, spent_poms, spent_h]
		
	if capacity_stats_lbl:
		capacity_stats_lbl.text = "⚡ Velocity: %.0f%%  •  🔋 Daily Cap: %d🍅" % [velocity_pct, cap_limit]
		
	if capacity_meter_fill:
		var ratio: float = clampf(float(planned_poms) / float(cap_limit), 0.02, 1.0)
		capacity_meter_fill.size_flags_stretch_ratio = ratio
		if planned_poms > cap_limit:
			capacity_meter_fill.modulate = Color(1.0, 0.35, 0.35) # Red overload
		elif planned_poms >= 8:
			capacity_meter_fill.modulate = Color(0.96, 0.62, 0.04) # Amber optimal
		else:
			capacity_meter_fill.modulate = Color(0.31, 0.82, 0.91) # Cyan light

# ==============================================================================
# 📋 SECTION 2: 3-COLUMN KANBAN BOARD
# ==============================================================================
func _refresh_kanban_columns() -> void:
	if not GameState:
		return
		
	# Clear column containers
	if col_backlog_vbox:
		for c in col_backlog_vbox.get_children(): c.queue_free()
	if col_sprint_vbox:
		for c in col_sprint_vbox.get_children(): c.queue_free()
	if col_done_vbox:
		for c in col_done_vbox.get_children(): c.queue_free()
		
	var all_tasks: Array[Dictionary] = GameState.get_tasks()
	var active_id: String = GameState.active_task_id
	
	var backlog_cards: Array[Dictionary] = []
	var sprint_cards: Array[Dictionary] = []
	var done_cards: Array[Dictionary] = []
	
	for t in all_tasks:
		var cat: String = t.get("category", "General")
		var prio: String = t.get("priority", "medium")
		var title: String = t.get("title", "")
		var status: String = t.get("status", "sprint").to_lower()
		
		# Apply Category filter
		if _active_category_filter != "all" and cat.to_lower() != _active_category_filter.to_lower():
			continue
		# Apply Priority filter
		if _active_priority_filter != "all" and prio.to_lower() != _active_priority_filter.to_lower():
			continue
		# Apply Search filter
		if not _active_search_query.is_empty():
			var q = _active_search_query
			if not title.to_lower().contains(q) and not cat.to_lower().contains(q):
				continue
				
		match status:
			"backlog": backlog_cards.append(t)
			"done": done_cards.append(t)
			_: sprint_cards.append(t)
			
	# Update column headers
	if col_backlog_title: col_backlog_title.text = "📥 BACKLOG (%d)" % backlog_cards.size()
	if col_sprint_title: col_sprint_title.text = "🎯 TODAY'S SPRINT (%d)" % sprint_cards.size()
	if col_done_title: col_done_title.text = "✅ DONE (%d)" % done_cards.size()
	
	# Populate Backlog Column
	if col_backlog_vbox:
		if backlog_cards.is_empty():
			col_backlog_vbox.add_child(_create_empty_lane_label("No backlog tasks."))
		else:
			for t in backlog_cards:
				col_backlog_vbox.add_child(_create_task_card(t, "backlog", active_id))
				
	# Populate Sprint Column
	if col_sprint_vbox:
		if sprint_cards.is_empty():
			col_sprint_vbox.add_child(_create_empty_lane_label("Sprint empty. Commit tasks!"))
		else:
			for t in sprint_cards:
				col_sprint_vbox.add_child(_create_task_card(t, "sprint", active_id))
				
	# Populate Done Column
	if col_done_vbox:
		if done_cards.is_empty():
			col_done_vbox.add_child(_create_empty_lane_label("No completed tasks yet."))
		else:
			for t in done_cards:
				col_done_vbox.add_child(_create_task_card(t, "done", active_id))

func _create_empty_lane_label(text: String) -> Control:
	var lbl: Label = Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 8)
	lbl.modulate = Color(0.55, 0.60, 0.70, 0.7)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(0, 32)
	return lbl

func _create_task_card(task: Dictionary, lane: String, active_id: String) -> Control:
	var t_id: String = task.get("id", "")
	var title: String = task.get("title", "Untitled")
	var cat: String = task.get("category", "General")
	var prio: String = task.get("priority", "medium")
	var p_est: int = int(task.get("pomodoro_estimate", 1))
	var p_spent: int = int(task.get("pomodoro_spent", 0))
	var is_active: bool = (t_id == active_id and lane == "sprint")
	
	var card_panel: PanelContainer = PanelContainer.new()
	card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Style active task card with glowing cyan border
	var sbox: StyleBoxFlat = StyleBoxFlat.new()
	sbox.content_margin_left = 6
	sbox.content_margin_top = 6
	sbox.content_margin_right = 6
	sbox.content_margin_bottom = 6
	sbox.bg_color = Color(0.06, 0.08, 0.13, 0.95) if not is_active else Color(0.08, 0.14, 0.22, 0.98)
	sbox.border_width_left = 2 if is_active else 1
	sbox.border_width_top = 1
	sbox.border_width_right = 1
	sbox.border_width_bottom = 1
	sbox.border_color = Color(0.31, 0.82, 0.91, 0.9) if is_active else Color(0.18, 0.22, 0.32, 0.8)
	sbox.corner_radius_top_left = 4
	sbox.corner_radius_top_right = 4
	sbox.corner_radius_bottom_right = 4
	sbox.corner_radius_bottom_left = 4
	card_panel.add_theme_stylebox_override("panel", sbox)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	card_panel.add_child(vbox)
	
	# Top Badges Row
	var badge_row: HBoxContainer = HBoxContainer.new()
	badge_row.add_theme_constant_override("separation", 4)
	vbox.add_child(badge_row)
	
	# Category Badge
	var cat_lbl: Label = Label.new()
	cat_lbl.text = "[%s]" % cat
	cat_lbl.add_theme_font_size_override("font_size", 7)
	cat_lbl.modulate = CATEGORY_COLORS.get(cat.to_lower(), Color(0.31, 0.82, 0.91))
	badge_row.add_child(cat_lbl)
	
	# Priority Badge
	var prio_lbl: Label = Label.new()
	var p_icon: String = "⚡"
	if prio == "high": p_icon = "🔥 High"
	elif prio == "low": p_icon = "🌱 Low"
	else: p_icon = "⚡ Med"
	prio_lbl.text = p_icon
	prio_lbl.add_theme_font_size_override("font_size", 7)
	prio_lbl.modulate = PRIORITY_COLORS.get(prio, Color(0.31, 0.82, 0.91))
	badge_row.add_child(prio_lbl)
	
	# Pomodoro Budget Badge
	var pom_lbl: Label = Label.new()
	pom_lbl.text = "🍅 %d/%d" % [p_spent, p_est]
	pom_lbl.add_theme_font_size_override("font_size", 7)
	pom_lbl.modulate = Color(0.96, 0.62, 0.04) if p_spent >= p_est else Color(0.70, 0.75, 0.85)
	badge_row.add_child(pom_lbl)
	
	if is_active:
		var active_badge: Label = Label.new()
		active_badge.text = "🎯 ACTIVE"
		active_badge.add_theme_font_size_override("font_size", 7)
		active_badge.modulate = Color(0.31, 0.82, 0.91)
		badge_row.add_child(active_badge)
		
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	badge_row.add_child(spacer)
	
	# Edit button
	var edit_btn: Button = Button.new()
	edit_btn.text = "✏️"
	edit_btn.flat = true
	edit_btn.custom_minimum_size = Vector2(18, 16)
	edit_btn.focus_mode = Control.FOCUS_NONE
	edit_btn.tooltip_text = "Edit Task"
	edit_btn.pressed.connect(func(): _open_edit_task_modal(task))
	badge_row.add_child(edit_btn)
	
	# Delete button
	var del_btn: Button = Button.new()
	del_btn.text = "🗑️"
	del_btn.flat = true
	del_btn.custom_minimum_size = Vector2(18, 16)
	del_btn.focus_mode = Control.FOCUS_NONE
	del_btn.tooltip_text = "Delete Task"
	del_btn.pressed.connect(func(): _delete_task(t_id))
	badge_row.add_child(del_btn)
	
	# Title Row
	var title_lbl: Label = Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_size_override("font_size", 9)
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if lane == "done":
		title_lbl.modulate = Color(0.55, 0.60, 0.70, 0.8)
	vbox.add_child(title_lbl)
	
	# Actions Row
	var act_row: HBoxContainer = HBoxContainer.new()
	act_row.add_theme_constant_override("separation", 4)
	vbox.add_child(act_row)
	
	match lane:
		"backlog":
			var commit_btn: Button = Button.new()
			commit_btn.text = "→ Commit to Sprint"
			commit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			commit_btn.custom_minimum_size = Vector2(0, 18)
			commit_btn.add_theme_font_size_override("font_size", 7)
			commit_btn.focus_mode = Control.FOCUS_NONE
			commit_btn.pressed.connect(func(): _move_task(t_id, "sprint"))
			act_row.add_child(commit_btn)
			
		"sprint":
			if not is_active:
				var focus_btn: Button = Button.new()
				focus_btn.text = "▶️ Focus Now"
				focus_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				focus_btn.custom_minimum_size = Vector2(0, 18)
				focus_btn.add_theme_font_size_override("font_size", 7)
				focus_btn.add_theme_color_override("font_color", Color(0.31, 0.82, 0.91))
				focus_btn.focus_mode = Control.FOCUS_NONE
				focus_btn.pressed.connect(func(): _set_active_focus_task(t_id))
				act_row.add_child(focus_btn)
			else:
				var active_lbl: Label = Label.new()
				active_lbl.text = "⏱️ Focused on Timer"
				active_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				active_lbl.add_theme_font_size_override("font_size", 7)
				active_lbl.modulate = Color(0.31, 0.82, 0.91)
				act_row.add_child(active_lbl)
				
			var done_btn: Button = Button.new()
			done_btn.text = "✓ Done"
			done_btn.custom_minimum_size = Vector2(50, 18)
			done_btn.add_theme_font_size_override("font_size", 7)
			done_btn.add_theme_color_override("font_color", Color(0.30, 0.85, 0.50))
			done_btn.focus_mode = Control.FOCUS_NONE
			done_btn.pressed.connect(func(): _move_task(t_id, "done"))
			act_row.add_child(done_btn)
			
			var back_btn: Button = Button.new()
			back_btn.text = "← Backlog"
			back_btn.custom_minimum_size = Vector2(55, 18)
			back_btn.add_theme_font_size_override("font_size", 7)
			back_btn.focus_mode = Control.FOCUS_NONE
			back_btn.pressed.connect(func(): _move_task(t_id, "backlog"))
			act_row.add_child(back_btn)
			
		"done":
			var reopen_btn: Button = Button.new()
			reopen_btn.text = "↩ Reopen in Sprint"
			reopen_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			reopen_btn.custom_minimum_size = Vector2(0, 18)
			reopen_btn.add_theme_font_size_override("font_size", 7)
			reopen_btn.focus_mode = Control.FOCUS_NONE
			reopen_btn.pressed.connect(func(): _move_task(t_id, "sprint"))
			act_row.add_child(reopen_btn)
			
	return card_panel

# ==============================================================================
# 🎯 SECTION 3: ACTIONS & TIMER BINDING
# ==============================================================================
func _set_active_focus_task(task_id: String) -> void:
	if not GameState:
		return
	GameState.set_active_task(task_id)
	if AudioManager:
		AudioManager.play_sfx("click")
	if NotificationManager:
		var t = GameState.get_active_task()
		NotificationManager.show_toast("🎯 Bound to Timer: %s" % t.get("title", ""), NotificationManager.ToastType.SUCCESS)
	refresh_all()

func _move_task(task_id: String, new_status: String) -> void:
	if not GameState:
		return
	GameState.move_task_status(task_id, new_status)
	if new_status == "done":
		if AudioManager: AudioManager.play_sfx("coin")
		if NotificationManager: NotificationManager.show_toast("🎉 Task Complete! Great focus.", NotificationManager.ToastType.SUCCESS)
	else:
		if AudioManager: AudioManager.play_sfx("click")
	refresh_all()

func _delete_task(task_id: String) -> void:
	if not GameState:
		return
	if GameState.delete_task(task_id):
		if NotificationManager:
			NotificationManager.show_toast("🗑️ Task removed.", NotificationManager.ToastType.INFO)
		refresh_all()

func _on_submit_quick_add() -> void:
	if not GameState or not quick_add_input:
		return
	var raw: String = quick_add_input.text.strip_edges()
	if raw.is_empty():
		return
		
	GameState.add_task(raw)
	quick_add_input.text = ""
	if AudioManager:
		AudioManager.play_sfx("click")
	if NotificationManager:
		NotificationManager.show_toast("➕ Task added to today's sprint!", NotificationManager.ToastType.SUCCESS)
	refresh_all()

func _append_to_quick_add(tag: String) -> void:
	if not quick_add_input:
		return
	quick_add_input.text = quick_add_input.text.strip_edges() + tag + " "
	quick_add_input.grab_focus()
	quick_add_input.caret_column = quick_add_input.text.length()

# ==============================================================================
# 🔍 SECTION 4: FILTERS
# ==============================================================================
func _on_category_filter_selected(idx: int) -> void:
	if idx == 0:
		_active_category_filter = "all"
	else:
		_active_category_filter = category_filter_option.get_item_text(idx).to_lower()
	_refresh_kanban_columns()

func _on_priority_filter_selected(idx: int) -> void:
	match idx:
		0: _active_priority_filter = "all"
		1: _active_priority_filter = "high"
		2: _active_priority_filter = "medium"
		3: _active_priority_filter = "low"
	_refresh_kanban_columns()

func _on_search_text_changed(new_text: String) -> void:
	_active_search_query = new_text.strip_edges().to_lower()
	_refresh_kanban_columns()

# ==============================================================================
# 📝 SECTION 5: TASK MODAL CRUD
# ==============================================================================
func _open_create_task_modal() -> void:
	_editing_task_id = ""
	if task_modal_title: task_modal_title.text = "➕ Create Sprint Task"
	if task_modal_title_input: task_modal_title_input.text = ""
	if task_modal_cat_input: task_modal_cat_input.text = "Development"
	if task_modal_prio_option: task_modal_prio_option.selected = 0
	if task_modal_status_option: task_modal_status_option.selected = 0
	if task_modal_poms_input: task_modal_poms_input.value = 2
	if task_modal_notes_input: task_modal_notes_input.text = ""
	
	if modal_overlay: modal_overlay.visible = true

func _open_edit_task_modal(task: Dictionary) -> void:
	_editing_task_id = task.get("id", "")
	if task_modal_title: task_modal_title.text = "✏️ Edit Task"
	if task_modal_title_input: task_modal_title_input.text = task.get("title", "")
	if task_modal_cat_input: task_modal_cat_input.text = task.get("category", "General")
	
	var p = task.get("priority", "medium")
	if task_modal_prio_option:
		match p:
			"high": task_modal_prio_option.selected = 1
			"low": task_modal_prio_option.selected = 2
			_: task_modal_prio_option.selected = 0
			
	var s = task.get("status", "sprint")
	if task_modal_status_option:
		match s:
			"backlog": task_modal_status_option.selected = 1
			"done": task_modal_status_option.selected = 2
			_: task_modal_status_option.selected = 0
			
	if task_modal_poms_input:
		task_modal_poms_input.value = task.get("pomodoro_estimate", 1)
	if task_modal_notes_input:
		task_modal_notes_input.text = task.get("notes", "")
		
	if modal_overlay: modal_overlay.visible = true

func _close_modal() -> void:
	if modal_overlay: modal_overlay.visible = false

func _save_modal_task() -> void:
	if not GameState or not task_modal_title_input:
		return
		
	var title = task_modal_title_input.text.strip_edges()
	var cat = task_modal_cat_input.text.strip_edges() if task_modal_cat_input else "General"
	var prio = "medium"
	if task_modal_prio_option:
		match task_modal_prio_option.selected:
			1: prio = "high"
			2: prio = "low"
			_: prio = "medium"
			
	var status = "sprint"
	if task_modal_status_option:
		match task_modal_status_option.selected:
			1: status = "backlog"
			2: status = "done"
			_: status = "sprint"
			
	var poms = int(task_modal_poms_input.value) if task_modal_poms_input else 1
	var notes = task_modal_notes_input.text.strip_edges() if task_modal_notes_input else ""
	
	if title.is_empty():
		if NotificationManager:
			NotificationManager.show_toast("Task title cannot be empty!", NotificationManager.ToastType.WARNING)
		return
		
	if _editing_task_id.is_empty():
		GameState.add_sprint_task(title, cat, prio, status, poms, notes)
		if NotificationManager:
			NotificationManager.show_toast("✨ Sprint Task created!", NotificationManager.ToastType.SUCCESS)
	else:
		GameState.update_task(_editing_task_id, {
			"title": title,
			"category": cat,
			"priority": prio,
			"status": status,
			"pomodoro_estimate": poms,
			"notes": notes,
			"completed": (status == "done")
		})
		if NotificationManager:
			NotificationManager.show_toast("💾 Task updated!", NotificationManager.ToastType.INFO)
			
	_close_modal()
	refresh_all()
