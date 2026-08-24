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
@onready var kp_label: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/KpCard/HBox/KpLabel
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

# DTR Modal References
@onready var dtr_modal: PanelContainer = $DTRModal
@onready var dtr_task_input: LineEdit = $DTRModal/Center/Card/VBox/TaskInput
@onready var dtr_cat_input: LineEdit = $DTRModal/Center/Card/VBox/CategoryInput
@onready var dtr_start_input: LineEdit = $DTRModal/Center/Card/VBox/HBox/StartVBox/StartInput
@onready var dtr_end_input: LineEdit = $DTRModal/Center/Card/VBox/HBox/EndVBox/EndInput
@onready var dtr_date_input: LineEdit = $DTRModal/Center/Card/VBox/DateInput
@onready var dtr_save_btn: Button = $DTRModal/Center/Card/VBox/SaveBtn
@onready var dtr_delete_btn: Button = $DTRModal/Center/Card/VBox/DeleteBtn
@onready var dtr_cancel_btn: Button = $DTRModal/Center/Card/VBox/CancelBtn

# Audio & Alerts References
@onready var master_slider: HSlider = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/MasterRow/MasterSlider
@onready var mute_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/MasterRow/MuteBtn
@onready var ambience_slider: HSlider = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/AmbienceRow/AmbienceSlider
@onready var ambience_toggle_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/AmbienceRow/AmbienceToggleBtn
@onready var sfx_slider: HSlider = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/SfxRow/SfxSlider
@onready var test_sfx_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/SfxRow/TestSfxBtn
@onready var timer_notif_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/NotifsRow/TimerNotifBtn
@onready var pet_nudge_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/NotifsRow/PetNudgeBtn

# Study Deck References
@onready var deck_count_badge: Label = $VBox/TabContainer/DECK/ScrollContainer/DeckVBox/HeaderCard/HBox/CountBadge
@onready var deck_kp_badge: Label = $VBox/TabContainer/DECK/ScrollContainer/DeckVBox/HeaderCard/HBox/KpBadge
@onready var deck_q_input: LineEdit = $VBox/TabContainer/DECK/ScrollContainer/DeckVBox/AddCardPanel/VBox/QuestionInput
@onready var deck_a_input: LineEdit = $VBox/TabContainer/DECK/ScrollContainer/DeckVBox/AddCardPanel/VBox/AnswerInput
@onready var deck_subject_input: LineEdit = $VBox/TabContainer/DECK/ScrollContainer/DeckVBox/AddCardPanel/VBox/SubjectInput
@onready var deck_add_btn: Button = $VBox/TabContainer/DECK/ScrollContainer/DeckVBox/AddCardPanel/VBox/AddBtn
@onready var deck_cards_list_vbox: VBoxContainer = $VBox/TabContainer/DECK/ScrollContainer/DeckVBox/CardsListVBox

