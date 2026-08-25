extends Node

## AudioManager for Kronos Desktop Companion.
## Generates pristine procedural 16-bit 44.1kHz retro pixel sound effects and
## silky smooth seamless ambient soundscapes at runtime with zero external assets!

# ==============================================================================
# 📊 INTERNAL STATE & PLAYERS
# ==============================================================================
const SAMPLE_RATE: int = 44100

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
	if not GameState:
		return
	var amb_enabled: bool = GameState.audio_settings.get("ambience_enabled", true)
	if amb_enabled:
		var init_room: String = GameState.active_view_room if GameState.active_view_room != "" else "room_bedroom"
		crossfade_ambience(init_room, 0.5)

func _connect_event_bus() -> void:
	EventBus.coins_changed.connect(_on_coins_changed)
	EventBus.audio_settings_changed.connect(update_volumes)
	EventBus.timer_started.connect(func(): stop_alarm())
	EventBus.room_light_toggled.connect(func(_r, _s): play_sfx("switch"))
	EventBus.item_used.connect(func(_i, _d): play_sfx("munch"))
	EventBus.cosmetic_equipped.connect(func(_s, _i): play_sfx("chime"))
	EventBus.decor_placed.connect(func(_i, _r, _p): play_sfx("thud"))
	EventBus.room_changed.connect(_on_room_changed)
	EventBus.level_up.connect(func(_l): play_sfx("levelup"))

# ==============================================================================
# ⏰ ALARM FANFARE API
# ==============================================================================
## Loops continuously until user clicks [⏹ Stop Alarm] (Used when Focus/Work ends)
func start_continuous_alarm() -> void:
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
		
	_alarm_player.stream = stream
	_alarm_player.volume_db = linear_to_db(clampf(master_vol * sfx_vol * 1.1, 0.001, 1.5))
	_alarm_player.play()

func play_short_alarm() -> void:
	play_sfx("bell", 1.0)

func stop_alarm() -> void:
	if _alarm_player and _alarm_player.playing:
		_alarm_player.stop()

# ==============================================================================
# 🔊 SOUND EFFECTS API
# ==============================================================================
func play_sfx(sfx_name: String, pitch_scale: float = 1.0) -> void:
	if not _sfx_cache.has(sfx_name):
		return
		
	var is_muted: bool = false
	var master_vol: float = 0.8
	var sfx_vol: float = 0.8
	if GameState and GameState.audio_settings:
		var settings: Dictionary = GameState.audio_settings
		is_muted = settings.get("is_muted", false)
		master_vol = settings.get("master_volume", 0.8)
		sfx_vol = settings.get("sfx_volume", 0.8)
		
	if is_muted or master_vol <= 0.0 or sfx_vol <= 0.0:
		return
		
	var player: AudioStreamPlayer = _sfx_players[_sfx_player_index]
	_sfx_player_index = (_sfx_player_index + 1) % MAX_SFX_PLAYERS
	
	player.stream = _sfx_cache[sfx_name]
	player.pitch_scale = pitch_scale * randf_range(0.98, 1.02)
	player.volume_db = linear_to_db(clampf(master_vol * sfx_vol, 0.001, 1.5))
	player.play()

## Only plays coin sound on quest claims, achievement payouts, or major bulk coin rewards.
## Background 1-coin continuous timer ticks are silent.
func _on_coins_changed(_new_balance: int, delta: int, reason: String) -> void:
	if delta > 0 and (reason == "quest_reward" or reason == "achievement" or reason == "dev_cheat" or delta >= 10):
		play_sfx("coin", randf_range(0.96, 1.04))

