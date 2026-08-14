import { app, BrowserWindow, ipcMain, Tray, Menu, nativeImage } from "electron";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Memory Optimization Flags
app.commandLine.appendSwitch("max-old-space-size", "64");
app.commandLine.appendSwitch("disable-background-timer-throttling");

let widgetWindow: BrowserWindow | null = null;
let tray: Tray | null = null;
let isWidgetPinned = false; // Default unpinned on boot as requested

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
        alwaysOnTop: false, // Default unpinned on boot
        hasShadow: false,
        skipTaskbar: false,
        webPreferences: {
            preload: path.join(__dirname, "preload.cjs"),
            nodeIntegration: false,
            contextIsolation: true,
        },
    });

    // Apply initial unpinned & movable state
    applyPinAndLockState(widgetWindow, isWidgetPinned);

    // --- Windows OS Z-Order Resilience Handlers ---
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

function openDashboardInSingleWindow(): void {
    if (!widgetWindow) {
        createWidgetWindow();
        return;
    }

    // Expand existing widget window into full dashboard view
    widgetWindow.setResizable(true);
    widgetWindow.setMovable(true);
    widgetWindow.setAlwaysOnTop(false, "normal");
    widgetWindow.setSize(1040, 720);
    widgetWindow.center();

    if (VITE_DEV_SERVER_URL) {
        widgetWindow.loadURL(`${VITE_DEV_SERVER_URL}#dashboard`);
    } else {
        widgetWindow.loadFile(path.join(__dirname, "../dist/index.html"), {
            hash: "dashboard",
        });
    }
}

function openWidgetInSingleWindow(): void {
    if (!widgetWindow) {
        createWidgetWindow();
        return;
    }

    // Shrink window back to compact widget overlay
    widgetWindow.setSize(260, 320);
    widgetWindow.setResizable(false);
    applyPinAndLockState(widgetWindow, isWidgetPinned);

    if (VITE_DEV_SERVER_URL) {
        widgetWindow.loadURL(`${VITE_DEV_SERVER_URL}#widget`);
    } else {
        widgetWindow.loadFile(path.join(__dirname, "../dist/index.html"), {
            hash: "widget",
        });
    }
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
                openWidgetInSingleWindow();
            },
        },
        {
            label: "Open Full Dashboard (DTR & Shop)",
            click: () => openDashboardInSingleWindow(),
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
        openWidgetInSingleWindow();
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
    openDashboardInSingleWindow();
});

ipcMain.on("widget-open", () => {
    openWidgetInSingleWindow();
});

ipcMain.on("dashboard-close", () => {
    openWidgetInSingleWindow();
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