# Config Tab UI references
@onready var scale_1x_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/ScaleCard/VBox/HBox/Scale1xBtn
@onready var scale_125x_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/ScaleCard/VBox/HBox/Scale125xBtn
@onready var scale_15x_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/ScaleCard/VBox/HBox/Scale15xBtn
@onready var pin_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/PinCard/VBox/PinButton
@onready var work_time_input: LineEdit = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/TimerCard/VBox/Grid/WorkVBox/WorkTimeInput
@onready var break_time_input: LineEdit = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/TimerCard/VBox/Grid/BreakVBox/BreakTimeInput
@onready var cycle_input: LineEdit = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/TimerCard/VBox/Grid/CycleVBox/CycleInput
@onready var mode_toggle_btn: OptionButton = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/TimerCard/VBox/ModeRow/ModeToggleBtn
@onready var apply_timer_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/TimerCard/VBox/ApplyTimerBtn
@onready var manual_save_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/SaveCard/VBox/ManualSaveBtn
@onready var save_status_label: Label = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/SaveCard/VBox/SaveStatusLabel

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _is_today_filter: bool = true
var _current_scale_preset: float = 1.0
var _editing_dtr_unix: int = 0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	if TimerEngine and mode_toggle_btn:
		mode_toggle_btn.selected = TimerEngine.current_mode
		
	if tab_container:
		tab_container.tab_changed.connect(_on_tab_changed)
		
	_connect_ui_signals()
	_connect_event_bus()
	
	# Initial UI updates
	_refresh_vitals_tab()
	_refresh_bag_tab()
	_refresh_dtr_tab()
	_refresh_deck_tab()
	_refresh_config_ui()

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
		
	# Audio & Notification Controls
	if master_slider:
		master_slider.value_changed.connect(func(v): GameState.set_audio_setting("master_volume", v))
	if mute_btn:
		mute_btn.pressed.connect(_on_mute_toggled)
	if ambience_slider:
		ambience_slider.value_changed.connect(func(v): GameState.set_audio_setting("ambience_volume", v))
	if ambience_toggle_btn:
		ambience_toggle_btn.pressed.connect(_on_ambience_toggled)
	if sfx_slider:
		sfx_slider.value_changed.connect(func(v): GameState.set_audio_setting("sfx_volume", v))
	if test_sfx_btn:
		test_sfx_btn.pressed.connect(func():
			if AudioManager:
				AudioManager.play_sfx("bell")
		)
	if timer_notif_btn:
		timer_notif_btn.pressed.connect(_on_timer_notifs_toggled)
	if pet_nudge_btn:
		pet_nudge_btn.pressed.connect(_on_pet_nudges_toggled)

	if scale_1x_btn:
		scale_1x_btn.pressed.connect(func(): _apply_scale(1.0))
	if scale_125x_btn:
		scale_125x_btn.pressed.connect(func(): _apply_scale(1.25))
	if scale_15x_btn:
		scale_15x_btn.pressed.connect(func(): _apply_scale(1.5))
		
	if pin_btn:
		pin_btn.pressed.connect(_on_pin_toggle_pressed)
		
	if apply_timer_btn:
		apply_timer_btn.pressed.connect(_on_apply_timers_pressed)
		
	if manual_save_btn:
		manual_save_btn.pressed.connect(_on_manual_save_pressed)
		
	if dtr_save_btn:
		dtr_save_btn.pressed.connect(_on_dtr_modal_save)
	if dtr_delete_btn:
		dtr_delete_btn.pressed.connect(_on_dtr_modal_delete)
	if dtr_cancel_btn:
		dtr_cancel_btn.pressed.connect(func(): dtr_modal.hide())
		
	if deck_add_btn:
		deck_add_btn.pressed.connect(_on_add_card_pressed)

func _connect_event_bus() -> void:
	EventBus.exp_changed.connect(_on_exp_changed)
	EventBus.level_up.connect(_on_level_up)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.joy_changed.connect(_on_joy_changed)
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.knowledge_points_changed.connect(_on_kp_changed)
	EventBus.streak_changed.connect(_on_streak_changed)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	EventBus.item_used.connect(_on_item_used)
	EventBus.cosmetic_equipped.connect(_on_cosmetic_equipped)
	EventBus.cosmetic_unequipped.connect(_on_cosmetic_unequipped)
	EventBus.decor_placed.connect(func(_i, _r, _p): _refresh_bag_tab())
	EventBus.session_completed.connect(_on_session_completed)
	EventBus.audio_settings_changed.connect(_refresh_audio_ui)
	EventBus.room_changed.connect(func(_r): _refresh_vitals_tab())
	EventBus.pet_room_changed.connect(func(_r): _refresh_vitals_tab())
	EventBus.pet_called.connect(func(_r): _refresh_vitals_tab())
	EventBus.window_scale_changed.connect(_on_window_scale_changed)
	EventBus.window_pin_toggled.connect(_on_window_pin_toggled)
	EventBus.save_completed.connect(_on_save_completed)
	EventBus.flashcards_updated.connect(_refresh_deck_tab)

