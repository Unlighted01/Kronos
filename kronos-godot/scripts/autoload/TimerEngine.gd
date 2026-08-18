extends Node
## Central Pomodoro & Focus Engine Singleton for Kronos.
## Handles work/break state machine, continuous coin accrual, energy burn/recovery, and jackpot payouts.

# ==============================================================================
# ⏱️ ENUMS & CONSTANTS
# ==============================================================================
enum TimerPhase { WORK, SHORT_BREAK, LONG_BREAK }
enum TimerStatus { STOPPED, RUNNING, PAUSED }

const PHASE_WORK_KEY: String = "work"
const PHASE_SHORT_BREAK_KEY: String = "short_break"
const PHASE_LONG_BREAK_KEY: String = "long_break"

const DEFAULT_WORK_SECONDS: float = 25.0 * 60.0 # 1500.0s (25:00)
const DEFAULT_SHORT_BREAK_SECONDS: float = 5.0 * 60.0 # 300.0s (05:00)
const DEFAULT_LONG_BREAK_SECONDS: float = 15.0 * 60.0 # 900.0s (15:00)

const BASE_JACKPOT_COINS: int = 100
const BASE_JACKPOT_EXP: int = 50

# Continuous Earning Rates
const FOCUS_COIN_INTERVAL: float = 10.0 # Seconds per base coin
const ENERGY_BURN_RATE: float = 1.0 / 120.0 # 1 energy point per 120s of active focus
const BREAK_RECOVERY_RATE: float = 1.0 / 30.0 # 1 energy point per 30s of break

# ==============================================================================
# 📊 ENGINE STATE
# ==============================================================================
var current_phase: TimerPhase = TimerPhase.WORK
var status: TimerStatus = TimerStatus.STOPPED

var work_duration: float = DEFAULT_WORK_SECONDS
var short_break_duration: float = DEFAULT_SHORT_BREAK_SECONDS
var long_break_duration: float = DEFAULT_LONG_BREAK_SECONDS

var time_left: float = DEFAULT_WORK_SECONDS
var total_phase_duration: float = DEFAULT_WORK_SECONDS

var completed_work_sessions: int = 0
var focus_seconds_elapsed: float = 0.0 # Accumulator for continuous coin ticks in current session
var session_start_unix: int = 0

var active_task_name: String = "General Deep Work"
var active_category: String = "Development"

# Sub-second accumulators
var _coin_accumulator: float = 0.0

# ==============================================================================
# ⚙️ LIFECYCLE & PROCESS
# ==============================================================================
func _ready() -> void:
	total_phase_duration = work_duration
	time_left = work_duration

func _process(delta: float) -> void:
	if status != TimerStatus.RUNNING:
		return
		
	time_left -= delta
	
	if current_phase == TimerPhase.WORK:
		_process_work_tick(delta)
	else:
		_process_break_tick(delta)
		
	# Broadcast tick event
	EventBus.timer_tick.emit(maxf(0.0, time_left), total_phase_duration, get_phase_string())
	
	# Check for completion
	if time_left <= 0.0:
		time_left = 0.0
		_on_phase_finished_naturally()

# ==============================================================================
# 🔄 CORE TICK LOGIC
# ==============================================================================
func _process_work_tick(delta: float) -> void:
	focus_seconds_elapsed += delta
	
	# Energy Burn: 1 pt / 120s
	GameState.add_energy(-ENERGY_BURN_RATE * delta)
	
	# Real-time Continuous Focus Coin Earning:
	# +1 coin per 10s. If Energy >= 70 (buffed), earn at +50% speed (effective 1.5x multiplier)
	var is_buffed: bool = GameState.is_energy_buffed()
	var rate_multiplier: float = 1.5 if is_buffed else 1.0
	_coin_accumulator += delta * rate_multiplier
	
	if _coin_accumulator >= FOCUS_COIN_INTERVAL:
		var coins_to_add: int = int(_coin_accumulator / FOCUS_COIN_INTERVAL)
		_coin_accumulator = fmod(_coin_accumulator, FOCUS_COIN_INTERVAL)
		GameState.add_coins(coins_to_add, "focus_continuous")
		EventBus.focus_coin_earned.emit(coins_to_add, is_buffed)

