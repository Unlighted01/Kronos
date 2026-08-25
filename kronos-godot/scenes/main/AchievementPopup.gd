extends Control
class_name AchievementPopup

## 🏆 Floating Retro Achievement Unlock Banner for Kronos.
## Slides in from top with golden sparkle particles, crystal fanfare, and reward details.

@onready var panel: PanelContainer = $CenterContainer/Panel
@onready var icon_label: Label = $CenterContainer/Panel/Margin/HBox/IconLabel
@onready var title_label: Label = $CenterContainer/Panel/Margin/HBox/VBox/TitleLabel
@onready var desc_label: Label = $CenterContainer/Panel/Margin/HBox/VBox/DescLabel
@onready var reward_label: Label = $CenterContainer/Panel/Margin/HBox/VBox/RewardLabel

var _sparkles: Array[Dictionary] = []
var _is_dismissing: bool = false

func _ready() -> void:
	z_index = 130
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	custom_minimum_size = Vector2(0, 50)
	position.y = -60.0
	
	for i in range(8):
		_spawn_sparkle()

func _process(delta: float) -> void:
	_update_sparkles(delta)
	queue_redraw()

func display_achievement(ach_def: Dictionary) -> void:
	var title: String = ach_def.get("title", "Achievement Unlocked!")
	var icon: String = ach_def.get("icon", "🏆")
	var desc: String = ach_def.get("description", "")
	var coins: int = int(ach_def.get("reward_coins", 0))
	var xp: int = int(ach_def.get("reward_xp", 0))
	var item: String = ach_def.get("reward_item", "")
	
	if icon_label: icon_label.text = icon
	if title_label: title_label.text = "🏆 UNLOCKED: " + title
	if desc_label: desc_label.text = desc
	
	var r_text: String = ""
	if coins > 0: r_text += "+%d 🪙 " % coins
	if xp > 0: r_text += "+%d XP " % xp
	if item != "": r_text += "🎁 %s" % item
	if reward_label: reward_label.text = r_text
	
	if AudioManager:
		AudioManager.play_sfx("levelup")
		
	# Animate slide down from top
	var tween: Tween = create_tween()
	tween.tween_property(self, "position:y", 12.0, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(2.8)
	tween.tween_property(self, "position:y", -70.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func _spawn_sparkle() -> void:
	_sparkles.append({
		"x": randf_range(40, 200),
		"y": randf_range(10, 40),
		"vx": randf_range(-4, 4),
		"vy": randf_range(-8, -2),
		"life": randf_range(0.6, 1.4),
		"max_life": 1.4,
		"color": Color(0.96, 0.78, 0.25) if randf() > 0.3 else Color(0.22, 0.74, 0.97)
	})

func _update_sparkles(delta: float) -> void:
	for i in range(_sparkles.size() - 1, -1, -1):
		var s = _sparkles[i]
		s["life"] -= delta
		s["x"] += s["vx"] * delta
		s["y"] += s["vy"] * delta
		if s["life"] <= 0:
			_sparkles.remove_at(i)
			if _sparkles.size() < 8:
				_spawn_sparkle()

func _draw() -> void:
	for s in _sparkles:
		var alpha: float = clampf(s["life"] / s["max_life"], 0.0, 1.0)
		var c: Color = s["color"]
		c.a = alpha
		draw_rect(Rect2(s["x"], s["y"], 2, 2), c)
