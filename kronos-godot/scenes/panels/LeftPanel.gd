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
@onready var tab_bar_scroll: ScrollContainer = $VBox/TabBarScroll
@onready var tab_shop_btn: Button = $VBox/TabBarScroll/TabHBox/TabShopBtn
@onready var tab_tasks_btn: Button = $VBox/TabBarScroll/TabHBox/TabTasksBtn
@onready var tab_quests_btn: Button = $VBox/TabBarScroll/TabHBox/TabQuestsBtn
@onready var tab_trophies_btn: Button = $VBox/TabBarScroll/TabHBox/TabTrophiesBtn


# Shop Nodes
@onready var shop_vbox: GridContainer = $VBox/TabContainer/SHOP/ShopScroll/ShopVBox
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
@onready var trophy_progress_label: Label = $VBox/TabContainer/TROPHIES/TrophyHeader/TrophyProgressLabel
@onready var trophies_list: VBoxContainer = $VBox/TabContainer/TROPHIES/TrophiesScroll/TrophiesVBox

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
	_on_tab_changed(0)

func _connect_ui_signals() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
		
	if tab_bar_scroll:
		tab_bar_scroll.gui_input.connect(_on_tab_bar_gui_input)
		
	if tab_shop_btn:
		tab_shop_btn.pressed.connect(func(): _switch_left_tab(0))
	if tab_tasks_btn:
		tab_tasks_btn.pressed.connect(func(): _switch_left_tab(1))
	if tab_quests_btn:
		tab_quests_btn.pressed.connect(func(): _switch_left_tab(2))
	if tab_trophies_btn:
		tab_trophies_btn.pressed.connect(func(): _switch_left_tab(3))
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
	EventBus.achievement_unlocked.connect(func(_id, _d): _populate_trophies_tab())

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

func _switch_left_tab(idx: int) -> void:
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
	if title_label:
		match tab_idx:
			0: title_label.text = "◈ SHOP"
			1: title_label.text = "◈ TASKS"
			2: title_label.text = "◈ DAILY QUESTS"
			3: title_label.text = "◈ TROPHIES"
			
	var buttons: Array = [tab_shop_btn, tab_tasks_btn, tab_quests_btn, tab_trophies_btn]
	for i in range(buttons.size()):
		var btn: Button = buttons[i]
		if btn:
			btn.modulate = Color(0.96, 0.62, 0.04) if i == tab_idx else Color(0.7, 0.7, 0.7, 0.8)
			
	_refresh_active_tab()

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
		3:
			_populate_trophies_tab()

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

