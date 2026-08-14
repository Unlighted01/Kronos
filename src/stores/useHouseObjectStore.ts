import { create } from 'zustand';

interface HouseObjectState {
  isDeskLampOn: boolean;
  isArcLampOn: boolean;
  isCandleLit: boolean;
  vinylSpinBoost: number;
  firePokedTimer: number;
  globeSpinBoost: number;
  clockChimeTimer: number;
  paintingTilt: number;
  plantBloomStage: number;

  toggleDeskLamp: () => void;
  toggleArcLamp: () => void;
  toggleCandle: () => void;
  boostVinyl: () => void;
  pokeFire: () => void;
  spinGlobe: () => void;
  chimeClock: () => void;
  tiltPainting: () => void;
  waterPlant: () => void;
}

export const useHouseObjectStore = create<HouseObjectState>((set) => ({
  isDeskLampOn: true,
  isArcLampOn: true,
  isCandleLit: true,
  vinylSpinBoost: 0,
  firePokedTimer: 0,
  globeSpinBoost: 0,
  clockChimeTimer: 0,
  paintingTilt: 0,
  plantBloomStage: 0,

  toggleDeskLamp: () => set((state) => ({ isDeskLampOn: !state.isDeskLampOn })),
  toggleArcLamp: () => set((state) => ({ isArcLampOn: !state.isArcLampOn })),
  toggleCandle: () => set((state) => ({ isCandleLit: !state.isCandleLit })),
  boostVinyl: () => set(() => ({ vinylSpinBoost: 100 })), // Example boost logic
  pokeFire: () => set(() => ({ firePokedTimer: 100 })),
  spinGlobe: () => set(() => ({ globeSpinBoost: 100 })),
  chimeClock: () => set(() => ({ clockChimeTimer: 100 })),
  tiltPainting: () => set((state) => ({ paintingTilt: state.paintingTilt === 0 ? 2 : 0 })),
  waterPlant: () => set((state) => ({ plantBloomStage: (state.plantBloomStage + 1) % 4 })),
}));
