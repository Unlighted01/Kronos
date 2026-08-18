extends PanelContainer
class_name RightPanel

## Right Panel for Kronos Desktop Workspace.
## Handles Pet Vitals ([VITALS]), Inventory Bag ([BAG] with Feed/Equip actions),
## and Daily Time Records ([DTR] with filtering, session logs, and CSV export).

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var title_label: Label = $VBox/Header/HBox/Title
@onready var close_btn: Button = $VBox/Header/HBox/CloseButton
@onready var tab_container: TabContainer = $VBox/TabContainer

# Vitals Tab References
@onready var vitals_lvl_badge: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/HeaderCard/HBox/LevelBadge
@onready var vitals_coins_badge: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/HeaderCard/HBox/CoinsBadge
@onready var exp_label: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/ExpCard/VBox/HBox/ExpLabel
@onready var exp_bar: ProgressBar = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/ExpCard/VBox/ExpBar
@onready var energy_val_label: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/EnergyCard/VBox/HBox/EnergyValLabel
@onready var energy_buff_badge: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/EnergyCard/VBox/HBox/BuffBadge
@onready var energy_bar: ProgressBar = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/EnergyCard/VBox/EnergyBar
@onready var joy_val_label: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/JoyCard/VBox/HBox/JoyValLabel
@onready var joy_bar: ProgressBar = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/JoyCard/VBox/JoyBar
@onready var streak_badge: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/StreakCard/StreakLabel

# Bag Tab References
@onready var bag_list_vbox: VBoxContainer = $VBox/TabContainer/BAG/ScrollContainer/BagVBox

# DTR Tab References
@onready var total_time_label: Label = $VBox/TabContainer/DTR/ScrollContainer/DtrVBox/MetricsRow/TimeCard/VBox/TimeVal
@onready var total_coins_label: Label = $VBox/TabContainer/DTR/ScrollContainer/DtrVBox/MetricsRow/CoinsCard/VBox/CoinsVal
@onready var date_filter_input: LineEdit = $VBox/TabContainer/DTR/ScrollContainer/DtrVBox/ControlsRow/DateInput
@onready var date_toggle_btn: Button = $VBox/TabContainer/DTR/ScrollContainer/DtrVBox/ControlsRow/DateToggleBtn
@onready var export_csv_btn: Button = $VBox/TabContainer/DTR/ScrollContainer/DtrVBox/ControlsRow/ExportCsvBtn
@onready var add_entry_btn: Button = $VBox/TabContainer/DTR/ScrollContainer/DtrVBox/AddEntryBtn
@onready var dtr_export_status_label: Label = $VBox/TabContainer/DTR/ScrollContainer/DtrVBox/ExportStatusLabel
@onready var dtr_list_vbox: VBoxContainer = $VBox/TabContainer/DTR/ScrollContainer/DtrVBox/SessionsListVBox

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _is_today_filter: bool = true

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	_connect_ui_signals()
	_connect_event_bus()
	
	# Initial UI updates
	_refresh_vitals_tab()
	_refresh_bag_tab()
	_refresh_dtr_tab()

func _connect_ui_signals() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
		
	if date_toggle_btn:
		date_toggle_btn.pressed.connect(_on_date_toggle_pressed)
		
	if date_filter_input:
		date_filter_input.text = Time.get_date_string_from_system()
		date_filter_input.text_changed.connect(func(_new_text: String): _refresh_dtr_sessions())
		
	if export_csv_btn:
		export_csv_btn.pressed.connect(_on_export_csv_pressed)
		
	if add_entry_btn:
		add_entry_btn.pressed.connect(_on_add_entry_pressed)

