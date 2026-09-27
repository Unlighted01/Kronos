extends Node2D

var room_camera: Camera2D = null
var current_zoom: float = 0.85
const MIN_ZOOM: float = 0.50
const MAX_ZOOM: float = 1.60

var _is_dragging: bool = false
var _drag_start_x: float = 0.0
var _cam_start_x: float = 0.0

func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(720, 360))
	DisplayServer.window_set_title("Hearth of Hestia - Interactive Live Preview (Mouse Wheel Zoom & Drag)")
	get_viewport().size = Vector2i(720, 360)

	var bg = ColorRect.new()
	bg.color = Color(0.04, 0.05, 0.08)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(720, 360)
	add_child(bg)

	var room = load("res://scenes/rooms/LivingRoom.tscn").instantiate()
	add_child(room)

	# Kitsune Fox by the shield and scroll niche
	var fox = PetRenderer.new()
	fox.species = "fox"
	fox.current_state = PetRenderer.AnimState.IDLE
	fox.position = Vector2(85.0, 102.0)
	fox.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(fox)

	# Shiba companion pet resting nestled in the plush couch cushion
	var shiba = PetRenderer.new()
	shiba.species = "shiba"
	shiba.current_state = PetRenderer.AnimState.NAP
	shiba.position = Vector2(242.0, 88.0)
	shiba.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(shiba)

	# Calico Cat companion by the Lyre of Apollo
	var cat = PetRenderer.new()
	cat.species = "cat"
	cat.current_state = PetRenderer.AnimState.IDLE
	cat.position = Vector2(480.0, 102.0)
	cat.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(cat)

	# Capybara companion enjoying the eternal fire brazier
	var capy = PetRenderer.new()
	capy.species = "capybara"
	capy.current_state = PetRenderer.AnimState.IDLE
	capy.position = Vector2(615.0, 102.0)
	capy.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(capy)

	# Camera with zoom and drag support
	room_camera = Camera2D.new()
	room_camera.position = Vector2(360.0, 80.0)
	room_camera.zoom = Vector2(current_zoom, current_zoom)
	add_child(room_camera)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_adjust_zoom(0.08)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_adjust_zoom(-0.08)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT or (event.button_index == MOUSE_BUTTON_LEFT and Input.is_key_pressed(KEY_SPACE)):
			if event.pressed:
				_is_dragging = true
				_drag_start_x = event.global_position.x
				_cam_start_x = room_camera.position.x
			else:
				_is_dragging = false
	elif event is InputEventMouseMotion and _is_dragging:
		var dx = event.global_position.x - _drag_start_x
		room_camera.position.x = clampf(_cam_start_x - dx, 150.0, 570.0)

func _adjust_zoom(delta: float) -> void:
	current_zoom = clampf(current_zoom + delta, MIN_ZOOM, MAX_ZOOM)
	if room_camera:
		var tw = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_property(room_camera, "zoom", Vector2(current_zoom, current_zoom), 0.12)
