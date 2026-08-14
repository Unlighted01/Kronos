import { contextBridge, ipcRenderer } from 'electron';

export interface KronosElectronAPI {
  minimizeWidget: () => void;
  closeWidget: () => void;
  setPresetSize: (preset: '1x' | '1.25x' | '1.5x') => void;
  updatePanelLayout: (layout: { leftOpen: boolean; rightOpen: boolean; scale: '1x' | '1.25x' | '1.5x' }) => void;
  toggleAlwaysOnTop: (flag?: boolean) => Promise<boolean>;
  pinWidget: (flag?: boolean) => Promise<boolean>;
  togglePin: (flag?: boolean) => Promise<boolean>;
  getPinState: () => Promise<boolean>;
  onTimerAction: (callback: (action: string) => void) => void;
}

const kronosAPI: KronosElectronAPI = {
  minimizeWidget: () => ipcRenderer.send('widget-minimize'),
  closeWidget: () => ipcRenderer.send('widget-close'),
  setPresetSize: (preset: '1x' | '1.25x' | '1.5x') => ipcRenderer.send('widget-set-preset-size', preset),
  updatePanelLayout: (layout: { leftOpen: boolean; rightOpen: boolean; scale: '1x' | '1.25x' | '1.5x' }) =>
    ipcRenderer.send('widget-update-panel-layout', layout),
  toggleAlwaysOnTop: (flag?: boolean) => ipcRenderer.invoke('widget-toggle-always-on-top', flag),
  pinWidget: (flag?: boolean) => ipcRenderer.invoke('widget-toggle-always-on-top', flag),
  togglePin: (flag?: boolean) => ipcRenderer.invoke('widget-toggle-always-on-top', flag),
  getPinState: () => ipcRenderer.invoke('widget-get-pin-state'),
  onTimerAction: (callback: (action: string) => void) => {
    ipcRenderer.on('timer-action', (_event, action) => callback(action));
  },
};

contextBridge.exposeInMainWorld('kronosElectron', kronosAPI);

declare global {
  interface Window {
    kronosElectron?: KronosElectronAPI;
  }
}
