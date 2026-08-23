extends PanelContainer
class_name LeftPanel

## Left Panel for Kronos Desktop Workspace.
## Handles Pet Shop catalog ([TREATS], [COSMETICS], [DECOR]),
## Micro-Tasks checklist ([TASKS]), Daily Pet Quests ([QUESTS]),
## live Energy Buff banner, and active focus sprint task binding.

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
@onready var title_label: Label = $VBox/Header/HBox/Title
@onready var coins_badge: Label = $VBox/Header/HBox/CoinsBadge
@onready var close_btn: Button = $VBox/Header/HBox/CloseButton

@onready var buff_banner: PanelContainer = $VBox/BuffBanner
@onready var buff_status_label: Label = $VBox/BuffBanner/HBox/BuffStatusLabel
@onready var buff_bonus_label: Label = $VBox/BuffBanner/HBox/BuffBonusLabel

@onready var tab_container: TabContainer = $VBox/TabContainer

# Shop Nodes
@onready var shop_vbox: VBoxContainer = $VBox/TabContainer/SHOP/ShopScroll/ShopVBox
@onready var rooms_filter_btn: Button = $VBox/TabContainer/SHOP/FilterHBox/RoomsFilterBtn
@onready var pets_filter_btn: Button = $VBox/TabContainer/SHOP/FilterHBox/PetsFilterBtn
@onready var treats_filter_btn: Button = $VBox/TabContainer/SHOP/FilterHBox/TreatsFilterBtn
@onready var cosmetics_filter_btn: Button = $VBox/TabContainer/SHOP/FilterHBox/CosmeticsFilterBtn
@onready var decor_filter_btn: Button = $VBox/TabContainer/SHOP/FilterHBox/DecorFilterBtn

# Tasks Nodes
@onready var task_line_edit: LineEdit = $VBox/TabContainer/TASKS/TaskInputRow/TaskLineEdit
@onready var add_task_btn: Button = $VBox/TabContainer/TASKS/TaskInputRow/AddTaskButton
@onready var tasks_list: VBoxContainer = $VBox/TabContainer/TASKS/TaskScroll/TasksVBox

# Quests Nodes
@onready var quests_list: VBoxContainer = $VBox/TabContainer/QUESTS/QuestsVBox

var current_shop_category: String = "room"

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	_connect_ui_signals()
	_connect_event_bus()
	_refresh_buff_banner()
	_refresh_coins_badge()
	_refresh_active_tab()

func _connect_ui_signals() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
	if tab_container:
		tab_container.tab_changed.connect(func(_idx): _refresh_active_tab())
	if rooms_filter_btn:
		rooms_filter_btn.pressed.connect(func(): _set_shop_category("room"))
	if pets_filter_btn:
		pets_filter_btn.pressed.connect(func(): _set_shop_category("pet"))
	if treats_filter_btn:
		treats_filter_btn.pressed.connect(func(): _set_shop_category("snack"))
	if cosmetics_filter_btn:
		cosmetics_filter_btn.pressed.connect(func(): _set_shop_category("cosmetic"))
	if decor_filter_btn:
		decor_filter_btn.pressed.connect(func(): _set_shop_category("decor"))
	if add_task_btn:
		add_task_btn.pressed.connect(_on_add_task_submitted)
	if task_line_edit:
		task_line_edit.text_submitted.connect(func(_text): _on_add_task_submitted())

func _connect_event_bus() -> void:
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	EventBus.room_unlocked.connect(func(_r): _populate_all_shop_tabs())
	EventBus.pet_adopted.connect(func(_p, _h): _populate_all_shop_tabs())
	EventBus.pet_list_changed.connect(func(_l): _populate_all_shop_tabs())
	EventBus.level_up.connect(func(_lvl): _populate_all_shop_tabs())
	EventBus.task_added.connect(func(_t): _populate_tasks_tab())
	EventBus.task_toggled.connect(func(_id, _c): _populate_tasks_tab())
	EventBus.task_deleted.connect(func(_id): _populate_tasks_tab())
	EventBus.active_task_selected.connect(func(_id, _title): _populate_tasks_tab())
	EventBus.quests_updated.connect(func(): _populate_quests_tab())

