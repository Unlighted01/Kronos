# 🎯 Implementation Plan — Kronos Pop-Out Productivity Studio & Architecture

Transform Kronos into a premier focus ecosystem: a **Cozy Ambient Desktop Companion** in the screen corner, paired with a **Widescreen Pop-Out Productivity Studio (`720×460`)** that opens on demand for deep focus analytics, Spaced Repetition flashcards with smart document/paste import, and task planning.

---

## 🏛️ System Architecture: Dual-Window Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    📊 KRONOS PRODUCTIVITY STUDIO (720×460)                  │
│       [📊 DTR & Analytics]       [🧠 Study Deck & SRS]       [📋 Tasks & Forecast]       [✕] │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  TAB 1: 📊 DTR & ANALYTICS STUDIO                                           │
│  • 60-Day Interactive Calendar Heatmap   • Category Time Distribution Bar   │
│  • Daily/Weekly Goal Progress (3.5h/4h)  • One-Click Standup Markdown [📋] │
│  • Full Session CRUD Table (Edit/Delete) • Clean CSV Data Exporter [📊]     │
│                                                                             │
│  TAB 2: 🧠 SRS STUDY DECK & SMART IMPORTER                                  │
│  • SuperMemo SM-2 Spaced Repetition      • "Due Today" Queue & Quiz Arena   │
│  • Dual Importer (File Picker + Smart Paste Box for Notes/PDF/AI text)      │
│  • Live Editable Preview Table           • Multi-Subject Card CRUD Manager  │
│                                                                             │
│  TAB 3: 📋 SPRINT TASKS & POMODORO FORECAST                                 │
│  • Task Categories with Color Tags       • Estimated Pomodoros (🍅 2/4)     │
│  • "Finish By" Time Predictor            • Subtask Checklists               │
│  • 1-Click Sprint Binding to Widget      • Priority Flags (High/Med/Low)    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
               ▲ (Toggled via [📊 Studio] button or Ctrl+D / F1)
