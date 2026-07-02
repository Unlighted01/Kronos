# Project Plan: Local DTR Calendar & Pomodoro App

This document serves as a reference for the project goals, features, tech stack, and structure.

## 📅 Project Overview
We are building a **local-first, full-stack web application** designed as a personal Daily Time Record (DTR) tracker and productivity dashboard. 

### Key Features:
1. **Interactive Calendar UI**: A calendar dashboard displaying the days of the current month. Clicking a day loads its corresponding log.
2. **Daily DTR Logging**: A form where the user can enter a text narrative of what was accomplished on a specific date, upload a picture snippet (screenshot), and save it. Days with logged records show a visual indicator on the calendar.
3. **Integrated Pomodoro Timer**: A simple 25-minute timer (work/break cycles) built into the interface to help track study/work sessions.
4. **One-Click Launch**: A local Windows script (`launch.bat`) that boots up the server and opens the browser interface automatically.

---

## 💻 Technology Stack (Local-First)
* **Frontend**: HTML5, Vanilla CSS, and Client-Side JavaScript (for rendering the calendar, running the timer, and handling UI inputs/fetch calls).
* **Backend**: **Node.js** with **Express** (serves static files, handles API requests, and processes file uploads).
* **Database**: **SQLite** via the `sqlite3` package (lightweight, serverless SQL database that saves all data directly to a single local file: `database/dtr_records.db`).
* **Image Handling**: **Multer** (middleware to save uploaded image snippets into a local `/uploads` folder).

---

## 📂 Folder Structure
```text
MyDTRCalendar/
├── database/            # Local SQLite database destination
├── docs/
│   └── AGENTS.md        # This project summary and agent rules
├── public/              # Frontend files
│   ├── css/style.css    # Stylesheets
│   ├── js/calendar.js   # Calendar rendering & API fetching
│   ├── js/timer.js      # Pomodoro timer logic
│   └── index.html       # Single-page application structure
├── uploads/             # Destination for uploaded screenshot snippets
├── server.js            # Node/Express API server & SQLite connection
├── package.json         # Node.js project configuration
└── launch.bat           # Desktop quick-launch script
```