func _populate_category_list(container: GridContainer, category: String) -> void:
	if not container or not GameState:
		return
		
	for child in container.get_children():
		child.queue_free()
		
	var items: Array[Dictionary] = GameState.get_items_by_category(category)
	
	# Determine Daily Deals using a daily seed
	var daily_seed = Time.get_date_string_from_system().hash()
	var deal_idx1 = daily_seed % max(1, items.size())
	var deal_idx2 = (daily_seed + 7) % max(1, items.size())
	
	for i in range(items.size()):
		var item = items[i].duplicate() # Duplicate so we don't modify the database!
		if i == deal_idx1 or i == deal_idx2:
			item["price"] = int(item.get("price", 0) * 0.7) # 30% off
			item["name"] = "⭐ " + item.get("name", "") + " (-30%)"
			
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
	card_panel.custom_minimum_size = Vector2(105, 95) # Fits perfectly in 2-column grid
	card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Apply rarity colors
	var r_col = Color(0.18, 0.22, 0.28) # Default border
	if item_price >= 1000: r_col = Color(1.0, 0.84, 0.0) # Legendary Gold
	elif item_price >= 500: r_col = Color(0.6, 0.2, 0.8) # Epic Purple
	elif item_price >= 200: r_col = Color(0.2, 0.6, 1.0) # Rare Blue
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.10, 0.14)
	style.border_color = r_col
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.content_margin_left = 4
	style.content_margin_right = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	card_panel.add_theme_stylebox_override("panel", style)
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	card_panel.add_child(vbox)
	
	# Icon Centered
	var icon_lbl: Label = Label.new()
	icon_lbl.text = item_icon
	icon_lbl.add_theme_font_size_override("font_size", 20)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(icon_lbl)
	
	# Name Label
	var name_lbl: Label = Label.new()
	name_lbl.text = item_name
	name_lbl.add_theme_font_size_override("font_size", 8)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.custom_minimum_size = Vector2(0, 20)
	vbox.add_child(name_lbl)
	
	# Price / Level Label
	var price_lbl: Label = Label.new()
	if not meets_level:
		price_lbl.text = "🔒 Lv. %d" % req_lvl
		price_lbl.modulate = Color(0.8, 0.3, 0.3)
	else:
		price_lbl.text = "%d G" % item_price
		price_lbl.modulate = Color(1.0, 0.84, 0.0)
	price_lbl.add_theme_font_size_override("font_size", 8)
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(price_lbl)
	
	# Buy Button
	var buy_btn: Button = Button.new()
	buy_btn.custom_minimum_size = Vector2(0, 20)
	buy_btn.add_theme_font_size_override("font_size", 8)
	
	if not meets_level:
		buy_btn.text = "LOCKED"
		buy_btn.disabled = true
		buy_btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
	else:
		if is_owned and category in ["room", "cosmetic"]:
			if category == "room":
				var is_active = (GameState.active_view_room == item_id)
				buy_btn.text = "HERE" if is_active else "VISIT"
				buy_btn.disabled = is_active
				buy_btn.modulate = Color(0.40, 0.85, 0.55) if is_active else Color(0.31, 0.82, 0.91)
				if not is_active:
					buy_btn.pressed.connect(func():
						EventBus.room_change_requested.emit(item_id)
						_refresh_coins_badge()
					)
			else:
				buy_btn.text = "OWNED"
				buy_btn.disabled = true
				buy_btn.modulate = Color(0.40, 0.85, 0.55)
		elif is_owned and category == "pet":
			buy_btn.text = "IN HOUSE"
			buy_btn.disabled = true
			buy_btn.modulate = Color(0.40, 0.85, 0.55)
		elif category == "pet" and GameState.is_pet_unlocked(item_id):
			buy_btn.text = "ADOPT (+)"
			buy_btn.disabled = not can_afford
			buy_btn.modulate = Color(0.31, 0.82, 0.91)
			buy_btn.pressed.connect(func():
				GameState.adopt_pet(item_id, true)
				_refresh_coins_badge()
				_populate_all_shop_tabs()
			)
		else:
			if not can_afford:
				buy_btn.text = "NEED G"
				buy_btn.disabled = true
				buy_btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
			else:
				buy_btn.text = "BUY"
				buy_btn.disabled = false
				buy_btn.modulate = Color(0.31, 0.82, 0.91)
				buy_btn.pressed.connect(func():
					if category == "pet":
						GameState.adopt_pet(item_id, true)
						_refresh_coins_badge()
						_populate_all_shop_tabs()
					else:
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

# ==============================================================================
# 🏆 TROPHIES & ACHIEVEMENTS TAB
# ==============================================================================
func _populate_trophies_tab() -> void:
	if not trophies_list or not GameState:
		return
		
	for child in trophies_list.get_children():
		child.queue_free()
		
	var ach_list: Array[Dictionary] = GameState.get_achievement_list()
	var unlocked_count: int = 0
	
	for ach in ach_list:
		if ach.get("is_unlocked", false):
			unlocked_count += 1
			
	var total_count: int = ach_list.size()
	var pct: int = int((float(unlocked_count) / float(maxi(1, total_count))) * 100.0)
	
	if trophy_progress_label:
		trophy_progress_label.text = "🏆 Trophies: %d / %d (%d%%)" % [unlocked_count, total_count, pct]
		
	for ach in ach_list:
		var card: PanelContainer = _create_trophy_card(ach)
		trophies_list.add_child(card)

func _create_trophy_card(ach: Dictionary) -> PanelContainer:
	var card: PanelContainer = PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 42)
	
	var is_unlocked: bool = ach.get("is_unlocked", false)
	var title: String = ach.get("title", "Achievement")
	var icon: String = ach.get("icon", "🏆")
	var desc: String = ach.get("description", "")
	var target_val: int = int(ach.get("target_value", 1))
	var cur_val: int = int(ach.get("current_progress", 0))
	var r_coins: int = int(ach.get("reward_coins", 0))
	var r_xp: int = int(ach.get("reward_xp", 0))
	var r_item: String = ach.get("reward_item", "")
	
	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 6)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 6)
	margin.add_theme_constant_override("margin_bottom", 4)
	card.add_child(margin)
	
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 6)
	margin.add_child(hbox)
	
	# Icon
	var icon_lbl: Label = Label.new()
	icon_lbl.text = icon if is_unlocked else "🔒"
	icon_lbl.add_theme_font_size_override("font_size", 12)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(icon_lbl)
	
	# Center Details
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 1)
	hbox.add_child(vbox)
	
	# Title
	var title_lbl: Label = Label.new()
	title_lbl.text = title if is_unlocked else "??? " + title
	title_lbl.add_theme_font_size_override("font_size", 7)
	if is_unlocked:
		title_lbl.add_theme_color_override("font_color", Color(0.96, 0.78, 0.25))
	else:
		title_lbl.add_theme_color_override("font_color", Color(0.65, 0.70, 0.80))
	vbox.add_child(title_lbl)
	
	# Description
	var desc_lbl: Label = Label.new()
	desc_lbl.text = desc
	desc_lbl.add_theme_font_size_override("font_size", 6)
	desc_lbl.add_theme_color_override("font_color", Color(0.85, 0.88, 0.92) if is_unlocked else Color(0.55, 0.60, 0.70))
	vbox.add_child(desc_lbl)
	
	# Reward / Progress Row
	if is_unlocked:
		var reward_lbl: Label = Label.new()
		var r_str: String = "Claimed: "
		if r_coins > 0: r_str += "+%d 🪙 " % r_coins
		if r_xp > 0: r_str += "+%d XP " % r_xp
		if r_item != "": r_str += "🎁 %s" % r_item
		reward_lbl.text = r_str
		reward_lbl.add_theme_font_size_override("font_size", 6)
		reward_lbl.add_theme_color_override("font_color", Color(0.31, 0.82, 0.91))
		vbox.add_child(reward_lbl)
	else:
		var prog_lbl: Label = Label.new()
		prog_lbl.text = "Progress: %d / %d" % [clampi(cur_val, 0, target_val), target_val]
		prog_lbl.add_theme_font_size_override("font_size", 6)
		prog_lbl.add_theme_color_override("font_color", Color(0.70, 0.75, 0.85))
		vbox.add_child(prog_lbl)
		
	return card
