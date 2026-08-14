import { contextBridge, ipcRenderer } from 'electron';

export interface KronosElectronAPI {
  minimizeWidget: () => void;
  closeWidget: () => void;
  openWidget: () => void;
  openDashboard: () => void;
  closeDashboard: () => void;
  toggleAlwaysOnTop: (flag?: boolean) => Promise<boolean>;
  pinWidget: (flag?: boolean) => Promise<boolean>;
  togglePin: (flag?: boolean) => Promise<boolean>;
  getPinState: () => Promise<boolean>;
  onTimerAction: (callback: (action: string) => void) => void;
}

const kronosAPI: KronosElectronAPI = {
  minimizeWidget: () => ipcRenderer.send('widget-minimize'),
  closeWidget: () => ipcRenderer.send('widget-close'),
  openWidget: () => ipcRenderer.send('widget-open'),
  openDashboard: () => ipcRenderer.send('dashboard-open'),
  closeDashboard: () => ipcRenderer.send('widget-open'),
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
