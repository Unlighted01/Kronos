<div align="center">

# 🐾 KRONOS
### *Cozy Pixel-Art Pomodoro Desktop Widget & Tamagotchi Workspace*

[![React](https://img.shields.io/badge/React-19-61dafb?style=for-the-badge&logo=react)](https://react.dev/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0-3178c6?style=for-the-badge&logo=typescript)](https://www.typescriptlang.org/)
[![Electron](https://img.shields.io/badge/Electron-30.0-47848f?style=for-the-badge&logo=electron)](https://www.electronjs.org/)
[![Tailwind CSS v4](https://img.shields.io/badge/Tailwind_CSS-v4.0-38bdf8?style=for-the-badge&logo=tailwindcss)](https://tailwindcss.com/)
[![Vite](https://img.shields.io/badge/Vite-6.0-646cff?style=for-the-badge&logo=vite)](https://vitejs.dev/)
[![Dexie.js](https://img.shields.io/badge/Dexie.js-v4.0-ff6b6b?style=for-the-badge)](https://dexie.org/)

<br />

**Kronos** is a single-window desktop productivity application designed for developers and deep-work enthusiasts. It blends an ergonomic **Pomodoro timer** and **Daily Time Record (DTR) tracker** with a responsive **2D pixel-art Tamagotchi companion** and cozy interactive environments.

---

</div>

## ✨ Key Features

### 🐾 1. Interactive 2D Pixel Pet & Tamagotchi Companion
* **Expressive Pixel Art Sprites**: Cat/creature anatomy with shaded ears, specular eye highlights, wagging tail physics, and rosy blush cheeks.
* **Non-Repetitive AI Behavior Engine**: Procedurally cycles through realistic focus and break states:
  * 💻 **Deep Focus**: Typing on laptop with screen glow and animated keyboard keys.
  * 🍵 **Coffee & Matcha Break**: Sipping warm drinks with rising steam particles.
  * 🧘 **Stretches & Micro-Dances**: Celebratory bounces with music notes (`♪`).
  * 💤 **Napping**: Sleeping posture with rhythmic floating 'z' bubbles.
  * 🙈 **AFK Detection**: Hides off-screen when the user is idle.
* **Click-to-Pet**: Interactive clicking generates floating heart particle effects and boosts pet happiness and Joy stats in real-time.

---

### 🏠 2. Cozy Multi-Room House & Exterior Biomes
Seamlessly change environments via the Shop and Inventory Bag. Environments render on a fixed **240×140 virtual canvas** that scales up proportionally and crisply across window scales (**1x**, **1.25x**, and **1.5x**) without cropping or distortion:

* 🛏️ **Study Bedroom**: Indigo diamond wallpaper, patchwork quilt bed, sunset painting, succulent plant, and real-time day/night window.
* 📚 **Attic Library**: Mahogany timber rafters, gold-trimmed book collections, velvet reading armchair, and floating magic dust motes.
* 🥐 **Warm Bakery Kitchen**: Red brick hearth with flickering fire, copper cookware, espresso machine, and golden glazed pastries.
* 🌿 **Sunlit Greenhouse**: Glass atrium ceiling with sunbeams, potted variegated monsteras, hanging ivy, and sprouting seedlings.
* 🌸 **Sakura Garden**: Spring blossom tree canopy, mossy stepping stones, and 22 drifting sakura petals.
* 🔥 **Starry Campfire**: Deep space nebula with animated shooting stars, pine trees, glowing coal bed, and crackling ember motes.
* 🍂 **Autumn Maple Grove**: Multi-shade autumn trees, log bench, hot spiced cider, and swirling autumn leaves.
* ☀️ **Real-Time Day/Night Cycle**: Window skies automatically shift between Dawn, Noon, Golden Sunset, and Starry Night based on your system clock.

---

### 🖥️ 3. Single-Window 3-Panel Workspace
A unified frameless desktop layout that collapses and expands smoothly:

```
┌─────────────────────────┬─────────────────────────┬─────────────────────────┐
│       LEFT PANEL        │      MIDDLE PANEL       │       RIGHT PANEL       │
│         (240px)         │   (260px min / Scaled)  │         (220px)         │
├─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ 🛍️ SHOP & SETTINGS      │ 🐾 PET PLATFORM & TIMER │ 📊 VITALS, BAG & DTR    │
│ - Tab 1: Pet Shop       │ - 100% Uncovered Pet    │ - Tab 1: Pet Vitals     │
│ - Tab 2: Settings       │ - Digital Clock Timer   │ - Tab 2: Inventory Bag  │
│   (Scale, Pin, Timers)  │ - Floating Action Dock  │ - Tab 3: DTR Focus Logs │
└─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

* **Window Scale Presets**: Instantly switch between `1x` (Compact), `1.25x` (Standard), and `1.5x` (Expanded) dimensions.
* **Always-on-Top & Position Lock**: Pin Kronos on top of all application windows with OS-level position locking (`setMovable`).
* **Clean Single Header**: Minimalist titlebar with seamless window dragging and independent panel toggles.

---

### ⏱️ 4. Pomodoro Timer & Daily Time Records (DTR)
* **Customizable Durations**: Configurable Focus, Short Break, and Long Break intervals.
* **Automated Focus Rewards**: Completing sessions awards Coins and EXP to level up your pet.
* **Persistent DTR Logging**: Every focus session is automatically cataloged in IndexedDB with task categories, exact durations, and timestamping.
* **CSV Export**: 1-click export of focus history for daily time recording and productivity tracking.

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Runtime & Desktop Engine** | [Electron 30](https://www.electronjs.org/) | Frameless transparent window management, IPC bridge, system tray |
| **Frontend Framework** | [React 19](https://react.dev/) + [TypeScript 5](https://www.typescriptlang.org/) | Strict type safety, functional component architecture |
| **Styling & Design Tokens** | [Tailwind CSS v4](https://tailwindcss.com/) (`@tailwindcss/vite`) | Utility-first CSS, custom design tokens, dark glassmorphism surfaces |
| **Build Tooling** | [Vite 6](https://vitejs.dev/) | Lightning-fast HMR and dual Electron preload CJS compilation |
| **Local Database** | [Dexie.js 4](https://dexie.org/) (IndexedDB) | Reactive local persistence for pet stats, inventory, and DTR logs |
| **State Management** | [Zustand](https://zustand-demo.pmnd.rs/) | Global timer and window layout store |
| **Audio Synthesizer** | Web Audio API | Procedural retro chime, click, and victory sound effects |

---

## 🚀 Getting Started

### Prerequisites
* [Node.js](https://nodejs.org/) (v18.0.0 or higher recommended)
* [npm](https://www.npmjs.com/) (v9.0.0 or higher)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Unlighted01/Kronos.git
   cd Kronos/"Kronos Project"
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Run in development mode**:
   ```bash
   npm run dev
   ```

4. **Build for production**:
   ```bash
   npm run build
   ```

---

## 📂 Project Structure

```text
Kronos Project/
├── electron/
│   ├── main.ts              # Electron main process, IPC handlers & window bounds
│   └── preload.ts           # Secure ContextBridge API bindings
├── src/
│   ├── components/
│   │   ├── layout/          # ThreePanelWorkspace coordinator
│   │   ├── panels/          # LeftPanel (Shop/Settings) & RightPanel (Vitals/Bag/DTR)
│   │   ├── pet/             # PlatformerPetCanvas, renderers (Rooms, Biomes, Pet Sprites)
│   │   ├── shop/            # PetShop catalog & segmented category controls
│   │   ├── dtr/             # DtrLogSheet & CSV exporter
│   │   └── widget/          # WidgetView, digital timer readout & action dock
│   ├── db/
│   │   └── kronosDb.ts      # Dexie DB schema (PetStats, Inventory, DtrSessions)
│   ├── stores/
│   │   ├── useTimerStore.ts # Pomodoro timing state machine & DTR auto-logging
│   │   └── useAppStore.ts   # Window state & Always-on-Top persistence
│   ├── styles/
│   │   └── global.css       # Tailwind v4 import, typography & container styles
│   └── utils/
│       ├── audioSynth.ts    # Web Audio API synthesizer for UI sound effects
│       └── petDialogues.ts  # Pet speech thoughts & ambient dialogues
├── package.json
├── tsconfig.json
└── vite.config.ts           # Vite 6 + Tailwind v4 + Electron config
```

---

## 🔒 Security & Performance Standards

* **TypeScript Strict Mode**: 0 `: any` type annotations, full static type safety.
* **Electron Security Hardening**: Strict Content Security Policy (CSP), `contextIsolation: true`, `nodeIntegration: false`, `sandbox: true`, with navigation and popup event blocking.
* **Clean Lifecycle Management**: All timers, audio nodes, and animation frames use cleanup functions to prevent memory leaks.
* **Zero Production Logs**: Clean production builds with no extraneous `console.log` statements.

---

## 📄 License
This project is open source and available under the [MIT License](LICENSE).
