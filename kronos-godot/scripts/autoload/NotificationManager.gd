extends Node

## NotificationManager for Kronos.
## Handles Windows Desktop Toast Notifications, Taskbar Attention Alerts,
## Timer Completion Announcements, and Gentle Pet Focus/Hunger Nudges.

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _idle_time_seconds: float = 0.0
var _idle_nudge_count: int = 0
var _last_hunger_notif_time: float = 0.0

const IDLE_NUDGE_1_TIME: float = 900.0  # 15 minutes idle
const HUNGER_NOTIF_COOLDOWN: float = 3600.0 # 1 hour between hunger alerts

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	_last_hunger_notif_time = Time.get_unix_time_from_system()
	EventBus.session_completed.connect(_on_session_completed)
	EventBus.energy_changed.connect(_on_energy_changed)
	EventBus.timer_started.connect(func(): _reset_idle_tracker())

func _process(delta: float) -> void:
	if not TimerEngine:
		return
		
	# Only accumulate idle time if timer is STOPPED or PAUSED
	if TimerEngine.status == TimerEngine.TimerStatus.STOPPED or TimerEngine.status == TimerEngine.TimerStatus.PAUSED:
		_idle_time_seconds += delta
		_check_idle_nudges()
	else:
		_idle_time_seconds = 0.0

var _last_notif_time: float = -9999.0

# ==============================================================================
# 🔔 NOTIFICATION SENDING
# ==============================================================================
## Sends a native Windows toast notification and requests taskbar attention
func send_notification(title: String, body: String) -> void:
	var now: float = Time.get_unix_time_from_system()
	if (now - _last_notif_time) < 4.0:
		return
	_last_notif_time = now

	# Flash taskbar icon
	DisplayServer.window_request_attention()
	
	if not _are_timer_notifs_enabled() and not _are_pet_nudges_enabled():
		return
		
	var clean_title = title.replace("'", " ").replace('"', " ")
	var clean_body = body.replace("'", " ").replace('"', " ")
	
	var ps_script: String = (
		"Add-Type -AssemblyName System.Windows.Forms; " +
		"$n = New-Object System.Windows.Forms.NotifyIcon; " +
		"$n.Icon = [System.Drawing.SystemIcons]::Information; " +
		"$n.BalloonTipTitle = '" + clean_title + "'; " +
		"$n.BalloonTipText = '" + clean_body + "'; " +
		"$n.Visible = $true; " +
		"$n.ShowBalloonTip(4000); " +
		"try { " +
		"[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null; " +
		"[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null; " +
		"$template = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent([Windows.UI.Notifications.ToastTemplateType]::ToastText02); " +
		"$textNodes = $template.GetElementsByTagName('text'); " +
		"$textNodes.Item(0).AppendChild($template.CreateTextNode('" + clean_title + "')) | Out-Null; " +
		"$textNodes.Item(1).AppendChild($template.CreateTextNode('" + clean_body + "')) | Out-Null; " +
		"$toast = [Windows.UI.Notifications.ToastNotification]::new($template); " +
		"[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe').Show($toast); " +
		"} catch {} " +
		"Start-Sleep -Milliseconds 3500; " +
		"$n.Visible = $false; " +
		"$n.Dispose()"
	)
	
	# Encode to UTF-16LE Base64 for PowerShell -EncodedCommand (bulletproof against escaping bugs)
	var utf16_bytes: PackedByteArray = ps_script.to_utf16_buffer()
	var b64: String = Marshalls.raw_to_base64(utf16_bytes)
	
	OS.create_process("powershell.exe", ["-NoProfile", "-WindowStyle", "Hidden", "-EncodedCommand", b64])

# ==============================================================================
# ⏰ TIMER COMPLETION HANDLER
# ==============================================================================
func _on_session_completed(session_type: String, coins_earned: int, _xp_earned: int, _streak: int) -> void:
	_reset_idle_tracker()
	
	if not _are_timer_notifs_enabled():
		return
		
	if session_type == "work":
		var title: String = "✨ Focus Complete! (+%d Coins)" % coins_earned
		var body: String = "Great work! Time for a refreshing break ☕"
		send_notification(title, body)
	else:
		var title: String = "🔔 Break Finished!"
		var body: String = "Ready to start the next focus sprint? Tap Start when ready! 🐾"
		send_notification(title, body)

# ==============================================================================
# 🐾 GENTLE PET NUDGES
# ==============================================================================
func _check_idle_nudges() -> void:
	if not _are_pet_nudges_enabled():
		return
		
	# Only send ONE single friendly reminder after 15m of being idle, then stop completely
	if _idle_nudge_count == 0 and _idle_time_seconds >= IDLE_NUDGE_1_TIME:
		_idle_nudge_count = 1
		var title: String = "🐾 Shiba is ready to work!"
		var body: String = "Ready for our next focus sprint? Tap Start when you're ready! ✨"
		send_notification(title, body)

func _on_energy_changed(new_energy: float, _max_energy: float, _is_buffed: bool) -> void:
	if not _are_pet_nudges_enabled():
		return
		
	var now_unix: float = Time.get_unix_time_from_system()
	if new_energy <= 15.0 and (now_unix - _last_hunger_notif_time) >= HUNGER_NOTIF_COOLDOWN:
		_last_hunger_notif_time = now_unix
		var title: String = "🥐 Shiba's tummy is rumbling!"
		var body: String = "Energy is low! Feed a treat from your Bag to restore the +20% Coin Buff 🥞"
		send_notification(title, body)

func _reset_idle_tracker() -> void:
	_idle_time_seconds = 0.0
	_idle_nudge_count = 0

# ==============================================================================
# ⚙️ SETTINGS CHECKERS
# ==============================================================================
func _are_timer_notifs_enabled() -> bool:
	if not GameState or not GameState.audio_settings:
		return true
	return GameState.audio_settings.get("timer_notifs_enabled", true)

func _are_pet_nudges_enabled() -> bool:
	if not GameState or not GameState.audio_settings:
		return true
	return GameState.audio_settings.get("pet_nudges_enabled", true)