func _set_shop_category(category: String) -> void:
	current_shop_category = category
	_update_filter_button_styles()
	_populate_category_list(shop_vbox, current_shop_category)

func _update_filter_button_styles() -> void:
	if rooms_filter_btn:
		rooms_filter_btn.modulate = Color(0.96, 0.62, 0.04) if current_shop_category == "room" else Color(0.7, 0.7, 0.7, 0.8)
	if pets_filter_btn:
		pets_filter_btn.modulate = Color(0.16, 0.82, 0.55) if current_shop_category == "pet" else Color(0.7, 0.7, 0.7, 0.8)
	if treats_filter_btn:
		treats_filter_btn.modulate = Color(0.31, 0.82, 0.91) if current_shop_category == "snack" else Color(0.7, 0.7, 0.7, 0.8)
	if cosmetics_filter_btn:
		cosmetics_filter_btn.modulate = Color(0.93, 0.28, 0.60) if current_shop_category == "cosmetic" else Color(0.7, 0.7, 0.7, 0.8)
	if decor_filter_btn:
		decor_filter_btn.modulate = Color(0.40, 0.85, 0.55) if current_shop_category == "decor" else Color(0.7, 0.7, 0.7, 0.8)

func _refresh_active_tab() -> void:
	if not tab_container:
		return
	match tab_container.current_tab:
		0:
			_set_shop_category(current_shop_category)
		1:
			_populate_tasks_tab()
		2:
			_populate_quests_tab()

# ==============================================================================
# ⚡ ENERGY BUFF BANNER
# ==============================================================================
func _refresh_buff_banner() -> void:
	if not GameState or not buff_banner:
		return
	var buffed: bool = GameState.is_energy_buffed()
	buff_banner.visible = buffed
	if buffed:
		buff_status_label.text = "⚡ SPEED BUFF ACTIVE (70%+)"
		buff_bonus_label.text = "+50% FOCUS COINS"

func _refresh_coins_badge() -> void:
	if not GameState or not coins_badge:
		return
	coins_badge.text = "%d G" % GameState.coins

# ==============================================================================
# 🛍️ SHOP CATALOG POPULATION
# ==============================================================================
var _is_shop_dirty: bool = false

func _populate_all_shop_tabs() -> void:
	if not _is_shop_dirty:
		_is_shop_dirty = true
		call_deferred("_do_populate_all_shop_tabs")

func _do_populate_all_shop_tabs() -> void:
	_is_shop_dirty = false
	_refresh_active_tab()

func _populate_category_list(container: VBoxContainer, category: String) -> void:
	if not container or not GameState:
		return
		
	for child in container.get_children():
		child.queue_free()
		
	var items: Array[Dictionary] = GameState.get_items_by_category(category)
	for item in items:
		var card: Control = _create_shop_card(item)
		container.add_child(card)

