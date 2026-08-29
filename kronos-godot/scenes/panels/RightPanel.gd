extends PanelContainer
class_name RightPanel

## Right Panel for Kronos Desktop Workspace.
## Handles Pet Vitals ([VITALS]), Inventory Bag ([BAG] with Feed/Equip/Decor actions),
## and Workspace Settings & Audio Controls ([CONFIG]).

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var title_label: Label = $VBox/Header/HBox/Title
@onready var close_btn: Button = $VBox/Header/HBox/CloseButton
@onready var tab_container: TabContainer = $VBox/TabContainer
@onready var tab_bar_scroll: ScrollContainer = $VBox/TabBarScroll
@onready var tab_vitals_btn: Button = $VBox/TabBarScroll/TabHBox/TabVitalsBtn
@onready var tab_bag_btn: Button = $VBox/TabBarScroll/TabHBox/TabBagBtn
@onready var tab_config_btn: Button = $VBox/TabBarScroll/TabHBox/TabConfigBtn

@onready var pet_prev_btn: Button = $VBox/PetSelectorHBox/PetPrevBtn
@onready var pet_next_btn: Button = $VBox/PetSelectorHBox/PetNextBtn
@onready var pet_name_lbl: Label = $VBox/PetSelectorHBox/PetNameLbl

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
@onready var friendship_hearts_label: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/FriendshipCard/VBox/HBox/FriendshipHearts
@onready var friendship_bar: ProgressBar = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/FriendshipCard/VBox/FriendshipBar
@onready var streak_badge: Label = $VBox/TabContainer/VITALS/ScrollContainer/VitalsVBox/StreakCard/StreakLabel

# Bag Tab References
@onready var bag_list_vbox: VBoxContainer = $VBox/TabContainer/BAG/ScrollContainer/BagVBox

# Audio & Alerts References
@onready var master_slider: HSlider = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/MasterRow/MasterSlider
@onready var mute_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/MasterRow/MuteBtn
@onready var ambience_slider: HSlider = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/AmbienceRow/AmbienceSlider
@onready var ambience_toggle_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/AmbienceRow/AmbienceToggleBtn
@onready var sfx_slider: HSlider = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/SfxRow/SfxSlider
@onready var test_sfx_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/SfxRow/TestSfxBtn
@onready var timer_notif_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/NotifsRow/TimerNotifBtn
@onready var pet_nudge_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/AudioCard/VBox/NotifsRow/PetNudgeBtn

# Config Tab UI references
@onready var scale_dropdown: OptionButton = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/ScaleCard/VBox/ScaleDropdown
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
var _current_scale_preset: float = 1.25

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	if pet_prev_btn:
		pet_prev_btn.queue_free()
	if pet_next_btn:
		pet_next_btn.queue_free()

	if TimerEngine and mode_toggle_btn:
		mode_toggle_btn.selected = TimerEngine.current_mode
		
	if tab_container:
		tab_container.tab_changed.connect(_on_tab_changed)
		
	_connect_ui_signals()
	_connect_event_bus()
	
	# Initial UI updates
	_refresh_vitals_tab()
	_refresh_bag_tab()
	_refresh_config_ui()
	_on_tab_changed(0)

func _connect_ui_signals() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
		
	if tab_bar_scroll:
		tab_bar_scroll.gui_input.connect(_on_tab_bar_gui_input)
		
	if tab_vitals_btn:
		tab_vitals_btn.pressed.connect(func(): _switch_tab(0))
	if tab_bag_btn:
		tab_bag_btn.pressed.connect(func(): _switch_tab(1))
	if tab_config_btn:
		tab_config_btn.pressed.connect(func(): _switch_tab(2))
		
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

	if scale_dropdown:
		scale_dropdown.item_selected.connect(_on_scale_dropdown_selected)
		
	if pin_btn:
		pin_btn.pressed.connect(_on_pin_toggle_pressed)
		
	if apply_timer_btn:
		apply_timer_btn.pressed.connect(_on_apply_timers_pressed)
		
	if manual_save_btn:
		manual_save_btn.pressed.connect(_on_manual_save_pressed)