func _connect_event_bus() -> void:
	EventBus.exp_changed.connect(_on_exp_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.joy_changed.connect(_on_joy_changed)
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.streak_changed.connect(_on_streak_changed)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	EventBus.item_used.connect(_on_item_used)
	EventBus.cosmetic_equipped.connect(_on_cosmetic_equipped)
	EventBus.cosmetic_unequipped.connect(_on_cosmetic_unequipped)
	EventBus.session_completed.connect(_on_session_completed)
	EventBus.room_changed.connect(func(_r): _refresh_vitals_tab())
	EventBus.pet_room_changed.connect(func(_r): _refresh_vitals_tab())
	EventBus.pet_called.connect(func(_r): _refresh_vitals_tab())

# ==============================================================================
# 📊 TAB 1: VITALS
# ==============================================================================
func _refresh_vitals_tab() -> void:
	if not GameState:
		return
		
	# Level & Coins badges
	if vitals_lvl_badge:
		vitals_lvl_badge.text = "LVL %d" % GameState.level
	if vitals_coins_badge:
		vitals_coins_badge.text = "%d G" % GameState.coins
		
	# EXP Bar
	var req_exp: int = GameState.get_exp_required_for_level(GameState.level)
	if exp_label:
		exp_label.text = "%d / %d" % [GameState.exp, req_exp]
	if exp_bar:
		exp_bar.max_value = float(req_exp)
		exp_bar.value = float(GameState.exp)
		
	# Energy Bar & Buff Badge
	var is_buffed: bool = GameState.is_energy_buffed()
	if energy_val_label:
		energy_val_label.text = "%d%%" % int(round(GameState.energy))
	if energy_buff_badge:
		energy_buff_badge.visible = is_buffed
	if energy_bar:
		energy_bar.max_value = GameState.MAX_ENERGY
		energy_bar.value = GameState.energy
		energy_bar.modulate = Color(0.3, 1.0, 0.4) if is_buffed else Color(0.96, 0.62, 0.04)
		
	# Joy Bar
	if joy_val_label:
		joy_val_label.text = "%d%%" % int(round(GameState.joy))
	if joy_bar:
		joy_bar.max_value = GameState.MAX_JOY
		joy_bar.value = GameState.joy
		
	# Streak
	if streak_badge:
		streak_badge.text = "🔥 %d FOCUS STREAK" % GameState.streak
		streak_badge.visible = GameState.streak > 0

# ==============================================================================
# 🎒 TAB 2: BAG (INVENTORY)
# ==============================================================================
func _refresh_bag_tab() -> void:
	if not bag_list_vbox or not GameState:
		return
		
	# Clear previous slots
	for child in bag_list_vbox.get_children():
		child.queue_free()
		
	var inv: Array[Dictionary] = GameState.inventory
	if inv.is_empty():
		var empty_card: PanelContainer = PanelContainer.new()
		empty_card.custom_minimum_size = Vector2(0, 48)
		empty_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var center: CenterContainer = CenterContainer.new()
		center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center.size_flags_vertical = Control.SIZE_EXPAND_FILL
		empty_card.add_child(center)
		
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "🎒 BAG EMPTY\n(Visit Shop to buy treats)"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 8)
		empty_lbl.modulate = Color(0.58, 0.64, 0.72)
		center.add_child(empty_lbl)
		
		bag_list_vbox.add_child(empty_card)
		return
		
	# Populate items
	for item_entry in inv:
		var item_id: String = item_entry.get("item_id", "")
		var quantity: int = item_entry.get("quantity", 1)
		var item_def: Dictionary = GameState.get_item_def(item_id)
		
		var slot_card: Control = _create_inventory_slot(item_id, item_def, quantity)
		bag_list_vbox.add_child(slot_card)

