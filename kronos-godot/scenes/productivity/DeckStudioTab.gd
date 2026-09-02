extends Control
class_name DeckStudioTab

const DocumentParser = preload("res://scripts/utils/DocumentParser.gd")

## 🧠 SuperMemo (SM-2) Spaced Repetition Study Sanctuary for Kronos.
## Phase 3 Deep Polish:
## 1. 2-Stage Squash/Expand Card Flip Animation with Particle & Audio FX.
## 2. 7-Day SRS Review Forecast & Tri-Color Mastery Distribution Meter.
## 3. Curated Starter Pack Loaders (Godot 4, Web Dev, Kronos Lore).
## 4. Markdown (Obsidian/Notion) & Anki CSV Exporters.
## 5. Subject Color Palette Coding & Sorting (Due Soonest, Hardest, Highest Reps, A-Z).
## 6. Gamified Pet Synergy with Celebratory Star Bursts and KP Payouts.

# ==============================================================================
# 🎛️ NODE REFERENCES
# ==============================================================================
# Metrics & Mastery
@onready var due_badge_lbl: Label = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/StatsHBox/DueBadge
@onready var total_cards_lbl: Label = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/StatsHBox/TotalCardsLabel
@onready var mastered_lbl: Label = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/StatsHBox/MasteredLabel
@onready var retention_lbl: Label = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/StatsHBox/RetentionLabel
@onready var kp_balance_lbl: Label = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/HeaderHBox/KpLabel

# Mastery Distribution & 7-Day Forecast
@onready var mastery_bar_learning: Panel = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/MasteryMeter/LearningSegment
@onready var mastery_bar_reviewing: Panel = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/MasteryMeter/ReviewingSegment
@onready var mastery_bar_mastered: Panel = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/MasteryMeter/MasteredSegment
@onready var mastery_legend_lbl: Label = $Scroll/ContentVBox/TopRow/MetricsCard/VBox/LegendLabel

@onready var forecast_lbl_today: Label = $Scroll/ContentVBox/ForecastCard/VBox/ForecastColumns/ColToday/VBox/ValLabel
@onready var forecast_lbl_tomorrow: Label = $Scroll/ContentVBox/ForecastCard/VBox/ForecastColumns/ColTomorrow/VBox/ValLabel
@onready var forecast_lbl_2_3: Label = $Scroll/ContentVBox/ForecastCard/VBox/ForecastColumns/Col23/VBox/ValLabel
@onready var forecast_lbl_4_7: Label = $Scroll/ContentVBox/ForecastCard/VBox/ForecastColumns/Col47/VBox/ValLabel
@onready var forecast_lbl_later: Label = $Scroll/ContentVBox/ForecastCard/VBox/ForecastColumns/ColLater/VBox/ValLabel

# Action Bar & Starters
@onready var btn_start_drill: Button = $Scroll/ContentVBox/TopRow/ActionsCard/VBox/BtnStartDrill
@onready var btn_new_card: Button = $Scroll/ContentVBox/TopRow/ActionsCard/VBox/BtnRow/BtnNewCard
@onready var btn_ai_extract: Button = $Scroll/ContentVBox/TopRow/ActionsCard/VBox/BtnRow/BtnAIExtract
@onready var btn_open_import: Button = $Scroll/ContentVBox/TopRow/ActionsCard/VBox/BtnRow/BtnOpenImport
@onready var btn_export_md: Button = $Scroll/ContentVBox/TopRow/ActionsCard/VBox/BtnRow/BtnExportMd

# Starter Packs Row
@onready var btn_pack_godot: Button = $Scroll/ContentVBox/TopRow/ActionsCard/VBox/StarterRow/BtnPackGodot
@onready var btn_pack_web: Button = $Scroll/ContentVBox/TopRow/ActionsCard/VBox/StarterRow/BtnPackWeb
@onready var btn_pack_lore: Button = $Scroll/ContentVBox/TopRow/ActionsCard/VBox/StarterRow/BtnPackLore

# Browse Table
@onready var cards_table_card: PanelContainer = $Scroll/ContentVBox/CardsTableCard
@onready var table_count_label: Label = $Scroll/ContentVBox/CardsTableCard/VBox/HeaderHBox/TableCountLabel
@onready var subject_filter_option: OptionButton = $Scroll/ContentVBox/CardsTableCard/VBox/HeaderHBox/SubjectFilterOption
@onready var sort_option: OptionButton = $Scroll/ContentVBox/CardsTableCard/VBox/HeaderHBox/SortOption
@onready var search_input: LineEdit = $Scroll/ContentVBox/CardsTableCard/VBox/HeaderHBox/SearchInput
@onready var cards_list_vbox: VBoxContainer = $Scroll/ContentVBox/CardsTableCard/VBox/CardsListVBox

# Interactive Study Arena
@onready var arena_card: PanelContainer = $Scroll/ContentVBox/StudyArenaCard
@onready var arena_progress_lbl: Label = $Scroll/ContentVBox/StudyArenaCard/VBox/TopRow/ProgressLabel
@onready var arena_subject_lbl: Label = $Scroll/ContentVBox/StudyArenaCard/VBox/TopRow/SubjectLabel
@onready var btn_exit_drill: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/TopRow/BtnExitDrill

@onready var card_display_root: Control = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay
@onready var question_panel: PanelContainer = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/QuestionPanel
@onready var question_text_lbl: Label = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/QuestionPanel/VBox/QuestionText
@onready var hint_toggle_btn: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/QuestionPanel/VBox/TagRow/HintToggleBtn
@onready var btn_ai_socratic_hint: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/QuestionPanel/VBox/TagRow/BtnAISocraticHint
@onready var hint_panel: PanelContainer = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/QuestionPanel/VBox/HintPanel
@onready var hint_text_lbl: Label = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/QuestionPanel/VBox/HintPanel/HintText
@onready var ai_analogy_panel: PanelContainer = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/QuestionPanel/VBox/AIAnalogyPanel
@onready var ai_analogy_text: Label = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/QuestionPanel/VBox/AIAnalogyPanel/VBox/AIAnalogyText

@onready var btn_reveal_answer: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/BtnRevealAnswer
@onready var answer_panel: PanelContainer = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/AnswerPanel
@onready var answer_text_lbl: Label = $Scroll/ContentVBox/StudyArenaCard/VBox/CardDisplay/VBox/AnswerPanel/VBox/AnswerText

# SM-2 Recall Rating Row (1-5)
@onready var rating_row: HBoxContainer = $Scroll/ContentVBox/StudyArenaCard/VBox/RatingRow
@onready var btn_rate_1: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/RatingRow/BtnRate1
@onready var btn_rate_2: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/RatingRow/BtnRate2
@onready var btn_rate_3: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/RatingRow/BtnRate3
@onready var btn_rate_4: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/RatingRow/BtnRate4
@onready var btn_rate_5: Button = $Scroll/ContentVBox/StudyArenaCard/VBox/RatingRow/BtnRate5

# Drill Complete Screen
@onready var session_complete_panel: PanelContainer = $Scroll/ContentVBox/SessionCompleteCard
@onready var complete_summary_lbl: Label = $Scroll/ContentVBox/SessionCompleteCard/VBox/CompleteSummaryLabel
@onready var complete_rewards_lbl: Label = $Scroll/ContentVBox/SessionCompleteCard/VBox/CompleteRewardsLabel
@onready var btn_finish_drill: Button = $Scroll/ContentVBox/SessionCompleteCard/VBox/Center/BtnFinishDrill

# Modals
@onready var modal_overlay: PanelContainer = $ModalOverlay