# ==============================================================================
# 🌿 ROOM AMBIENCE API & SMOOTH CROSSFADING
# ==============================================================================
func crossfade_ambience(room_id: String, fade_duration: float = 0.8) -> void:
	if room_id.is_empty():
		room_id = "room_bedroom"
	_current_ambience_room = room_id
	
	var is_muted: bool = false
	var master_vol: float = 0.8
	var amb_vol: float = 0.35
	var amb_enabled: bool = true
	if GameState and GameState.audio_settings:
		var settings: Dictionary = GameState.audio_settings
		is_muted = settings.get("is_muted", false)
		master_vol = settings.get("master_volume", 0.8)
		amb_vol = settings.get("ambience_volume", 0.35)
		amb_enabled = settings.get("ambience_enabled", true)
		
	if is_muted or not amb_enabled or master_vol <= 0.0 or amb_vol <= 0.0:
		stop_ambience()
		return
		
	var stream: AudioStreamWAV = _get_ambience_for_room(room_id)
	if not stream:
		stop_ambience()
		return
		
	var target_db: float = linear_to_db(clampf(master_vol * amb_vol, 0.001, 1.0))
	
	var active_p = _ambience_player_1 if _current_ambience_player == 1 else _ambience_player_2
	var incoming_p = _ambience_player_2 if _current_ambience_player == 1 else _ambience_player_1
	_current_ambience_player = 2 if _current_ambience_player == 1 else 1
	
	incoming_p.stream = stream
	incoming_p.volume_db = -80.0
	incoming_p.play()
	
	var tween: Tween = create_tween().set_parallel(true)
	if active_p.playing:
		tween.tween_property(active_p, "volume_db", -80.0, fade_duration).set_trans(Tween.TRANS_SINE)
		tween.chain().tween_callback(active_p.stop)
	tween.tween_property(incoming_p, "volume_db", target_db, fade_duration).set_trans(Tween.TRANS_SINE)

func update_volumes() -> void:
	if not GameState or not GameState.audio_settings:
		return
	var settings: Dictionary = GameState.audio_settings
	var is_muted: bool = settings.get("is_muted", false)
	var master_vol: float = settings.get("master_volume", 0.8)
	var amb_vol: float = settings.get("ambience_volume", 0.35)
	var amb_enabled: bool = settings.get("ambience_enabled", true)
	
	if is_muted or not amb_enabled or master_vol <= 0.0 or amb_vol <= 0.0:
		if _ambience_player_1 and _ambience_player_1.playing:
			_ambience_player_1.stop()
		if _ambience_player_2 and _ambience_player_2.playing:
			_ambience_player_2.stop()
		return
		
	var cur_room: String = GameState.active_view_room if GameState.active_view_room != "" else "room_bedroom"
	var target_db: float = linear_to_db(clampf(master_vol * amb_vol, 0.001, 1.0))
	
	var active_p = _ambience_player_1 if _current_ambience_player == 1 else _ambience_player_2
	if active_p.playing and _current_ambience_room == cur_room:
		active_p.volume_db = target_db
	else:
		crossfade_ambience(cur_room, 0.5)

func stop_ambience() -> void:
	if _ambience_player_1 and _ambience_player_1.playing:
		_ambience_player_1.stop()
	if _ambience_player_2 and _ambience_player_2.playing:
		_ambience_player_2.stop()

func _get_ambience_for_room(room_id: String) -> AudioStreamWAV:
	match room_id:
		"room_bedroom": return _ambience_cache.get("ambience_rain", null)
		"room_livingroom": return _ambience_cache.get("ambience_fire", null)
		"room_library": return _ambience_cache.get("ambience_celestial", null)
		"room_kitchen": return _ambience_cache.get("ambience_cafe", null)
		"room_greenhouse": return _ambience_cache.get("ambience_nature", null)
		"room_styx": return _ambience_cache.get("ambience_styx", null)
		_: return _ambience_cache.get("ambience_rain", null)

func _on_room_changed(room_id: String) -> void:
	crossfade_ambience(room_id)

# ==============================================================================
# 🎛️ PROCEDURAL PCM AUDIO SYNTHESIS (Zero Buzz, Soft Consonant Harmonics)
# ==============================================================================
func _build_audio_cache() -> void:
	# SFX
	_sfx_cache["boot_fanfare"] = _synth_boot_fanfare()
	_sfx_cache["coin"] = _synth_coin_chime()
	_sfx_cache["bell"] = _synth_timer_bell()
	_sfx_cache["click"] = _synth_ui_click()
	_sfx_cache["chirp"] = _synth_pet_chirp()
	_sfx_cache["munch"] = _synth_snack_munch()
	_sfx_cache["switch"] = _synth_light_switch()
	_sfx_cache["thud"] = _synth_decor_thud()
	_sfx_cache["step"] = _synth_door_step()
	_sfx_cache["chime"] = _synth_sparkle_chime()
	_sfx_cache["levelup"] = _synth_levelup_fanfare()
	
	# Ambience Loops (all 5 domains + Styx)
	_ambience_cache["ambience_rain"] = _synth_ambience_rain()
	_ambience_cache["ambience_fire"] = _synth_ambience_fire()
	_ambience_cache["ambience_celestial"] = _synth_ambience_celestial()
	_ambience_cache["ambience_cafe"] = _synth_ambience_cafe()
	_ambience_cache["ambience_nature"] = _synth_ambience_nature()
	_ambience_cache["ambience_styx"] = _synth_ambience_styx()

