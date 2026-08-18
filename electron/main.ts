import { app, BrowserWindow, ipcMain, Tray, Menu, nativeImage, screen } from "electron";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Memory Optimization Flags
app.commandLine.appendSwitch("max-old-space-size", "64");
app.commandLine.appendSwitch("disable-background-timer-throttling");

let widgetWindow: BrowserWindow | null = null;
let tray: Tray | null = null;
let isWidgetPinned = false;

const VITE_DEV_SERVER_URL = process.env.VITE_DEV_SERVER_URL;

const ALLOWED_PRESETS = new Set<string>(["1x", "1.25x", "1.5x"]);
type PresetSize = "1x" | "1.25x" | "1.5x";

/**
 * Exact fixed dimensions for each preset.
 * Widget height = 36px header + 20px HUD banner + canvas_height + 4px border + 80px timer dock + 8px padding.
 * Canvas sizes: 1x=240x140, 1.25x=300x175, 1.5x=360x210.
 */
const PRESET_DIMS: Record<PresetSize, { w: number; h: number; leftW: number; rightW: number }> = {
    "1x":    { w: 240, h: 288, leftW: 220, rightW: 200 },
    "1.25x": { w: 300, h: 330, leftW: 255, rightW: 230 },
    "1.5x":  { w: 360, h: 372, leftW: 290, rightW: 260 },
};

let lastLayout = { leftOpen: false, rightOpen: false, scale: "1x" as PresetSize };

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
        win.setMovable(false);
    } else {
        win.setAlwaysOnTop(false, "normal");
        win.setMovable(true);
    }
}

function createWidgetWindow(): void {
    if (widgetWindow) {
        widgetWindow.show();
        widgetWindow.focus();
        return;
    }

    const initial = PRESET_DIMS["1x"];

    widgetWindow = new BrowserWindow({
        width: initial.w,
        height: initial.h,
        resizable: false,   // Sizes controlled only via presets
        frame: false,
        backgroundColor: "#07080f",
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
            click: () => { widgetWindow?.webContents.send("timer-action", "toggle"); },
        },
        {
            label: "Reset Timer",
            click: () => { widgetWindow?.webContents.send("timer-action", "reset"); },
        },
        { type: "separator" },
        {
            label: "Quit Kronos",
            click: () => { app.quit(); },
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
    contents.setWindowOpenHandler(() => ({ action: "deny" }));
    contents.on("will-attach-webview", (attachEvent) => { attachEvent.preventDefault(); });
});

// IPC Handlers
ipcMain.on("widget-minimize", () => { widgetWindow?.minimize(); });
ipcMain.on("widget-close", () => { app.quit(); });

/**
 * Panel layout IPC: adjusts total window width and clamps to screen bounds.
 * Also anchors leftward when Left Panel is toggled.
 */
ipcMain.on("widget-update-panel-layout", (_event, layout: { leftOpen: boolean; rightOpen: boolean; scale: string }) => {
    if (!widgetWindow) return;
    const preset = isValidPreset(layout.scale) ? layout.scale : "1x";
    const dims = PRESET_DIMS[preset];
    const totalW = dims.w
        + (layout.leftOpen ? dims.leftW : 0)
        + (layout.rightOpen ? dims.rightW : 0);

    const currentBounds = widgetWindow.getBounds();
    const display = screen.getDisplayMatching(currentBounds);
    const workArea = display.workArea;

    let targetX = currentBounds.x;
    let targetY = currentBounds.y;

    // Anchor: If left panel opened, shift X leftward so the middle widget stays in place
    if (layout.leftOpen && !lastLayout.leftOpen) {
        targetX -= dims.leftW;
    } else if (!layout.leftOpen && lastLayout.leftOpen) {
        targetX += dims.leftW;
    }

    // Screen Bounds Clamping: ensure window never extends beyond monitor edges
    if (targetX + totalW > workArea.x + workArea.width) {
        targetX = workArea.x + workArea.width - totalW;
    }
    if (targetX < workArea.x) {
        targetX = workArea.x;
    }

    if (targetY + dims.h > workArea.y + workArea.height) {
        targetY = workArea.y + workArea.height - dims.h;
    }
    if (targetY < workArea.y) {
        targetY = workArea.y;
    }

    lastLayout = {
        leftOpen: layout.leftOpen,
        rightOpen: layout.rightOpen,
        scale: preset,
    };

    widgetWindow.setBounds({
        x: Math.round(targetX),
        y: Math.round(targetY),
        width: totalW,
        height: dims.h,
    }, false);
});

/**
 * Preset size IPC: locks window to exact size for the preset and clamps within screen.
 */
ipcMain.on("widget-set-preset-size", (_event, preset: unknown) => {
    if (!widgetWindow || !isValidPreset(preset)) return;
    const dims = PRESET_DIMS[preset];
    const totalW = dims.w
        + (lastLayout.leftOpen ? dims.leftW : 0)
        + (lastLayout.rightOpen ? dims.rightW : 0);

    const currentBounds = widgetWindow.getBounds();
    const display = screen.getDisplayMatching(currentBounds);
    const workArea = display.workArea;

    let targetX = currentBounds.x;
    let targetY = currentBounds.y;

    if (targetX + totalW > workArea.x + workArea.width) {
        targetX = workArea.x + workArea.width - totalW;
    }
    if (targetX < workArea.x) {
        targetX = workArea.x;
    }

    if (targetY + dims.h > workArea.y + workArea.height) {
        targetY = workArea.y + workArea.height - dims.h;
    }
    if (targetY < workArea.y) {
        targetY = workArea.y;
    }

    lastLayout.scale = preset;

    widgetWindow.setBounds({
        x: Math.round(targetX),
        y: Math.round(targetY),
        width: totalW,
        height: dims.h,
    }, false);
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

ipcMain.handle("widget-get-pin-state", () => isWidgetPinned);

app.whenReady().then(() => {
    createWidgetWindow();
    createSystemTray();
    app.on("activate", () => {
        if (BrowserWindow.getAllWindows().length === 0) createWidgetWindow();
    });
});

app.on("window-all-closed", () => {
    if (process.platform !== "darwin") app.quit();
});