func _create_shop_card(item: Dictionary) -> Control:
	var item_id: String = item.get("id", "")
	var item_name: String = item.get("name", "Unknown Item")
	var item_icon: String = item.get("icon", "📦")
	var item_price: int = item.get("price", 0)
	var category: String = item.get("category", "")
	var req_lvl: int = int(item.get("unlock_level", 1))
	var player_lvl: int = GameState.level
	
	var is_owned: bool = false
	if category == "room":
		is_owned = GameState.is_room_unlocked(item_id)
	elif category == "pet":
		is_owned = false
		for p in GameState.active_pets:
			if p.get("id", "") == item_id:
				is_owned = true
				break
	elif category == "snack":
		is_owned = false
	else:
		is_owned = GameState.has_item(item_id, 1)
		
	var owned_count: int = GameState.get_item_count(item_id)
	var can_afford: bool = GameState.coins >= item_price
	if category == "pet" and GameState.is_pet_unlocked(item_id):
		can_afford = true
		
	var meets_level: bool = player_lvl >= req_lvl
	
	var card_panel: PanelContainer = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(0, 54)
	card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	card_panel.add_child(vbox)
	
	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_theme_constant_override("separation", 4)
	vbox.add_child(top_hbox)
	
	var icon_lbl: Label = Label.new()
	icon_lbl.text = item_icon
	icon_lbl.add_theme_font_size_override("font_size", 14)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_hbox.add_child(icon_lbl)
	
	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 1)
	top_hbox.add_child(info_vbox)
	
	var name_lbl: Label = Label.new()
	name_lbl.text = item_name
	name_lbl.add_theme_font_size_override("font_size", 8)
	name_lbl.modulate = Color(1.0, 1.0, 1.0)
	info_vbox.add_child(name_lbl)
	
	var sub_lbl: Label = Label.new()
	sub_lbl.add_theme_font_size_override("font_size", 7)
	
	var prereq_met: bool = true
	var prereq_name: String = ""
	if category == "room":
		if item_id == "room_library" or item_id == "room_kitchen":
			if not GameState.is_room_unlocked("room_livingroom"):
				prereq_met = false
				prereq_name = "Living Room"
		elif item_id == "room_greenhouse":
			if not GameState.is_room_unlocked("room_kitchen"):
				prereq_met = false
				prereq_name = "Kitchen"
				
	if category == "room":
		if not prereq_met:
			sub_lbl.text = "🔒 Requires %s first" % prereq_name
			sub_lbl.modulate = Color(0.95, 0.45, 0.45)
		else:
			sub_lbl.text = "🔑 Real Estate • Req. Lv. %d" % req_lvl
			sub_lbl.modulate = Color(0.96, 0.62, 0.04) # Gold
	elif category == "pet":
		sub_lbl.text = "🐾 Household: %d / %d Slots (Lv. %d)" % [GameState.active_pets.size(), GameState.get_max_pet_slots(), req_lvl]
		sub_lbl.modulate = Color(0.16, 0.82, 0.55) # Green
	elif category == "decor":
		var r_tag: String = item.get("target_room_name", "Room")
		sub_lbl.text = "📍 %s" % r_tag.to_upper()
		sub_lbl.modulate = Color(0.40, 0.85, 0.55)
	elif category == "cosmetic":
		var slot_str: String = item.get("slot", "item").capitalize()
		sub_lbl.text = "👗 %s Slot" % slot_str
		sub_lbl.modulate = Color(0.93, 0.28, 0.60)
	elif category == "snack":
		var e_boost = item.get("energy_boost", 0)
		var j_boost = item.get("joy_boost", 0)
		sub_lbl.text = "⚡ +%d  ❤️ +%d" % [int(e_boost), int(j_boost)]
		sub_lbl.modulate = Color(0.31, 0.82, 0.91)
	info_vbox.add_child(sub_lbl)
	
	var price_lbl: Label = Label.new()
	price_lbl.text = "%d G" % item_price
	price_lbl.add_theme_font_size_override("font_size", 8)
	price_lbl.modulate = Color(0.96, 0.62, 0.04)
	price_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_hbox.add_child(price_lbl)
	
	# Action Button / Buttons Row
	if category == "pet" and not is_owned and meets_level and can_afford:
		var is_unlocked: bool = GameState.is_pet_unlocked(item_id)
		var price_text: String = "Owned" if is_unlocked else "%d G" % item_price
		
		# Double action row: Switch OR Add to Household!
		var btn_hbox: HBoxContainer = HBoxContainer.new()
		btn_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn_hbox.add_theme_constant_override("separation", 2)
		
		var switch_btn: Button = Button.new()
		switch_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		switch_btn.custom_minimum_size = Vector2(0, 18)
		switch_btn.add_theme_font_size_override("font_size", 7)
		switch_btn.text = "🔁 Switch (%s)" % price_text
		switch_btn.modulate = Color(0.31, 0.82, 0.91)
		switch_btn.pressed.connect(func():
			if AudioManager:
				AudioManager.play_sfx("click")
			GameState.adopt_pet(item_id, false)
		)
		btn_hbox.add_child(switch_btn)
		
		var add_btn: Button = Button.new()
		add_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_btn.custom_minimum_size = Vector2(0, 18)
		add_btn.add_theme_font_size_override("font_size", 7)
		var has_free_slot: bool = GameState.active_pets.size() < GameState.get_max_pet_slots()
		add_btn.text = "➕ Add (+1 Pet)" if has_free_slot else "HOUSE FULL"
		add_btn.disabled = not has_free_slot
		add_btn.modulate = Color(0.16, 0.82, 0.55) if has_free_slot else Color(0.5, 0.5, 0.5, 0.7)
		add_btn.pressed.connect(func():
			if AudioManager:
				AudioManager.play_sfx("click")
			GameState.adopt_pet(item_id, true)
		)
		btn_hbox.add_child(add_btn)
		vbox.add_child(btn_hbox)
	else:
		var buy_btn: Button = Button.new()
		buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		buy_btn.custom_minimum_size = Vector2(0, 18)
		buy_btn.add_theme_font_size_override("font_size", 8)
		
		if is_owned:
			if category == "room":
				buy_btn.text = "🚪 VISIT ROOM"
				buy_btn.disabled = false
				buy_btn.modulate = Color(0.16, 0.82, 0.55) # Green
				buy_btn.pressed.connect(func():
					if AudioManager:
						AudioManager.play_sfx("click")
					EventBus.room_change_requested.emit(item_id)
				)
			elif category == "pet":
				var can_remove: bool = GameState.active_pets.size() > 1
				buy_btn.text = "➖ Return to Bag" if can_remove else "🏡 Main Pet"
				buy_btn.disabled = not can_remove
				buy_btn.modulate = Color(0.85, 0.40, 0.40) if can_remove else Color(0.6, 0.6, 0.6, 0.8)
				if can_remove:
					buy_btn.pressed.connect(func():
						if AudioManager:
							AudioManager.play_sfx("click")
						GameState.remove_pet(item_id)
					)
			else:
				buy_btn.text = "✓ OWNED"
				buy_btn.disabled = true
				buy_btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
		elif category == "room" and not prereq_met:
			buy_btn.text = "🔒 NEEDS %s" % prereq_name.to_upper()
			buy_btn.disabled = true
			buy_btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
		elif not meets_level:
			buy_btn.text = "🔒 UNLOCKS AT LV. %d" % req_lvl
			buy_btn.disabled = true
			buy_btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
		elif not can_afford:
			buy_btn.text = "NEED %d G" % item_price
			buy_btn.disabled = true
			buy_btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
		else:
			buy_btn.text = "UNLOCK ROOM (%d G)" % item_price if category == "room" else "BUY (%d G)" % item_price
			buy_btn.disabled = false
			buy_btn.modulate = Color(0.96, 0.62, 0.04) if category == "room" else Color(0.31, 0.82, 0.91)
			buy_btn.pressed.connect(func():
				if AudioManager:
					AudioManager.play_sfx("click")
				_on_buy_item_clicked(item)
			)
		vbox.add_child(buy_btn)
		
	return card_panel

