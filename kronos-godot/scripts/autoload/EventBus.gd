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

## Emitted on continuous focus coin ticks (+1 coin / 10s, +50% speed if energy >= 70)
signal focus_coin_earned(coins_added: int, is_buffed: bool)

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

## Emitted when a cosmetic accessory is equipped
signal cosmetic_equipped(slot: String, cosmetic_id: String)

## Emitted when a cosmetic accessory is unequipped
signal cosmetic_unequipped(slot: String)

## Emitted when active room / biome changes
signal room_changed(room_id: String)

## Emitted when a room transition is requested (e.g. clicking a door)
signal room_change_requested(target_room: String)

## Emitted when pet changes room location autonomously or summoned
signal pet_room_changed(new_pet_room: String)

## Emitted when pet is summoned to view room
signal pet_called(target_room: String)

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