# 1. Single Card Edit/Create Modal
@onready var card_modal: PanelContainer = $ModalOverlay/Center/CardModal
@onready var card_modal_title: Label = $ModalOverlay/Center/CardModal/VBox/TitleLabel
@onready var card_modal_q_input: TextEdit = $ModalOverlay/Center/CardModal/VBox/QuestionInput
@onready var card_modal_a_input: TextEdit = $ModalOverlay/Center/CardModal/VBox/AnswerInput
@onready var card_modal_hint_input: LineEdit = $ModalOverlay/Center/CardModal/VBox/HintInput
@onready var card_modal_subj_input: LineEdit = $ModalOverlay/Center/CardModal/VBox/SubjectInput
@onready var card_modal_polish_btn: Button = $ModalOverlay/Center/CardModal/VBox/BtnRow/BtnAIPolish
@onready var card_modal_save_btn: Button = $ModalOverlay/Center/CardModal/VBox/BtnRow/SaveBtn
@onready var card_modal_cancel_btn: Button = $ModalOverlay/Center/CardModal/VBox/BtnRow/CancelBtn

# 2. Bulk Import Modal
@onready var import_modal: PanelContainer = $ModalOverlay/Center/ImportModal
@onready var btn_switch_to_ai: Button = $ModalOverlay/Center/ImportModal/VBox/HeaderHBox/BtnSwitchToAI
@onready var import_text_edit: TextEdit = $ModalOverlay/Center/ImportModal/VBox/ImportTextEdit
@onready var import_subj_input: LineEdit = $ModalOverlay/Center/ImportModal/VBox/SubjInput
@onready var import_submit_btn: Button = $ModalOverlay/Center/ImportModal/VBox/BtnRow/ImportBtn
@onready var import_cancel_btn: Button = $ModalOverlay/Center/ImportModal/VBox/BtnRow/CancelBtn

# 3. AI Document & Flashcard Synthesizer Modal
@onready var ai_extract_modal: PanelContainer = $ModalOverlay/Center/AIExtractModal
@onready var ai_key_provider_option: OptionButton = $ModalOverlay/Center/AIExtractModal/VBox/AIKeyBanner/HBox/KeyProviderOption
@onready var ai_key_input: LineEdit = $ModalOverlay/Center/AIExtractModal/VBox/AIKeyBanner/HBox/KeyInput
@onready var ai_key_test_btn: Button = $ModalOverlay/Center/AIExtractModal/VBox/AIKeyBanner/HBox/TestKeyBtn
@onready var ai_key_get_btn: Button = $ModalOverlay/Center/AIExtractModal/VBox/AIKeyBanner/HBox/GetKeyBtn
@onready var ai_pick_file_btn: Button = $ModalOverlay/Center/AIExtractModal/VBox/FileRow/PickFileBtn
@onready var ai_selected_file_lbl: Label = $ModalOverlay/Center/AIExtractModal/VBox/FileRow/SelectedFileLabel
@onready var ai_source_text_edit: TextEdit = $ModalOverlay/Center/AIExtractModal/VBox/SourceTextEdit
@onready var ai_subj_input: LineEdit = $ModalOverlay/Center/AIExtractModal/VBox/OptionsRow/SubjectInput
@onready var ai_count_option: OptionButton = $ModalOverlay/Center/AIExtractModal/VBox/OptionsRow/CountOption
@onready var ai_focus_input: LineEdit = $ModalOverlay/Center/AIExtractModal/VBox/OptionsRow/FocusPromptInput
@onready var ai_section_option: OptionButton = $ModalOverlay/Center/AIExtractModal/VBox/SectionRow/SectionOption
@onready var ai_token_estimator_lbl: Label = $ModalOverlay/Center/AIExtractModal/VBox/SectionRow/TokenEstimatorLabel
@onready var ai_status_lbl: Label = $ModalOverlay/Center/AIExtractModal/VBox/StatusLbl
@onready var ai_preview_scroll: ScrollContainer = $ModalOverlay/Center/AIExtractModal/VBox/PreviewScroll
@onready var ai_preview_vbox: VBoxContainer = $ModalOverlay/Center/AIExtractModal/VBox/PreviewScroll/PreviewVBox
@onready var ai_generate_btn: Button = $ModalOverlay/Center/AIExtractModal/VBox/BtnRow/GenerateBtn
@onready var ai_commit_btn: Button = $ModalOverlay/Center/AIExtractModal/VBox/BtnRow/CommitBtn
@onready var ai_cancel_btn: Button = $ModalOverlay/Center/AIExtractModal/VBox/BtnRow/CancelBtn
@onready var file_dialog: FileDialog = $FileDialog

var _ai_generated_cards_cache: Array[Dictionary] = []
var _document_sections: Array[Dictionary] = []

# ==============================================================================
# 🎨 SUBJECT COLOR PALETTE
# ==============================================================================
const SUBJECT_COLORS: Dictionary = {
	"godot": Color(0.31, 0.82, 0.91),    # Cyan
	"code": Color(0.31, 0.82, 0.91),
	"typescript": Color(0.38, 0.74, 1.0), # Blue
	"study": Color(0.38, 0.74, 1.0),
	"language": Color(0.85, 0.60, 1.0),  # Violet
	"writing": Color(0.85, 0.60, 1.0),
	"design": Color(0.96, 0.45, 0.75),   # Pink
	"lore": Color(0.96, 0.78, 0.25),     # Gold
	"general": Color(0.30, 0.85, 0.50)   # Emerald
}

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _active_subject_filter: String = "all"
var _active_sort_order: String = "due" # "due", "hardest", "mastery", "alpha"
var _active_search_query: String = ""
var _editing_card_id: String = ""

# Drill session state
var _drill_cards: Array[Dictionary] = []
var _drill_index: int = 0
var _is_answer_revealed: bool = false
var _session_reviewed_count: int = 0
var _session_kp_earned: int = 0
var _session_exp_earned: int = 0

# ==============================================================================
# ⚙️ LIFECYCLE & SIGNALS
# ==============================================================================
func _ready() -> void:
	_init_sort_options()
	_connect_signals()
	refresh_all()

func _init_sort_options() -> void:
	if sort_option:
		sort_option.clear()
		sort_option.add_item("Sort: Due Soonest", 0)
		sort_option.add_item("Sort: Hardest (Low EF)", 1)
		sort_option.add_item("Sort: Highest Mastery", 2)
		sort_option.add_item("Sort: Alphabetical", 3)
		sort_option.selected = 0