┌──────────────────────────┬──────────────────────────┬───────────────────────┐
│       LEFT PANEL         │       MIDDLE PANEL       │      RIGHT PANEL      │
│      (Pet Lifestyle)     │ (Procedural Pet Canvas)  │  (Vitals & Ambience)  │
├──────────────────────────┼──────────────────────────┼───────────────────────┤
│ • Treats & Snacks Shop   │ • Enhanced Pixel Timer   │ • Pet Vitals & Stats  │
│ • Wearable Cosmetics     │ • Active Task Pill 🎯    │ • Inventory Bag       │
│ • Room Real Estate/Decor │ • Mythological Biomes    │ • Soundscape Mixer 🎧 │
│ • Daily Pet Quests       │ • Ambient Procedural Pet │ • Window & System Cfg │
│ • Trophies & Badges      │ • 1-Click [📊 Studio]    │ • Friendship & Streak │
└──────────────────────────┴──────────────────────────┴───────────────────────┘
```

---

## 🛠️ Detailed Feature Specifications

### 🖥️ 1. Pop-Out Productivity Studio Window (`720×460`)
* **Window Lifecycle & Multi-Monitor Freedom**:
  * Opens centered on screen via `[📊 Studio]` button on the widget, or hotkey `Ctrl+D` / `F1`.
  * Can be moved independently across monitors without disturbing the pet companion widget.
  * Closes cleanly with `Esc` or `✕` button.
* **Widescreen Tabs**:

#### Tab A: 📊 DTR Analytics & Session Studio
* **60-Day Focus Heatmap**: Color-graded daily squares (gray &rarr; light emerald &rarr; deep green). Hover to inspect sprint count and hours.
* **Goal & Metric Bars**:
  * `Daily Goal: 3.5h / 4.0h [████████░░] 87% 🎯`
  * `Category Breakdown: 💻 Dev 45% | 📚 Study 30% | ✍️ Writing 25%`
* **Session CRUD Table**: View all historical sessions with inline edit (edit task name, category, duration, date) and delete buttons.
* **Exporters**:
  * **Standup Markdown Generator**: 1-click copies a clean formatted standup report to the system clipboard for Slack/Discord/Notion.
  * **CSV Exporter**: Generates a standard `.csv` spreadsheet of all focus records.

#### Tab B: 🧠 SRS Study Deck & Smart Importer Studio
* **SuperMemo (SM-2) Spaced Repetition Algorithm**:
  * Dynamically schedules card reviews based on recall difficulty (`Hard` = 1d, `Good` = 3d &rarr; 6d &rarr; 14d, `Easy` = bonus interval):
    $$\text{Interval}_{n} = \text{Interval}_{n-1} \times \text{Ease Factor}$$
  * "Due Today" counter ensures optimal cognitive retention without burnout.
* **Smart Dual Importer (File Picker + Smart Paste Box)**:
  * **File Picker**: Load `.pdf`, `.txt`, `.csv`, `.md` files.
  * **Smart Paste Box**: Paste raw lecture slides, notes, ChatGPT flashcard outputs, or textbook summaries directly into the box.
  * **Automatic Regex Extractor**: Automatically parses:
    * `Q: ... A: ...` / `Question: ... Answer: ...`
    * `Term : Definition` / `Term - Definition`
    * Numbered quiz format (`1. Question? \n A) ... or Answer: ...`)
  * **Interactive Preview Table**: Shows all extracted cards with checkboxes and inline editing before adding them to the deck.
* **Spacious Quiz Arena**: Distraction-free, readable flashcard review session.

#### Tab C: 📋 Sprint Tasks & Pomodoro Forecast
* **Category Color Tags**: Tag tasks as `💻 Dev`, `📚 Study`, `✍️ Writing`, `🎨 Design`, `📋 Admin`.
* **Pomodoro Estimation & Auto-Increment**: Set target Pomodoros (`🍅 4`). Completing a sprint automatically ticks the counter (`🍅 1/4` &rarr; `🍅 2/4`).
* **"Finish By" Time Predictor**: Calculates: *"4 Pomodoros remaining (2.0 hrs). Estimated completion: 4:45 PM."*
* **1-Click Sprint Binding**: Instantly sets the selected task as the active focus goal on the desktop companion widget.

---

### 🐾 2. Primary Desktop Companion Widget (Cozy Focus & Pet Life)
* **Enhanced Retro Pixel-Art Timer**:
  * High-contrast glowing pixel digits with retro shadow bevel.
  * Radial / Segmented pixel progress ring indicating sprint completion.
  * Quick-switch presets: `25/5 Classic`, `50/10 Deep Work`, `90/20 Ultradian`, `Flowmodoro Stopwatch`, `Custom Mins`.
  * Active task pill: `🎯 [Dev 💻] Auth Engine (🍅 2/4)`.
  * Prominent **`[📊 Studio]`** launch button in the header bar.
* **Streamlined Side Panels**:
  * **Left Panel**: Pet shop (treats, snacks, cosmetics, decor), daily quests, and trophies.
  * **Right Panel**: Pet vitals (Joy, Energy, Friendship, Streak), Inventory Bag, and Soundscape Mixer (Rain, Alpha Waves, Brown Noise, Lofi).

---

## 📅 Phased Execution Plan

### Phase 1: Studio Window Framework & Retro Pixel Timer Redesign [✅ COMPLETED]
* **Deliverables**:
  * `[NEW] scenes/productivity/ProductivityStudio.tscn` & `ProductivityStudio.gd`: Standalone `720×460` frameless pixel window with 3-tab navigation switcher (`[📊 DTR]`, `[🧠 DECK]`, `[📋 TASKS]`), header dragging, and smooth open/close hotkeys (`Ctrl+D` / `F1` / `Esc`).
  * `[MODIFY] scenes/main/WindowController.gd` & `MainWorkspace.tscn`: Connect `[📊 Studio]` button and `Ctrl+D` shortcut; compact middle panel HeaderBar and timer dock controls; maintain clean uncropped pixel layout across 1x/1.25x/1.5x/2x scales.
  * `[MODIFY] scripts/autoload/TimerEngine.gd`: Added presets (`25/5`, `50/10`, `90/20`, `Flowmodoro`), sprint progress bar integration, and preset cycling.

### Phase 2: DTR Analytics Studio & Standup Exporter [✅ COMPLETED]
* **Deliverables**:
  * `[NEW] scenes/productivity/DTRStudioTab.tscn` & `DTRStudioTab.gd`: 60-day interactive GitHub-style heatmap with tooltips and date filter, daily focus goal progress bar (`3.0h / 4.0h`), multi-timeframe category distribution charts, reverse-chronological session CRUD table with search, inline edit/add modal, 1-click Markdown Standup generator for clipboard, and CSV export.
  * `[MODIFY] scripts/autoload/DatabaseManager.gd`: Heatmap data aggregation (60 days), category distribution, lifetime statistics summary, standup markdown generation, and `dtr_updated` signal.
  * `[MODIFY] scripts/autoload/EventBus.gd`: Added `dtr_updated` signal for real-time reactivity.
  * `[MODIFY] scenes/productivity/ProductivityStudio.tscn` & `ProductivityStudio.gd`: Embedded `DTRStudioTab` into Tab 1 with borderless/transparent pixel styling and header dragging.

### Phase 3: SuperMemo (SM-2) Engine & Smart Document/Paste Importer [🟡 NEXT UP]
* **Deliverables**:
  * `[NEW] scripts/study/SRSAlgorithm.gd`: SuperMemo SM-2 interval calculations ($I_n = I_{n-1} \times \text{EF}$), ease factor adaptation, and "Due Today" queue scheduler.
  * `[NEW] scripts/study/SmartQAParser.gd`: Regex parser supporting Q&A patterns, Term-Definition pairs, numbered quizzes, and cloze deletions.
  * `[NEW] scenes/productivity/StudyDeckStudioTab.tscn` & `StudyDeckStudioTab.gd`: SRS card manager, "Due Today" queue, interactive quiz arena with card flipper, file picker, and smart paste import preview table.
  * `[MODIFY] scripts/autoload/DatabaseManager.gd`: Persist flashcard decks (`user://kronos_study_decks.json`), review history, and SM-2 parameters.
  * `[MODIFY] scenes/productivity/ProductivityStudio.tscn`: Mount `StudyDeckStudioTab` into Tab 2 (`DeckTab`).