func _on_buy_item_clicked(item: Dictionary) -> void:
	var item_id: String = item.get("id", "")
	var item_price: int = item.get("price", 0)
	var category: String = item.get("category", "")
	
	if category == "room":
		GameState.buy_room(item_id)
		EventBus.room_change_requested.emit(item_id) # Teleport directly to newly unlocked room!
		_refresh_coins_badge()
	elif category == "pet":
		GameState.adopt_pet(item_id, false)
		_refresh_coins_badge()
	else:
		if GameState.spend_coins(item_price, "shop_buy_" + item_id):
			GameState.add_item(item_id, 1, item)
			if category == "decor":
				GameState.place_decor(item_id)
				
			_refresh_coins_badge()
			
			if DatabaseManager:
				DatabaseManager.save_game()

# ==============================================================================
# 📋 MICRO-TASKS TAB
# ==============================================================================
func _on_add_task_submitted() -> void:
	if not task_line_edit or not GameState:
		return
	var text: String = task_line_edit.text.strip_edges()
	if text.is_empty():
		return
		
	GameState.add_task(text)
	task_line_edit.text = ""
	if AudioManager:
		AudioManager.play_sfx("click")
	_populate_tasks_tab()

func _populate_tasks_tab() -> void:
	if not tasks_list or not GameState:
		return
		
	for child in tasks_list.get_children():
		child.queue_free()
		
	var all_tasks: Array[Dictionary] = GameState.tasks
	if all_tasks.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No tasks yet!\nType above and tap + ADD ✨"
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_font_size_override("font_size", 8)
		empty_lbl.modulate = Color(0.6, 0.65, 0.75, 0.8)
		empty_lbl.custom_minimum_size = Vector2(0, 100)
		tasks_list.add_child(empty_lbl)
		return
		
	for task in all_tasks:
		var task_row: Control = _create_task_row(task)
		tasks_list.add_child(task_row)

