extends PanelContainer
class_name LeftPanel

## Left Panel for Kronos Desktop Workspace.
## Handles Pet Shop catalog ([TREATS], [COSMETICS], [DECOR]),
## live Energy Buff banner, and [CONFIG] settings (Scale, Pin, Timers).

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
@onready var treats_list: VBoxContainer = $VBox/TabContainer/TREATS/ScrollContainer/TreatsVBox
@onready var cosmetics_list: VBoxContainer = $VBox/TabContainer/COSMETICS/ScrollContainer/CosmeticsVBox
@onready var decor_list: VBoxContainer = $VBox/TabContainer/DECOR/ScrollContainer/DecorVBox

# Config Tab UI references
@onready var scale_1x_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/ScaleCard/HBox/Scale1xBtn
@onready var scale_125x_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/ScaleCard/HBox/Scale125xBtn
@onready var scale_15x_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/ScaleCard/HBox/Scale15xBtn
@onready var pin_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/PinCard/PinButton
@onready var work_time_input: LineEdit = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/TimerCard/VBox/Grid/WorkVBox/WorkTimeInput
@onready var break_time_input: LineEdit = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/TimerCard/VBox/Grid/BreakVBox/BreakTimeInput
@onready var apply_timer_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/TimerCard/VBox/ApplyTimerBtn
@onready var manual_save_btn: Button = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/SaveCard/VBox/ManualSaveBtn
@onready var save_status_label: Label = $VBox/TabContainer/CONFIG/ScrollContainer/ConfigVBox/SaveCard/VBox/SaveStatusLabel

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _current_scale_preset: float = 1.0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	_connect_ui_signals()
	_connect_event_bus()
	_refresh_buff_banner()
	_refresh_coins_badge()
	_populate_all_shop_tabs()
	_refresh_config_ui()

func _connect_ui_signals() -> void:
	if close_btn:
		close_btn.pressed.connect(_on_close_pressed)
		
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

func _connect_event_bus() -> void:
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	EventBus.window_scale_changed.connect(_on_window_scale_changed)
	EventBus.window_pin_toggled.connect(_on_window_pin_toggled)
	EventBus.save_completed.connect(_on_save_completed)

# ==============================================================================
# ⚡ ENERGY BUFF BANNER
# ==============================================================================
func _refresh_buff_banner() -> void:
	if not GameState or not buff_banner:
		return
		
	var is_buffed: bool = GameState.is_energy_buffed()
	if is_buffed:
		buff_status_label.text = "⚡ ENERGY BUFF ACTIVE"
		buff_status_label.modulate = Color(0.96, 0.62, 0.04) # Gold
		buff_bonus_label.text = "+20% COINS"
		buff_bonus_label.modulate = Color(0.96, 0.62, 0.04)
		buff_banner.modulate = Color(1.0, 1.0, 1.0, 1.0)
	else:
		buff_status_label.text = "💤 NO ENERGY BUFF"
		buff_status_label.modulate = Color(0.58, 0.64, 0.72) # Muted
		buff_bonus_label.text = "FEED >70%"
		buff_bonus_label.modulate = Color(0.58, 0.64, 0.72)
		buff_banner.modulate = Color(0.8, 0.8, 0.8, 0.9)

func _refresh_coins_badge() -> void:
	if not GameState or not coins_badge:
		return
	coins_badge.text = "%d G" % GameState.coins

# ==============================================================================
# 🛍️ SHOP CATALOG POPULATION
# ==============================================================================
func _populate_all_shop_tabs() -> void:
	_populate_category_list(treats_list, "snack")
	_populate_category_list(cosmetics_list, "cosmetic")
	_populate_category_list(decor_list, "decor")