func _process_break_tick(delta: float) -> void:
	# Break Energy Recovery: 1 pt / 30s
	if GameState.energy < GameState.MAX_ENERGY:
		GameState.add_energy(BREAK_RECOVERY_RATE * delta)
		
	# Break Joy slight regeneration
	if GameState.joy < GameState.MAX_JOY:
		GameState.add_joy(0.2 * delta)

# ==============================================================================
# 🎯 PHASE COMPLETION & JACKPOT LOGIC
# ==============================================================================
func _on_phase_finished_naturally() -> void:
	if current_phase == TimerPhase.WORK:
		# Natural 25-min jackpot computation
		var current_streak: int = GameState.streak
		# Streak multiplier: 1.0x -> 1.2x -> 1.4x -> 1.6x (max 3+ streak bonus)
		var streak_multiplier: float = minf(1.6, 1.0 + float(current_streak) * 0.2)
		var is_buffed: float = 1.2 if GameState.is_energy_buffed() else 1.0
		
		var jackpot_coins: int = int(round(BASE_JACKPOT_COINS * streak_multiplier * is_buffed))
		var jackpot_exp: int = int(round(BASE_JACKPOT_EXP * streak_multiplier))
		
		GameState.increment_streak()
		GameState.add_coins(jackpot_coins, "jackpot_natural_25min")
		GameState.add_exp(jackpot_exp)
		
		# Log to DTR database
		_log_dtr_session("completed", jackpot_coins, jackpot_exp)
		
		completed_work_sessions += 1
		EventBus.session_completed.emit("work", jackpot_coins, jackpot_exp, GameState.streak)
		
		# Transition to break: 4 work sessions -> 1 long break, else short break
		if completed_work_sessions % 4 == 0:
			_switch_to_phase(TimerPhase.LONG_BREAK)
		else:
			_switch_to_phase(TimerPhase.SHORT_BREAK)
	else:
		# Break finished naturally -> transition back to work
		EventBus.session_completed.emit(get_phase_string(), 0, 0, GameState.streak)
		_switch_to_phase(TimerPhase.WORK)
		
	# Auto-save after session completion
	if DatabaseManager:
		DatabaseManager.save_game()

# ==============================================================================
# 🛑 SKIP & CANCEL POLICY
# ==============================================================================
## Skips the current phase. If skipping work manually, 0 jackpot and resets streak.
func skip_phase(is_manual: bool = true) -> void:
	if current_phase == TimerPhase.WORK:
		if is_manual:
			# Log partial session if active for at least 60 seconds
			if focus_seconds_elapsed >= 60.0:
				_log_dtr_session("skipped", 0, 0)
			GameState.reset_streak()
			EventBus.session_skipped.emit("work")
			
		completed_work_sessions += 1
		if completed_work_sessions % 4 == 0:
			_switch_to_phase(TimerPhase.LONG_BREAK)
		else:
			_switch_to_phase(TimerPhase.SHORT_BREAK)
	else:
		_switch_to_phase(TimerPhase.WORK)
		
	status = TimerStatus.STOPPED
	EventBus.timer_state_changed.emit(false, false)

# ==============================================================================
# 🎮 CONTROLS & API
# ==============================================================================
## Starts or resumes the timer
func start_timer() -> void:
	if status == TimerStatus.RUNNING:
		return
	if status == TimerStatus.STOPPED:
		session_start_unix = Time.get_unix_time_from_system()
		_coin_accumulator = 0.0
		focus_seconds_elapsed = 0.0
		
	status = TimerStatus.RUNNING
	EventBus.timer_state_changed.emit(true, false)

## Pauses the running timer
func pause_timer() -> void:
	if status != TimerStatus.RUNNING:
		return
	status = TimerStatus.PAUSED
	EventBus.timer_state_changed.emit(false, true)

