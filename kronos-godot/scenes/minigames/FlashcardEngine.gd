extends Control

@onready var question_label: Label = $Panel/VBox/CardScroll/CardVBox/QuestionCard/QuestionLabel
@onready var answer_card: PanelContainer = $Panel/VBox/CardScroll/CardVBox/AnswerCard
@onready var answer_label: Label = $Panel/VBox/CardScroll/CardVBox/AnswerCard/AnswerLabel
@onready var subject_badge: Label = $Panel/VBox/Header/SubjectBadge
@onready var reveal_button: Button = $Panel/VBox/BottomActions/RevealButton
@onready var grading_hbox: HBoxContainer = $Panel/VBox/BottomActions/GradingHBox
@onready var hard_button: Button = $Panel/VBox/BottomActions/GradingHBox/HardButton
@onready var good_button: Button = $Panel/VBox/BottomActions/GradingHBox/GoodButton
@onready var easy_button: Button = $Panel/VBox/BottomActions/GradingHBox/EasyButton
@onready var close_button: Button = $Panel/VBox/Header/CloseButton
@onready var progress_label: Label = $Panel/VBox/Header/ProgressLabel

var current_card_index: int = 0
var cards_to_review: Array[Dictionary] = []

signal closed()

func _ready() -> void:
	close_button.pressed.connect(_on_close_button_pressed)
	reveal_button.pressed.connect(_on_reveal_button_pressed)
	hard_button.pressed.connect(func(): _on_grade_button_pressed("hard"))
	good_button.pressed.connect(func(): _on_grade_button_pressed("good"))
	easy_button.pressed.connect(func(): _on_grade_button_pressed("easy"))
	
	_start_session()

func _start_session() -> void:
	if GameState:
		var saved_deck = GameState.get_flashcards()
		cards_to_review = saved_deck.duplicate()
	else:
		cards_to_review = []
		
	if cards_to_review.is_empty():
		_show_empty_deck()
		return
		
	cards_to_review.shuffle()
	current_card_index = 0
	_show_current_card()

func _show_empty_deck() -> void:
	if subject_badge:
		subject_badge.text = "• EMPTY"
	question_label.text = "No cards in your study deck!\n\nAdd cards in the [DECK] tab in the right panel."
	answer_card.hide()
	reveal_button.hide()
	grading_hbox.hide()
	progress_label.text = "0 / 0"

func _show_current_card() -> void:
	if current_card_index >= cards_to_review.size():
		_finish_session()
		return
		
	var card: Dictionary = cards_to_review[current_card_index]
	var subj: String = card.get("subject", "General")
	if subject_badge:
		subject_badge.text = "• " + subj.to_upper()
		
	question_label.text = "Q: " + card.get("q", "")
	answer_label.text = "A: " + card.get("a", "")
	answer_card.hide()
	
	reveal_button.show()
	grading_hbox.hide()
	progress_label.text = "%d / %d" % [current_card_index + 1, cards_to_review.size()]

func _on_reveal_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("click")
	answer_card.show()
	reveal_button.hide()
	grading_hbox.show()

func _on_grade_button_pressed(grade: String) -> void:
	if AudioManager:
		AudioManager.play_sfx("click")
		
	var kp_earned: int = 0
	match grade:
		"hard": kp_earned = 1
		"good": kp_earned = 3
		"easy": kp_earned = 5
			
	if GameState:
		GameState.add_knowledge_points(kp_earned, "flashcard_" + grade)
		if NotificationManager:
			NotificationManager.show_toast("Reviewed! +%d KP" % kp_earned, NotificationManager.ToastType.SUCCESS)
	
	var cur_card = cards_to_review[current_card_index] if current_card_index < cards_to_review.size() else {}
	EventBus.flashcard_reviewed.emit(cur_card.get("id", ""), grade)
	
	current_card_index += 1
	_show_current_card()

func _finish_session() -> void:
	if subject_badge:
		subject_badge.text = "• COMPLETE"
	question_label.text = "🎉 Study Drill Complete!"
	answer_label.text = "Awesome recall work! All cards reviewed."
	answer_card.show()
	reveal_button.hide()
	grading_hbox.hide()
	progress_label.text = "Done"

func _on_close_button_pressed() -> void:
	if AudioManager:
		AudioManager.play_sfx("click")
	closed.emit()
	queue_free()
