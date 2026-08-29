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

func update_session(created_unix: int, updated_fields: Dictionary) -> bool:
	for i in range(_dtr_cache.size()):
		if int(_dtr_cache[i].get("created_unix", 0)) == created_unix:
			var record: Dictionary = _dtr_cache[i]
			# Strictly update only reflection metadata (task title, category, notes)
			if updated_fields.has("task_name"):
				record["task_name"] = updated_fields["task_name"]
			if updated_fields.has("category"):
				record["category"] = updated_fields["category"]
			if updated_fields.has("notes"):
				record["notes"] = updated_fields["notes"]
				
			_dtr_cache[i] = record
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
			var notes: String = r.get("notes", "").strip_edges()
			var time_str: String = r.get("start_time", "")
			if not time_str.is_empty() and "T" in time_str:
				var t_parts = time_str.split("T")[1].split(":")
				if t_parts.size() >= 2:
					time_str = "[%s:%s] " % [t_parts[0], t_parts[1]]
			else:
				time_str = ""
				
			lines.append("- %s`[%s]` **%s** (%dm)" % [time_str, cat, task, duration])
			if not notes.is_empty():
				for n_line in notes.split("\n"):
					var trimmed: String = n_line.strip_edges()
					if not trimmed.is_empty():
						if trimmed.begins_with("-") or trimmed.begins_with("*"):
							lines.append("    %s" % trimmed)
						else:
							lines.append("    - %s" % trimmed)
			
	lines.append("\n*Generated automatically by Kronos Productivity Studio* ⏱️")
	return "\n".join(lines)

## Computes 24-hour focus distribution histogram (00:00 to 23:00)
## Returns { "hours": Array[int](size 24), "peak_hour": int, "peak_minutes": int, "peak_label": String, "total_minutes": int }
func get_hourly_focus_distribution(days: int = 30) -> Dictionary:
	var hourly_mins: Array[int] = []
	hourly_mins.resize(24)
	hourly_mins.fill(0)
	
	var now_unix: int = int(Time.get_unix_time_from_system())
	var cutoff_unix: int = now_unix - (days * 86400)
	var total_period_min: int = 0
	
	for r in _dtr_cache:
		var created_unix: int = int(r.get("created_unix", 0))
		if created_unix < cutoff_unix:
			continue
			
		var dur: int = r.get("duration_minutes", 25)
		total_period_min += dur
		
		var start_time: String = r.get("start_time", "")
		var hour: int = 12 # fallback noon
		if not start_time.is_empty() and "T" in start_time:
			var t_parts = start_time.split("T")[1].split(":")
			if t_parts.size() >= 1:
				hour = clampi(int(t_parts[0]), 0, 23)
		else:
			var dt = Time.get_datetime_dict_from_unix_time(created_unix)
			hour = clampi(dt.get("hour", 12), 0, 23)
			
		hourly_mins[hour] += dur
		
	# Find peak hour
	var peak_hour: int = 0
	var peak_minutes: int = 0
	for h in range(24):
		if hourly_mins[h] > peak_minutes:
			peak_minutes = hourly_mins[h]
			peak_hour = h
			
	var peak_label: String = "Balanced Flow"
	if peak_hour >= 5 and peak_hour < 12:
		peak_label = "Morning Deep Work (%02d:00 - %02d:00)" % [peak_hour, (peak_hour + 1) % 24]
	elif peak_hour >= 12 and peak_hour < 18:
		peak_label = "Afternoon Prime (%02d:00 - %02d:00)" % [peak_hour, (peak_hour + 1) % 24]
	elif peak_hour >= 18 and peak_hour < 23:
		peak_label = "Evening Sprint (%02d:00 - %02d:00)" % [peak_hour, (peak_hour + 1) % 24]
	else:
		peak_label = "Night Owl Flow (%02d:00 - %02d:00)" % [peak_hour, (peak_hour + 1) % 24]
		
	return {
		"hours": hourly_mins,
		"peak_hour": peak_hour,
		"peak_minutes": peak_minutes,
		"peak_label": peak_label,
		"total_minutes": total_period_min
	}

## Calculates weekly velocity comparison and productive day of week
func get_weekly_velocity_stats() -> Dictionary:
	var now_unix: int = int(Time.get_unix_time_from_system())
	var this_week_start: int = now_unix - (7 * 86400)
	var last_week_start: int = now_unix - (14 * 86400)
	
	var this_week_mins: int = 0
	var last_week_mins: int = 0
	var weekday_mins: Dictionary = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0} # Sunday(0) to Saturday(6) or Godot weekday
	var active_days: Dictionary = {}
	
	for r in _dtr_cache:
		var unix: int = int(r.get("created_unix", 0))
		var dur: int = r.get("duration_minutes", 0)
		var date_k: String = r.get("date_key", "")
		
		if unix >= this_week_start:
			this_week_mins += dur
			active_days[date_k] = true
			
			var dt = Time.get_date_dict_from_unix_time(unix)
			var wday = dt.get("weekday", 0)
			weekday_mins[wday] = weekday_mins.get(wday, 0) + dur
		elif unix >= last_week_start and unix < this_week_start:
			last_week_mins += dur
			
	var diff_mins: int = this_week_mins - last_week_mins
	var pct_change: float = 0.0
	if last_week_mins > 0:
		pct_change = (float(diff_mins) / float(last_week_mins)) * 100.0
	elif this_week_mins > 0:
		pct_change = 100.0
		
	# Find most productive day of week
	var best_wday: int = 1
	var best_wday_mins: int = 0
	for w in weekday_mins.keys():
		if weekday_mins[w] > best_wday_mins:
			best_wday_mins = weekday_mins[w]
			best_wday = w
			
	var day_names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
	var best_day_name = day_names[best_wday % day_names.size()]
	
	var active_count: int = maxi(1, active_days.size())
	var daily_avg: float = (float(this_week_mins) / 60.0) / float(active_count)
	
	return {
		"this_week_minutes": this_week_mins,
		"this_week_hours": float(this_week_mins) / 60.0,
		"last_week_minutes": last_week_mins,
		"last_week_hours": float(last_week_mins) / 60.0,
		"diff_minutes": diff_mins,
		"pct_change": pct_change,
		"best_day_name": best_day_name,
		"best_day_minutes": best_wday_mins,
		"daily_avg_hours": daily_avg
	}

