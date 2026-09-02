extends Node

## NotificationManager for Kronos.
## Pure native engine notification system: In-App Pixel Toasts & OS Taskbar Flashes.
## 100% Free of external PowerShell processes.

signal toast_requested(msg: String, toast_type: int)

enum ToastType { INFO, SUCCESS, WARNING, ERROR }

var _idle_time_seconds: float = 0.0
var _idle_nudge_count: int = 0
var _last_hunger_notif_time: float = 0.0
var _last_notif_time: float = -9999.0

const IDLE_NUDGE_1_TIME: float = 900.0   # 15 minutes idle
const HUNGER_NOTIF_COOLDOWN: float = 3600.0 # 1 hour between hunger alerts

func _ready() -> void:
	_last_hunger_notif_time = Time.get_unix_time_from_system()
	EventBus.session_completed.connect(_on_session_completed)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.timer_started.connect(func(): _reset_idle_tracker())

func _process(delta: float) -> void:
	if not TimerEngine:
		return
		
	if TimerEngine.status == TimerEngine.TimerStatus.STOPPED or TimerEngine.status == TimerEngine.TimerStatus.PAUSED:
		_idle_time_seconds += delta
		_check_idle_nudges()
	else:
		_idle_time_seconds = 0.0

## Shows an in-app retro toast notification in Kronos
func show_toast(msg: String, type: Variant = ToastType.INFO) -> void:
	var t_type: int = int(type)
	toast_requested.emit(msg, t_type)
	
	# If the main window doesn't have focus (e.g. minimized or in background),
	# pop up the native Desktop Toast so the user actually sees it!
	if not DisplayServer.window_is_focused(0):
		var title = "Kronos"
		if t_type == ToastType.SUCCESS: title = "Kronos - Success"
		elif t_type == ToastType.WARNING: title = "Kronos - Alert"
		
		# We bypass send_notification's internal cooldown here because
		# show_toast is explicit. We just instantiate the DesktopToast.
		var toast_scene = load("res://scenes/main/DesktopToast.tscn")
		if toast_scene:
			var toast = toast_scene.instantiate()
			get_tree().root.add_child(toast)
			var color = Color(0.35, 0.85, 0.55, 1.0) # Default Emerald
			if t_type == ToastType.WARNING or t_type == ToastType.ERROR:
				color = Color(0.96, 0.62, 0.04, 1.0)
			toast.setup_and_show(title, msg, color)

## Native OS notification & taskbar alert (Multi-Window Desktop Toast)
func send_notification(title: String, body: String) -> void:
	var now: float = Time.get_unix_time_from_system()
	if (now - _last_notif_time) < 2.0:
		return
	_last_notif_time = now

	# Native OS Taskbar attention flash (zero external processes)
	DisplayServer.window_request_attention(0)
	
	if not _are_timer_notifs_enabled() and not _are_pet_nudges_enabled():
		return
		
	# Spawn Native Godot Window Notification over OS
	var toast_scene = load("res://scenes/main/DesktopToast.tscn")
	if toast_scene:
		var toast = toast_scene.instantiate()
		get_tree().root.add_child(toast)
		var color = Color(0.35, 0.85, 0.55, 1.0) # Default Emerald
		if "Warning" in title or "hungry" in body: color = Color(0.96, 0.62, 0.04, 1.0)
		toast.setup_and_show(title, body, color)

func _on_session_completed(session_type: String, coins_earned: int, _xp_earned: int, _streak: int) -> void:
	_reset_idle_tracker()
	
	# Always flash taskbar when a session finishes
	DisplayServer.window_request_attention(0)
	
	if not _are_timer_notifs_enabled():
		return
		
	if session_type == "work":
		show_toast("✨ Focus Complete! (+%d Coins)" % coins_earned, ToastType.SUCCESS)
	else:
		show_toast("🔔 Break Finished! Ready for next sprint?", ToastType.INFO)

func _check_idle_nudges() -> void:
	if not _are_pet_nudges_enabled():
		return
		
	if _idle_nudge_count == 0 and _idle_time_seconds >= IDLE_NUDGE_1_TIME:
		_idle_nudge_count = 1
		show_toast("🐾 Shiba is waiting for the next sprint! ✨", ToastType.INFO)

func _on_energy_changed(new_energy: float, _max_energy: float, _is_buffed: bool) -> void:
	if not _are_pet_nudges_enabled():
		return
		
	var now_unix: float = Time.get_unix_time_from_system()
	if new_energy <= 15.0 and (now_unix - _last_hunger_notif_time) >= HUNGER_NOTIF_COOLDOWN:
		_last_hunger_notif_time = now_unix
		show_toast("🥐 Shiba is hungry! Feed a treat from your Bag 🥞", ToastType.WARNING)

func _reset_idle_tracker() -> void:
	_idle_time_seconds = 0.0
	_idle_nudge_count = 0

func _are_timer_notifs_enabled() -> bool:
	if not GameState or not ("audio_settings" in GameState) or not GameState.audio_settings:
		return true
	return GameState.audio_settings.get("timer_notifications_enabled", true)

func _are_pet_nudges_enabled() -> bool:
	if not GameState or not ("audio_settings" in GameState) or not GameState.audio_settings:
		return true
	return GameState.audio_settings.get("pet_nudges_enabled", true)
