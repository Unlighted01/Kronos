extends Node
## Database & Persistence Manager Singleton for Kronos.
## Handles robust JSON serialization for pet state (`user://kronos_save.json`)
## and DTR Daily Time Records (`user://kronos_dtr.json`).

# ==============================================================================
# 📁 FILE PATHS & CONSTANTS
# ==============================================================================
const SAVE_PATH: String = "user://kronos_save.json"
const DTR_PATH: String = "user://kronos_dtr.json"
const BACKUP_SAVE_PATH: String = "user://kronos_save.bak"
const CSV_EXPORT_PATH: String = "user://kronos_dtr_export.csv"

const AUTO_SAVE_INTERVAL: float = 60.0 # Auto-save every 60s

# ==============================================================================
# 📊 INTERNAL STATE
# ==============================================================================
var _dtr_cache: Array[Dictionary] = []
var _auto_save_timer: float = 0.0

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	# Load existing data on startup
	load_game()
	load_dtr()

func _process(delta: float) -> void:
	_auto_save_timer += delta
	if _auto_save_timer >= AUTO_SAVE_INTERVAL:
		_auto_save_timer = 0.0
		save_game()

func _notification(what: int) -> void:
	# Auto-save when window is closed or application quits
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		save_game()
		save_dtr()

# ==============================================================================
# 💾 GAME STATE SAVE & LOAD
# ==============================================================================
## Saves pet stats, inventory, and settings to disk with safe backup rotation
func save_game() -> bool:
	if not GameState:
		return false
		
	var data: Dictionary = GameState.serialize()
	var json_string: String = JSON.stringify(data, "\t")
	
	# Rotate backup if save exists
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.copy_absolute(
			ProjectSettings.globalize_path(SAVE_PATH),
			ProjectSettings.globalize_path(BACKUP_SAVE_PATH)
		)
		
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		var err: Error = FileAccess.get_open_error()
		push_error("[DatabaseManager] Failed to open save file for writing: %s" % error_string(err))
		EventBus.save_completed.emit(false, "")
		return false
		
	file.store_string(json_string)
	file.close()
	
	var timestamp: String = Time.get_datetime_string_from_system()
	EventBus.save_completed.emit(true, timestamp)
	return true