func _connect_signals() -> void:
	if EventBus:
		EventBus.flashcards_updated.connect(refresh_all)
		EventBus.knowledge_points_changed.connect(func(_b, _d, _r): _refresh_metrics_bar())
		
	if btn_start_drill:
		btn_start_drill.pressed.connect(_start_study_drill)
	if btn_open_import:
		btn_open_import.pressed.connect(_open_bulk_import_modal)
	if btn_switch_to_ai:
		btn_switch_to_ai.pressed.connect(_open_ai_extract_modal)
	if btn_ai_extract:
		btn_ai_extract.pressed.connect(_open_ai_extract_modal)
	if btn_export_md:
		btn_export_md.pressed.connect(_export_deck_to_clipboard)
	if btn_new_card:
		btn_new_card.pressed.connect(_open_create_card_modal)
		
	if ai_key_provider_option:
		ai_key_provider_option.item_selected.connect(_on_modal_ai_provider_selected)
	if ai_key_input:
		ai_key_input.text_changed.connect(_on_modal_ai_key_changed)
	if ai_key_test_btn:
		ai_key_test_btn.pressed.connect(_on_modal_ai_test_pressed)
	if ai_key_get_btn:
		ai_key_get_btn.pressed.connect(_on_modal_ai_get_key_pressed)
		
	if ai_pick_file_btn:
		ai_pick_file_btn.pressed.connect(_open_file_dialog)
	if file_dialog:
		file_dialog.file_selected.connect(_on_file_selected)
	if ai_section_option:
		ai_section_option.item_selected.connect(_on_ai_section_selected)
	if ai_source_text_edit:
		ai_source_text_edit.text_changed.connect(_update_token_estimate)
	if ai_generate_btn:
		ai_generate_btn.pressed.connect(_on_ai_generate_pressed)
	if ai_commit_btn:
		ai_commit_btn.pressed.connect(_on_ai_commit_pressed)
	if ai_cancel_btn:
		ai_cancel_btn.pressed.connect(_close_modals)
		
	# Starter pack buttons
	if btn_pack_godot: btn_pack_godot.pressed.connect(func(): _load_starter_pack("godot"))
	if btn_pack_web: btn_pack_web.pressed.connect(func(): _load_starter_pack("web"))
	if btn_pack_lore: btn_pack_lore.pressed.connect(func(): _load_starter_pack("lore"))
		
	if subject_filter_option:
		subject_filter_option.item_selected.connect(_on_subject_filter_selected)
	if sort_option:
		sort_option.item_selected.connect(_on_sort_selected)
	if search_input:
		search_input.text_changed.connect(_on_search_text_changed)
		
	# Drill buttons
	if btn_exit_drill:
		btn_exit_drill.pressed.connect(_exit_study_drill)
	if btn_reveal_answer:
		btn_reveal_answer.pressed.connect(_reveal_answer_with_flip_fx)
	if hint_toggle_btn:
		hint_toggle_btn.pressed.connect(_toggle_hint)
	if btn_ai_socratic_hint:
		btn_ai_socratic_hint.pressed.connect(_on_ai_socratic_hint_pressed)
	if btn_finish_drill:
		btn_finish_drill.pressed.connect(_exit_study_drill)
		
	if card_modal_polish_btn:
		card_modal_polish_btn.pressed.connect(_on_card_modal_polish_pressed)
		
	if btn_rate_1: btn_rate_1.pressed.connect(func(): _submit_rating(1))
	if btn_rate_2: btn_rate_2.pressed.connect(func(): _submit_rating(2))
	if btn_rate_3: btn_rate_3.pressed.connect(func(): _submit_rating(3))
	if btn_rate_4: btn_rate_4.pressed.connect(func(): _submit_rating(4))
	if btn_rate_5: btn_rate_5.pressed.connect(func(): _submit_rating(5))
	
	# Modal buttons
	if card_modal_save_btn:
		card_modal_save_btn.pressed.connect(_save_single_card)
	if card_modal_cancel_btn:
		card_modal_cancel_btn.pressed.connect(_close_modals)
		
	if import_submit_btn:
		import_submit_btn.pressed.connect(_submit_bulk_import)
	if import_cancel_btn:
		import_cancel_btn.pressed.connect(_close_modals)

func _input(event: InputEvent) -> void:
	# Keyboard shortcuts during Active Study Drill
	if arena_card and arena_card.visible:
		if event is InputEventKey and event.pressed and not event.is_echo():
			var key = event.keycode
			if key == KEY_SPACE:
				if not _is_answer_revealed:
					_reveal_answer_with_flip_fx()
					get_viewport().set_input_as_handled()
			elif key == KEY_H:
				_toggle_hint()
				get_viewport().set_input_as_handled()
			elif key == KEY_ESCAPE:
				_exit_study_drill()
				get_viewport().set_input_as_handled()
			elif _is_answer_revealed:
				if key == KEY_1: _submit_rating(1); get_viewport().set_input_as_handled()
				elif key == KEY_2: _submit_rating(2); get_viewport().set_input_as_handled()
				elif key == KEY_3: _submit_rating(3); get_viewport().set_input_as_handled()
				elif key == KEY_4: _submit_rating(4); get_viewport().set_input_as_handled()
				elif key == KEY_5: _submit_rating(5); get_viewport().set_input_as_handled()

# ==============================================================================
# 🔄 REFRESH CONTROLLER
# ==============================================================================
func refresh_all() -> void:
	_refresh_metrics_bar()
	_refresh_forecast_and_mastery()
	_refresh_subject_options()
	_refresh_cards_table()

func refresh_tab() -> void:
	refresh_all()

# ==============================================================================
# 📊 SECTION 1: TOP METRICS & FORECAST BREAKDOWN
# ==============================================================================
func _refresh_metrics_bar() -> void:
	if not GameState:
		return
		
	var stats: Dictionary = GameState.get_srs_stats()
	var due_count: int = stats.get("due_cards", 0)
	var total: int = stats.get("total_cards", 0)
	var mastered: int = stats.get("mastered_cards", 0)
	var retention: float = stats.get("retention_pct", 100.0)
	var kp: int = GameState.knowledge_points
	
	if due_badge_lbl:
		due_badge_lbl.text = "🔥 %d Due Now" % due_count
		due_badge_lbl.modulate = Color(0.96, 0.62, 0.04) if due_count > 0 else Color(0.3, 0.85, 0.5)
		
	if total_cards_lbl:
		total_cards_lbl.text = "📚 %d Cards" % total
	if mastered_lbl:
		mastered_lbl.text = "🏆 %d Mastered" % mastered
	if retention_lbl:
		retention_lbl.text = "📈 %.0f%% Retention" % retention
	if kp_balance_lbl:
		kp_balance_lbl.text = "⭐ %d KP" % kp
		
	if btn_start_drill:
		btn_start_drill.text = "▶️ START STUDY DRILL (%d DUE)" % due_count if due_count > 0 else "▶️ CRAM ALL (%d CARDS)" % total

func _refresh_forecast_and_mastery() -> void:
	if not GameState:
		return
		
	var stats: Dictionary = GameState.get_srs_stats()
	var total: int = stats.get("total_cards", 0)
	var learning: int = stats.get("learning_cards", 0)
	var reviewing: int = stats.get("reviewing_cards", 0)
	var mastered: int = stats.get("mastered_cards", 0)
	
	if mastery_legend_lbl:
		mastery_legend_lbl.text = "🌱 Learning: %d  •  ⚡ Reviewing: %d  •  👑 Mastered: %d" % [learning, reviewing, mastered]
		
	if total > 0:
		var pct_l = float(learning) / float(total)
		var pct_r = float(reviewing) / float(total)
		var pct_m = float(mastered) / float(total)
		if mastery_bar_learning: mastery_bar_learning.size_flags_stretch_ratio = maxf(0.01, pct_l)
		if mastery_bar_reviewing: mastery_bar_reviewing.size_flags_stretch_ratio = maxf(0.01, pct_r)
		if mastery_bar_mastered: mastery_bar_mastered.size_flags_stretch_ratio = maxf(0.01, pct_m)
		
	# 7-Day Forecast
	var forecast: Dictionary = GameState.get_srs_forecast()
	if forecast_lbl_today: forecast_lbl_today.text = str(forecast.get("today", 0))
	if forecast_lbl_tomorrow: forecast_lbl_tomorrow.text = str(forecast.get("tomorrow", 0))
	if forecast_lbl_2_3: forecast_lbl_2_3.text = str(forecast.get("days_2_3", 0))
	if forecast_lbl_4_7: forecast_lbl_4_7.text = str(forecast.get("days_4_7", 0))
	if forecast_lbl_later: forecast_lbl_later.text = str(forecast.get("later", 0))

func _refresh_subject_options() -> void:
	if not subject_filter_option or not GameState:
		return
		
	var cur_sel: int = subject_filter_option.selected
	var prev_text: String = subject_filter_option.get_item_text(cur_sel) if cur_sel >= 0 else "All Subjects"
	
	subject_filter_option.clear()
	subject_filter_option.add_item("All Subjects", 0)
	
	var cards: Array[Dictionary] = GameState.get_flashcards()
	var subjects: Dictionary = {}
	for c in cards:
		var s: String = c.get("subject", "General").strip_edges()
		if not s.is_empty():
			subjects[s] = true
			
	var sorted_subjs: Array = subjects.keys()
	sorted_subjs.sort()
	
	var idx: int = 1
	var reselect_idx: int = 0
	for s in sorted_subjs:
		subject_filter_option.add_item(s, idx)
		if s == prev_text:
			reselect_idx = idx
		idx += 1
		
	subject_filter_option.selected = reselect_idx

func _on_subject_filter_selected(idx: int) -> void:
	if idx == 0:
		_active_subject_filter = "all"
	else:
		_active_subject_filter = subject_filter_option.get_item_text(idx)
	_refresh_cards_table()