## Resumes a paused timer
func resume_timer() -> void:
	if status != TimerStatus.PAUSED:
		return
	status = TimerStatus.RUNNING
	EventBus.timer_state_changed.emit(true, false)

## Toggles between running and paused/started
func toggle_timer() -> void:
	if status == TimerStatus.RUNNING:
		pause_timer()
	elif status == TimerStatus.PAUSED or status == TimerStatus.STOPPED:
		start_timer()

## Stops and resets the current timer to the beginning of its phase
func stop_timer() -> void:
	status = TimerStatus.STOPPED
	_coin_accumulator = 0.0
	focus_seconds_elapsed = 0.0
	time_left = total_phase_duration
	EventBus.timer_state_changed.emit(false, false)
	EventBus.timer_tick.emit(time_left, total_phase_duration, get_phase_string())

## Switches to a specific phase ("work", "short_break", "long_break")
func switch_to_phase_by_name(phase_name: String) -> void:
	match phase_name:
		"work", PHASE_WORK_KEY:
			_switch_to_phase(TimerPhase.WORK)
		"short_break", PHASE_SHORT_BREAK_KEY:
			_switch_to_phase(TimerPhase.SHORT_BREAK)
		"long_break", PHASE_LONG_BREAK_KEY:
			_switch_to_phase(TimerPhase.LONG_BREAK)

func _switch_to_phase(new_phase: TimerPhase) -> void:
	current_phase = new_phase
	status = TimerStatus.STOPPED
	_coin_accumulator = 0.0
	focus_seconds_elapsed = 0.0
	
	match current_phase:
		TimerPhase.WORK:
			total_phase_duration = work_duration
		TimerPhase.SHORT_BREAK:
			total_phase_duration = short_break_duration
		TimerPhase.LONG_BREAK:
			total_phase_duration = long_break_duration
			
	time_left = total_phase_duration
	EventBus.phase_changed.emit(get_phase_string(), total_phase_duration)
	EventBus.timer_tick.emit(time_left, total_phase_duration, get_phase_string())
	EventBus.timer_state_changed.emit(false, false)

# ==============================================================================
# 📝 DTR & LOGGING HELPER
# ==============================================================================
func _log_dtr_session(completion_status: String, coins: int, xp: int) -> void:
	if not DatabaseManager:
		return
		
	var duration_min: int = maxi(1, int(round(focus_seconds_elapsed / 60.0)))
	var now_unix: int = Time.get_unix_time_from_system()
	var start_iso: String = Time.get_datetime_string_from_unix_time(session_start_unix if session_start_unix > 0 else now_unix - int(focus_seconds_elapsed))
	var end_iso: String = Time.get_datetime_string_from_unix_time(now_unix)
	var date_key: String = Time.get_date_string_from_system()
	
	var dtr_entry: Dictionary = {
		"task_name": active_task_name,
		"category": active_category,
		"start_time": start_iso,
		"end_time": end_iso,
		"duration_minutes": duration_min,
		"status": completion_status,
		"coins_earned": coins,
		"exp_earned": xp,
		"date_key": date_key,
		"created_unix": now_unix
	}
	
	DatabaseManager.log_session(dtr_entry)

# ==============================================================================
# 🛠️ GETTERS & FORMATTERS
# ==============================================================================
func get_phase_string() -> String:
	match current_phase:
		TimerPhase.WORK:
			return PHASE_WORK_KEY
		TimerPhase.SHORT_BREAK:
			return PHASE_SHORT_BREAK_KEY
		TimerPhase.LONG_BREAK:
			return PHASE_LONG_BREAK_KEY
	return PHASE_WORK_KEY

func get_formatted_time() -> String:
	var total_secs: int = int(ceil(time_left))
	var mins: int = total_secs / 60
	var secs: int = total_secs % 60
	return "%02d:%02d" % [mins, secs]

func get_progress() -> float:
	if total_phase_duration <= 0.0:
		return 0.0
	return clampf(1.0 - (time_left / total_phase_duration), 0.0, 1.0)