## Loads game state from disk or falls back to backup / default values
func load_game() -> bool:
	if not GameState:
		return false
		
	if not FileAccess.file_exists(SAVE_PATH):
		# No save file yet, start with fresh default state
		EventBus.load_completed.emit(true)
		return true
		
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		# Attempt loading from backup
		return _try_load_backup()
		
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var parse_err: Error = json.parse(json_string)
	if parse_err != OK:
		push_error("[DatabaseManager] Save file corrupted! Error: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		return _try_load_backup()
		
	var data = json.get_data()
	if data is Dictionary:
		GameState.deserialize(data)
		EventBus.load_completed.emit(true)
		return true
		
	return _try_load_backup()

## Wipes save file and backup from disk and resets GameState to a clean Lv. 1 test profile
func wipe_save_and_reset() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if FileAccess.file_exists(BACKUP_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(BACKUP_SAVE_PATH))
	if GameState:
		GameState.reset_to_clean_slate()

func _try_load_backup() -> bool:
	if not FileAccess.file_exists(BACKUP_SAVE_PATH):
		EventBus.load_completed.emit(false)
		return false
		
	var file: FileAccess = FileAccess.open(BACKUP_SAVE_PATH, FileAccess.READ)
	if not file:
		EventBus.load_completed.emit(false)
		return false
		
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	if json.parse(json_string) == OK and json.get_data() is Dictionary:
		GameState.deserialize(json.get_data())
		EventBus.load_completed.emit(true)
		return true
		
	EventBus.load_completed.emit(false)
	return false

# ==============================================================================
# 📝 DTR (DAILY TIME RECORD) PERSISTENCE
# ==============================================================================
## Appends a new focus session record into DTR
func log_session(session_record: Dictionary) -> void:
	_dtr_cache.append(session_record)
	save_dtr()
	if EventBus:
		EventBus.dtr_updated.emit()

func update_session(created_unix: int, updated_record: Dictionary) -> bool:
	for i in range(_dtr_cache.size()):
		if int(_dtr_cache[i].get("created_unix", 0)) == created_unix:
			_dtr_cache[i] = updated_record
			save_dtr()
			if EventBus:
				EventBus.dtr_updated.emit()
			return true
	return false

func delete_session(created_unix: int) -> bool:
	for i in range(_dtr_cache.size()):
		if int(_dtr_cache[i].get("created_unix", 0)) == created_unix:
			_dtr_cache.remove_at(i)
			save_dtr()
			if EventBus:
				EventBus.dtr_updated.emit()
			return true
	return false

## Saves all cached DTR records to disk
func save_dtr() -> bool:
	var json_string: String = JSON.stringify(_dtr_cache, "\t")
	var file: FileAccess = FileAccess.open(DTR_PATH, FileAccess.WRITE)
	if not file:
		push_error("[DatabaseManager] Failed to write DTR log: %s" % error_string(FileAccess.get_open_error()))
		return false
		
	file.store_string(json_string)
	file.close()
	return true

## Loads all DTR records from disk into cache
func load_dtr() -> Array[Dictionary]:
	_dtr_cache.clear()
	if not FileAccess.file_exists(DTR_PATH):
		return _dtr_cache
		
	var file: FileAccess = FileAccess.open(DTR_PATH, FileAccess.READ)
	if not file:
		return _dtr_cache
		
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	if json.parse(json_string) == OK:
		var data = json.get_data()
		if data is Array:
			for item in data:
				if item is Dictionary:
					_dtr_cache.append(item)
					
	return _dtr_cache

## Returns total focus minutes completed today
func get_today_focus_minutes() -> int:
	var today_key: String = Time.get_date_string_from_system()
	var total_min: int = 0
	for record in _dtr_cache:
		if record.get("date_key", "") == today_key:
			total_min += record.get("duration_minutes", 0)
	return total_min

## Returns all DTR records
func get_all_records() -> Array[Dictionary]:
	return _dtr_cache

## Aggregates 60-day heatmap data mapping date_key -> {minutes: int, sprints: int}
func get_heatmap_data(days: int = 60) -> Dictionary:
	var result: Dictionary = {}
	var now_unix: int = int(Time.get_unix_time_from_system())
	
	# Pre-populate all days with 0
	for d in range(days - 1, -1, -1):
		var day_unix: int = now_unix - (d * 86400)
		var dt_dict: Dictionary = Time.get_date_dict_from_unix_time(day_unix)
		var date_key: String = "%04d-%02d-%02d" % [dt_dict.year, dt_dict.month, dt_dict.day]
		result[date_key] = {"minutes": 0, "sprints": 0}
		
	# Aggregate from records
	for r in _dtr_cache:
		var date_key: String = r.get("date_key", "")
		if result.has(date_key):
			result[date_key]["minutes"] += r.get("duration_minutes", 0)
			result[date_key]["sprints"] += 1
			
	return result

## Returns category percentage & minute distribution
func get_category_distribution(timeframe: String = "all") -> Dictionary:
	var today_str: String = Time.get_date_string_from_system()
	var now_unix: int = int(Time.get_unix_time_from_system())
	var week_ago_unix: int = now_unix - (7 * 86400)
	
	var cat_mins: Dictionary = {}
	var total_min: int = 0
	
	for r in _dtr_cache:
		var r_date: String = r.get("date_key", "")
		var r_unix: int = int(r.get("created_unix", 0))
		
		var include_record: bool = false
		match timeframe:
			"today":
				include_record = (r_date == today_str)
			"week":
				include_record = (r_unix >= week_ago_unix)
			_: # "all"
				include_record = true
				
		if include_record:
			var cat: String = r.get("category", "General")
			if cat.is_empty():
				cat = "General"
			var m: int = r.get("duration_minutes", 0)
			cat_mins[cat] = cat_mins.get(cat, 0) + m
			total_min += m
			
	return {
		"categories": cat_mins,
		"total_minutes": total_min
	}

## Returns lifetime DTR statistics summary
func get_lifetime_dtr_stats() -> Dictionary:
	var total_min: int = 0
	var total_coins: int = 0
	var total_exp: int = 0
	var total_sprints: int = _dtr_cache.size()
	var unique_days: Dictionary = {}
	
	for r in _dtr_cache:
		total_min += r.get("duration_minutes", 0)
		total_coins += r.get("coins_earned", 0)
		total_exp += r.get("exp_earned", 0)
		unique_days[r.get("date_key", "")] = true
		
	return {
		"total_minutes": total_min,
		"total_hours": float(total_min) / 60.0,
		"total_sprints": total_sprints,
		"total_coins": total_coins,
		"total_exp": total_exp,
		"active_days_count": unique_days.size()
	}

## Generates formatted daily standup markdown from completed sessions
func generate_standup_markdown(date_filter: String = "") -> String:
	var target_date: String = date_filter if not date_filter.is_empty() else Time.get_date_string_from_system()
	var day_records: Array[Dictionary] = []
	var total_min: int = 0
	
	for r in _dtr_cache:
		if r.get("date_key", "") == target_date:
			day_records.append(r)
			total_min += r.get("duration_minutes", 0)
			
	var hours: float = float(total_min) / 60.0
	var lines: PackedStringArray = PackedStringArray()
	lines.append("### 🎯 Daily Focus Standup — %s" % target_date)
	lines.append("**Total Focus:** %.1fh (%d minutes • %d sprints)\n" % [hours, total_min, day_records.size()])
	lines.append("**Accomplished Tasks:**")
	
	if day_records.is_empty():
		lines.append("- *(No recorded focus sessions yet for this date)*")
	else:
		for r in day_records:
			var cat: String = r.get("category", "General")
			var task: String = r.get("task_name", "Focus Session")
			var duration: int = r.get("duration_minutes", 25)
			var time_str: String = r.get("start_time", "")
			if not time_str.is_empty() and "T" in time_str:
				var t_parts = time_str.split("T")[1].split(":")
				if t_parts.size() >= 2:
					time_str = "[%s:%s] " % [t_parts[0], t_parts[1]]
			else:
				time_str = ""
				
			lines.append("- %s`[%s]` **%s** (%dm)" % [time_str, cat, task, duration])
			
	lines.append("\n*Generated automatically by Kronos Productivity Studio* ⏱️")
	return "\n".join(lines)

## Exports DTR history to standard CSV format.
## Attempts to write to Desktop, then Downloads, then user://
func export_dtr_to_csv(custom_folder: String = "") -> Dictionary:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("ID,Date,Task,Category,Duration (min),Status,Coins,EXP,Start Time,End Time")
	
	for i in range(_dtr_cache.size()):
		var r: Dictionary = _dtr_cache[i]
		var line: String = "%d,%s,\"%s\",\"%s\",%d,%s,%d,%d,%s,%s" % [
			i + 1,
			r.get("date_key", ""),
			r.get("task_name", "General Work").replace("\"", "\"\""),
			r.get("category", "General").replace("\"", "\"\""),
			r.get("duration_minutes", 0),
			r.get("status", "completed"),
			r.get("coins_earned", 0),
			r.get("exp_earned", 0),
			r.get("start_time", ""),
			r.get("end_time", "")
		]
		lines.append(line)
		
	var csv_text: String = "\n".join(lines)
	
	# Always save to internal user:// path as backup
	var user_file: FileAccess = FileAccess.open(CSV_EXPORT_PATH, FileAccess.WRITE)
	if user_file:
		user_file.store_string(csv_text)
		user_file.close()
		
	# Determine external export folder
	var export_dir: String = custom_folder
	if export_dir.is_empty():
		export_dir = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		if export_dir.is_empty() or not DirAccess.dir_exists_absolute(export_dir):
			export_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
			
	var today_str: String = Time.get_date_string_from_system().replace("-", "")
	var file_name: String = "kronos_dtr_export_%s.csv" % today_str
	var full_path: String = ""
	
	if not export_dir.is_empty() and DirAccess.dir_exists_absolute(export_dir):
		full_path = export_dir.path_join(file_name)
		var ext_file: FileAccess = FileAccess.open(full_path, FileAccess.WRITE)
		if ext_file:
			ext_file.store_string(csv_text)
			ext_file.close()
			return {"success": true, "path": full_path, "count": _dtr_cache.size(), "csv": csv_text}
			
	return {"success": true, "path": ProjectSettings.globalize_path(CSV_EXPORT_PATH), "count": _dtr_cache.size(), "csv": csv_text}

## Completely wipes the local save file and resets to a clean day-1 player state
func reset_all_data() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if FileAccess.file_exists(BACKUP_SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(BACKUP_SAVE_PATH))
	if FileAccess.file_exists(DTR_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(DTR_PATH))
	_dtr_cache.clear()
	if GameState and GameState.has_method("reset_to_defaults"):
		GameState.reset_to_defaults()
	if NotificationManager:
		NotificationManager.show_toast("🔄 Save wiped! Reset to fresh Day-1 state.", NotificationManager.ToastType.INFO)