## Helper to create AudioStreamWAV with smooth 0.4s sinusoidal loop crossfade
func _create_wav(data: PackedByteArray, loop: bool = false, crossfade_sec: float = 0.40) -> AudioStreamWAV:
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SAMPLE_RATE
	wav.stereo = false
	
	if loop and crossfade_sec > 0.0:
		var total_samples: int = data.size() / 2
		var fade_samples: int = int(SAMPLE_RATE * crossfade_sec)
		if total_samples > fade_samples * 2:
			for i in range(fade_samples):
				var progress: float = float(i) / float(fade_samples)
				var start_byte: int = i * 2
				var end_byte: int = (total_samples - fade_samples + i) * 2
				var s_start: int = data.decode_s16(start_byte)
				var s_end: int = data.decode_s16(end_byte)
				
				# Sinusoidal equal-power crossfade
				var w_in: float = sin(progress * PI * 0.5)
				var w_out: float = cos(progress * PI * 0.5)
				var blended: int = clampi(int(float(s_start) * w_in + float(s_end) * w_out), -32768, 32767)
				data.encode_s16(start_byte, blended)
				data.encode_s16(end_byte, blended)
				
	wav.data = data
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = data.size() / 2
	return wav

# --- 0. Grand Retro Boot Opening Fanfare (Ascending Crystal Chimes) ---
func _synth_boot_fanfare() -> AudioStreamWAV:
	var duration: float = 2.4
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	var notes: Array[float] = [523.25, 659.25, 783.99, 987.77, 1046.50, 1318.51, 1567.98]
	var spacing: float = 0.09
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var total_sample: float = 0.0
		
		for n in range(notes.size()):
			var n_start: float = float(n) * spacing
			if t >= n_start:
				var lt: float = t - n_start
				var env: float = exp(-lt * 4.0)
				var f: float = notes[n]
				var s1: float = sin(lt * f * TAU) * 0.45
				var s2: float = sin(lt * f * 2.0 * TAU) * 0.15
				total_sample += (s1 + s2) * env
				
		var sample_val: float = clampf(total_sample * 0.85, -1.0, 1.0)
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 1. Golden Coin Pickup Ding (Bright Glockenspiel B5 -> E6 -> G6) ---
func _synth_coin_chime() -> AudioStreamWAV:
	var duration: float = 0.45
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	var notes: Array[float] = [987.77, 1318.51, 1567.98]
	var spacing: float = 0.06
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var total: float = 0.0
		for n in range(notes.size()):
			var n_start: float = float(n) * spacing
			if t >= n_start:
				var lt: float = t - n_start
				var env: float = exp(-lt * 9.0)
				var f: float = notes[n]
				var s: float = (sin(lt * f * TAU) * 0.70 + sin(lt * f * 2.0 * TAU) * 0.20) * env
				total += s
				
		var sample_val: float = clampf(total * 0.85, -1.0, 1.0)
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 2. Full Timer Finish Alarm (Deep Temple Gong 528 Hz) ---
func _synth_timer_bell() -> AudioStreamWAV:
	var duration: float = 3.5
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	var base_freq: float = 528.0
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 0.9)
		var tremolo: float = 1.0 + sin(t * 3.0 * TAU) * 0.06
		var fundamental: float = sin(t * base_freq * TAU) * 0.50
		var sub: float = sin(t * (base_freq * 0.5) * TAU) * 0.35
		var harmonic2: float = sin(t * (base_freq * 2.0) * TAU) * 0.12
		
		var sample_val: float = (fundamental + sub + harmonic2) * env * tremolo * 0.90
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 3. UI Tactile Wooden Click ---
func _synth_ui_click() -> AudioStreamWAV:
	var duration: float = 0.03
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 120.0)
		var sample_val: float = sin(t * 1500.0 * TAU) * env * 0.70
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 4. Pet Cute Melodic Chirp ---
func _synth_pet_chirp() -> AudioStreamWAV:
	var duration: float = 0.22
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var t_norm: float = t / duration
		var vibrato: float = sin(t_norm * 25.0) * 30.0
		var freq: float = 600.0 + sin(t_norm * PI) * 500.0 + vibrato
		var env: float = sin(t_norm * PI)
		
		var sample_val: float = sin(t * freq * TAU) * env * 0.80
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 5. Snack Pop ---
func _synth_snack_munch() -> AudioStreamWAV:
	var duration: float = 0.16
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	var split_sample: int = int(SAMPLE_RATE * 0.08)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var freq: float = (340.0 + t * 420.0) if i < split_sample else (540.0 - (t - 0.08) * 300.0)
		var env: float = 1.0 - (float(i) / num_samples)
		var sample_val: float = sin(t * freq * TAU) * env * 0.80
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 6. Light Switch ---
func _synth_light_switch() -> AudioStreamWAV:
	var duration: float = 0.045
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 110.0)
		var freq: float = 900.0 - (t * 5000.0)
		var sample_val: float = sin(t * freq * TAU) * env * 0.70
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 7. Decor Thud ---
func _synth_decor_thud() -> AudioStreamWAV:
	var duration: float = 0.12
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 40.0)
		var freq: float = 140.0 * exp(-t * 18.0)
		var sample_val: float = sin(t * freq * TAU) * env * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 8. Door Step ---