func _connect_event_bus() -> void:
	EventBus.exp_changed.connect(_on_exp_changed)
	EventBus.active_pet_selected.connect(_on_active_pet_selected)
	EventBus.pet_list_changed.connect(_on_pet_list_changed)

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
	EventBus.affection_changed.connect(func(_p, _l, _x, _d): _refresh_vitals_tab())

func _switch_tab(idx: int) -> void:
	if AudioManager:
		AudioManager.play_sfx("click")
	if tab_container:
		tab_container.current_tab = idx
	_on_tab_changed(idx)

func _on_tab_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_LEFT:
			if tab_bar_scroll:
				tab_bar_scroll.scroll_horizontal -= 35
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN or event.button_index == MOUSE_BUTTON_WHEEL_RIGHT:
			if tab_bar_scroll:
				tab_bar_scroll.scroll_horizontal += 35
			get_viewport().set_input_as_handled()

func _on_tab_changed(tab_idx: int) -> void:
	if not title_label:
		return
	match tab_idx:
		0: title_label.text = "◈ VITALS"
		1: title_label.text = "◈ INVENTORY BAG"
		2: title_label.text = "◈ SETTINGS"
		
	var buttons: Array = [tab_vitals_btn, tab_bag_btn, tab_config_btn]
	for i in range(buttons.size()):
		var btn: Button = buttons[i]
		if btn:
			btn.modulate = Color(0.31, 0.82, 0.91) if i == tab_idx else Color(0.7, 0.7, 0.7, 0.8)

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
		energy_val_label.text = "%d%%" % int(round(GameState.get_active_energy()))
	if energy_buff_badge:
		energy_buff_badge.visible = is_buffed
	if energy_bar:
		energy_bar.max_value = GameState.MAX_ENERGY
		energy_bar.value = GameState.get_active_energy()
		energy_bar.modulate = Color(0.3, 1.0, 0.4) if is_buffed else Color(0.96, 0.62, 0.04)
		
	# Joy Bar
	if joy_val_label:
		joy_val_label.text = "%d%%" % int(round(GameState.get_active_joy()))
	if joy_bar:
		joy_bar.max_value = GameState.MAX_JOY
		joy_bar.value = GameState.get_active_joy()
		
	# Friendship / Affection
	var pet = GameState.active_pets[GameState.selected_pet_index] if GameState.selected_pet_index < GameState.active_pets.size() else null
	var affection_lvl: int = pet.get("affection_level", 1) if pet else 1
	var affection_exp: int = pet.get("affection_exp", 0) if pet else 0
	var req_aff_exp: int = affection_lvl * 50
	
	if friendship_hearts_label:
		var hearts_str: String = ""
		for h in range(min(5, affection_lvl)):
			hearts_str += "♥ "
		friendship_hearts_label.text = hearts_str + "Lv.%d" % affection_lvl
		
	if friendship_bar:
		friendship_bar.max_value = float(req_aff_exp)
		friendship_bar.value = float(affection_exp)
		
	# Streak
	if streak_badge:
		streak_badge.text = "%d 🔥" % GameState.streak

# ==============================================================================
# 🎒 TAB 2: INVENTORY BAG
# ==============================================================================
func _refresh_bag_tab() -> void:
	if not bag_list_vbox or not GameState:
		return
		
	for child in bag_list_vbox.get_children():
		child.queue_free()
		
	var inv: Array[Dictionary] = GameState.inventory
	
	if inv.is_empty():
		var empty_card: PanelContainer = PanelContainer.new()
		empty_card.custom_minimum_size = Vector2(0, 50)
		empty_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var center: CenterContainer = CenterContainer.new()
		center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		center.size_flags_vertical = Control.SIZE_EXPAND_FILL
		empty_card.add_child(center)
		
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "BAG IS EMPTY\nVisit Shop (Left Panel)!"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 8)
		empty_lbl.modulate = Color(0.58, 0.64, 0.72)
		center.add_child(empty_lbl)
		
		bag_list_vbox.add_child(empty_card)
		return
		
	for item in inv:
		var card: PanelContainer = _create_bag_item_card(item)
		bag_list_vbox.add_child(card)

