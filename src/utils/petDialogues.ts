export interface PetStatsContext {
  energy: number;
  happiness: number;
}

export const FOCUS_THOUGHTS = [
  "Debugging pixels... 💻",
  "Compiling code...",
  "Need a coffee break ☕",
  "Focus level: 100% ⚡",
  "You're crushing it! 💪",
  "Syntax error fixed! ✨",
  "Writing clean code...",
  "Almost done!",
  "Deep focus mode...",
  "Building Kronos ⏳",
];

export const IDLE_THOUGHTS = [
  "What are we building today?",
  "Is it snack time? 🍕",
  "I love 2D pixels! 👾",
  "Yawn... 💤",
  "Let's do some work!",
  "Pacing around...",
  "Looking at you 👀",
  "So peaceful...",
  "Ready when you are!",
];

export const LOW_ENERGY_THOUGHTS = [
  "Tired... ☕",
  "Hungry for donuts... 🍩",
  "Energy low 🪫",
  "Feed me pizza 🍕",
  "Need espresso!",
];

export const LOW_HAPPINESS_THOUGHTS = [
  "Need some joy...",
  "Let's play!",
  "Visit the Pet Shop!",
  "Snack time please?",
];

export const AFK_THOUGHTS = [
  "Out for a stroll... 🚶",
  "Brb exploring!",
  "Hiding 🙈",
  "Taking a quick break...",
];

export function getRandomThought(
  mode: 'work' | 'shortBreak' | 'longBreak',
  status: 'idle' | 'running' | 'paused',
  isAfk: boolean,
  stats?: PetStatsContext
): string {
  if (isAfk) {
    return AFK_THOUGHTS[Math.floor(Math.random() * AFK_THOUGHTS.length)];
  }

  if (stats && stats.energy < 30) {
    return LOW_ENERGY_THOUGHTS[Math.floor(Math.random() * LOW_ENERGY_THOUGHTS.length)];
  }

  if (stats && stats.happiness < 30) {
    return LOW_HAPPINESS_THOUGHTS[Math.floor(Math.random() * LOW_HAPPINESS_THOUGHTS.length)];
  }

  if (status === 'running' && mode === 'work') {
    return FOCUS_THOUGHTS[Math.floor(Math.random() * FOCUS_THOUGHTS.length)];
  }

  return IDLE_THOUGHTS[Math.floor(Math.random() * IDLE_THOUGHTS.length)];
}
