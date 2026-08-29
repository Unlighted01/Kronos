extends Node
## Centralized EventBus Singleton for Kronos.
## Provides strongly-typed signals across all subsystems (Timer, GameState, UI, Window, DB).

# ==============================================================================
# ⏱️ TIMER & POMODORO SIGNALS
# ==============================================================================
## Emitted on every timer tick with remaining seconds, total seconds, and current phase ("work", "short_break", "long_break")
signal timer_tick(time_left_seconds: float, total_seconds: float, phase: String)

## Emitted when the timer phase changes
signal phase_changed(new_phase: String, duration_seconds: float)

## Emitted when timer running/paused state changes
signal timer_state_changed(is_running: bool, is_paused: bool)

## Emitted when a session completes naturally
signal session_completed(session_type: String, coins_earned: int, xp_earned: int, streak: int)

## Emitted when a session is manually skipped or reset
signal session_skipped(session_type: String)

## Emitted when timer starts or resumes
signal timer_started()

## Emitted when audio or notification settings change
signal audio_settings_changed()

## Emitted on continuous focus coin ticks (+1 coin / 10s, +50% speed if energy >= 70)
signal focus_coin_earned(coins_added: int, is_buffed: bool)

## Emitted when the timer preset changes (e.g. 25/5, 50/10, 90/20, flowmodoro)
signal timer_preset_changed(preset_id: String, preset_def: Dictionary)

## Emitted when Productivity Studio open/toggle is requested
signal productivity_studio_requested(initial_tab: String)
signal productivity_studio_toggled(is_open: bool)

# ==============================================================================
# 📋 MICRO-TASKS & DAILY QUEST SIGNALS
# ==============================================================================
## Emitted when a micro-task is added
signal task_added(task: Dictionary)

## Emitted when a task is checked or unchecked
signal task_toggled(task_id: String, completed: bool)

## Emitted when a task is deleted
signal task_deleted(task_id: String)

## Emitted when the active focus task is changed
signal active_task_selected(task_id: String, task_title: String)

## Emitted when daily quests are generated, refreshed, or progressed
signal quests_updated()

## Emitted when a quest reward is claimed
signal quest_claimed(quest_id: String, coins: int, exp: int)

# ==============================================================================
# 🐾 GAME STATE & PET STAT SIGNALS
# ==============================================================================
## Emitted when coin balance changes
signal coins_changed(new_balance: int, amount_delta: int, reason: String)

## Emitted when pet exp changes
signal exp_changed(current_exp: int, max_exp: int, level: int)

## Emitted when pet levels up
signal level_up(new_level: int)

## Emitted when energy stat changes
signal energy_changed(new_energy: float, max_energy: float, is_buffed: bool)

## Emitted when joy / happiness stat changes
signal joy_changed(new_joy: float, max_joy: float)

## Emitted when all stats are refreshed or loaded
signal stats_updated(stats: Dictionary)

## Emitted when Knowledge Points (KP) balance changes
signal knowledge_points_changed(new_balance: int, amount_delta: int, reason: String)

## Emitted when flashcards are added, edited, or deleted in the deck
signal flashcards_updated()

## Emitted when focus streak changes
signal streak_changed(current_streak: int)

## Emitted when the user interacts with the pet (click to pet, play, feed)
signal pet_interacted(interaction_type: String)

# ==============================================================================
# 🎒 INVENTORY & COSMETIC SIGNALS
# ==============================================================================
## Emitted when an inventory item is used (snack/buff)
signal item_used(item_id: String, item_data: Dictionary)

## Emitted when an item is added to inventory
signal item_acquired(item_id: String, quantity: int)

## Emitted when an item is consumed or removed
signal item_removed(item_id: String, quantity: int)

## Emitted when inventory contents change
signal inventory_changed(items: Array[Dictionary])

## Emitted when a cosmetic item is equipped/unequipped
signal cosmetic_equipped(pet_index: int, slot: String, cosmetic_id: String)

## Emitted when a cosmetic accessory is unequipped
signal cosmetic_unequipped(pet_index: int, slot: String)

## Emitted when a room decoration is placed or stowed
signal decor_placed(item_id: String, room_id: String, is_placed: bool)

## Emitted when a room is unlocked in the Shop
signal room_unlocked(room_id: String)

## Emitted when active room / biome changes
signal room_changed(room_id: String)

## Emitted when a room transition is requested (e.g. clicking a door)
signal room_change_requested(target_room: String)

## Emitted when pet changes room location autonomously or summoned
signal pet_room_changed(new_pet_room: String)

## Emitted when pet is summoned to view room
signal pet_called(target_room: String)

## Emitted when a new pet is adopted
signal pet_adopted(pet_data: Dictionary, as_household: bool)

## Emitted when a pet delivery parcel box is spawned in the room
signal pet_delivery_box_spawned(pet_data: Dictionary, spawn_pos: Vector2)

## Emitted when maximum household pet slot capacity increases via level
signal max_pets_changed(new_max: int)

## Emitted when the household active pets list changes
signal pet_list_changed(active_pets: Array)
## Emitted when a pet is selected from the active list
signal active_pet_selected(index: int, pet_data: Dictionary)

## Emitted when a room's light switch is toggled
signal room_light_toggled(room_id: String, is_on: bool)

## Emitted when an interactive room object state changes (e.g. bed open, window open)
signal object_state_changed(object_id: String, state_value: Variant)

# ==============================================================================
# 🪟 WINDOW & WORKSPACE SIGNALS
# ==============================================================================
## Emitted when window scaling preset changes (1.0, 1.25, 1.5)
signal window_scale_changed(scale_factor: float, window_size: Vector2i)

## Emitted when Always-on-Top pin state changes
signal window_pin_toggled(is_pinned: bool)

## Emitted when a side panel expands or collapses ("left", "right")
signal panel_visibility_changed(panel_id: String, is_visible: bool)

## Emitted when window layout dimensions recalculate
signal layout_resized(new_size: Vector2i)

## Emitted when window drag begins
signal window_drag_started()

## Emitted when window drag ends
signal window_drag_ended(new_position: Vector2i)

# ==============================================================================
# 💾 DATABASE & PERSISTENCE SIGNALS
# ==============================================================================
## Emitted after save operation
signal save_completed(success: bool, timestamp: String)

## Emitted after load operation
signal load_completed(success: bool)

## Emitted when DTR focus records are added, updated, or deleted
signal dtr_updated()

## Emitted by rooms with dynamic floors (like Charon's Skiff)
signal floor_y_offset_changed(offset: float)

# ==============================================================================
# 🏆 ACHIEVEMENTS & FRIENDSHIP SIGNALS
# ==============================================================================
## Emitted when an achievement/trophy is unlocked
signal achievement_unlocked(achievement_id: String, achievement_def: Dictionary)

## Emitted when pet affection/friendship level or exp increases
signal affection_changed(pet_id: String, new_level: int, new_xp: int, delta: int)

## Emitted when a flashcard is reviewed in study drill
signal flashcard_reviewed(card_id: String, rating: String)

## Emitted when a new flashcard is created
signal flashcard_created(card_id: String)