### Phase 4: Task Command Board, Pomodoro Forecast & Panel Streamlining [❌ QUEUED]
* **Deliverables**:
  * `[NEW] scenes/productivity/TaskBoardStudioTab.tscn` & `TaskBoardStudioTab.gd`: Category color tags, subtasks, estimated Pomodoro tracking, "Finish By" time forecast, and sprint binder.
  * `[MODIFY] scenes/panels/LeftPanel.gd` & `RightPanel.gd`: Clean up redundant panels to focus purely on pet shop/lifestyle and vitals/inventory.

---

## 🔍 Verification & Testing

1. **Headless GDScript Validation**:
   ```powershell
   & "C:\Users\netne\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "c:\Users\netne\Codes\Kronos\Kronos\kronos-godot" --check-only -s res://path/to/script.gd 2>&1
   ```
2. **Multi-Window Interaction**: Open the Productivity Studio via `[📊 Studio]` and `Ctrl+D`; verify opening, tab switching, and closing with `Esc` without affecting the pet companion widget.
3. **DTR CRUD**: Create, edit, and delete focus sessions; verify instant heatmap updates and clipboard Standup copy.
4. **Smart Importer & SRS**: Test pasting sample study notes and loading a text/pdf file; verify parsed Q&A cards populate the preview table, save to the deck, and schedule correctly under SM-2.
5. **Pomodoro Forecast**: Add 3 tasks with Pomodoro estimates; verify completion time calculation updates dynamically.