func _create_inventory_slot(item_id: String, item_def: Dictionary, quantity: int) -> Control:
	var item_name: String = item_def.get("name", item_id)
	var item_icon: String = item_def.get("icon", "📦")
	var category: String = item_def.get("category", "snack")
	var slot_type: String = item_def.get("slot", "head")
	
	var slot_panel: PanelContainer = PanelContainer.new()
	slot_panel.custom_minimum_size = Vector2(0, 36)
	slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 6)
	slot_panel.add_child(hbox)
	
	# Icon
	var icon_lbl: Label = Label.new()
	icon_lbl.text = item_icon
	icon_lbl.add_theme_font_size_override("font_size", 16)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)
	
	# Item Info
	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 1)
	hbox.add_child(info_vbox)
	
	var name_lbl: Label = Label.new()
	name_lbl.text = "%s %s" % [item_name, ("(x%d)" % quantity) if quantity > 1 else ""]
	name_lbl.add_theme_font_size_override("font_size", 9)
	info_vbox.add_child(name_lbl)
	
	var cat_lbl: Label = Label.new()
	cat_lbl.text = category.to_upper()
	cat_lbl.add_theme_font_size_override("font_size", 7)
	cat_lbl.modulate = Color(0.93, 0.28, 0.60) if category == "cosmetic" else Color(0.31, 0.82, 0.91)
	info_vbox.add_child(cat_lbl)
	
	# Action Button based on category
	if category == "snack":
		var feed_btn: Button = Button.new()
		feed_btn.text = "FEED"
		feed_btn.custom_minimum_size = Vector2(46, 20)
		feed_btn.add_theme_font_size_override("font_size", 8)
		feed_btn.modulate = Color(0.96, 0.62, 0.04) # Gold
		feed_btn.pressed.connect(func(): _on_feed_item_pressed(item_id))
		hbox.add_child(feed_btn)
	elif category == "cosmetic":
		var is_equipped: bool = GameState.is_cosmetic_equipped(item_id)
		var equip_btn: Button = Button.new()
		equip_btn.text = "✓ ON" if is_equipped else "EQUIP"
		equip_btn.custom_minimum_size = Vector2(46, 20)
		equip_btn.add_theme_font_size_override("font_size", 8)
		equip_btn.modulate = Color(0.31, 0.82, 0.91) if is_equipped else Color(1.0, 1.0, 1.0)
		equip_btn.pressed.connect(func(): _on_equip_toggle_pressed(slot_type, item_id))
		hbox.add_child(equip_btn)
	elif category == "decor":
		var placed_badge: Label = Label.new()
		placed_badge.text = "PLACED"
		placed_badge.add_theme_font_size_override("font_size", 8)
		placed_badge.modulate = Color(0.40, 0.85, 0.55) # Green
		hbox.add_child(placed_badge)
		
	return slot_panel

func _on_feed_item_pressed(item_id: String) -> void:
	if GameState.use_item(item_id):
		_refresh_bag_tab()
		_refresh_vitals_tab()
		if DatabaseManager:
			DatabaseManager.save_game()

func _on_equip_toggle_pressed(slot: String, cosmetic_id: String) -> void:
	if GameState.is_cosmetic_equipped(cosmetic_id):
		GameState.unequip_cosmetic(slot)
	else:
		GameState.equip_cosmetic(slot, cosmetic_id)
	_refresh_bag_tab()
	if DatabaseManager:
		DatabaseManager.save_game()

# ==============================================================================
# 📝 TAB 3: DTR (DAILY TIME RECORDS)
# ==============================================================================
func _refresh_dtr_tab() -> void:
	_refresh_dtr_metrics()
	_refresh_dtr_sessions()

func _refresh_dtr_metrics() -> void:
	if not DatabaseManager:
		return
		
	var records: Array[Dictionary] = DatabaseManager.get_all_records()
	var total_min: int = 0
	var total_coins: int = 0
	var today_str: String = Time.get_date_string_from_system()
	
	for r in records:
		if not _is_today_filter or r.get("date_key", "") == today_str:
			total_min += r.get("duration_minutes", 0)
			total_coins += r.get("coins_earned", 0)
			
	if total_time_label:
		if total_min >= 60:
			total_time_label.text = "%.1fh" % (float(total_min) / 60.0)
		else:
			total_time_label.text = "%dm" % total_min
			
	if total_coins_label:
		total_coins_label.text = "+%d" % total_coins