func _create_bag_item_card(item: Dictionary) -> PanelContainer:
	var item_id: String = item.get("id", "")
	var count: int = item.get("count", 1)
	var item_def: Dictionary = GameState.get_item_def(item_id)
	var item_name: String = item_def.get("name", item_id.capitalize())
	var item_type: String = item_def.get("type", "consumable")
	var icon: String = item_def.get("icon", "📦")
	var description: String = item_def.get("description", "")
	
	var card: PanelContainer = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 3)
	card.add_child(main_vbox)
	
	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_theme_constant_override("separation", 4)
	main_vbox.add_child(top_hbox)
	
	var icon_lbl: Label = Label.new()
	icon_lbl.text = icon
	icon_lbl.add_theme_font_size_override("font_size", 10)
	top_hbox.add_child(icon_lbl)
	
	var name_lbl: Label = Label.new()
	name_lbl.text = item_name
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 8)
	top_hbox.add_child(name_lbl)
	
	if count > 1:
		var count_badge: Label = Label.new()
		count_badge.text = "x%d" % count
		count_badge.add_theme_font_size_override("font_size", 8)
		count_badge.modulate = Color(0.96, 0.78, 0.25)
		top_hbox.add_child(count_badge)
		
	var desc_lbl: Label = Label.new()
	desc_lbl.text = description
	desc_lbl.add_theme_font_size_override("font_size", 7)
	desc_lbl.modulate = Color(0.58, 0.64, 0.72)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	main_vbox.add_child(desc_lbl)
	
	var action_btn: Button = Button.new()
	action_btn.custom_minimum_size = Vector2(0, 20)
	action_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_btn.add_theme_font_size_override("font_size", 8)
	
	match item_type:
		"food", "snack", "drink", "consumable":
			action_btn.text = "🍴 USE / FEED"
			action_btn.pressed.connect(func(): _on_use_item_pressed(item_id))
		"cosmetic", "hat", "accessory", "collar", "glasses":
			var slot: String = item_def.get("slot", "hat")
			var is_eq: bool = GameState.is_cosmetic_equipped(item_id)
			action_btn.text = "✓ UNEQUIP" if is_eq else "👕 EQUIP"
			action_btn.modulate = Color(0.96, 0.78, 0.25) if is_eq else Color(0.31, 0.82, 0.91)
			action_btn.pressed.connect(func(): _on_equip_toggle_pressed(slot, item_id))
		"furniture", "decor":
			var is_placed: bool = GameState.is_decor_placed(item_id)
			action_btn.text = "📦 STORE" if is_placed else "🏡 PLACE IN ROOM"
			action_btn.modulate = Color(0.4, 0.85, 0.5) if is_placed else Color(0.31, 0.82, 0.91)
			action_btn.pressed.connect(func(): _on_decor_toggle_pressed(item_id))
		_:
			action_btn.text = "USE"
			action_btn.pressed.connect(func(): _on_use_item_pressed(item_id))
			
	main_vbox.add_child(action_btn)
	return card

func _on_use_item_pressed(item_id: String) -> void:
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
# ⚙️ CONFIG TAB LOGIC
# ==============================================================================
func _refresh_config_ui() -> void:
	_update_scale_buttons_highlight(_current_scale_preset)
	
	if pin_btn:
		var pinned: bool = false
		var wc: WindowController = _find_window_controller()
		if wc:
			pinned = wc.is_pinned
		else:
			pinned = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, 0)
		pin_btn.text = "📌 PINNED" if pinned else "📌 PIN TO TOP"
		pin_btn.modulate = Color(0.96, 0.62, 0.04) if pinned else Color(1.0, 1.0, 1.0)
		
	if TimerEngine and work_time_input and break_time_input and cycle_input:
		var w_min: float = TimerEngine.work_duration / 60.0
		work_time_input.text = str(w_min) if w_min < 1.0 else str(int(round(w_min)))
		var b_min: float = TimerEngine.short_break_duration / 60.0
		break_time_input.text = str(b_min) if b_min < 1.0 else str(int(round(b_min)))
		cycle_input.text = str(TimerEngine.pomodoro_cycle_goal)
		
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

