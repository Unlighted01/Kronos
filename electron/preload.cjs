const { contextBridge, ipcRenderer } = require('electron');

const kronosAPI = {
  minimizeWidget: () => ipcRenderer.send('widget-minimize'),
  closeWidget: () => ipcRenderer.send('widget-close'),
  openDashboard: () => ipcRenderer.send('dashboard-open'),
  closeDashboard: () => ipcRenderer.send('dashboard-close'),
  toggleAlwaysOnTop: (flag) => ipcRenderer.invoke('widget-toggle-always-on-top', flag),
  onTimerAction: (callback) => {
    ipcRenderer.on('timer-action', (_event, action) => callback(action));
  },
};

contextBridge.exposeInMainWorld('kronosElectron', kronosAPI);
