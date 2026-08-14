import { defineConfig, Plugin } from 'vite';
import react from '@vitejs/plugin-react';
import electron from 'vite-plugin-electron';
import renderer from 'vite-plugin-electron-renderer';
import path from 'path';
import fs from 'fs';

// Custom plugin to guarantee clean CommonJS preload.cjs without ESM imports/exports
function buildPreloadCjsPlugin(): Plugin {
  return {
    name: 'build-preload-cjs',
    closeBundle() {
      const outDir = path.resolve(__dirname, 'dist-electron');
      if (!fs.existsSync(outDir)) {
        fs.mkdirSync(outDir, { recursive: true });
      }
      const cjsContent = `const { contextBridge, ipcRenderer } = require('electron');

const kronosAPI = {
  minimizeWidget: () => ipcRenderer.send('widget-minimize'),
  closeWidget: () => ipcRenderer.send('widget-close'),
  openWidget: () => ipcRenderer.send('widget-open'),
  openDashboard: () => ipcRenderer.send('dashboard-open'),
  closeDashboard: () => ipcRenderer.send('widget-open'),
  toggleAlwaysOnTop: (flag) => ipcRenderer.invoke('widget-toggle-always-on-top', flag),
  pinWidget: (flag) => ipcRenderer.invoke('widget-toggle-always-on-top', flag),
  togglePin: (flag) => ipcRenderer.invoke('widget-toggle-always-on-top', flag),
  getPinState: () => ipcRenderer.invoke('widget-get-pin-state'),
  onTimerAction: (callback) => {
    ipcRenderer.on('timer-action', (_event, action) => callback(action));
  },
};

contextBridge.exposeInMainWorld('kronosElectron', kronosAPI);
`;
      fs.writeFileSync(path.join(outDir, 'preload.cjs'), cjsContent, 'utf-8');
    },
  };
}

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    electron([
      {
        // Main-process entry file of the Electron App.
        entry: 'electron/main.ts',
        onstart(options) {
          options.startup();
        },
        vite: {
          build: {
            outDir: 'dist-electron',
            rollupOptions: {
              external: ['electron'],
            },
          },
        },
      },
    ]),
    buildPreloadCjsPlugin(),
    renderer(),
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 5173,
    strictPort: true,
  },
});