## Generates formatted Weekly Retrospective Report markdown
func generate_weekly_retrospective_markdown() -> String:
	var velocity: Dictionary = get_weekly_velocity_stats()
	var cat_dist: Dictionary = get_category_distribution("week")
	var cat_mins: Dictionary = cat_dist.get("categories", {})
	
	var now_unix: int = int(Time.get_unix_time_from_system())
	var week_ago_unix: int = now_unix - (7 * 86400)
	var recent_records: Array[Dictionary] = []
	for r in _dtr_cache:
		if int(r.get("created_unix", 0)) >= week_ago_unix:
			recent_records.append(r)
			
	var lines: PackedStringArray = PackedStringArray()
	lines.append("## 📈 Weekly Productivity Retrospective")
	lines.append("**Period:** Past 7 Days • Generated on %s\n" % Time.get_date_string_from_system())
	
	lines.append("### ⚡ Executive Summary")
	lines.append("- **Total Focus Time:** %.1fh (%d minutes • %d sprints)" % [velocity.get("this_week_hours", 0.0), velocity.get("this_week_minutes", 0), recent_records.size()])
	var change_str = "+%.1f%%" % velocity.get("pct_change", 0.0) if velocity.get("pct_change", 0.0) >= 0 else "%.1f%%" % velocity.get("pct_change", 0.0)
	lines.append("- **Velocity vs Last Week:** %s (Last week: %.1fh)" % [change_str, velocity.get("last_week_hours", 0.0)])
	lines.append("- **Daily Average:** %.1fh / active day" % velocity.get("daily_avg_hours", 0.0))
	lines.append("- **Peak Day:** %s (%dm)\n" % [velocity.get("best_day_name", "N/A"), velocity.get("best_day_minutes", 0)])
	
	lines.append("### 📊 Category Distribution")
	if cat_mins.is_empty():
		lines.append("- *(No category records this week)*")
	else:
		var total_m: int = cat_dist.get("total_minutes", 1)
		for cat in cat_mins.keys():
			var m = cat_mins[cat]
			var pct = int((float(m) / float(total_m)) * 100.0)
			lines.append("- **%s**: %.1fh (%dm • %d%%)" % [cat, float(m) / 60.0, m, pct])
			
	lines.append("\n### 🎯 Completed Key Tasks")
	if recent_records.is_empty():
		lines.append("- *(No completed sessions recorded this week)*")
	else:
		for r in recent_records:
			var cat = r.get("category", "General")
			var task = r.get("task_name", "Focus Session")
			var dur = r.get("duration_minutes", 25)
			var date_k = r.get("date_key", "")
			var notes = r.get("notes", "").strip_edges()
			if not notes.is_empty():
				var first_line = notes.split("\n")[0].strip_edges()
				lines.append("- `[%s]` **%s** — %s (%dm): *\"%s\"*" % [date_k, task, cat, dur, first_line])
			else:
				lines.append("- `[%s]` **%s** — %s (%dm)" % [date_k, task, cat, dur])
			
	lines.append("\n*Generated by Kronos Productivity Studio* ⏱️⚡")
	return "\n".join(lines)

## Exports full DTR JSON string for backup
func export_dtr_json() -> String:
	return JSON.stringify(_dtr_cache, "\t")

## Imports and restores/merges DTR records from JSON
func import_dtr_json(json_string: String) -> Dictionary:
	var json: JSON = JSON.new()
	var err = json.parse(json_string)
	if err != OK:
		return {"success": false, "error": "Invalid JSON format."}
		
	var data = json.get_data()
	if not data is Array:
		return {"success": false, "error": "JSON data must be an array of session records."}
		
	var imported_count: int = 0
	var existing_timestamps: Dictionary = {}
	for r in _dtr_cache:
		existing_timestamps[int(r.get("created_unix", 0))] = true
		
	for item in data:
		if item is Dictionary:
			var unix: int = int(item.get("created_unix", 0))
			if not existing_timestamps.has(unix):
				_dtr_cache.append(item)
				existing_timestamps[unix] = true
				imported_count += 1
				
	if imported_count > 0:
		save_dtr()
		if EventBus:
			EventBus.dtr_updated.emit()
			
	return {"success": true, "imported_count": imported_count, "total_count": _dtr_cache.size()}

## Exports DTR history to standard CSV format.
## Attempts to write to Desktop, then Downloads, then user://
func export_dtr_to_csv(custom_folder: String = "") -> Dictionary:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("ID,Date,Task,Category,Duration (min),Notes,Status,Coins,EXP,Start Time,End Time")
	
	for i in range(_dtr_cache.size()):
		var r: Dictionary = _dtr_cache[i]
		var line: String = "%d,%s,\"%s\",\"%s\",%d,\"%s\",%s,%d,%d,%s,%s" % [
			i + 1,
			r.get("date_key", ""),
			r.get("task_name", "General Work").replace("\"", "\"\""),
			r.get("category", "General").replace("\"", "\"\""),
			r.get("duration_minutes", 0),
			r.get("notes", "").replace("\"", "\"\""),
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

