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
let isWidgetPinned = false; // Default unpinned on boot

const VITE_DEV_SERVER_URL = process.env.VITE_DEV_SERVER_URL;

const ALLOWED_PRESETS = new Set<string>(["1x", "1.25x", "1.5x"]);
type PresetSize = "1x" | "1.25x" | "1.5x";

function isValidPreset(preset: unknown): preset is PresetSize {
    return typeof preset === "string" && ALLOWED_PRESETS.has(preset);
}

function validateNavigationUrl(navigationUrl: string): boolean {
    if (VITE_DEV_SERVER_URL) {
        try {
            const allowedOrigin = new URL(VITE_DEV_SERVER_URL).origin;
            const targetOrigin = new URL(navigationUrl).origin;
            return targetOrigin === allowedOrigin;
        } catch {
            return false;
        }
    }
    return navigationUrl.startsWith("file://");
}

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
        widgetWindow.show();
        widgetWindow.focus();
        return;
    }

    widgetWindow = new BrowserWindow({
        width: 260,
        height: 320,
        minWidth: 220,
        minHeight: 220,
        resizable: true,
        frame: false,
        backgroundColor: "#0b0f19",
        alwaysOnTop: false,
        hasShadow: true,
        skipTaskbar: false,
        webPreferences: {
            preload: path.join(__dirname, "preload.cjs"),
            contextIsolation: true,
            nodeIntegration: false,
            sandbox: true,
            webSecurity: true,
            allowRunningInsecureContent: false,
            navigateOnDragDrop: false,
        },
    });

    applyPinAndLockState(widgetWindow, isWidgetPinned);

    // --- Windows OS Z-Order Resilience Handlers ---
    const reassertTopmost = () => {
        if (widgetWindow && isWidgetPinned) {
            widgetWindow.setAlwaysOnTop(true, "screen-saver");
        }
    };

    widgetWindow.on("restore", reassertTopmost);
    widgetWindow.on("show", reassertTopmost);

    if (VITE_DEV_SERVER_URL) {
        widgetWindow.loadURL(VITE_DEV_SERVER_URL);
    } else {
        widgetWindow.loadFile(path.join(__dirname, "../dist/index.html"));
    }

    widgetWindow.on("closed", () => {
        widgetWindow = null;
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
            label: "Show Kronos Workspace",
            click: () => {
                if (widgetWindow) {
                    widgetWindow.show();
                    widgetWindow.focus();
                } else {
                    createWidgetWindow();
                }
            },
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
        } else {
            createWidgetWindow();
        }
    });
}

// Global WebContents Security Handlers
app.on("web-contents-created", (_event, contents) => {
    contents.on("will-navigate", (navEvent, navigationUrl) => {
        if (!validateNavigationUrl(navigationUrl)) {
            navEvent.preventDefault();
        }
    });

    contents.setWindowOpenHandler(() => {
        return { action: "deny" };
    });

    contents.on("will-attach-webview", (attachEvent) => {
        attachEvent.preventDefault();
    });
});

// IPC Handlers
ipcMain.on("widget-minimize", () => {
    widgetWindow?.minimize();
});

ipcMain.on("widget-close", () => {
    app.quit();
});

// Single Window Dynamic Panel Layout Resizer (Switched: Left Shop/DTR 240px, Right Vitals/Settings 220px)
ipcMain.on("widget-update-panel-layout", (_event, layout: { leftOpen: boolean; rightOpen: boolean; scale: '1x' | '1.25x' | '1.5x' }) => {
    if (!widgetWindow) return;

    const baseMiddleWidth = layout.scale === "1.5x" ? 390 : layout.scale === "1.25x" ? 325 : 260;
    const baseHeight = layout.scale === "1.5x" ? 480 : layout.scale === "1.25x" ? 400 : 320;

    const leftWidth = layout.leftOpen ? 240 : 0;
    const rightWidth = layout.rightOpen ? 220 : 0;
    const totalWidth = leftWidth + baseMiddleWidth + rightWidth;

    const currentBounds = widgetWindow.getBounds();
    widgetWindow.setBounds(
        {
            x: currentBounds.x,
            y: currentBounds.y,
            width: totalWidth,
            height: baseHeight,
        },
        false
    );
});

ipcMain.on("widget-set-preset-size", (_event, preset: unknown) => {
    if (!widgetWindow || !isValidPreset(preset)) return;

    if (preset === "1x") {
        widgetWindow.setSize(260, 320);
    } else if (preset === "1.25x") {
        widgetWindow.setSize(325, 400);
    } else if (preset === "1.5x") {
        widgetWindow.setSize(390, 480);
    }
});

ipcMain.handle("widget-toggle-always-on-top", (_event, flag?: unknown) => {
    if (!widgetWindow) return false;

    if (typeof flag === "boolean") {
        isWidgetPinned = flag;
    } else {
        isWidgetPinned = !isWidgetPinned;
    }

    applyPinAndLockState(widgetWindow, isWidgetPinned);
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
