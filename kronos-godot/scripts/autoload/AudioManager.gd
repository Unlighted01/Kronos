extends Node

## AudioManager for Kronos Desktop Companion.
## Generates pure procedural 16-bit PCM retro pixel sound effects and
## seamless room ambient soundscapes at runtime with zero external assets!

# ==============================================================================
# 📊 INTERNAL STATE & PLAYERS
# ==============================================================================
const SAMPLE_RATE: int = 22050

var _sfx_cache: Dictionary = {}
var _ambience_cache: Dictionary = {}

var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_player_index: int = 0
const MAX_SFX_PLAYERS: int = 6

var _ambience_player_1: AudioStreamPlayer
var _ambience_player_2: AudioStreamPlayer
var _current_ambience_player: int = 1
var _current_ambience_room: String = ""

var _alarm_player: AudioStreamPlayer

# ==============================================================================
# ⚙️ LIFECYCLE
# ==============================================================================
func _ready() -> void:
	# 1. Instantiate SFX Player Pool
	for i in range(MAX_SFX_PLAYERS):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.name = "SFXPlayer_%d" % i
		p.bus = "Master"
		add_child(p)
		_sfx_players.append(p)
		
	# 2. Instantiate Dual Ambience Players for smooth crossfading
	_ambience_player_1 = AudioStreamPlayer.new()
	_ambience_player_1.name = "AmbiencePlayer_1"
	_ambience_player_1.bus = "Master"
	add_child(_ambience_player_1)
	
	_ambience_player_2 = AudioStreamPlayer.new()
	_ambience_player_2.name = "AmbiencePlayer_2"
	_ambience_player_2.bus = "Master"
	add_child(_ambience_player_2)
	
	# 3. Instantiate Dedicated Alarm Player
	_alarm_player = AudioStreamPlayer.new()
	_alarm_player.name = "AlarmPlayer"
	_alarm_player.bus = "Master"
	add_child(_alarm_player)
	
	# 4. Synthesize & Cache All Procedural Audio Samples
	_build_audio_cache()
	
	# 5. Connect to EventBus signals
	_connect_event_bus()
	
	# 6. Start initial ambient soundscape only if enabled
	call_deferred("_start_initial_ambience")

func _start_initial_ambience() -> void:
	if not GameState or not GameState.audio_settings.get("ambience_enabled", false):
		return
	var init_room: String = GameState.active_view_room if GameState else "room_bedroom"
	crossfade_ambience(init_room)

func _connect_event_bus() -> void:
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.session_completed.connect(func(_type, _coins, _xp, _streak): start_alarm())
	EventBus.timer_started.connect(func(): stop_alarm())
	EventBus.room_light_toggled.connect(func(_r, _s): play_sfx("switch"))
	EventBus.item_used.connect(func(_i, _d): play_sfx("munch"))
	EventBus.cosmetic_equipped.connect(func(_s, _i): play_sfx("chime"))
	EventBus.decor_placed.connect(func(_i, _r, _p): play_sfx("thud"))
	EventBus.room_changed.connect(_on_room_changed)

# ==============================================================================
# ⏰ CONTINUOUS ALARM LOOP
# ==============================================================================
func start_alarm() -> void:
	if not _alarm_player:
		return
	var stream: AudioStreamWAV = _sfx_cache.get("bell", null)
	if not stream:
		return
		
	var is_muted: bool = false
	var master_vol: float = 0.8
	var sfx_vol: float = 0.8
	if GameState and GameState.audio_settings:
		var settings: Dictionary = GameState.audio_settings
		is_muted = settings.get("is_muted", false)
		master_vol = settings.get("master_volume", 0.8)
		sfx_vol = settings.get("sfx_volume", 0.8)
		
	if is_muted:
		return
		
	# Loop continuous Kalimba fanfare until acknowledged
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size() / 2
	
	_alarm_player.stream = stream
	_alarm_player.volume_db = linear_to_db(clampf(master_vol * sfx_vol, 0.001, 1.0))
	_alarm_player.play()

func stop_alarm() -> void:
	if _alarm_player and _alarm_player.playing:
		_alarm_player.stop()