func _on_tab_changed(tab_idx: int) -> void:
	if not title_label:
		return
	match tab_idx:
		0: title_label.text = "◈ VITALS"
		1: title_label.text = "◈ INVENTORY BAG"
		2: title_label.text = "◈ DAILY TIME RECORD"
		3: title_label.text = "◈ STUDY DECK"
		4: title_label.text = "◈ SETTINGS"

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
		
	# Knowledge Points
	if kp_label:
		kp_label.text = "%d KP" % GameState.knowledge_points
		
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
	if category == "decor":
		var room_name_str: String = item_def.get("target_room_name", "Room")
		cat_lbl.text = "📍 %s" % room_name_str.to_upper()
		cat_lbl.modulate = Color(0.40, 0.85, 0.55) # Green
	else:
		cat_lbl.text = category.to_upper()
		cat_lbl.modulate = Color(0.93, 0.28, 0.60) if category == "cosmetic" else Color(0.31, 0.82, 0.91)
	cat_lbl.add_theme_font_size_override("font_size", 7)
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
		var is_placed: bool = GameState.is_decor_placed(item_id)
		var decor_btn: Button = Button.new()
		decor_btn.text = "✓ PLACED" if is_placed else "PLACE"
		decor_btn.custom_minimum_size = Vector2(58, 20)
		decor_btn.add_theme_font_size_override("font_size", 8)
		decor_btn.modulate = Color(0.40, 0.85, 0.55) if is_placed else Color(1.0, 1.0, 1.0)
		decor_btn.pressed.connect(func(): _on_decor_toggle_pressed(item_id))
		hbox.add_child(decor_btn)
		
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

func _on_decor_toggle_pressed(item_id: String) -> void:
	GameState.toggle_decor(item_id)
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
	
	var edit_btn: Button = Button.new()
	edit_btn.text = "✏️"
	edit_btn.flat = true
	edit_btn.add_theme_font_size_override("font_size", 8)
	edit_btn.modulate = Color(0.58, 0.64, 0.72)
	edit_btn.pressed.connect(func(): _open_dtr_modal(session))
	top_hbox.add_child(edit_btn)
	
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
	_open_dtr_modal(null)

func _open_dtr_modal(session) -> void: # session is Dictionary or null
	if not dtr_modal:
		return
	if session == null:
		_editing_dtr_unix = 0
		dtr_task_input.text = ""
		dtr_cat_input.text = ""
		dtr_date_input.text = Time.get_date_string_from_system()
		var now: Dictionary = Time.get_time_dict_from_system()
		dtr_start_input.text = "%02d:%02d" % [now.hour, now.minute]
		dtr_end_input.text = "%02d:%02d" % [now.hour, now.minute]
		dtr_delete_btn.visible = false
	else:
		_editing_dtr_unix = session.get("created_unix", 0)
		dtr_task_input.text = session.get("task_name", "")
		dtr_cat_input.text = session.get("category", "")
		dtr_date_input.text = session.get("date_key", "")
		
		var st: String = session.get("start_time", "")
		var et: String = session.get("end_time", "")
		dtr_start_input.text = st.split("T")[-1].substr(0, 5) if "T" in st else st.substr(0, 5)
		dtr_end_input.text = et.split("T")[-1].substr(0, 5) if "T" in et else et.substr(0, 5)
		
		dtr_delete_btn.visible = true
		
	dtr_modal.show()

func _on_dtr_modal_save() -> void:
	if not DatabaseManager:
		return
		
	var start_parts: PackedStringArray = dtr_start_input.text.split(":")
	var end_parts: PackedStringArray = dtr_end_input.text.split(":")
	var duration: int = 0
	
	if start_parts.size() == 2 and end_parts.size() == 2:
		var start_mins: int = start_parts[0].to_int() * 60 + start_parts[1].to_int()
		var end_mins: int = end_parts[0].to_int() * 60 + end_parts[1].to_int()
		duration = max(0, end_mins - start_mins)
		
	var entry: Dictionary = {
		"task_name": dtr_task_input.text if dtr_task_input.text != "" else "Manual Entry",
		"category": dtr_cat_input.text if dtr_cat_input.text != "" else "General",
		"start_time": dtr_date_input.text + "T" + dtr_start_input.text + ":00",
		"end_time": dtr_date_input.text + "T" + dtr_end_input.text + ":00",
		"duration_minutes": duration,
		"status": "completed",
		"coins_earned": 0, # Manual entries don't grant coins to prevent exploit
		"exp_earned": 0,
		"date_key": dtr_date_input.text,
		"created_unix": _editing_dtr_unix if _editing_dtr_unix != 0 else Time.get_unix_time_from_system()
	}
	
	if _editing_dtr_unix == 0:
		DatabaseManager.log_session(entry)
	else:
		DatabaseManager.update_session(_editing_dtr_unix, entry)
		
	dtr_modal.hide()
	_refresh_dtr_tab()