func _populate_category_list(container: VBoxContainer, category: String) -> void:
	if not container or not GameState:
		return
		
	# Clear existing child cards
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
	var item_desc: String = item.get("description", "")
	var item_price: int = item.get("price", 0)
	var category: String = item.get("category", "")
	
	var is_owned: bool = (category != "snack") and GameState.has_item(item_id, 1)
	var owned_count: int = GameState.get_item_count(item_id)
	var can_afford: bool = GameState.coins >= item_price
	
	# Root Panel Card
	var card_panel: PanelContainer = PanelContainer.new()
	card_panel.custom_minimum_size = Vector2(0, 52)
	card_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	card_panel.add_child(vbox)
	
	# Top Row: Icon + Name/Desc + Price
	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(top_hbox)
	
	# Icon
	var icon_lbl: Label = Label.new()
	icon_lbl.text = item_icon
	icon_lbl.add_theme_font_size_override("font_size", 16)
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_hbox.add_child(icon_lbl)
	
	# Info VBox
	var info_vbox: VBoxContainer = VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_vbox.add_theme_constant_override("separation", 1)
	top_hbox.add_child(info_vbox)
	
	var name_lbl: Label = Label.new()
	name_lbl.text = item_name
	name_lbl.add_theme_font_size_override("font_size", 9)
	name_lbl.modulate = Color(1.0, 1.0, 1.0)
	info_vbox.add_child(name_lbl)
	
	var desc_lbl: Label = Label.new()
	desc_lbl.text = item_desc
	desc_lbl.add_theme_font_size_override("font_size", 8)
	desc_lbl.modulate = Color(0.58, 0.64, 0.72)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info_vbox.add_child(desc_lbl)
	
	# Price / Owned Count Badge
	var price_lbl: Label = Label.new()
	price_lbl.text = "%d G" % item_price
	price_lbl.add_theme_font_size_override("font_size", 9)
	price_lbl.modulate = Color(0.96, 0.62, 0.04) # Gold
	top_hbox.add_child(price_lbl)
	
	# Bottom Row: Action Button
	var buy_btn: Button = Button.new()
	buy_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_btn.custom_minimum_size = Vector2(0, 20)
	buy_btn.add_theme_font_size_override("font_size", 9)
	
	if is_owned:
		buy_btn.text = "✓ OWNED"
		buy_btn.disabled = true
		buy_btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
	else:
		if category == "snack" and owned_count > 0:
			buy_btn.text = "BUY MORE (%d G) [Have %d]" % [item_price, owned_count]
		else:
			buy_btn.text = "BUY (%d G)" % item_price
			
		buy_btn.disabled = not can_afford
		if can_afford:
			buy_btn.modulate = Color(0.31, 0.82, 0.91) # Cyan highlight
		else:
			buy_btn.text = "NEED COINS"
			buy_btn.modulate = Color(0.5, 0.5, 0.5, 0.7)
			
		buy_btn.pressed.connect(func(): _on_buy_item_clicked(item))
		
	vbox.add_child(buy_btn)
	
	return card_panel

func _on_buy_item_clicked(item: Dictionary) -> void:
	var item_id: String = item.get("id", "")
	var item_price: int = item.get("price", 0)
	
	if GameState.spend_coins(item_price, "shop_buy_" + item_id):
		GameState.add_item(item_id, 1, item)
		# Refresh UI lists & coins
		_refresh_coins_badge()
		_populate_all_shop_tabs()
		
		# Trigger auto-save
		if DatabaseManager:
			DatabaseManager.save_game()

# ==============================================================================
# ⚙️ CONFIG TAB LOGIC
# ==============================================================================
func _refresh_config_ui() -> void:
	# Update active scale buttons
	_update_scale_buttons_highlight(_current_scale_preset)
	
	# Update Pin button
	if pin_btn:
		var pinned: bool = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_ALWAYS_ON_TOP, 0)
		pin_btn.text = "📌 PINNED" if pinned else "📌 PIN TO TOP"
		pin_btn.modulate = Color(0.96, 0.62, 0.04) if pinned else Color(1.0, 1.0, 1.0)
		
	# Update timer presets
	if TimerEngine and work_time_input and break_time_input:
		work_time_input.text = str(int(TimerEngine.work_duration / 60.0))
		break_time_input.text = str(int(TimerEngine.short_break_duration / 60.0))

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
	if not TimerEngine or not work_time_input or not break_time_input:
		return
		
	var work_mins: int = work_time_input.text.to_int()
	var break_mins: int = break_time_input.text.to_int()
	
	if work_mins > 0:
		TimerEngine.work_duration = float(work_mins) * 60.0
	if break_mins > 0:
		TimerEngine.short_break_duration = float(break_mins) * 60.0
		
	if TimerEngine.status == TimerEngine.TimerStatus.STOPPED:
		TimerEngine.stop_timer() # Resets current countdown to updated duration
		
	if save_status_label:
		save_status_label.text = "✓ Timer updated (%dm / %dm)" % [work_mins, break_mins]
		save_status_label.modulate = Color(0.31, 0.82, 0.91)

func _on_manual_save_pressed() -> void:
	if DatabaseManager:
		var ok: bool = DatabaseManager.save_game()
		DatabaseManager.save_dtr()
		if save_status_label:
			save_status_label.text = "✓ Saved successfully!" if ok else "✗ Save failed!"
			save_status_label.modulate = Color(0.3, 1.0, 0.4) if ok else Color(1.0, 0.3, 0.3)

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
	_populate_all_shop_tabs()

func _on_energy_changed(_energy: float, _max: float, _buffed: bool) -> void:
	_refresh_buff_banner()

func _on_inventory_changed(_inv: Array[Dictionary]) -> void:
	_populate_all_shop_tabs()

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