func _on_sort_selected(idx: int) -> void:
	match idx:
		0: _active_sort_order = "due"
		1: _active_sort_order = "hardest"
		2: _active_sort_order = "mastery"
		3: _active_sort_order = "alpha"
	_refresh_cards_table()

func _on_search_text_changed(new_text: String) -> void:
	_active_search_query = new_text.strip_edges().to_lower()
	_refresh_cards_table()

# ==============================================================================
# 📋 SECTION 2: BROWSE & MANAGE TABLE
# ==============================================================================
func _refresh_cards_table() -> void:
	if not cards_list_vbox or not GameState:
		return
		
	for child in cards_list_vbox.get_children():
		child.queue_free()
		
	var cards: Array[Dictionary] = GameState.get_flashcards()
	var now_unix: int = int(Time.get_unix_time_from_system())
	var filtered: Array[Dictionary] = []
	
	for c in cards:
		var match_subj: bool = (_active_subject_filter == "all" or c.get("subject", "").to_lower() == _active_subject_filter.to_lower())
		var match_search: bool = true
		if not _active_search_query.is_empty():
			var q: String = c.get("q", "").to_lower()
			var a: String = c.get("a", "").to_lower()
			var s: String = c.get("subject", "").to_lower()
			match_search = q.contains(_active_search_query) or a.contains(_active_search_query) or s.contains(_active_search_query)
			
		if match_subj and match_search:
			filtered.append(c)
			
	# Sort filtered cards
	match _active_sort_order:
		"due":
			filtered.sort_custom(func(a, b): return int(a.get("next_due_unix", 0)) < int(b.get("next_due_unix", 0)))
		"hardest":
			filtered.sort_custom(func(a, b): return float(a.get("ef", 2.5)) < float(b.get("ef", 2.5)))
		"mastery":
			filtered.sort_custom(func(a, b): return int(a.get("repetitions", 0)) > int(b.get("repetitions", 0)))
		"alpha":
			filtered.sort_custom(func(a, b): return a.get("q", "").to_lower() < b.get("q", "").to_lower())
			
	if table_count_label:
		table_count_label.text = "%d Flashcards" % filtered.size()
		
	if filtered.is_empty():
		var empty_card: PanelContainer = PanelContainer.new()
		empty_card.custom_minimum_size = Vector2(0, 56)
		var center: CenterContainer = CenterContainer.new()
		var empty_lbl: Label = Label.new()
		empty_lbl.text = "No flashcards found. Click '✨ AI Extract', '+ New Card', 'Import', or a Starter Pack!"
		empty_lbl.add_theme_font_size_override("font_size", 9)
		empty_lbl.modulate = Color(0.55, 0.60, 0.70)
		center.add_child(empty_lbl)
		empty_card.add_child(center)
		cards_list_vbox.add_child(empty_card)
		return
		
	for card in filtered:
		var row: Control = _create_card_row(card, now_unix)
		cards_list_vbox.add_child(row)

func _create_card_row(card: Dictionary, now_unix: int) -> Control:
	var c_id: String = card.get("id", "")
	var q: String = card.get("q", "")
	var a: String = card.get("a", "")
	var h: String = card.get("hint", "")
	var subj: String = card.get("subject", "General")
	var due_unix: int = int(card.get("next_due_unix", 0))
	var reps: int = int(card.get("repetitions", 0))
	var interval: int = int(card.get("interval_days", 0))
	var ef: float = float(card.get("ef", 2.5))
	var is_due: bool = due_unix <= now_unix
	
	var row_panel: PanelContainer = PanelContainer.new()
	row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 2)
	row_panel.add_child(vbox)
	
	var top_hbox: HBoxContainer = HBoxContainer.new()
	top_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_theme_constant_override("separation", 6)
	vbox.add_child(top_hbox)
	
	# 1. Due / Status Pill
	var status_lbl: Label = Label.new()
	if is_due:
		status_lbl.text = "🔥 Due Now"
		status_lbl.modulate = Color(0.96, 0.62, 0.04)
	else:
		var days_left: int = maxi(1, int(round(float(due_unix - now_unix) / 86400.0)))
		status_lbl.text = "⏱️ In %dd" % days_left
		status_lbl.modulate = Color(0.3, 0.85, 0.5)
	status_lbl.add_theme_font_size_override("font_size", 8)
	status_lbl.custom_minimum_size = Vector2(75, 0)
	top_hbox.add_child(status_lbl)
	
	# 2. Subject Badge with Subject Palette
	var subj_lbl: Label = Label.new()
	subj_lbl.text = "[%s]" % subj
	subj_lbl.add_theme_font_size_override("font_size", 8)
	var s_key = subj.to_lower()
	subj_lbl.modulate = SUBJECT_COLORS.get(s_key, Color(0.31, 0.82, 0.91))
	subj_lbl.custom_minimum_size = Vector2(80, 0)
	top_hbox.add_child(subj_lbl)
	
	# 3. Question (Expands)
	var q_lbl: Label = Label.new()
	q_lbl.text = q
	q_lbl.add_theme_font_size_override("font_size", 9)
	q_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	q_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	top_hbox.add_child(q_lbl)
	
	# 4. SM-2 Mastery stats
	var stats_lbl: Label = Label.new()
	stats_lbl.text = "Rep: %d | I: %dd | EF: %.1f" % [reps, interval, ef]
	stats_lbl.add_theme_font_size_override("font_size", 8)
	stats_lbl.modulate = Color(0.55, 0.60, 0.70)
	stats_lbl.custom_minimum_size = Vector2(100, 0)
	top_hbox.add_child(stats_lbl)
	
	# 5. Edit Button
	var edit_btn: Button = Button.new()
	edit_btn.text = "✏️"
	edit_btn.flat = true
	edit_btn.custom_minimum_size = Vector2(22, 20)
	edit_btn.focus_mode = Control.FOCUS_NONE
	edit_btn.tooltip_text = "Edit Flashcard"
	edit_btn.pressed.connect(func(): _open_edit_card_modal(card))
	top_hbox.add_child(edit_btn)
	
	# 6. Delete Button
	var del_btn: Button = Button.new()
	del_btn.text = "🗑️"
	del_btn.flat = true
	del_btn.custom_minimum_size = Vector2(22, 20)
	del_btn.focus_mode = Control.FOCUS_NONE
	del_btn.tooltip_text = "Delete Flashcard"
	del_btn.pressed.connect(func(): _delete_card(c_id))
	top_hbox.add_child(del_btn)
	
	# Sub-Row: Answer & Hint Preview
	var ans_hbox: HBoxContainer = HBoxContainer.new()
	ans_hbox.add_theme_constant_override("separation", 4)
	
	var a_icon: Label = Label.new()
	a_icon.text = "  ↳ 💡"
	a_icon.add_theme_font_size_override("font_size", 8)
	a_icon.modulate = Color(0.3, 0.85, 0.5, 0.8)
	ans_hbox.add_child(a_icon)
	
	var a_lbl: Label = Label.new()
	var preview_str: String = a.replace("\n", " ")
	if not h.strip_edges().is_empty():
		preview_str = "[Hint: %s]  " % h + preview_str
	a_lbl.text = preview_str
	a_lbl.add_theme_font_size_override("font_size", 8)
	a_lbl.modulate = Color(0.70, 0.75, 0.85, 0.9)
	a_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	a_lbl.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	ans_hbox.add_child(a_lbl)
	
	vbox.add_child(ans_hbox)
	return row_panel

# ==============================================================================
# 🎮 SECTION 3: INTERACTIVE ACTIVE RECALL STUDY ARENA
# ==============================================================================
func _start_study_drill() -> void:
	if not GameState:
		return
		
	var due_list: Array[Dictionary] = GameState.get_due_flashcards(_active_subject_filter)
	if due_list.is_empty():
		# If no cards are due, cram all cards
		due_list = GameState.get_flashcards()
		
	if due_list.is_empty():
		if NotificationManager:
			NotificationManager.show_toast("📚 Deck is empty! Add cards first.", NotificationManager.ToastType.WARNING)
		return
		
	_drill_cards = due_list.duplicate()
	_drill_cards.shuffle() # Randomize review order
	_drill_index = 0
	_session_reviewed_count = 0
	_session_kp_earned = 0
	_session_exp_earned = 0
	
	# Hide browse table & complete panel, show arena
	if cards_table_card: cards_table_card.visible = false
	if session_complete_panel: session_complete_panel.visible = false
	if arena_card: arena_card.visible = true
	
	_load_current_drill_card()
	
	if AudioManager:
		AudioManager.play_sfx("click")