func _synth_door_step() -> AudioStreamWAV:
	var duration: float = 0.08
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = exp(-t * 60.0)
		var freq: float = 260.0 - (t * 1800.0)
		var sample_val: float = sin(t * freq * TAU) * env * 0.65
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 9. Sparkle / Equip Chime ---
func _synth_sparkle_chime() -> AudioStreamWAV:
	var duration: float = 0.40
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var env: float = 1.0 - (float(i) / num_samples)
		var s1: float = sin(t * 1174.66 * TAU) * 0.45 # D6
		var s2: float = sin(t * 1760.00 * TAU) * 0.35 # A6
		var s3: float = sin(t * 2349.32 * TAU) * 0.20 # D7
		var sample_val: float = (s1 + s2 + s3) * env * 0.85
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# --- 10. Level Up Celebratory Melody ---
func _synth_levelup_fanfare() -> AudioStreamWAV:
	var duration: float = 1.6
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	var notes: Array[float] = [523.25, 659.25, 783.99, 1046.50, 1318.51] # C5 -> E6
	var spacing: float = 0.11
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var total: float = 0.0
		for n in range(notes.size()):
			var n_start: float = float(n) * spacing
			if t >= n_start:
				var lt: float = t - n_start
				var env: float = exp(-lt * 4.5)
				var f: float = notes[n]
				var s: float = (sin(lt * f * TAU) * 0.60 + sin(lt * f * 2.0 * TAU) * 0.20) * env
				total += s
				
		var sample_val: float = clampf(total * 0.85, -1.0, 1.0)
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes)

# ==============================================================================
# 🌿 PROCEDURAL AMBIENCE (Lush Harmonic Chords & Organic Textured Soundscapes)
# ==============================================================================

# --- 1. Study Bedroom: Lo-Fi C-Major9 Warm Pad & Soft Rain ---
func _synth_ambience_rain() -> AudioStreamWAV:
	var duration: float = 6.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	var filter_state: float = 0.0
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.80 + sin(t * (1.0 / duration) * TAU) * 0.20
		
		# C-Major9 Warm Harmonized Sine Waves
		var c3: float = sin(t * 130.81 * TAU) * 0.28
		var g3: float = sin(t * 196.00 * TAU) * 0.22
		var b3: float = sin(t * 246.94 * TAU) * 0.18
		var e4: float = sin(t * 329.63 * TAU) * 0.14
		var d5: float = sin(t * 587.33 * TAU) * 0.08
		
		# Low-pass filtered pink noise rain texture
		var white_noise: float = randf_range(-1.0, 1.0)
		filter_state = filter_state * 0.94 + white_noise * 0.06
		var rain_texture: float = filter_state * 0.08
		
		var sample_val: float = (c3 + g3 + b3 + e4 + d5 + rain_texture) * swell * 0.70
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

