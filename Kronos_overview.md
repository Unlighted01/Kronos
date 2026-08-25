# 🐾 Kronos — Complete Feature Architecture & Overview

> **Kronos** is a lightweight, frameless desktop productivity widget and Tamagotchi companion workspace. It combines a flexible **Flowmodoro focus engine**, an **Active Recall study deck**, and a **Daily Time Record (DTR) tracker** with an autonomous **2D procedural pixel-art pet companion** living in interactive mythological biomes.

---

## 🧭 System Architecture & Interface Layout

Kronos operates as a single-window, frameless desktop widget with a fixed **240×140 virtual pixel canvas** and independent collapsible side drawers:

```
┌─────────────────────────┬─────────────────────────┬─────────────────────────┐
│       LEFT PANEL        │      MIDDLE PANEL       │       RIGHT PANEL       │
│         (220px)         │         (240px)         │         (200px)         │
├─────────────────────────┼─────────────────────────┼─────────────────────────┤
│ 🛍️ SHOP & TASKS         │ 🐾 VIRTUAL ROOM CANVAS  │ 📊 VITALS, BAG & DTR    │
│ • Treats & Snacks       │ • 100% Uncovered Pet    │ • Pet Stats & Vitals    │
│ • Wearable Cosmetics    │ • Digital Focus Timer   │ • Inventory & Equips    │
│ • Real Estate / Pets    │ • Floating Action Dock  │ • DTR Work Session Logs │
│ • Micro-Tasks Checklist │ • Camera Pan & Day/Night│ • Audio & Window Config │
│ • Daily Pet Quests      │ • Interactive Room Props│ • CSV Focus Export      │
└─────────────────────────┴─────────────────────────┴─────────────────────────┘
```

---

## 🐾 1. Autonomous Pet AI & Companion Engine

Kronos features an expressive, non-repetitive pet AI built on a decoupled state machine and procedural animation engine.

### 🐕 Multi-Species Household Roster
Adopt and switch between 5 distinct companion species, each rendered entirely in pure procedural pixel art:

| Species | Companion | Visual Identity & Key Animations | Focus Stance |
| :--- | :--- | :--- | :--- |
| **Shiba Inu** | *Kronos* | Honey-gold fur, white eyebrow dots, fluffy curled tail with sine-wave wagging, happy squint squints. | Rapid typing on a glowing laptop terminal with screen reflections. |
| **Chubby Penguin** | *Pippin* | Round tuxedo body, orange beak, cozy red scarf, signature side-to-side waddle step cycle. | Holds mug between flippers; dual flipper keyboard tapping. |
| **Snowy Bunny** | *Boba* | Snowy white fur, long floppy ears with periodic twitches, 4-legged hopping walk cycle. | Sits upright holding a tiny mug, ears drooping from steam warmth. |
| **Red Fox** | *Kitsune* | Sleek amber silhouette, dark ear tips, pointed muzzle, large brush tail with fluid pendulum sway. | Deep study posture with open scrolls & celestial grimoires. |
| **Calico Cat** | *Mochi* | Calico patches (slate & ginger), delicate whiskers, curled sleeping donut formation. | Attentive screen watcher and rhythmic paw grooming. |

---

### 🧠 Weighted-Random Idle Interaction System
While idle, pets organically trigger special room-aware moments based on a **rarity weight system** (Common: 60, Uncommon: 30, Rare: 10) with multi-stage reactions:

```
[Cooldown: 25s–50s] ──> [Weighted Selection] ──> [Navigate to Anchor] ──> [Primary Action] ──> [Reaction / Tween] ──> [Return to Idle]
```

#### Universal Behaviors (All Rooms)
- **Common**: Sleepy yawn with floating `zzz` particles; rhythmic paw grooming (`heart` particles).
- **Uncommon**: Turning directly to gaze into the camera (`"Looking right at you! 👀✨"`); watching the timer during active sprints.
- **Reactive Hooks**: Joyful hop on coin gain (`+Coins! 🪙`); victory celebration dance on session completion.

#### Multi-Stage Reactions & Procedural Tweens
- `startle_hop`: Quick vertical jump + recoil bounce when startled.
- `wobble`: Drowsy rotational tilt (`0.22` rad) followed by a sharp snap-awake recoil when nodding off standing up.
- `head_shake`: Rapid rotational head shake when spitting out bitter wheat in the greenhouse.
- `happy_hop`: Cheerful mini-bounce on discovering secret stars or sweet berries.

---

## 🏛️ 2. Procedural Mythological Biomes (Rooms)

All rooms are drawn using pure mathematical GDScript `_draw()` calls (no external static PNG textures for environments), allowing live diurnal day/night cycles, ambient lighting, and particle effects.

```
                    ┌─────────────────────────┐
                    │ 🔭 Tower of Urania      │
                    │    (Attic Observatory)  │
                    └────────────┬────────────┘
                                 │
  ┌─────────────────────────┐    │    ┌─────────────────────────┐
  │ 🌙 Temple of Morpheus   ├────┼────┤ 🌾 Elysian Fields       │
  │    (Study Bedroom)      │    │    │    (Golden Plains)      │
  └─────────────────────────┘    │    └────────────┬────────────┘
                                 │                 │
                    ┌────────────┴────────────┐    │
                    │ 🔥 Hearth of Hestia     │    │
                    │    (Living Room Lounge) │    │
                    └────────────┬────────────┘    │
                                 │                 │
                    ┌────────────┴─────────────────┴┐
                    │ 🛶 Banks of the Styx          │
                    │    (Underworld Ferry Dock)    │
                    └───────────────────────────────┘
```

