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
let isWidgetPinned = true; // Default pinned state

const VITE_DEV_SERVER_URL = process.env.VITE_DEV_SERVER_URL;
const isDev = !!VITE_DEV_SERVER_URL || !app.isPackaged;

function applyPinAndLockState(win: BrowserWindow, pinned: boolean): void {
    if (pinned) {
        win.setAlwaysOnTop(true, "screen-saver");
        win.setMovable(false); // Lock spatial movement on OS level when pinned
    } else {
        win.setAlwaysOnTop(false, "normal");
        win.setMovable(true); // Allow dragging when unpinned
    }
}

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
        hasShadow: false, // Prevents DWM border shadow artifacts on transparent windows
        skipTaskbar: false,
        webPreferences: {
            preload: path.join(__dirname, "preload.cjs"),
            nodeIntegration: false,
            contextIsolation: true,
        },
    });

    // Apply initial pin & position lock
    applyPinAndLockState(widgetWindow, isWidgetPinned);

    // --- Windows OS Z-Order Resilience Handlers ---
    // Re-assert alwaysOnTop on focus/show/restore to prevent DWM from dropping HWND_TOPMOST
    const reassertTopmost = () => {
        if (widgetWindow && isWidgetPinned) {
            widgetWindow.setAlwaysOnTop(true, "screen-saver");
        }
    };

    widgetWindow.on("restore", reassertTopmost);
    widgetWindow.on("show", reassertTopmost);
    widgetWindow.on("focus", reassertTopmost);

    if (VITE_DEV_SERVER_URL) {
        widgetWindow.loadURL(`${VITE_DEV_SERVER_URL}#widget`);
        if (isDev) {
            widgetWindow.webContents.openDevTools({ mode: "detach" });
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
        if (isDev) {
            dashboardWindow.webContents.openDevTools({ mode: "detach" });
        }
    } else {
        dashboardWindow.loadFile(path.join(__dirname, "../dist/index.html"), {
            hash: "dashboard",
        });
    }

    dashboardWindow.on("closed", () => {
        dashboardWindow = null;
    });
}

function createSystemTray(): void {
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

// IPC Handlers
ipcMain.on("widget-minimize", () => {
    widgetWindow?.minimize();
});

ipcMain.on("widget-close", () => {
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
    isWidgetPinned = flag !== undefined ? flag : !isWidgetPinned;
    applyPinAndLockState(widgetWindow, isWidgetPinned);

    console.log(`[IPC] Widget Pin & Lock state set to: ${isWidgetPinned}`);
    return isWidgetPinned;
});

ipcMain.handle("widget-get-pin-state", () => {
    return isWidgetPinned;
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