func _on_pet_nudge_toggled() -> void:
	if GameState:
		var cur: bool = GameState.audio_settings.get("pet_nudges_enabled", true)
		GameState.set_audio_setting("pet_nudges_enabled", not cur)

func _on_pet_nudges_toggled() -> void:
	_on_pet_nudge_toggled()

func _on_scale_dropdown_selected(index: int) -> void:
	var scales: Array[float] = [1.25, 1.5, 2.0]
	if index >= 0 and index < scales.size():
		_apply_scale(scales[index])

func _update_scale_buttons_highlight(active_scale: float) -> void:
	if not scale_dropdown:
		return
	if is_equal_approx(active_scale, 1.25):
		scale_dropdown.selected = 0
	elif is_equal_approx(active_scale, 1.5):
		scale_dropdown.selected = 1
	elif is_equal_approx(active_scale, 2.0):
		scale_dropdown.selected = 2

func _apply_scale(target_scale: float) -> void:
	_current_scale_preset = target_scale
	_update_scale_buttons_highlight(target_scale)
	
	var wc: WindowController = _find_window_controller()
	if wc:
		var scale_idx: int = 0
		if is_equal_approx(target_scale, 1.5):
			scale_idx = 1
		elif is_equal_approx(target_scale, 2.0):
			scale_idx = 2
		wc.current_scale_index = scale_idx
		wc._update_layout()
	else:
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

func _find_window_controller() -> WindowController:
	var cur: Node = get_parent()
	while cur:
		if cur is WindowController:
			return cur as WindowController
		cur = cur.get_parent()
	return null

# ==============================================================================
# 🎮 EVENT LISTENERS
# ==============================================================================
func _on_exp_changed(_cur: int, _req: int, _lvl: int = 1) -> void:
	_refresh_vitals_tab()

func _on_level_up(_new_lvl: int) -> void:
	_refresh_vitals_tab()

func _on_energy_changed(_e: float, _max_e: float = 100.0, _buff: bool = false) -> void:
	_refresh_vitals_tab()

func _on_joy_changed(_j: float, _max_j: float = 100.0) -> void:
	_refresh_vitals_tab()

func _on_coins_changed(_c: int, _delta: int = 0, _reason: String = "") -> void:
	_refresh_vitals_tab()

func _on_kp_changed(_kp: int, _delta: int = 0, _reason: String = "") -> void:
	_refresh_vitals_tab()

func _on_streak_changed(_s: int) -> void:
	_refresh_vitals_tab()

func _on_inventory_changed(_inv: Array) -> void:
	_refresh_bag_tab()

func _on_item_used(_item_id: String, _data: Dictionary) -> void:
	_refresh_bag_tab()
	_refresh_vitals_tab()

func _on_cosmetic_equipped(_slot: String, _cosmetic_id: String) -> void:
	_refresh_bag_tab()

func _on_cosmetic_unequipped(_slot: String) -> void:
	_refresh_bag_tab()

func _on_session_completed(_type: String, _coins: int, _xp: int, _streak: int) -> void:
	_refresh_vitals_tab()

func _on_close_pressed() -> void:
	hide()

func _on_active_pet_selected(_idx: int, pet_data: Dictionary) -> void:
	if pet_name_lbl:
		pet_name_lbl.text = "🐾 " + pet_data.get("name", "Companion")
	_refresh_vitals_tab()
	_refresh_bag_tab()

func _on_pet_list_changed(_pets: Array) -> void:
	if GameState.selected_pet_index < GameState.active_pets.size():
		var sel = GameState.active_pets[GameState.selected_pet_index]
		if sel and pet_name_lbl:
			pet_name_lbl.text = "🐾 " + sel.get("name", "Companion")