# --- 2. Cozy Living Room: A-Minor7 Hearth Embers & Fireplace Warmth ---
func _synth_ambience_fire() -> AudioStreamWAV:
	var duration: float = 6.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	var filter_state: float = 0.0
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.80 + sin(t * (1.0 / duration) * TAU) * 0.20
		
		# A-Minor7 Cozy Ambient Pad
		var a2: float = sin(t * 110.00 * TAU) * 0.30
		var e3: float = sin(t * 164.81 * TAU) * 0.24
		var c4: float = sin(t * 261.63 * TAU) * 0.18
		var g4: float = sin(t * 392.00 * TAU) * 0.12
		
		# Smooth low-pass warm hearth noise
		var raw_n: float = randf_range(-1.0, 1.0)
		filter_state = filter_state * 0.96 + raw_n * 0.04
		var fire_hum: float = filter_state * 0.06
		
		var sample_val: float = (a2 + e3 + c4 + g4 + fire_hum) * swell * 0.70
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

# --- 3. Grand Library: Celestial Glass Harmonica & Cosmic Resonance ---
func _synth_ambience_celestial() -> AudioStreamWAV:
	var duration: float = 6.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.80 + sin(t * (1.0 / duration) * TAU) * 0.20
		var chorus: float = sin(t * 0.15 * TAU) * 1.5
		
		# Glass Harmonica E-Major Chord (E3, B3, G#4, D#5)
		var e3: float = sin(t * (164.81 + chorus) * TAU) * 0.28
		var b3: float = sin(t * 246.94 * TAU) * 0.22
		var g_sharp4: float = sin(t * (415.30 - chorus) * TAU) * 0.18
		var d_sharp5: float = sin(t * 622.25 * TAU) * 0.12
		
		var sample_val: float = (e3 + b3 + g_sharp4 + d_sharp5) * swell * 0.68
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

# --- 4. Zen Greenhouse: Nature Breeze & Morning Harmony ---
func _synth_ambience_nature() -> AudioStreamWAV:
	var duration: float = 6.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	var filter_state: float = 0.0
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.80 + sin(t * (1.0 / duration) * TAU) * 0.20
		
		# F-Major9 Lush Nature Pad
		var f3: float = sin(t * 174.61 * TAU) * 0.28
		var c4: float = sin(t * 261.63 * TAU) * 0.22
		var a4: float = sin(t * 440.00 * TAU) * 0.16
		var e5: float = sin(t * 659.25 * TAU) * 0.10
		
		# Soft morning wind breeze
		var raw_n: float = randf_range(-1.0, 1.0)
		filter_state = filter_state * 0.98 + raw_n * 0.02
		var breeze: float = filter_state * 0.10
		
		var sample_val: float = (f3 + c4 + a4 + e5 + breeze) * swell * 0.68
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

# --- 5. Chef's Kitchen: Cozy Cafe Jazz Pad & Warm Steam ---
func _synth_ambience_cafe() -> AudioStreamWAV:
	var duration: float = 6.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	var filter_state: float = 0.0
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.80 + sin(t * (1.0 / duration) * TAU) * 0.20
		
		# D-Major7 Warm Coffee Chord
		var d3: float = sin(t * 146.83 * TAU) * 0.28
		var a3: float = sin(t * 220.00 * TAU) * 0.22
		var c_sharp4: float = sin(t * 277.18 * TAU) * 0.16
		var f_sharp4: float = sin(t * 369.99 * TAU) * 0.10
		
		# Filtered warm steam shimmer
		var raw_n: float = randf_range(-1.0, 1.0)
		filter_state = filter_state * 0.95 + raw_n * 0.05
		var steam: float = filter_state * 0.06
		
		var sample_val: float = (d3 + a3 + c_sharp4 + f_sharp4 + steam) * swell * 0.68
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)

# --- 6. Banks of the Styx: Subterranean Drone & Cavern Tone ---
func _synth_ambience_styx() -> AudioStreamWAV:
	var duration: float = 6.0
	var num_samples: int = int(SAMPLE_RATE * duration)
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(num_samples * 2)
	
	for i in range(num_samples):
		var t: float = float(i) / SAMPLE_RATE
		var swell: float = 0.80 + sin(t * (1.0 / duration) * TAU) * 0.20
		
		# Deep D-Minor Sub Drone
		var d2: float = sin(t * 73.42 * TAU) * 0.35
		var a2: float = sin(t * 110.00 * TAU) * 0.25
		var f3: float = sin(t * 174.61 * TAU) * 0.15
		
		var sample_val: float = (d2 + a2 + f3) * swell * 0.70
		var sample_int: int = clampi(int(sample_val * 32767.0), -32768, 32767)
		bytes.encode_s16(i * 2, sample_int)
		
	return _create_wav(bytes, true)