func _on_dtr_modal_delete() -> void:
	if not DatabaseManager or _editing_dtr_unix == 0:
		return
		
	DatabaseManager.delete_session(_editing_dtr_unix)
	dtr_modal.hide()
	_refresh_dtr_tab()

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

func _on_kp_changed(_balance: int, _delta: int, _reason: String) -> void:
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

# ==============================================================================
# ⚙️ CONFIG TAB LOGIC
# ==============================================================================
func _refresh_config_ui() -> void:
	# Update active scale buttons
	_update_scale_buttons_highlight(_current_scale_preset)
	
	# Update Pin button
	if pin_btn:
		var pinned: bool = false
		var wc: WindowController = _find_window_controller()
		if wc:
			pinned = wc.is_pinned
		else:
			pinned = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, 0)
		pin_btn.text = "📌 PINNED" if pinned else "📌 PIN TO TOP"
		pin_btn.modulate = Color(0.96, 0.62, 0.04) if pinned else Color(1.0, 1.0, 1.0)
		
	# Update timer presets
	if TimerEngine and work_time_input and break_time_input and cycle_input:
		var w_min: float = TimerEngine.work_duration / 60.0
		work_time_input.text = str(w_min) if w_min < 1.0 else str(int(round(w_min)))
		var b_min: float = TimerEngine.short_break_duration / 60.0
		break_time_input.text = str(b_min) if b_min < 1.0 else str(int(round(b_min)))
		cycle_input.text = str(TimerEngine.pomodoro_cycle_goal)
		
	# Refresh Audio & Alert controls
	_refresh_audio_ui()

func _refresh_audio_ui() -> void:
	if not GameState or not GameState.audio_settings:
		return
		
	var s: Dictionary = GameState.audio_settings
	if master_slider:
		master_slider.set_value_no_signal(s.get("master_volume", 0.8))
	if ambience_slider:
		ambience_slider.set_value_no_signal(s.get("ambience_volume", 0.5))
	if sfx_slider:
		sfx_slider.set_value_no_signal(s.get("sfx_volume", 0.7))
		
	var is_muted: bool = s.get("is_muted", false)
	if mute_btn:
		mute_btn.text = "🔇 OFF" if is_muted else "🔊 ON"
		mute_btn.modulate = Color(0.9, 0.4, 0.4) if is_muted else Color(0.3, 0.8, 0.9)
		
	var is_amb: bool = s.get("ambience_enabled", true)
	if ambience_toggle_btn:
		ambience_toggle_btn.text = "✓ ROOM" if is_amb else "✗ OFF"
		ambience_toggle_btn.modulate = Color(0.4, 0.9, 0.5) if is_amb else Color(0.6, 0.6, 0.6)
		
	var is_timer_notif: bool = s.get("timer_notifs_enabled", true)
	if timer_notif_btn:
		timer_notif_btn.text = "🔔 TIMER (ON)" if is_timer_notif else "🔕 TIMER (OFF)"
		timer_notif_btn.modulate = Color(0.96, 0.62, 0.04) if is_timer_notif else Color(0.6, 0.6, 0.6)
		
	var is_pet_nudge: bool = s.get("pet_nudges_enabled", true)
	if pet_nudge_btn:
		pet_nudge_btn.text = "🐾 NUDGES (ON)" if is_pet_nudge else "🐾 NUDGES (OFF)"
		pet_nudge_btn.modulate = Color(0.93, 0.28, 0.60) if is_pet_nudge else Color(0.6, 0.6, 0.6)

func _on_mute_toggled() -> void:
	if GameState:
		var cur: bool = GameState.audio_settings.get("is_muted", false)
		GameState.set_audio_setting("is_muted", not cur)

func _on_ambience_toggled() -> void:
	if GameState:
		var cur: bool = GameState.audio_settings.get("ambience_enabled", true)
		GameState.set_audio_setting("ambience_enabled", not cur)

