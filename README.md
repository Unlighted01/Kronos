<div align="center">

# 🐾 KRONOS
### *Cozy Pixel-Art Pomodoro Desktop Widget & Tamagotchi Workspace*

[![Godot Engine](https://img.shields.io/badge/Godot_Engine-4.3+-478cbf?style=for-the-badge&logo=godotengine&logoColor=white)](https://godotengine.org/)
[![GDScript](https://img.shields.io/badge/GDScript-4.x-478cbf?style=for-the-badge&logo=godotengine&logoColor=white)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
[![SQLite](https://img.shields.io/badge/SQLite-Local_DB-003B57?style=for-the-badge&logo=sqlite&logoColor=white)](https://sqlite.org/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

<br />

**Kronos** is a lightweight, frameless desktop productivity widget for deep-work focus and retro game enthusiasts. It blends a **Pomodoro focus timer** and **Daily Time Record (DTR) tracker** with an autonomous **2D pixel-art companion**, interactive multi-room house, and local item economy.

Built with **Godot Engine 4 (Forward+ / GL Compatibility)** in `kronos-godot/`.

---

</div>

## ✨ Key Features

### 🐾 1. Interactive 2D Pixel Pet & Tamagotchi Companion
* **Expressive Pixel Art Sprites**: Cat companion with animated tail wagging, ear twitches, blinking eyes, and blush cheeks.
* **Autonomous Room Wandering**: Companion independently roams connected rooms based on house topology or stays with you during focus sessions.
* **Instant Summon HUD**: Call your companion to your current room anytime with a single click.
* **Non-Repetitive AI Behavior Engine**: Procedurally cycles through realistic focus and break states:
  * 💻 **Deep Focus**: Typing on mini laptop with glowing screen reflection.
  * 🍵 **Warm Drink Break**: Sipping warm tea/coffee with animated steam particles.
  * 💤 **Napping**: Curled up peacefully with floating 'z' bubbles.
  * 💖 **Click-to-Pet**: Interactive petting generates floating heart bursts and boosts pet happiness and Joy stats in real-time.

---

### 🏠 2. Cozy Multi-Room House & Biomes
Navigate between rooms using interactive pixel-art doors and rustic ladders rendered on a fixed **240×140 virtual canvas** with smooth transitions:

* 🛏️ **Study Bedroom**: Indigo diamond wallpaper, patchwork quilt bed, sunset painting, oak workstation desk, and real-time day/night cycle sky.
* 🛋️ **Living Room Lounge**: Crackling brick fireplace with animated embers, cozy sofa, floor lamp, and wall-mounted Attic Ladder.
* 📚 **Attic Library**: Warm timber rafters, gold-trimmed bookshelves, reading armchair, and floor trapdoor leading downstairs.
* 🥐 **Bakery Kitchen**: Red brick hearth, espresso machine, hanging copper cookware, and pastry display counter.
* 🌿 **Sunlit Greenhouse**: Glass atrium ceiling with sunbeams, potted monsteras, hanging ivy vines, and sprouting seedlings.
* ☀️ **Real-Time Day/Night Cycle**: Window skies automatically shift between Dawn, Noon, Golden Sunset, and Starry Night based on system clock.

---

### 🖥️ 3. Single-Window 3-Panel Workspace
A frameless, transparent desktop widget that collapses and expands smoothly:

```
┌─────────────────────────┬─────────────────────────┬─────────────────────────┐
│       LEFT PANEL        │      MIDDLE PANEL       │       RIGHT PANEL       │
│         (220px)         │         (240px)         │         (200px)         │
├─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ 🛍️ SHOP & SETTINGS      │ 🐾 PET PLATFORM & TIMER │ 📊 VITALS, BAG & DTR    │
│ - Tab 1: Treats & Snacks│ - 100% Uncovered Pet    │ - Tab 1: Pet Vitals     │
│ - Tab 2: Cosmetics      │ - Digital Clock Timer   │ - Tab 2: Inventory Bag  │
│ - Tab 3: Decor Catalog  │ - Floating Action Dock  │ - Tab 3: DTR Focus Logs │
│ - Tab 4: Config/Timers  │ - Dynamic HUD Status    │   (Filter & CSV Export) │
└─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

* **Window Scale Presets**: Instantly cycle between `1x`, `1.25x`, and `1.5x` dimensions with crisp pixel-art scaling.
* **Always-on-Top & Dragging**: Frameless titlebar dragging and pinning toggle.
* **Independent Panel Collapsing**: `◀` (Left) and `▶` (Right) buttons collapse side drawers while keeping the center widget anchored.

---

### ⏱️ 4. Pomodoro Timer & Daily Time Records (DTR)
* **Configurable Intervals**: Focus (25m), Short Break (5m), and Long Rest (15m) phases with retro sound chimes.
* **Economy & EXP System**: Completing focus sessions rewards Coins and Pet EXP to level up your companion.
* **Local Data Persistence**: Saves pet stats, inventory items, and session history locally in user data storage.
* **CSV Export**: 1-click export of focus history for daily time recording and productivity tracking.

---

## 🛠️ Project Structure

```
kronos/
├── docs/                        # Design documentation & asset reviews
├── kronos-godot/                # Godot 4 Native Engine Project
│   ├── assets/                  # Pixel-art audio, fonts, and sprite assets
│   ├── scenes/
│   │   ├── main/                # MainWorkspace & WindowController
│   │   ├── panels/              # LeftPanel (Shop/Config), RightPanel (Vitals/Bag/DTR)
│   │   ├── pet/                 # PetBrain, procedural sprite renderers, cosmetics
│   │   └── rooms/               # BaseRoom, Bedroom, LivingRoom, Library, Kitchen, Greenhouse
│   ├── scripts/
│   │   └── autoload/            # EventBus, GameState, TimerEngine, DatabaseManager
│   ├── themes/                  # Custom retro dark pixel UI theme
│   └── project.godot            # Engine settings & autoload configuration
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
* [Godot Engine 4.3+ (or 4.4 / 4.7)](https://godotengine.org/download/) — Standard (GDScript) version.

### Running the Project

1. Open **Godot Engine**.
2. Click **Import** and select the [`kronos-godot/project.godot`](file:///c:/Users/netne/Kronos/Kronos%20Project/kronos-godot/project.godot) file.
3. Click **Import & Edit**.
4. Press **F5** (or click the Play button in the top right) to launch Kronos!

## 📄 License
This project is open-source under the [MIT License](LICENSE).