# ==============================================================================
# 🔊 SFX PLAYBACK
# ==============================================================================
func play_sfx(sound_name: String) -> void:
	if not _sfx_cache.has(sound_name):
		return
		
	var is_muted: bool = false
	var master_vol: float = 0.8
	var sfx_vol: float = 0.7
	
	if GameState and GameState.audio_settings:
		var settings: Dictionary = GameState.audio_settings
		is_muted = settings.get("is_muted", false)
		master_vol = settings.get("master_volume", 0.8)
		sfx_vol = settings.get("sfx_volume", 0.7)
		
	if is_muted:
		return
		
	var final_vol: float = master_vol * sfx_vol
	if final_vol <= 0.001:
		return
		
	var player: AudioStreamPlayer = _sfx_players[_sfx_player_index]
	_sfx_player_index = (_sfx_player_index + 1) % MAX_SFX_PLAYERS
	
	player.stream = _sfx_cache[sound_name]
	player.volume_db = linear_to_db(clampf(final_vol, 0.001, 1.0))
	player.play()

# ==============================================================================
# 🌧️ AMBIENCE CROSSFADING
# ==============================================================================
func crossfade_ambience(room_id: String) -> void:
	if _current_ambience_room == room_id and (_ambience_player_1.playing or _ambience_player_2.playing):
		return
		
	_current_ambience_room = room_id
	
	var is_muted: bool = false
	var is_ambience_on: bool = false
	var master_vol: float = 0.8
	var amb_vol: float = 0.5
	
	if GameState and GameState.audio_settings:
		var settings: Dictionary = GameState.audio_settings
		is_muted = settings.get("is_muted", false)
		is_ambience_on = settings.get("ambience_enabled", false)
		master_vol = settings.get("master_volume", 0.8)
		amb_vol = settings.get("ambience_volume", 0.5)
		
	var target_vol: float = master_vol * amb_vol if (not is_muted and is_ambience_on) else 0.0001
	
	var amb_key: String = _get_ambience_key_for_room(room_id)
	if not _ambience_cache.has(amb_key):
		return
		
	var stream: AudioStreamWAV = _ambience_cache[amb_key]
	
	var active_player: AudioStreamPlayer
	var fade_out_player: AudioStreamPlayer
	
	if _current_ambience_player == 1:
		active_player = _ambience_player_2
		fade_out_player = _ambience_player_1
		_current_ambience_player = 2
	else:
		active_player = _ambience_player_1
		fade_out_player = _ambience_player_2
		_current_ambience_player = 1
		
	# Setup new active player
	active_player.stream = stream
	active_player.volume_db = linear_to_db(0.0001)
	if is_ambience_on and not is_muted:
		active_player.play()
	
	# Smooth crossfade tween
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(active_player, "volume_db", linear_to_db(clampf(target_vol, 0.0001, 1.0)), 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(fade_out_player, "volume_db", linear_to_db(0.0001), 0.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(func(): fade_out_player.stop())

func update_volumes() -> void:
	var is_muted: bool = false
	var is_ambience_on: bool = false
	var master_vol: float = 0.8
	var amb_vol: float = 0.65
	
	if GameState and GameState.audio_settings:
		var settings: Dictionary = GameState.audio_settings
		is_muted = settings.get("is_muted", false)
		is_ambience_on = settings.get("ambience_enabled", false)
		master_vol = settings.get("master_volume", 0.8)
		amb_vol = settings.get("ambience_volume", 0.65)
		
	var target_vol: float = master_vol * amb_vol if (not is_muted and is_ambience_on) else 0.0001
	
	if not is_ambience_on or is_muted:
		if _ambience_player_1:
			_ambience_player_1.stop()
			_ambience_player_1.volume_db = linear_to_db(0.0001)
		if _ambience_player_2:
			_ambience_player_2.stop()
			_ambience_player_2.volume_db = linear_to_db(0.0001)
	else:
		if not _ambience_player_1.playing and not _ambience_player_2.playing:
			var init_room: String = GameState.active_view_room if GameState else "room_bedroom"
			_current_ambience_room = ""
			crossfade_ambience(init_room)
		else:
			var active_player = _ambience_player_1 if _current_ambience_player == 1 else _ambience_player_2
			if active_player and active_player.playing:
				active_player.volume_db = linear_to_db(clampf(target_vol, 0.0001, 1.0))

func _get_ambience_key_for_room(room_id: String) -> String:
	match room_id:
		"room_bedroom": return "ambience_rain"
		"room_livingroom": return "ambience_fire"
		"room_library": return "ambience_breeze"
		"room_kitchen": return "ambience_cafe"
		"room_greenhouse": return "ambience_breeze"
		_: return "ambience_rain"

# ==============================================================================
# 📡 EVENT LISTENERS
# ==============================================================================
func _on_coins_changed(_new_coins: int, delta: int, reason: String = "") -> void:
	# Only play chime for deliberate reward payouts (quests, minigames, jackpots), NOT silent continuous focus/passive ticks
	if delta > 0 and reason != "continuous_focus" and reason != "passive_presence" and reason != "init":
		play_sfx("coin")

func _on_session_completed(_type: String, _coins: int, _xp: int, _streak: int) -> void:
	play_sfx("bell")

func _on_room_changed(room_id: String) -> void:
	play_sfx("step")
	if GameState and GameState.audio_settings.get("ambience_enabled", false):
		crossfade_ambience(room_id)

# ==============================================================================
# 🎛️ PROCEDURAL PCM AUDIO SYNTHESIS
# ==============================================================================
func _build_audio_cache() -> void:
	# SFX
	_sfx_cache["coin"] = _synth_coin_chime()
	_sfx_cache["bell"] = _synth_timer_bell()
	_sfx_cache["click"] = _synth_ui_click()
	_sfx_cache["chirp"] = _synth_pet_chirp()
	_sfx_cache["munch"] = _synth_snack_munch()
	_sfx_cache["switch"] = _synth_light_switch()
	_sfx_cache["thud"] = _synth_decor_thud()
	_sfx_cache["step"] = _synth_door_step()
	_sfx_cache["chime"] = _synth_sparkle_chime()
	
	# Ambience Loops
	_ambience_cache["ambience_rain"] = _synth_ambience_rain()
	_ambience_cache["ambience_fire"] = _synth_ambience_fire()
	_ambience_cache["ambience_cafe"] = _synth_ambience_cafe()
	_ambience_cache["ambience_breeze"] = _synth_ambience_breeze()

## Helper to create AudioStreamWAV from PackedByteArray
func _create_wav(data: PackedByteArray, loop: bool = false) -> AudioStreamWAV:
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = data.size() / 2 # 16-bit = 2 bytes per sample
	return wav

# --- 1. Golden Coin Pickup Ding (Bright Glockenspiel B5 -> E6) ---
func _synth_coin_chime() -> AudioStreamWAV:
	var duration: float = 0.35
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	var note1_len: float = 0.09
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var freq: float = 987.77 if t < note1_len else 1318.51 # B5 -> E6
		var local_t: float = t if t < note1_len else (t - note1_len)
		var env: float = exp(-local_t * 12.0)
		
		var fundamental: float = sin(t * freq * TAU) * 0.75
		var overtone: float = sin(t * freq * 2.0 * TAU) * 0.20
		var sample_val: float = (fundamental + overtone) * env * 0.90
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 2. Full Timer Finish Alarm (Double-Cascade Kalimba Crystal Chime) ---
func _synth_timer_bell() -> AudioStreamWAV:
	var duration: float = 2.4
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	# 10-note melodic celebration fanfare
	var notes: Array[float] = [
		783.99, 1046.50, 1318.51, 1567.98, 2093.00, # Phrase 1: G5, C6, E6, G6, C7
		1318.51, 1567.98, 2093.00, 2637.02, 3135.96  # Phrase 2: E6, G6, C7, E7, G7
	]
	var note_spacing: float = 0.12
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var total_sample: float = 0.0
		
		for n in range(notes.size()):
			var note_start: float = float(n) * note_spacing
			if t >= note_start:
				var local_t: float = t - note_start
				var env: float = exp(-local_t * 4.0)
				var freq: float = notes[n]
				var tone: float = sin(local_t * freq * TAU) * 0.32
				var harmonic: float = sin(local_t * freq * 2.0 * TAU) * 0.10
				total_sample += (tone + harmonic) * env
				
		var sample_val: float = clampf(total_sample * 0.95, -1.0, 1.0)
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 3. UI Soft Wooden Sine Blip ---
func _synth_ui_click() -> AudioStreamWAV:
	var duration: float = 0.03
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 90.0)
		var sample_val: float = sin(t * 1400.0 * TAU) * env * 0.70
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 4. Pet Cute Melodic Chirp / Purr ---
func _synth_pet_chirp() -> AudioStreamWAV:
	var duration: float = 0.18
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / duration
		var vibrato: float = sin(t * 30.0) * 40.0
		var freq: float = 650.0 + sin(t * PI) * 550.0 + vibrato
		var env: float = sin(t * PI)
		
		var sample_val: float = sin(float(i) / SAMPLE_RATE * freq * TAU) * env * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 5. Snack Sweet Bubble Pop ---
func _synth_snack_munch() -> AudioStreamWAV:
	var duration: float = 0.15
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	var split_sample: int = int(SAMPLE_RATE * 0.07)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var freq: float = (320.0 + t * 400.0) if i < split_sample else (520.0 - (t - 0.07) * 300.0)
		var env: float = 1.0 - (float(i) / num_samples)
		var sample_val: float = sin(t * freq * TAU) * env * 0.80
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 6. Light Switch Toggle ---
func _synth_light_switch() -> AudioStreamWAV:
	var duration: float = 0.04
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 120.0)
		var freq: float = 900.0 - (t * 6000.0)
		var sample_val: float = sin(t * freq * TAU) * env * 0.75
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 7. Decor Placement Deep Wood Thud ---
func _synth_decor_thud() -> AudioStreamWAV:
	var duration: float = 0.10
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 30.0)
		var sample_val: float = sin(t * 120.0 * TAU) * env * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 8. Room Transition Floor Tap ---