func _load_current_drill_card() -> void:
	if _drill_index >= _drill_cards.size():
		_finish_study_drill()
		return
		
	var card: Dictionary = _drill_cards[_drill_index]
	_is_answer_revealed = false
	
	if arena_progress_lbl:
		arena_progress_lbl.text = "Card %d / %d" % [_drill_index + 1, _drill_cards.size()]
	if arena_subject_lbl:
		var s = card.get("subject", "General")
		arena_subject_lbl.text = "🏷️ [%s]" % s
		var s_key = s.to_lower()
		arena_subject_lbl.modulate = SUBJECT_COLORS.get(s_key, Color(0.31, 0.82, 0.91))
		
	if question_text_lbl:
		question_text_lbl.text = card.get("q", "")
	if answer_text_lbl:
		answer_text_lbl.text = card.get("a", "")
		
	# Hint handling
	var hint_str: String = card.get("hint", "").strip_edges()
	if hint_toggle_btn:
		hint_toggle_btn.visible = not hint_str.is_empty()
	if hint_panel:
		hint_panel.visible = false
	if hint_text_lbl:
		hint_text_lbl.text = hint_str
		
	# AI Socratic Hint & Analogy
	if ai_analogy_panel:
		ai_analogy_panel.visible = false
	if btn_ai_socratic_hint:
		var has_saved_analogy = not card.get("ai_hint", "").strip_edges().is_empty()
		btn_ai_socratic_hint.text = "💡 AI Analogy (Saved)" if has_saved_analogy else "✨ AI Analogy"
		btn_ai_socratic_hint.disabled = false
		
	if answer_panel:
		answer_panel.visible = false
	if btn_reveal_answer:
		btn_reveal_answer.visible = true
	if rating_row:
		rating_row.visible = false
		
	# Reset scale
	if card_display_root:
		card_display_root.scale = Vector2.ONE

func _toggle_hint() -> void:
	if hint_panel:
		hint_panel.visible = not hint_panel.visible
		if AudioManager:
			AudioManager.play_sfx("click")

func _on_ai_socratic_hint_pressed() -> void:
	if _drill_cards.is_empty() or _drill_index >= _drill_cards.size():
		return
		
	var card: Dictionary = _drill_cards[_drill_index]
	var saved_analogy = card.get("ai_hint", "").strip_edges()
	
	if ai_analogy_panel and ai_analogy_panel.visible:
		ai_analogy_panel.visible = false
		return
		
	# If already cached locally, display immediately with 0 API cost!
	if not saved_analogy.is_empty():
		if ai_analogy_text:
			ai_analogy_text.text = saved_analogy
		if ai_analogy_panel:
			ai_analogy_panel.visible = true
		if AudioManager:
			AudioManager.play_sfx("click")
		return
		
	if not AIService:
		return
		
	if AIService.provider != AIService.Provider.OLLAMA and AIService.api_key.is_empty():
		if NotificationManager:
			NotificationManager.show_toast("⚠️ API Key required. Configure in Config tab!", NotificationManager.ToastType.WARNING)
		return
		
	if btn_ai_socratic_hint:
		btn_ai_socratic_hint.text = "⚡ Asking pet..."
		btn_ai_socratic_hint.disabled = true
		
	var q = card.get("q", "")
	var a = card.get("a", "")
	
	AIService.explain_concept(q, a, func(success: bool, result_text: Variant, err_msg: String):
		if btn_ai_socratic_hint:
			btn_ai_socratic_hint.disabled = false
			
		if not success:
			if btn_ai_socratic_hint:
				btn_ai_socratic_hint.text = "✨ AI Analogy"
			if NotificationManager:
				NotificationManager.show_toast("⚠️ Analogy error: " + err_msg, NotificationManager.ToastType.ERROR)
			return
			
		var analogy = str(result_text).strip_edges()
		card["ai_hint"] = analogy
		
		# Persist to database so subsequent drills are 100% free and instant
		var card_id = card.get("id", "")
		if not card_id.is_empty() and GameState:
			GameState.edit_flashcard(card_id, card.get("q", ""), card.get("a", ""), card.get("subject", "General"), card.get("hint", ""))
			
		if ai_analogy_text:
			ai_analogy_text.text = analogy
		if ai_analogy_panel:
			ai_analogy_panel.visible = true
		if btn_ai_socratic_hint:
			btn_ai_socratic_hint.text = "💡 AI Analogy (Saved)"
		if AudioManager:
			AudioManager.play_sfx("achievement")
	)

func _reveal_answer_with_flip_fx() -> void:
	if _is_answer_revealed:
		return
		
	_is_answer_revealed = true
	
	if AudioManager:
		AudioManager.play_sfx("card_flip")
		
	# 2-Stage Squash & Expand Card Flip Animation
	if card_display_root:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_QUAD)
		# Phase 1: Squash horizontally
		tween.tween_property(card_display_root, "scale:x", 0.05, 0.08)
		tween.tween_callback(func():
			if answer_panel: answer_panel.visible = true
			if btn_reveal_answer: btn_reveal_answer.visible = false
			if rating_row: rating_row.visible = true
		)
		# Phase 2: Expand back with subtle bounce
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(card_display_root, "scale:x", 1.0, 0.12)
	else:
		if answer_panel: answer_panel.visible = true
		if btn_reveal_answer: btn_reveal_answer.visible = false
		if rating_row: rating_row.visible = true

func _submit_rating(quality: int) -> void:
	if _drill_index >= _drill_cards.size() or not GameState:
		return
		
	var card: Dictionary = _drill_cards[_drill_index]
	var c_id: String = card.get("id", "")
	
	var res: Dictionary = GameState.submit_sm2_review(c_id, quality)
	_session_reviewed_count += 1
	_session_kp_earned += res.get("earned_kp", 2)
	_session_exp_earned += res.get("earned_exp", 10)
	
	# Pet Reaction & Audio Feedback
	if quality >= 4:
		if AudioManager: AudioManager.play_sfx("level_up")
		if EventBus: EventBus.pet_interacted.emit("petted")
	elif quality >= 3:
		if AudioManager: AudioManager.play_sfx("coin_pop")
	else:
		if AudioManager: AudioManager.play_sfx("click")
			
	_drill_index += 1
	_load_current_drill_card()

func _finish_study_drill() -> void:
	if arena_card: arena_card.visible = false
	if session_complete_panel:
		session_complete_panel.visible = true
		if complete_summary_lbl:
			complete_summary_lbl.text = "🎉 Awesome Job! You reviewed %d cards in this active recall session." % _session_reviewed_count
		if complete_rewards_lbl:
			complete_rewards_lbl.text = "⭐ +%d Knowledge Points (KP)  •  ✨ +%d EXP Earned" % [_session_kp_earned, _session_exp_earned]
			
	if AudioManager:
		AudioManager.play_sfx("achievement")
	if NotificationManager:
		NotificationManager.show_toast("🧠 Study Drill Complete! +%d KP" % _session_kp_earned, NotificationManager.ToastType.SUCCESS)
	refresh_all()

func _exit_study_drill() -> void:
	if arena_card: arena_card.visible = false
	if session_complete_panel: session_complete_panel.visible = false
	if cards_table_card: cards_table_card.visible = true
	refresh_all()