func _on_timer_notifs_toggled() -> void:
	if GameState:
		var cur: bool = GameState.audio_settings.get("timer_notifs_enabled", true)
		GameState.set_audio_setting("timer_notifs_enabled", not cur)

func _on_pet_nudges_toggled() -> void:
	if GameState:
		var cur: bool = GameState.audio_settings.get("pet_nudges_enabled", true)
		GameState.set_audio_setting("pet_nudges_enabled", not cur)

func _update_scale_buttons_highlight(active_scale: float) -> void:
	if scale_1x_btn:
		scale_1x_btn.modulate = Color(0.31, 0.82, 0.91) if is_equal_approx(active_scale, 1.0) else Color(1.0, 1.0, 1.0)
	if scale_125x_btn:
		scale_125x_btn.modulate = Color(0.31, 0.82, 0.91) if is_equal_approx(active_scale, 1.25) else Color(1.0, 1.0, 1.0)
	if scale_15x_btn:
		scale_15x_btn.modulate = Color(0.31, 0.82, 0.91) if is_equal_approx(active_scale, 1.5) else Color(1.0, 1.0, 1.0)

func _apply_scale(target_scale: float) -> void:
	_current_scale_preset = target_scale
	_update_scale_buttons_highlight(target_scale)
	
	# Find WindowController in ancestor tree and apply scale index
	var wc: WindowController = _find_window_controller()
	if wc:
		var scale_idx: int = 0
		if is_equal_approx(target_scale, 1.25):
			scale_idx = 1
		elif is_equal_approx(target_scale, 1.5):
			scale_idx = 2
		wc.current_scale_index = scale_idx
		wc._update_layout()
	else:
		# Fallback window sizing
		var win_w: int = int(round(240.0 * target_scale))
		var win_h: int = int(round(320.0 * target_scale))
		DisplayServer.window_set_size(Vector2i(win_w, win_h), 0)
		EventBus.window_scale_changed.emit(target_scale, Vector2i(win_w, win_h))

func _on_pin_toggle_pressed() -> void:
	var wc: WindowController = _find_window_controller()
	if wc:
		wc.toggle_always_on_top()
	else:
		var cur_pin: bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, 0)
		var next_pin: bool = not cur_pin
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, next_pin, 0)
		EventBus.window_pin_toggled.emit(next_pin)

func _on_apply_timers_pressed() -> void:
	if not TimerEngine or not work_time_input or not break_time_input or not cycle_input:
		return
		
	var work_mins: float = work_time_input.text.to_float()
	var break_mins: float = break_time_input.text.to_float()
	var cycles: int = cycle_input.text.to_int()
	
	var w_sec: float = (work_mins * 60.0) if work_mins > 0.0 else TimerEngine.DEFAULT_WORK_SECONDS
	var b_sec: float = (break_mins * 60.0) if break_mins > 0.0 else TimerEngine.DEFAULT_SHORT_BREAK_SECONDS
	
	if cycles > 0:
		TimerEngine.pomodoro_cycle_goal = cycles
		
	if mode_toggle_btn:
		TimerEngine.current_mode = mode_toggle_btn.selected as TimerEngine.TimerMode
		
	TimerEngine.set_custom_durations(w_sec, b_sec)
	
	if AudioManager:
		AudioManager.play_sfx("click")
		
	if save_status_label:
		save_status_label.text = "✓ Timer set to %s min" % str(work_mins)
		save_status_label.modulate = Color(0.31, 0.82, 0.91)

func _on_manual_save_pressed() -> void:
	if DatabaseManager:
		var ok: bool = DatabaseManager.save_game()
		DatabaseManager.save_dtr()
		if save_status_label:
			save_status_label.text = "✓ Saved successfully!" if ok else "✗ Save failed!"
			save_status_label.modulate = Color(0.3, 1.0, 0.4) if ok else Color(1.0, 0.3, 0.3)

func _on_window_scale_changed(scale_factor: float, _size: Vector2i) -> void:
	_current_scale_preset = scale_factor
	_update_scale_buttons_highlight(scale_factor)