func _synth_door_step() -> AudioStreamWAV:
	var duration: float = 0.05
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 60.0)
		var sample_val: float = sin(t * 110.0 * TAU) * env * 0.40
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 9. Sparkle / Equip Chime ---
func _synth_sparkle_chime() -> AudioStreamWAV:
	var duration: float = 0.35
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = 1.0 - (float(i) / num_samples)
		var s1: float = sin(t * 1174.66 * TAU) * 0.50 # D6
		var s2: float = sin(t * 1760.00 * TAU) * 0.40 # A6
		var sample_val: float = (s1 + s2) * env * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# ==============================================================================
# 🌿 PROCEDURAL AMBIENCE (Lush Lo-Fi Sine Harmony Pads - Zero Noise/Static)
# ==============================================================================
# --- 1. Study Bedroom Lo-Fi C-Major9 Pad ---
func _synth_ambience_rain() -> AudioStreamWAV:
	var duration: float = 4.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.75 + sin(t * 0.5 * TAU) * 0.25
		var c4: float = sin(t * 261.63 * TAU) * 0.32
		var e4: float = sin(t * 329.63 * TAU) * 0.26
		var g4: float = sin(t * 392.00 * TAU) * 0.22
		var b4: float = sin(t * 493.88 * TAU) * 0.15
		var d5: float = sin(t * 587.33 * TAU) * 0.10
		var sample_val: float = (c4 + e4 + g4 + b4 + d5) * swell * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

