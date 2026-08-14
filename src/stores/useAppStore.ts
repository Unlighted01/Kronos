import { create } from 'zustand';

export type WindowMode = 'widget' | 'dashboard';

interface AppState {
  windowMode: WindowMode;
  alwaysOnTop: boolean;
  setWindowMode: (mode: WindowMode) => void;
  setAlwaysOnTop: (alwaysOnTop: boolean) => void;
}

export const useAppStore = create<AppState>((set) => ({
  windowMode: 'widget',
  alwaysOnTop: false, // Default unpinned on boot
  setWindowMode: (mode: WindowMode) => set({ windowMode: mode }),
  setAlwaysOnTop: (alwaysOnTop: boolean) => set({ alwaysOnTop }),
}));