func _on_window_pin_toggled(pinned: bool) -> void:
	if pin_btn:
		pin_btn.text = "📌 PINNED" if pinned else "📌 PIN TO TOP"
		pin_btn.modulate = Color(0.96, 0.62, 0.04) if pinned else Color(1.0, 1.0, 1.0)

func _on_save_completed(success: bool, timestamp: String) -> void:
	if save_status_label and timestamp != "":
		save_status_label.text = "Saved: %s" % timestamp.split("T")[-1]
		save_status_label.modulate = Color(0.58, 0.64, 0.72)

# ==============================================================================
# 📚 TAB 4: STUDY DECK LOGIC
# ==============================================================================
func _refresh_deck_tab() -> void:
	if not GameState or not deck_cards_list_vbox:
		return
		
	var cards: Array[Dictionary] = GameState.get_flashcards()
	if deck_count_badge:
		deck_count_badge.text = "%d CARDS" % cards.size()
	if deck_kp_badge:
		deck_kp_badge.text = "⭐ %d KP" % GameState.knowledge_points
		
	for child in deck_cards_list_vbox.get_children():
		child.queue_free()
		
	if cards.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No cards in deck.\nAdd questions below!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.theme_type_variation = "HeaderSmall"
		empty_lbl.modulate = Color(0.58, 0.64, 0.72)
		deck_cards_list_vbox.add_child(empty_lbl)
		return
		
	for card in cards:
		var card_id: String = card.get("id", "")
		var q: String = card.get("q", "")
		var a: String = card.get("a", "")
		var subj: String = card.get("subject", "General")
		
		var card_panel: PanelContainer = PanelContainer.new()
		var card_vbox: VBoxContainer = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 2)
		
		# Top Row: Subject Tag + Delete Button
		var top_hbox: HBoxContainer = HBoxContainer.new()
		var subj_lbl: Label = Label.new()
		subj_lbl.text = "🏷️ " + subj.to_upper()
		subj_lbl.theme_type_variation = "HeaderSmall"
		subj_lbl.modulate = Color(0.38, 0.77, 0.99)
		top_hbox.add_child(subj_lbl)
		
		var spacer: Control = Control.new()
		spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top_hbox.add_child(spacer)
		
		var del_btn: Button = Button.new()
		del_btn.text = "✕"
		del_btn.custom_minimum_size = Vector2(16, 16)
		del_btn.pressed.connect(func():
			if AudioManager:
				AudioManager.play_sfx("click")
			GameState.delete_flashcard(card_id)
		)
		top_hbox.add_child(del_btn)
		card_vbox.add_child(top_hbox)
		
		# Question
		var q_lbl: Label = Label.new()
		q_lbl.text = "Q: " + q
		q_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card_vbox.add_child(q_lbl)
		
		# Answer (Subdued / Accent)
		var a_lbl: Label = Label.new()
		a_lbl.text = "A: " + a
		a_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		a_lbl.modulate = Color(0.75, 0.85, 0.75)
		card_vbox.add_child(a_lbl)
		
		card_panel.add_child(card_vbox)
		deck_cards_list_vbox.add_child(card_panel)

func _on_add_card_pressed() -> void:
	if not GameState or not deck_q_input or not deck_a_input:
		return
		
	var q: String = deck_q_input.text.strip_edges()
	var a: String = deck_a_input.text.strip_edges()
	var subj: String = deck_subject_input.text.strip_edges() if deck_subject_input else "General"
	
	if q == "" or a == "":
		if NotificationManager:
			NotificationManager.show_toast("Question & Answer required!", NotificationManager.ToastType.WARNING)
		return
		
	var new_id: String = GameState.add_flashcard(q, a, subj)
	if new_id != "":
		deck_q_input.text = ""
		deck_a_input.text = ""
		if deck_subject_input:
			deck_subject_input.text = ""
		if AudioManager:
			AudioManager.play_sfx("click")
		if NotificationManager:
			NotificationManager.show_toast("Flashcard Added! 📚✨", NotificationManager.ToastType.SUCCESS)

func _find_window_controller() -> WindowController:
	var cur: Node = get_parent()
	while cur:
		if cur is WindowController:
			return cur as WindowController
		cur = cur.get_parent()
	return null
