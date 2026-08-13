import { create } from 'zustand';
import { db, initPetStats } from '../db/kronosDb';

export type TimerMode = 'work' | 'shortBreak' | 'longBreak';
export type TimerStatus = 'idle' | 'running' | 'paused';

interface TimerSettings {
  workDuration: number; // in seconds (default 25 * 60)
  shortBreakDuration: number; // in seconds (default 5 * 60)
  longBreakDuration: number; // in seconds (default 15 * 60)
  autoStartBreaks: boolean;
  autoStartWork: boolean;
}

interface TimerState {
  mode: TimerMode;
  status: TimerStatus;
  timeLeft: number; // in seconds
  sessionStartTime: string | null;
  completedSessions: number;
  activeTaskName: string;
  activeCategory: string;
  settings: TimerSettings;

  // Actions
  startTimer: () => void;
  pauseTimer: () => void;
  resetTimer: () => void;
  skipPhase: (isManualSkip?: boolean) => void;
  tick: () => void;
  setTaskInfo: (taskName: string, category: string) => void;
  updateSettings: (newSettings: Partial<TimerSettings>) => void;
}

const DEFAULT_SETTINGS: TimerSettings = {
  workDuration: 25 * 60,
  shortBreakDuration: 5 * 60,
  longBreakDuration: 15 * 60,
  autoStartBreaks: false,
  autoStartWork: false,
};

export const useTimerStore = create<TimerState>((set, get) => ({
  mode: 'work',
  status: 'idle',
  timeLeft: DEFAULT_SETTINGS.workDuration,
  sessionStartTime: null,
  completedSessions: 0,
  activeTaskName: 'General Work',
  activeCategory: 'Development',
  settings: DEFAULT_SETTINGS,

  startTimer: () => {
    const { sessionStartTime } = get();
    set({
      status: 'running',
      sessionStartTime: sessionStartTime || new Date().toISOString(),
    });
  },

  pauseTimer: () => set({ status: 'paused' }),

  resetTimer: () => {
    const { mode, settings } = get();
    let duration = settings.workDuration;
    if (mode === 'shortBreak') duration = settings.shortBreakDuration;
    if (mode === 'longBreak') duration = settings.longBreakDuration;

    set({
      status: 'idle',
      timeLeft: duration,
      sessionStartTime: null,
    });
  },

  skipPhase: (isManualSkip = false) => {
    const { mode, completedSessions, settings, sessionStartTime, activeTaskName, activeCategory, timeLeft } = get();
    const now = new Date();

    if (mode === 'work') {
      // 1. Calculate Actual Elapsed Time
      let elapsedSeconds = 0;
      if (!isManualSkip) {
        // Natural timer completion -> full work duration
        elapsedSeconds = settings.workDuration;
      } else if (sessionStartTime) {
        // Manual skip with recorded session start time
        elapsedSeconds = Math.max(0, Math.floor((now.getTime() - new Date(sessionStartTime).getTime()) / 1000));
      } else {
        // Fallback manual skip calculation
        elapsedSeconds = Math.max(0, settings.workDuration - timeLeft);
      }

      const elapsedMinutes = Math.floor(elapsedSeconds / 60);

      // 2. Minimum 1-Minute Threshold for DTR Logging & Rewards
      if (elapsedMinutes >= 1) {
        const completionRatio = Math.min(1, elapsedSeconds / settings.workDuration);
        const coinsEarned = Math.round(completionRatio * 100);
        const expEarned = Math.round(completionRatio * 50);

        // Format DateKey in Local Timezone (YYYY-MM-DD)
        const dateKey = now.toLocaleDateString('en-CA');

        // Auto-Log DTR Session into Dexie IndexedDB
        db.dtrSessions.add({
          taskName: activeTaskName,
          category: activeCategory,
          startTime: sessionStartTime || new Date(now.getTime() - elapsedSeconds * 1000).toISOString(),
          endTime: now.toISOString(),
          durationMinutes: elapsedMinutes,
          status: isManualSkip ? 'skipped' : 'completed',
          coinsEarned,
          expEarned,
          dateKey,
        }).catch(() => {});

        // Update Pet Stats (Coins & EXP)
        initPetStats().then((pet) => {
          const nextExp = pet.exp + expEarned;
          const levelUp = nextExp >= pet.level * 100;
          db.petStats.put({
            ...pet,
            coins: pet.coins + coinsEarned,
            exp: levelUp ? nextExp - pet.level * 100 : nextExp,
            level: levelUp ? pet.level + 1 : pet.level,
            lastUpdated: now.toISOString(),
          });
        }).catch(() => {});
      }

      // 3. Phase Transition logic
      const nextSessions = completedSessions + 1;
      const isLongBreak = nextSessions % 4 === 0;
      const nextMode: TimerMode = isLongBreak ? 'longBreak' : 'shortBreak';
      const nextDuration = isLongBreak ? settings.longBreakDuration : settings.shortBreakDuration;

      set({
        mode: nextMode,
        status: settings.autoStartBreaks ? 'running' : 'idle',
        timeLeft: nextDuration,
        completedSessions: nextSessions,
        sessionStartTime: null,
      });
    } else {
      // Transitioning from Break back to Work
      set({
        mode: 'work',
        status: settings.autoStartWork ? 'running' : 'idle',
        timeLeft: settings.workDuration,
        sessionStartTime: null,
      });
    }
  },

  tick: () => {
    const { timeLeft, status } = get();
    if (status !== 'running') return;

    if (timeLeft > 1) {
      set({ timeLeft: timeLeft - 1 });
    } else {
      get().skipPhase(false); // Natural completion
    }
  },

  setTaskInfo: (taskName: string, category: string) =>
    set({ activeTaskName: taskName, activeCategory: category }),

  updateSettings: (newSettings: Partial<TimerSettings>) => {
    const { settings, status, mode } = get();
    const updated = { ...settings, ...newSettings };
    set({ settings: updated });

    if (status === 'idle') {
      let duration = updated.workDuration;
      if (mode === 'shortBreak') duration = updated.shortBreakDuration;
      if (mode === 'longBreak') duration = updated.longBreakDuration;
      set({ timeLeft: duration });
    }
  },
}));
