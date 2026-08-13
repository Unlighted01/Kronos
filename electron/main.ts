import { app, BrowserWindow, ipcMain, Tray, Menu, nativeImage } from "electron";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Memory Optimization Flags
app.commandLine.appendSwitch("max-old-space-size", "64");
app.commandLine.appendSwitch("disable-background-timer-throttling");

let widgetWindow: BrowserWindow | null = null;
let dashboardWindow: BrowserWindow | null = null;
let tray: Tray | null = null;

const VITE_DEV_SERVER_URL = process.env.VITE_DEV_SERVER_URL;
const isDev = !!VITE_DEV_SERVER_URL || !app.isPackaged;

function createWidgetWindow(): void {
    if (widgetWindow) {
        widgetWindow.focus();
        return;
    }

    widgetWindow = new BrowserWindow({
        width: 260,
        height: 320,
        resizable: false,
        frame: false,
        transparent: true,
        alwaysOnTop: true,
        skipTaskbar: false,
        hasShadow: true,
        webPreferences: {
            preload: path.join(__dirname, "preload.cjs"),
            nodeIntegration: false,
            contextIsolation: true,
        },
    });

    if (VITE_DEV_SERVER_URL) {
        widgetWindow.loadURL(`${VITE_DEV_SERVER_URL}#widget`);
        // Auto-open DevTools in detached window when in dev mode
        if (isDev) {
            widgetWindow.webContents.openDevTools({ mode: 'detach' });
        }
    } else {
        widgetWindow.loadFile(path.join(__dirname, "../dist/index.html"), {
            hash: "widget",
        });
    }

    widgetWindow.on("closed", () => {
        widgetWindow = null;
    });
}

function createDashboardWindow(): void {
    if (dashboardWindow) {
        dashboardWindow.show();
        dashboardWindow.focus();
        return;
    }

    dashboardWindow = new BrowserWindow({
        width: 1040,
        height: 720,
        minWidth: 800,
        minHeight: 600,
        frame: true,
        title: "Kronos - Tamagotchi Pomodoro & DTR Dashboard",
        webPreferences: {
            preload: path.join(__dirname, "preload.cjs"),
            nodeIntegration: false,
            contextIsolation: true,
        },
    });

    if (VITE_DEV_SERVER_URL) {
        dashboardWindow.loadURL(`${VITE_DEV_SERVER_URL}#dashboard`);
        // Auto-open DevTools in dev mode
        if (isDev) {
            dashboardWindow.webContents.openDevTools({ mode: 'detach' });
        }
    } else {
        dashboardWindow.loadFile(path.join(__dirname, "../dist/index.html"), {
            hash: "dashboard",
        });
    }

    // Destroy dashboard on close to free memory!
    dashboardWindow.on("closed", () => {
        dashboardWindow = null;
    });
}

function createSystemTray(): void {
    // Simple 16x16 canvas icon fallback or native image
    const svgIcon = `
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="#6366f1">
      <circle cx="12" cy="12" r="10" />
      <path d="M12 6v6l4 2" stroke="#ffffff" stroke-width="2" stroke-linecap="round" />
    </svg>
  `;
    const iconBuffer = Buffer.from(svgIcon);
    const icon = nativeImage.createFromBuffer(iconBuffer);

    tray = new Tray(icon);
    tray.setToolTip("Kronos Tamagotchi Pomodoro");

    const contextMenu = Menu.buildFromTemplate([
        {
            label: "Kronos Widget",
            click: () => {
                if (widgetWindow) {
                    widgetWindow.show();
                    widgetWindow.focus();
                } else {
                    createWidgetWindow();
                }
            },
        },
        {
            label: "Open Full Dashboard (DTR & Shop)",
            click: () => createDashboardWindow(),
        },
        { type: "separator" },
        {
            label: "Start / Pause Timer",
            click: () => {
                widgetWindow?.webContents.send("timer-action", "toggle");
            },
        },
        {
            label: "Reset Timer",
            click: () => {
                widgetWindow?.webContents.send("timer-action", "reset");
            },
        },
        { type: "separator" },
        {
            label: "Quit Kronos",
            click: () => {
                app.quit();
            },
        },
    ]);

    tray.setContextMenu(contextMenu);
    tray.on("double-click", () => {
        if (widgetWindow) {
            widgetWindow.show();
            widgetWindow.focus();
        }
    });
}

// Setup IPC listeners
ipcMain.on("widget-minimize", () => {
    widgetWindow?.minimize();
});

ipcMain.on("widget-close", () => {
    // Quits application on widget X click as expected
    app.quit();
});

ipcMain.on("dashboard-open", () => {
    createDashboardWindow();
});

ipcMain.on("dashboard-close", () => {
    dashboardWindow?.close();
});

ipcMain.handle("widget-toggle-always-on-top", (_event, flag?: boolean) => {
    if (!widgetWindow) return false;
    const current = widgetWindow.isAlwaysOnTop();
    const nextState = flag !== undefined ? flag : !current;
    widgetWindow.setAlwaysOnTop(nextState);
    return nextState;
});

app.whenReady().then(() => {
    createWidgetWindow();
    createSystemTray();

    app.on("activate", () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWidgetWindow();
        }
    });
});

app.on("window-all-closed", () => {
    if (process.platform !== "darwin") {
        app.quit();
    }
});