# --- 2. Living Room Cozy Warm A-Minor7 Pad ---
func _synth_ambience_fire() -> AudioStreamWAV:
	var duration: float = 4.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.75 + sin(t * 0.4 * TAU) * 0.25
		var a3: float = sin(t * 220.00 * TAU) * 0.35
		var c4: float = sin(t * 261.63 * TAU) * 0.28
		var e4: float = sin(t * 329.63 * TAU) * 0.22
		var g4: float = sin(t * 392.00 * TAU) * 0.15
		var sample_val: float = (a3 + c4 + e4 + g4) * swell * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

# --- 3. Kitchen Cafe F-Major7 Warm Pad ---
func _synth_ambience_cafe() -> AudioStreamWAV:
	var duration: float = 4.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.75 + sin(t * 0.45 * TAU) * 0.25
		var f3: float = sin(t * 174.61 * TAU) * 0.35
		var a3: float = sin(t * 220.00 * TAU) * 0.28
		var c4: float = sin(t * 261.63 * TAU) * 0.22
		var e4: float = sin(t * 329.63 * TAU) * 0.15
		var sample_val: float = (f3 + a3 + c4 + e4) * swell * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

# --- 4. Library & Conservatory Ethereal G-Major9 Pad ---
func _synth_ambience_breeze() -> AudioStreamWAV:
	var duration: float = 4.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.75 + sin(t * 0.5 * TAU) * 0.25
		var g3: float = sin(t * 196.00 * TAU) * 0.35
		var b3: float = sin(t * 246.94 * TAU) * 0.26
		var d4: float = sin(t * 293.66 * TAU) * 0.22
		var f_sharp: float = sin(t * 369.99 * TAU) * 0.15
		var a4: float = sin(t * 440.00 * TAU) * 0.10
		var sample_val: float = (g3 + b3 + d4 + f_sharp + a4) * swell * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