| Room / Biome | Theme & Geometry | Special Idle Behaviors |
| :--- | :--- | :--- |
| **🌙 Temple of Morpheus** *(Bedroom)* | Hourglass Altar, Font of Lethe pool, patchwork quilt daybed, dynamic starfield with twinkling phases, ambient floating dream orbs. | • Stargazing by the Lethe pool<br>• Curled daybed nap<br>• Winding the pendulum clock<br>• Chasing dream moths<br>• Shadow startle & sleepy wobble |
| **🔥 Hearth of Hestia** *(Living Room)* | Sacred marble hearth with soft 8-ring radiant glow, fading clustered sparks, plush carved lounging couch with tufted cushions, fluted architectural columns. | • Toasting paws by the hearth<br>• Couch stretching & cushion burrowing<br>• Batting at floating golden sparks<br>• Fire yelp jump-back<br>• Fluffing a comfy cushion nest |
| **🔭 Tower of Urania** *(Attic Library)* | Giant interactive spinning celestial globe, observation terrace & brass telescope, dark walnut bookshelves, shooting star trails. | • Reading ancient grimoires<br>• Telescope deep-sky observation<br>• Knocking a tome off the stack<br>• Spinning the celestial globe<br>• Discovering a secret constellation |
| **🌾 Elysian Fields** *(Greenhouse / Plains)* | 3-layer dense golden wheat field with wind sways, rustic scarecrow clearing, drifting cumulus clouds, animated fluttering butterflies. | • Chewing wheat stalk (disgust & head shake!)<br>• Planting seeds in the soil<br>• Chasing golden butterflies<br>• Sneezing from pollen<br>• Spooked by moving scarecrow |
| **🛶 Banks of the Styx** *(Underworld Dock)* | Foreground iron prison bars with reflection highlights, Charon's Skiff with tall curved prow & glowing lantern, swinging pendulum chains, murky teal river with rolling fog, live boat bobbing broadcast. | • Peering cautiously into the River Styx<br>• Curled nap under the spectral lantern<br>• Rattling the ancient iron prison bars<br>• Flinching at creaking chains<br>• Slipping near boat edge & catch balance |

---

## ⏱️ 3. Productivity & Focus Suite

### 1. Flowmodoro & Pomodoro Timer Engines
- **Flowmodoro Mode (Count-Up)**: Track uninterrupted focus flow without artificial alarms. When you stop, your earned break time is dynamically calculated based on your focus ratio (e.g., 5:1 ratio).
- **Classic Pomodoro (Count-Down)**: Configurable sprint intervals (e.g. 25 min work, 5 min short break, 15 min long break) with retro sound chimes.
- **Dynamic Energy Buff**: Maintaining your pet's Energy above 70% grants a **+50% Focus Coin Speed Buff** during active sessions.

### 2. Active Recall Flashcards & Learning Engine
- Create, manage, and review flashcard decks during focus breaks.
- Self-grade answers (Hard / Good / Easy) to earn **Knowledge Points (KP)**, linking companion progression to real-world study mastery.

### 3. Daily Time Record (DTR) & Focus History
- Automatic session logging with duration, timestamp, task name, category, and coins earned.
- Reverse-chronological session feed with date filtering (`Today` vs `All`).
- **1-Click CSV Export**: Exports session logs to `user://kronos_dtr_export.csv` for timesheet tracking and analytics.

---

## 🛍️ 4. Inventory, Economy & Customization

### 1. Multi-Tier Item Catalog
- **Treats & Snacks**: Pixel Espresso, Croissant, Ceremonial Matcha, Star Donut, Ramen, Deluxe Bento (+Energy, +Joy, +EXP).
- **Wearable Cosmetics**: Multi-slot cosmetic rendering system supporting **Head** (Crown, Wizard Hat, Beanie, Chef Hat, Cap), **Face** (Sunglasses, Wireframe Glasses, Monocle), and **Neck** (Red Bowtie, Plaid Scarf, Bell Collar).
- **Room Decor**: Mini Bonsai, Lava Lamp, Retro Boombox, Terrarium, Fairy Lantern.

### 2. Micro-Tasks & Daily Quests
- **Checklist Task Engine**: Add, check off, select active focus sprint target, or delete micro-tasks.
- **Daily Pet Quests**: Automatically generated daily objectives (e.g., *"Complete 2 Work Sprints"*, *"Feed 3 Treats"*, *"Pet Companion 5 Times"*) awarding bonus Coins and EXP.

---

## ⚙️ 5. Technical Specifications & Desktop Utility

- **Engine**: Godot Engine 4.7.1 (GDScript).
- **Window Management**: Frameless window dragging, scale presets (`1.0x`, `1.25x`, `1.5x`), and **Always-on-Top desktop pinning** via native background helper binary (`kronos_pinner.exe`).
- **Data Persistence**: Safe JSON serialization with automated backup rotation (`kronos_save.json` and `kronos_dtr.json` in OS `user://` storage).
- **Performance**: Lightweight CPU footprint, pixel-perfect 60 FPS viewport rendering, zero heavy asset loading.
