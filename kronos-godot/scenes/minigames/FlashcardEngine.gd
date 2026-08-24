extends Control

@onready var question_label: Label = $Panel/VBox/CardArea/VBox/QuestionLabel
@onready var answer_label: Label = $Panel/VBox/CardArea/VBox/AnswerLabel
@onready var reveal_button: Button = $Panel/VBox/RevealButton
@onready var grading_hbox: HBoxContainer = $Panel/VBox/GradingHBox
@onready var hard_button: Button = $Panel/VBox/GradingHBox/HardButton
@onready var good_button: Button = $Panel/VBox/GradingHBox/GoodButton
@onready var easy_button: Button = $Panel/VBox/GradingHBox/EasyButton
@onready var close_button: Button = $Panel/VBox/Header/CloseButton
@onready var progress_label: Label = $Panel/VBox/Header/ProgressLabel

var deck: Array[Dictionary] = [
	{
		"q": "What does UI stand for?",
		"a": "User Interface"
	},
	{
		"q": "What is the main programming language used in Godot?",
		"a": "GDScript"
	},
	{
		"q": "What does API stand for?",
		"a": "Application Programming Interface"
	},
	{
		"q": "What is 'Active Recall'?",
		"a": "Retrieving information from memory without looking at the answer."
	}
]

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
		if not saved_deck.is_empty():
			cards_to_review = saved_deck.duplicate()
		else:
			cards_to_review = deck.duplicate()
	else:
		cards_to_review = deck.duplicate()
		
	cards_to_review.shuffle()
	current_card_index = 0
	_show_current_card()

func _show_current_card() -> void:
	if current_card_index >= cards_to_review.size():
		_finish_session()
		return
		
	var card = cards_to_review[current_card_index]
	question_label.text = card["q"]
	answer_label.text = card["a"]
	answer_label.hide()
	
	reveal_button.show()
	grading_hbox.hide()
	progress_label.text = str(current_card_index + 1) + " / " + str(cards_to_review.size())

func _on_reveal_button_pressed() -> void:
	answer_label.show()
	reveal_button.hide()
	grading_hbox.show()

func _on_grade_button_pressed(grade: String) -> void:
	var kp_earned: int = 0
	
	match grade:
		"hard":
			kp_earned = 1
		"good":
			kp_earned = 3
		"easy":
			kp_earned = 5
			
	if GameState:
		GameState.add_knowledge_points(kp_earned, "flashcard_" + grade)
		if NotificationManager:
			NotificationManager.show_toast("Card Reviewed! +" + str(kp_earned) + " KP", NotificationManager.ToastType.SUCCESS)
	
	current_card_index += 1
	_show_current_card()

func _finish_session() -> void:
	question_label.text = "Session Complete!"
	answer_label.text = "Great job! Take a break or study more."
	answer_label.show()
	reveal_button.hide()
	grading_hbox.hide()
	progress_label.text = "Done"

func _on_close_button_pressed() -> void:
	closed.emit()
	queue_free()