# ==============================================================================
# 📦 SECTION 4: STARTER PACKS & EXPORT
# ==============================================================================
func _load_starter_pack(pack_id: String) -> void:
	if not GameState:
		return
	var added: int = GameState.load_starter_deck(pack_id)
	if added > 0:
		if NotificationManager:
			NotificationManager.show_toast("🚀 Loaded %d %s starter cards!" % [added, pack_id.capitalize()], NotificationManager.ToastType.SUCCESS)
		if AudioManager:
			AudioManager.play_sfx("achievement")
		refresh_all()

func _export_deck_to_clipboard() -> void:
	if not GameState:
		return
	var md: String = GameState.export_deck_markdown()
	DisplayServer.clipboard_set(md)
	if NotificationManager:
		NotificationManager.show_toast("📋 Study Deck exported to Clipboard in Markdown format!", NotificationManager.ToastType.SUCCESS)
	if AudioManager:
		AudioManager.play_sfx("coin_pop")

# ==============================================================================
# 📝 SECTION 5: MODALS & EDIT/DELETE/IMPORT ACTIONS
# ==============================================================================
func _open_create_card_modal() -> void:
	_editing_card_id = ""
	if card_modal_title: card_modal_title.text = "➕ Create New Flashcard"
	if card_modal_q_input: card_modal_q_input.text = ""
	if card_modal_a_input: card_modal_a_input.text = ""
	if card_modal_hint_input: card_modal_hint_input.text = ""
	if card_modal_subj_input: card_modal_subj_input.text = "General"
	
	if import_modal: import_modal.visible = false
	if ai_extract_modal: ai_extract_modal.visible = false
	if card_modal: card_modal.visible = true
	if modal_overlay: modal_overlay.visible = true

func _open_edit_card_modal(card: Dictionary) -> void:
	_editing_card_id = card.get("id", "")
	if card_modal_title: card_modal_title.text = "✏️ Edit Flashcard"
	if card_modal_q_input: card_modal_q_input.text = card.get("q", "")
	if card_modal_a_input: card_modal_a_input.text = card.get("a", "")
	if card_modal_hint_input: card_modal_hint_input.text = card.get("hint", "")
	if card_modal_subj_input: card_modal_subj_input.text = card.get("subject", "General")
	
	if import_modal: import_modal.visible = false
	if ai_extract_modal: ai_extract_modal.visible = false
	if card_modal: card_modal.visible = true
	if modal_overlay: modal_overlay.visible = true

func _open_bulk_import_modal() -> void:
	if import_text_edit: import_text_edit.text = ""
	if import_subj_input: import_subj_input.text = "General"
	
	if card_modal: card_modal.visible = false
	if ai_extract_modal: ai_extract_modal.visible = false
	if import_modal: import_modal.visible = true
	if modal_overlay: modal_overlay.visible = true

func _open_ai_extract_modal() -> void:
	_ai_generated_cards_cache.clear()
	_document_sections.clear()
	if ai_source_text_edit: ai_source_text_edit.text = ""
	if ai_selected_file_lbl: ai_selected_file_lbl.text = "No file selected (or paste text below)"
	if ai_subj_input: ai_subj_input.text = "General"
	if ai_focus_input: ai_focus_input.text = ""
	if ai_section_option:
		ai_section_option.clear()
		ai_section_option.add_item("All Document", 0)
		ai_section_option.selected = 0
		
	_refresh_modal_ai_key_ui()
	_update_token_estimate()
	
	if ai_status_lbl:
		if AIService and AIService.provider != AIService.Provider.OLLAMA and AIService.api_key.is_empty():
			ai_status_lbl.text = "🔑 Enter your Gemini API key above (Click 'ℹ️ Get Key' for free key)!"
			ai_status_lbl.modulate = Color(0.96, 0.78, 0.25)
		else:
			ai_status_lbl.text = "Ready to generate"
			ai_status_lbl.modulate = Color(0.58, 0.64, 0.72)
			
	if ai_preview_scroll: ai_preview_scroll.visible = false
	if ai_commit_btn: ai_commit_btn.visible = false
	if ai_generate_btn:
		ai_generate_btn.visible = true
		ai_generate_btn.disabled = false
		
	if card_modal: card_modal.visible = false
	if import_modal: import_modal.visible = false
	if ai_extract_modal: ai_extract_modal.visible = true
	if modal_overlay: modal_overlay.visible = true

func _refresh_modal_ai_key_ui() -> void:
	if not AIService:
		return
	if ai_key_provider_option:
		ai_key_provider_option.selected = int(AIService.provider)
	if ai_key_input:
		ai_key_input.text = AIService.api_key
		match AIService.provider:
			AIService.Provider.GEMINI:
				ai_key_input.placeholder_text = "Paste Gemini API key..."
			AIService.Provider.OPENAI:
				ai_key_input.placeholder_text = "Paste OpenAI API key..."
			AIService.Provider.OLLAMA:
				ai_key_input.placeholder_text = "Local Ollama (no key required)"
	if ai_key_get_btn:
		ai_key_get_btn.visible = (AIService.provider != AIService.Provider.OLLAMA)
		ai_key_get_btn.text = "ℹ️ Get Key"

func _on_modal_ai_provider_selected(idx: int) -> void:
	if not AIService:
		return
	AIService.save_ai_config(idx as AIService.Provider, ai_key_input.text if ai_key_input else "")
	_refresh_modal_ai_key_ui()
	_update_token_estimate()
	if ai_status_lbl:
		ai_status_lbl.text = "Provider changed to %s" % AIService.PROVIDER_NAMES[idx]
		ai_status_lbl.modulate = Color(0.31, 0.82, 0.91)

func _on_modal_ai_key_changed(new_key: String) -> void:
	if not AIService:
		return
	AIService.save_ai_config(AIService.provider, new_key)
	if ai_status_lbl:
		ai_status_lbl.text = "✓ API Key saved! Click '⚡ Test' to verify or '✨ Generate with AI'."
		ai_status_lbl.modulate = Color(0.31, 0.82, 0.91)

func _on_modal_ai_test_pressed() -> void:
	if not AIService or not ai_status_lbl:
		return
	if ai_key_test_btn:
		ai_key_test_btn.disabled = true
		ai_key_test_btn.text = "⚡ Testing..."
	ai_status_lbl.text = "Testing %s connection..." % AIService.PROVIDER_NAMES[AIService.provider]
	ai_status_lbl.modulate = Color(0.96, 0.78, 0.25)
	
	AIService.test_connection(func(success: bool, msg: String):
		if ai_key_test_btn:
			ai_key_test_btn.disabled = false
			ai_key_test_btn.text = "⚡ Test"
		if success:
			ai_status_lbl.text = "✓ API Key Verified! %s is ready." % AIService.PROVIDER_NAMES[AIService.provider]
			ai_status_lbl.modulate = Color(0.24, 0.86, 0.52)
			if NotificationManager:
				NotificationManager.show_toast("✓ Connected to AI successfully!", NotificationManager.ToastType.SUCCESS)
			if AudioManager:
				AudioManager.play_sfx("achievement")
		else:
			var short_msg = msg if msg.length() <= 80 else msg.substr(0, 76) + "..."
			ai_status_lbl.text = "✗ " + short_msg
			ai_status_lbl.tooltip_text = msg
			ai_status_lbl.modulate = Color(1.0, 0.35, 0.35)
			if NotificationManager:
				NotificationManager.show_toast("⚠️ " + short_msg, NotificationManager.ToastType.ERROR)
	)

func _on_modal_ai_get_key_pressed() -> void:
	if AIService:
		AIService.open_get_key_url()

func _update_token_estimate() -> void:
	if not ai_token_estimator_lbl:
		return
	var tokens = DocumentParser.estimate_tokens(ai_source_text_edit.text) if ai_source_text_edit else 0
	var provider_str = "Free on Gemini"
	if AIService:
		if AIService.provider == AIService.Provider.OLLAMA:
			provider_str = "Local Ollama"
		elif AIService.provider == AIService.Provider.OPENAI:
			provider_str = "OpenAI"
	ai_token_estimator_lbl.text = "📊 ~%d Tokens (%s)" % [tokens, provider_str]