func _create_task_row(task: Dictionary) -> Control:
	var task_id: String = task.get("id", "")
	var title: String = task.get("title", "")
	var is_completed: bool = task.get("completed", false)
	var is_active: bool = (task_id == GameState.active_task_id)
	
	var row_panel: PanelContainer = PanelContainer.new()
	row_panel.custom_minimum_size = Vector2(0, 32)
	row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_theme_constant_override("separation", 4)
	row_panel.add_child(hbox)
	
	# Checkbox Button
	var check_btn: Button = Button.new()
	check_btn.custom_minimum_size = Vector2(22, 22)
	check_btn.text = "✓" if is_completed else " "
	check_btn.add_theme_font_size_override("font_size", 9)
	check_btn.modulate = Color(0.35, 0.85, 0.45) if is_completed else Color(0.7, 0.7, 0.7)
	check_btn.pressed.connect(func():
		if AudioManager:
			AudioManager.play_sfx("click")
		GameState.toggle_task(task_id)
	)
	hbox.add_child(check_btn)
	
	# Task Title Label
	var title_lbl: Label = Label.new()
	title_lbl.text = title
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 8)
	if is_completed:
		title_lbl.modulate = Color(0.5, 0.55, 0.60, 0.7) # Strikethrough-style dim
	elif is_active:
		title_lbl.modulate = Color(0.96, 0.62, 0.04) # Gold active
	else:
		title_lbl.modulate = Color(1.0, 1.0, 1.0)
	title_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	hbox.add_child(title_lbl)
	
	# Active Focus Marker Button
	var active_btn: Button = Button.new()
	active_btn.custom_minimum_size = Vector2(24, 20)
	active_btn.text = "🎯" if is_active else "⭐"
	active_btn.add_theme_font_size_override("font_size", 8)
	active_btn.tooltip_text = "Set as active focus task"
	active_btn.modulate = Color(0.96, 0.62, 0.04) if is_active else Color(0.6, 0.6, 0.6, 0.6)
	active_btn.pressed.connect(func():
		if AudioManager:
			AudioManager.play_sfx("click")
		GameState.set_active_task(task_id)
	)
	hbox.add_child(active_btn)
	
	# Delete Button
	var del_btn: Button = Button.new()
	del_btn.custom_minimum_size = Vector2(20, 20)
	del_btn.text = "✕"
	del_btn.add_theme_font_size_override("font_size", 8)
	del_btn.modulate = Color(0.85, 0.35, 0.35, 0.7)
	del_btn.pressed.connect(func():
		if AudioManager:
			AudioManager.play_sfx("click")
		GameState.delete_task(task_id)
	)
	hbox.add_child(del_btn)
	
	return row_panel

# ==============================================================================
# 📜 DAILY QUESTS TAB
# ==============================================================================
func _populate_quests_tab() -> void:
	if not quests_list or not GameState:
		return
		
	for child in quests_list.get_children():
		child.queue_free()
	
	# Daily Reset Banner
	var banner: PanelContainer = PanelContainer.new()
	banner.custom_minimum_size = Vector2(0, 22)
	banner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var b_lbl: Label = Label.new()
	b_lbl.text = "📜 DAILY PET QUEST BOARD"
	b_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	b_lbl.add_theme_font_size_override("font_size", 8)
	b_lbl.modulate = Color(0.96, 0.62, 0.04)
	banner.add_child(b_lbl)
	quests_list.add_child(banner)
	
	var quests: Array[Dictionary] = GameState.daily_quests
	for q in quests:
		var q_card: Control = _create_quest_card(q)
		quests_list.add_child(q_card)