func _refresh_dtr_sessions() -> void:
	if not dtr_list_vbox or not DatabaseManager:
		return
		
	for child in dtr_list_vbox.get_children():
		child.queue_free()
		
	var records: Array[Dictionary] = DatabaseManager.get_all_records()
	var filter_date: String = date_filter_input.text.strip_edges() if date_filter_input else ""
	var today_str: String = Time.get_date_string_from_system()
	
	var filtered: Array[Dictionary] = []
	for i in range(records.size() - 1, -1, -1): # Reverse chronological
		var r: Dictionary = records[i]
		var match_filter: bool = false
		if _is_today_filter:
			match_filter = (r.get("date_key", "") == today_str)
		else:
			if filter_date == "" or filter_date == "ALL":
				match_filter = true
			else:
				match_filter = (r.get("date_key", "") == filter_date or r.get("task_name", "").containsn(filter_date))
				
		if match_filter:
			filtered.append(r)
			
	if filtered.is_empty():
		var empty_card: PanelContainer = PanelContainer.new()
		empty_card.custom_minimum_size = Vector2(0, 40)
		empty_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var center: CenterContainer = CenterContainer.new()
		center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center.size_flags_vertical = Control.SIZE_EXPAND_FILL
		empty_card.add_child(center)
		
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "NO DTR SESSIONS"
		empty_lbl.add_theme_font_size_override("font_size", 8)
		empty_lbl.modulate = Color(0.58, 0.64, 0.72)
		center.add_child(empty_lbl)
		
		dtr_list_vbox.add_child(empty_card)
		return
		
	for session in filtered:
		var card: Control = _create_dtr_card(session)
		dtr_list_vbox.add_child(card)

func _create_dtr_card(session: Dictionary) -> Control:
	var task_name: String = session.get("task_name", "General Work")
	var category: String = session.get("category", "Development")
	var duration_min: int = session.get("duration_minutes", 0)
	var coins: int = session.get("coins_earned", 0)
	var xp: int = session.get("exp_earned", 0)
	var status: String = session.get("status", "completed")
	var start_time: String = session.get("start_time", "")
	
	var time_snippet: String = ""
	if start_time != "":
		var parts: PackedStringArray = start_time.split("T")
		if parts.size() > 1:
			var time_parts: PackedStringArray = parts[1].split(":")
			if time_parts.size() >= 2:
				time_snippet = "%s:%s" % [time_parts[0], time_parts[1]]
				
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 42)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	card.add_child(vbox)
	
	# Top line: Task Name + Coins
	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(top_hbox)
	
	var task_lbl: Label = Label.new()
	task_lbl.text = task_name
	task_lbl.add_theme_font_size_override("font_size", 9)
	task_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	task_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top_hbox.add_child(task_lbl)
	
	var coins_lbl: Label = Label.new()
	coins_lbl.text = "+%d 🪙" % coins
	coins_lbl.add_theme_font_size_override("font_size", 8)
	coins_lbl.modulate = Color(0.96, 0.62, 0.04) # Gold
	top_hbox.add_child(coins_lbl)
	
	# Bottom line: Category & Duration + Status
	var bottom_hbox: HBoxContainer = HBoxContainer.new()
	bottom_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(bottom_hbox)
	
	var details_lbl: Label = Label.new()
	details_lbl.text = "%dm • %s %s" % [duration_min, category, ("• " + time_snippet) if time_snippet != "" else ""]
	details_lbl.add_theme_font_size_override("font_size", 7)
	details_lbl.modulate = Color(0.31, 0.82, 0.91) # Cyan
	details_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_hbox.add_child(details_lbl)
	
	var status_lbl: Label = Label.new()
	status_lbl.text = status.to_upper()
	status_lbl.add_theme_font_size_override("font_size", 7)
	status_lbl.modulate = Color(0.40, 0.85, 0.55) if status == "completed" else Color(0.90, 0.40, 0.40)
	bottom_hbox.add_child(status_lbl)
	
	return card