func _open_file_dialog() -> void:
	if not file_dialog:
		return
	var downloads_path = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	var documents_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	
	if not downloads_path.is_empty() and DirAccess.dir_exists_absolute(downloads_path):
		file_dialog.current_dir = downloads_path
	elif not documents_path.is_empty() and DirAccess.dir_exists_absolute(documents_path):
		file_dialog.current_dir = documents_path
		
	file_dialog.use_native_dialog = true
	file_dialog.popup_centered_ratio(0.75)

func _on_file_selected(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
		
	var fname = path.get_file()
	if ai_selected_file_lbl:
		ai_selected_file_lbl.text = "📄 " + fname
		
	var extracted = DocumentParser.extract_text_from_file(path)
	if ai_source_text_edit:
		ai_source_text_edit.text = extracted
		
	# Parse document sections / chapters
	_document_sections = DocumentParser.parse_document_sections(extracted)
	if ai_section_option:
		ai_section_option.clear()
		ai_section_option.add_item("Full Document (%dw)" % DocumentParser.count_words(extracted), 0)
		for i in range(_document_sections.size()):
			var sec = _document_sections[i]
			var raw_title = str(sec.get("title", "Section %d" % (i+1)))
			var display_title = raw_title if raw_title.length() <= 24 else raw_title.substr(0, 22) + ".."
			ai_section_option.add_item("%s (%dw)" % [display_title, sec.get("word_count", 0)], i + 1)
		ai_section_option.selected = 0
		
	# Smart subject deduction
	if ai_subj_input and (ai_subj_input.text == "General" or ai_subj_input.text.is_empty()):
		ai_subj_input.text = DocumentParser.detect_subject_tag(extracted, fname)
		
	_update_token_estimate()
	
	var word_count = DocumentParser.count_words(extracted)
	if word_count <= 3 or extracted.length() < 20:
		if ai_status_lbl:
			ai_status_lbl.text = "⚠️ Extracted text is very short (%d words). If this is a scanned PDF image, please copy/paste text directly." % word_count
			ai_status_lbl.modulate = Color(1.0, 0.7, 0.2)
		if NotificationManager:
			NotificationManager.show_toast("⚠️ Little or no selectable text found in %s" % fname, NotificationManager.ToastType.WARNING)
	else:
		if ai_status_lbl:
			ai_status_lbl.text = "✓ Extracted %d words across %d sections! Click '✨ Generate with AI'." % [word_count, max(1, _document_sections.size())]
			ai_status_lbl.modulate = Color(0.24, 0.86, 0.52)
		if NotificationManager:
			NotificationManager.show_toast("📄 Loaded %s (%d words)" % [fname, word_count], NotificationManager.ToastType.SUCCESS)

func _on_ai_section_selected(idx: int) -> void:
	if idx == 0:
		# Full document
		pass
	elif idx - 1 < _document_sections.size():
		var sec = _document_sections[idx - 1]
		if ai_source_text_edit:
			ai_source_text_edit.text = sec.get("text", "")
		if ai_subj_input:
			var sec_title = sec.get("title", "")
			if not sec_title.is_empty():
				ai_subj_input.text = sec_title.substr(0, 24)
	_update_token_estimate()

func _on_card_modal_polish_pressed() -> void:
	if not AIService:
		return
		
	if AIService.provider != AIService.Provider.OLLAMA and AIService.api_key.is_empty():
		if NotificationManager:
			NotificationManager.show_toast("⚠️ API Key missing! Add in Config tab.", NotificationManager.ToastType.WARNING)
		return
		
	var draft_q = card_modal_q_input.text.strip_edges() if card_modal_q_input else ""
	var draft_a = card_modal_a_input.text.strip_edges() if card_modal_a_input else ""
	
	if draft_q.is_empty() and draft_a.is_empty():
		if NotificationManager:
			NotificationManager.show_toast("⚠️ Enter a draft question or answer to polish!", NotificationManager.ToastType.WARNING)
		return
		
	if card_modal_polish_btn:
		card_modal_polish_btn.text = "⚡ Polishing..."
		card_modal_polish_btn.disabled = true
		
	AIService.polish_card(draft_q, draft_a, func(success: bool, data: Variant, err_msg: String):
		if card_modal_polish_btn:
			card_modal_polish_btn.text = "✨ AI Polish"
			card_modal_polish_btn.disabled = false
			
		if not success or typeof(data) != TYPE_DICTIONARY:
			if NotificationManager:
				NotificationManager.show_toast("⚠️ AI Polish failed: " + err_msg, NotificationManager.ToastType.ERROR)
			return
			
		var dict: Dictionary = data
		if card_modal_q_input and dict.has("front") and not str(dict["front"]).is_empty():
			card_modal_q_input.text = str(dict["front"])
		if card_modal_a_input and dict.has("back") and not str(dict["back"]).is_empty():
			card_modal_a_input.text = str(dict["back"])
		if card_modal_hint_input and dict.has("hint") and not str(dict["hint"]).is_empty():
			card_modal_hint_input.text = str(dict["hint"])
		if card_modal_subj_input and dict.has("subject") and not str(dict["subject"]).is_empty() and card_modal_subj_input.text == "General":
			card_modal_subj_input.text = str(dict["subject"])
			
		if NotificationManager:
			NotificationManager.show_toast("✨ Card sharpened with SuperMemo active-recall principles!", NotificationManager.ToastType.SUCCESS)
		if AudioManager:
			AudioManager.play_sfx("achievement")
	)

func _on_ai_generate_pressed() -> void:
	if not AIService:
		return
		
	if AIService.provider != AIService.Provider.OLLAMA and AIService.api_key.is_empty():
		if ai_status_lbl:
			ai_status_lbl.text = "⚠️ API Key missing! Open Config (Right Panel) to add your key."
			ai_status_lbl.modulate = Color(1.0, 0.4, 0.4)
		if NotificationManager:
			NotificationManager.show_toast("⚠️ Please enter your AI API key in Config tab first!", NotificationManager.ToastType.WARNING)
		return
		
	var raw_text = ai_source_text_edit.text.strip_edges() if ai_source_text_edit else ""
	if raw_text.is_empty():
		if ai_status_lbl:
			ai_status_lbl.text = "⚠️ Please paste text or choose a document first."
			ai_status_lbl.modulate = Color(1.0, 0.6, 0.2)
		return
		
	var count = 10
	if ai_count_option:
		var sel_id = ai_count_option.get_selected_id()
		count = sel_id if sel_id > 0 else 10
		
	var focus_hint = ai_focus_input.text.strip_edges() if ai_focus_input else ""
	var default_subj = ai_subj_input.text.strip_edges() if ai_subj_input else "General"
	if default_subj.is_empty(): default_subj = "General"
	
	if ai_status_lbl:
		ai_status_lbl.text = "⚡ Asking %s... Synthesizing %d atomic flashcards..." % [AIService.PROVIDER_NAMES[AIService.provider], count]
		ai_status_lbl.modulate = Color(0.96, 0.78, 0.25)
		
	if ai_generate_btn:
		ai_generate_btn.text = "⚡ Synthesizing..."
		ai_generate_btn.disabled = true
		
	AIService.generate_flashcards(raw_text, count, focus_hint, func(success: bool, data: Variant, err_msg: String):
		if ai_generate_btn:
			ai_generate_btn.text = "✨ Generate with AI"
			ai_generate_btn.disabled = false
			
		if not success or typeof(data) != TYPE_ARRAY:
			if ai_status_lbl:
				ai_status_lbl.text = "✗ " + err_msg.substr(0, 50)
				ai_status_lbl.modulate = Color(1.0, 0.35, 0.35)
			if NotificationManager:
				NotificationManager.show_toast("⚠️ AI Generation failed: " + err_msg, NotificationManager.ToastType.ERROR)
			return
			
		var raw_cards = data as Array
		if raw_cards.is_empty():
			if ai_status_lbl:
				ai_status_lbl.text = "⚠️ No cards returned by model. Try adding more text."
				ai_status_lbl.modulate = Color(1.0, 0.6, 0.2)
			return
			
		_ai_generated_cards_cache.clear()
		for c in raw_cards:
			if typeof(c) == TYPE_DICTIONARY:
				var front = c.get("front", c.get("q", c.get("question", "")))
				var back = c.get("back", c.get("a", c.get("answer", "")))
				var subj = c.get("subject", default_subj)
				var hint = c.get("hint", "")
				if front != "" and back != "":
					_ai_generated_cards_cache.append({
						"q": front,
						"a": back,
						"subject": subj,
						"hint": hint
					})
					
		if _ai_generated_cards_cache.is_empty():
			if ai_status_lbl:
				ai_status_lbl.text = "⚠️ Could not parse valid Q&A from model response."
				ai_status_lbl.modulate = Color(1.0, 0.4, 0.4)
			return
			
		_populate_ai_preview_cards()
		
		if ai_preview_scroll:
			ai_preview_scroll.visible = true
			
		if ai_status_lbl:
			ai_status_lbl.text = "🎉 Synthesized %d cards! Review below, then click 'Add All to Deck'." % _ai_generated_cards_cache.size()
			ai_status_lbl.modulate = Color(0.24, 0.86, 0.52)
			
		if ai_commit_btn:
			ai_commit_btn.visible = true
			ai_commit_btn.text = "📥 Add All (%d Cards) to Deck (+15 KP)" % _ai_generated_cards_cache.size()
			
		if AudioManager:
			AudioManager.play_sfx("achievement")
		if NotificationManager:
			NotificationManager.show_toast("🎉 AI synthesized %d flashcards!" % _ai_generated_cards_cache.size(), NotificationManager.ToastType.SUCCESS)
	)

func _populate_ai_preview_cards() -> void:
	if not ai_preview_vbox or not ai_preview_scroll:
		return
		
	for child in ai_preview_vbox.get_children():
		child.queue_free()
		
	ai_preview_scroll.visible = true
	
	for i in range(_ai_generated_cards_cache.size()):
		var card = _ai_generated_cards_cache[i]
		var item_card = PanelContainer.new()
		item_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var sbox = StyleBoxFlat.new()
		sbox.bg_color = Color(0.06, 0.08, 0.13, 0.95)
		sbox.border_width_left = 1
		sbox.border_width_top = 1
		sbox.border_width_right = 1
		sbox.border_width_bottom = 1
		sbox.border_color = Color(0.2, 0.25, 0.38, 0.8)
		sbox.corner_radius_top_left = 3
		sbox.corner_radius_top_right = 3
		sbox.corner_radius_bottom_right = 3
		sbox.corner_radius_bottom_left = 3
		sbox.content_margin_left = 6
		sbox.content_margin_top = 4
		sbox.content_margin_right = 6
		sbox.content_margin_bottom = 4
		item_card.add_theme_stylebox_override("panel", sbox)
		
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 6)
		item_card.add_child(row)
		
		var num_lbl = Label.new()
		num_lbl.text = "#%d" % (i + 1)
		num_lbl.add_theme_font_size_override("font_size", 7)
		num_lbl.modulate = Color(0.31, 0.82, 0.91)
		row.add_child(num_lbl)
		
		var q_edit = LineEdit.new()
		q_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		q_edit.add_theme_font_size_override("font_size", 8)
		q_edit.text = card.get("q", "")
		var idx_capture = i
		q_edit.text_changed.connect(func(new_q): _ai_generated_cards_cache[idx_capture]["q"] = new_q)
		row.add_child(q_edit)
		
		var a_edit = LineEdit.new()
		a_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		a_edit.add_theme_font_size_override("font_size", 8)
		a_edit.text = card.get("a", "")
		a_edit.text_changed.connect(func(new_a): _ai_generated_cards_cache[idx_capture]["a"] = new_a)
		row.add_child(a_edit)
		
		var del_btn = Button.new()
		del_btn.text = "✖"
		del_btn.add_theme_font_size_override("font_size", 7)
		del_btn.focus_mode = Control.FOCUS_NONE
		del_btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		del_btn.pressed.connect(func():
			_ai_generated_cards_cache.remove_at(idx_capture)
			_populate_ai_preview_cards()
			if ai_commit_btn:
				ai_commit_btn.text = "📥 Add All (%d Cards)" % _ai_generated_cards_cache.size()
				if _ai_generated_cards_cache.is_empty():
					ai_commit_btn.visible = false
					ai_preview_scroll.visible = false
		)
		row.add_child(del_btn)
		
		ai_preview_vbox.add_child(item_card)

