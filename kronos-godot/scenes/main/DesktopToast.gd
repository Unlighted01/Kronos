extends Window

@onready var card: PanelContainer = $Card
@onready var title_lbl: Label = $Card/VBox/Title
@onready var body_lbl: Label = $Card/VBox/Body

func _ready() -> void:
	# Make Godot Window node transparent borderless correctly
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.14, 0.95)
	style.set_border_width_all(2)
	style.border_color = Color(0.35, 0.85, 0.55, 1.0)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	card.add_theme_stylebox_override("panel", style)

func setup_and_show(title: String, body: String, color: Color) -> void:
	# Assign Text
	if title_lbl: title_lbl.text = title
	if body_lbl: body_lbl.text = body
	
	# Apply Border Color
	var s: StyleBoxFlat = card.get_theme_stylebox("panel") as StyleBoxFlat
	if s: s.border_color = color
	
	# Position at bottom right of the primary screen
	var screen_rect = DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	var target_x = screen_rect.position.x + screen_rect.size.x - size.x - 20
	var target_y = screen_rect.position.y + screen_rect.size.y - size.y - 20
	position = Vector2i(target_x, target_y)
	
	# Fade in Tween
	card.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(card, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(4.0)
	tween.tween_property(card, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): queue_free())