func _on_date_toggle_pressed() -> void:
	_is_today_filter = not _is_today_filter
	if date_toggle_btn:
		date_toggle_btn.text = "TODAY" if _is_today_filter else "ALL"
		date_toggle_btn.modulate = Color(0.31, 0.82, 0.91) if _is_today_filter else Color(1.0, 1.0, 1.0)
	_refresh_dtr_tab()

func _on_export_csv_pressed() -> void:
	if not DatabaseManager:
		return
		
	var res: Dictionary = DatabaseManager.export_dtr_to_csv()
	var path: String = res.get("path", "")
	var count: int = res.get("count", 0)
	
	if dtr_export_status_label:
		if path != "":
			dtr_export_status_label.text = "✓ Exported %d logs to CSV\n%s" % [count, path.get_file()]
			dtr_export_status_label.modulate = Color(0.3, 1.0, 0.4)
		else:
			dtr_export_status_label.text = "✗ Export failed"
			dtr_export_status_label.modulate = Color(1.0, 0.3, 0.3)

func _on_add_entry_pressed() -> void:
	# Add a standard focus record to DTR
	if not DatabaseManager or not TimerEngine:
		return
		
	var now_unix: int = Time.get_unix_time_from_system()
	var new_entry: Dictionary = {
		"task_name": TimerEngine.active_task_name,
		"category": TimerEngine.active_category,
		"start_time": Time.get_datetime_string_from_unix_time(now_unix - 1500),
		"end_time": Time.get_datetime_string_from_unix_time(now_unix),
		"duration_minutes": 25,
		"status": "completed",
		"coins_earned": 100,
		"exp_earned": 50,
		"date_key": Time.get_date_string_from_system(),
		"created_unix": now_unix
	}
	
	DatabaseManager.log_session(new_entry)
	GameState.add_coins(100, "dtr_manual_log")
	GameState.add_exp(50)
	
	_refresh_dtr_tab()
	_refresh_vitals_tab()

# ==============================================================================
# 🔄 EVENT HANDLERS & HELPERS
# ==============================================================================
func _on_close_pressed() -> void:
	var wc: WindowController = _find_window_controller()
	if wc:
		wc.toggle_right_panel()
	else:
		visible = false
		EventBus.panel_visibility_changed.emit("right", false)

func _on_exp_changed(_cur: int, _req: int, _lvl: int) -> void:
	_refresh_vitals_tab()

func _on_level_up(_new_lvl: int) -> void:
	_refresh_vitals_tab()

func _on_energy_changed(_cur: float, _max: float, _buffed: bool) -> void:
	_refresh_vitals_tab()

func _on_joy_changed(_cur: float, _max: float) -> void:
	_refresh_vitals_tab()

func _on_coins_changed(_balance: int, _delta: int, _reason: String) -> void:
	_refresh_vitals_tab()

func _on_streak_changed(_streak: int) -> void:
	_refresh_vitals_tab()

func _on_inventory_changed(_inv: Array[Dictionary]) -> void:
	_refresh_bag_tab()

func _on_item_used(_item_id: String, _data: Dictionary) -> void:
	_refresh_bag_tab()
	_refresh_vitals_tab()

func _on_cosmetic_equipped(_slot: String, _cosmetic_id: String) -> void:
	_refresh_bag_tab()

func _on_cosmetic_unequipped(_slot: String) -> void:
	_refresh_bag_tab()

func _on_session_completed(_type: String, _coins: int, _xp: int, _streak: int) -> void:
	_refresh_dtr_tab()
	_refresh_vitals_tab()

func _find_window_controller() -> WindowController:
	var cur: Node = get_parent()
	while cur:
		if cur is WindowController:
			return cur as WindowController
		cur = cur.get_parent()
	return null