func _on_ai_commit_pressed() -> void:
	if not GameState or _ai_generated_cards_cache.is_empty():
		return
		
	var default_subj = ai_subj_input.text.strip_edges() if ai_subj_input else "General"
	if default_subj.is_empty(): default_subj = "General"
	
	var added_count = 0
	for card in _ai_generated_cards_cache:
		var q = card.get("q", "").strip_edges()
		var a = card.get("a", "").strip_edges()
		var subj = card.get("subject", default_subj)
		var hint = card.get("hint", "")
		if q != "" and a != "":
			GameState.add_flashcard(q, a, subj, hint)
			added_count += 1
			
	if added_count > 0:
		GameState.add_knowledge_points(15, "ai_deck_synthesis")
		if NotificationManager:
			NotificationManager.show_toast("🎉 Added %d AI flashcards to your deck! (+15 KP)" % added_count, NotificationManager.ToastType.SUCCESS)
		if AudioManager:
			AudioManager.play_sfx("achievement")
			
	_close_modals()
	refresh_all()

func _close_modals() -> void:
	if modal_overlay: modal_overlay.visible = false
	if ai_extract_modal: ai_extract_modal.visible = false

func _save_single_card() -> void:
	if not GameState:
		return
		
	var q: String = card_modal_q_input.text.strip_edges() if card_modal_q_input else ""
	var a: String = card_modal_a_input.text.strip_edges() if card_modal_a_input else ""
	var h: String = card_modal_hint_input.text.strip_edges() if card_modal_hint_input else ""
	var subj: String = card_modal_subj_input.text.strip_edges() if card_modal_subj_input else "General"
	
	if q.is_empty() or a.is_empty():
		if NotificationManager:
			NotificationManager.show_toast("Question and Answer cannot be empty!", NotificationManager.ToastType.WARNING)
		return
		
	if _editing_card_id.is_empty():
		GameState.add_flashcard(q, a, subj, h)
		if NotificationManager:
			NotificationManager.show_toast("✨ Flashcard added to deck!", NotificationManager.ToastType.SUCCESS)
	else:
		GameState.edit_flashcard(_editing_card_id, q, a, subj, h)
		if NotificationManager:
			NotificationManager.show_toast("💾 Flashcard updated!", NotificationManager.ToastType.INFO)
			
	_close_modals()
	refresh_all()

func _delete_card(card_id: String) -> void:
	if not GameState:
		return
	if GameState.delete_flashcard(card_id):
		if NotificationManager:
			NotificationManager.show_toast("🗑️ Card removed from deck.", NotificationManager.ToastType.INFO)
		refresh_all()

func _submit_bulk_import() -> void:
	if not GameState or not import_text_edit:
		return
		
	var raw_text: String = import_text_edit.text.strip_edges()
	var default_subj: String = import_subj_input.text.strip_edges() if import_subj_input else "General"
	
	if raw_text.is_empty():
		if NotificationManager:
			NotificationManager.show_toast("Import text is empty!", NotificationManager.ToastType.WARNING)
		return
		
	var count: int = GameState.bulk_import_flashcards(raw_text, default_subj)
	if count > 0:
		if NotificationManager:
			NotificationManager.show_toast("🎉 Successfully imported %d flashcards!" % count, NotificationManager.ToastType.SUCCESS)
		if AudioManager:
			AudioManager.play_sfx("achievement")
	else:
		if NotificationManager:
			NotificationManager.show_toast("No valid flashcards found in text.", NotificationManager.ToastType.WARNING)
			
	_close_modals()
	refresh_all()