func _create_quest_card(quest: Dictionary) -> Control:
	var q_id: String = quest.get("id", "")
	var q_title: String = quest.get("title", "Daily Quest")
	var q_desc: String = quest.get("description", "")
	var q_icon: String = quest.get("icon", "📜")
	var cur_count: int = int(quest.get("current_count", 0))
	var target_count: int = int(quest.get("target_count", 1))
	var coins_reward: int = int(quest.get("reward_coins", 100))
	var exp_reward: int = int(quest.get("reward_exp", 50))
	var is_claimed: bool = quest.get("claimed", false)
	var is_ready: bool = (cur_count >= target_count and not is_claimed)
	
	var card_panel: PanelContainer = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(0, 56)
	card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	card_panel.add_child(vbox)
	
	# Top Row: Icon + Title + Reward
	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(top_hbox)
	
	var icon_lbl: Label = Label.new()
	icon_lbl.text = q_icon
	icon_lbl.add_theme_font_size_override("font_size", 12)
	top_hbox.add_child(icon_lbl)
	
	var title_lbl: Label = Label.new()
	title_lbl.text = " " + q_title
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_lbl.add_theme_font_size_override("font_size", 8)
	top_hbox.add_child(title_lbl)
	
	var rew_lbl: Label = Label.new()
	rew_lbl.text = "+%d G  +%d XP" % [coins_reward, exp_reward]
	rew_lbl.add_theme_font_size_override("font_size", 7)
	rew_lbl.modulate = Color(0.96, 0.62, 0.04) # Gold
	top_hbox.add_child(rew_lbl)
	
	# Description
	var desc_lbl: Label = Label.new()
	desc_lbl.text = q_desc
	desc_lbl.add_theme_font_size_override("font_size", 7)
	desc_lbl.modulate = Color(0.7, 0.75, 0.85)
	vbox.add_child(desc_lbl)
	
	# Bottom Row: Progress Bar + Claim Button
	var bot_hbox: HBoxContainer = HBoxContainer.new()
	bot_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bot_hbox.add_theme_constant_override("separation", 4)
	vbox.add_child(bot_hbox)
	
	var prog_bar: ProgressBar = ProgressBar.new()
	prog_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prog_bar.custom_minimum_size = Vector2(0, 14)
	prog_bar.max_value = float(target_count)
	prog_bar.value = float(cur_count)
	prog_bar.show_percentage = false
	if is_claimed:
		prog_bar.modulate = Color(0.5, 0.5, 0.5)
	elif is_ready:
		prog_bar.modulate = Color(0.35, 0.95, 0.45)
	else:
		prog_bar.modulate = Color(0.31, 0.82, 0.91)
	bot_hbox.add_child(prog_bar)
	
	var frac_lbl: Label = Label.new()
	frac_lbl.text = "%d/%d" % [cur_count, target_count]
	frac_lbl.add_theme_font_size_override("font_size", 7)
	bot_hbox.add_child(frac_lbl)
	
	var claim_btn: Button = Button.new()
	claim_btn.custom_minimum_size = Vector2(50, 16)
	claim_btn.add_theme_font_size_override("font_size", 7)
	
	if is_claimed:
		claim_btn.text = "✓ CLAIMED"
		claim_btn.disabled = true
		claim_btn.modulate = Color(0.5, 0.5, 0.5, 0.6)
	elif is_ready:
		claim_btn.text = "★ CLAIM"
		claim_btn.disabled = false
		claim_btn.modulate = Color(0.96, 0.62, 0.04) # Gold glowing button
		claim_btn.pressed.connect(func():
			GameState.claim_quest(q_id)
		)
	else:
		claim_btn.text = "IN PROGRESS"
		claim_btn.disabled = true
		claim_btn.modulate = Color(0.5, 0.5, 0.5, 0.6)
		
	bot_hbox.add_child(claim_btn)
	return card_panel

# ==============================================================================
# 🔄 EVENT HANDLERS & HELPERS
# ==============================================================================
func _on_close_pressed() -> void:
	var wc: WindowController = _find_window_controller()
	if wc:
		wc.toggle_left_panel()
	else:
		visible = false
		EventBus.panel_visibility_changed.emit("left", false)

func _on_coins_changed(_balance: int, _delta: int, _reason: String) -> void:
	_refresh_coins_badge()
	_refresh_active_tab()

func _on_energy_changed(_energy: float, _max: float, _buffed: bool) -> void:
	_refresh_buff_banner()

func _on_inventory_changed(_inv: Array[Dictionary]) -> void:
	_refresh_active_tab()

func _find_window_controller() -> WindowController:
	var cur: Node = get_parent()
	while cur:
		if cur is WindowController:
			return cur as WindowController
		cur = cur.get_parent()
	return null
