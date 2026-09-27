# System Design Document: Chim Nhà (Bird Care App)

## 1. Overview
**Chim Nhà** is a 100% offline, privacy-focused Flutter application designed for bird enthusiasts and breeders. It serves as an electronic care log, offline knowledge base, health tracker with rule engine alerts, food safety guide, breeding & pedigree manager, local reminder scheduler, and local data backup/restore system.

---

## 2. Architecture & Tech Stack

### Architecture Pattern: Clean Architecture & Feature-First Structure
```
lib/
├── core/
│   ├── constants/        # App colors, styles, asset paths
│   ├── database/         # SQLite / Database helper (sqflite)
│   ├── notifications/    # Local notification service
│   ├── theme/            # Material 3 design system, themes
│   └── utils/            # Backup/Restore zip helper, date formatters, math utilities
├── features/
│   ├── birds/            # Bird profiles & management
│   │   ├── domain/ (models, repository interfaces)
│   │   ├── data/ (sqlite implementation, image storage)
│   │   └── presentation/ (screens, widgets)
│   ├── health/           # Health tracking, weight chart, rule-based alerts
│   ├── diary/            # Photo diary & timeline logs
│   ├── food/             # Offline food safety database & search
│   ├── knowledge/        # Offline care knowledge base articles
│   ├── reminders/        # Local reminder management & notifications
│   ├── breeding/         # Breeding pairs, egg tracking, pedigree trees
│   └── settings/         # Theme, backup/restore ZIP export/import, about
└── main.dart             # App entry point, initializations
```

### Core Libraries & Dependencies
- `flutter`: Framework UI engine
- `sqflite` & `path`: Robust SQLite database for local relational data storage
- `flutter_local_notifications` / notification services: Scheduled local notifications for feeding, cleaning, water changes
- `image_picker` & `path_provider`: Local image attachment saving in private app storage
- `fl_chart`: Weight history rendering and health trends visualization
- `archive` & `share_plus` / `file_picker`: Local offline zip backup & restore capabilities
- `google_fonts` / custom typography & Material 3 dynamic styling

---

## 3. Database Schema Design (SQLite)

```sql
-- Birds Table
CREATE TABLE birds (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    species TEXT NOT NULL,
    gender TEXT, -- Male, Female, Unknown
    birth_date TEXT,
    adopt_date TEXT,
    color TEXT,
    weight REAL,
    avatar_path TEXT,
    father_id TEXT,
    mother_id TEXT,
    notes TEXT,
    created_at TEXT
);

-- Health Logs Table
CREATE TABLE health_logs (
    id TEXT PRIMARY KEY,
    bird_id TEXT NOT NULL,
    date TEXT NOT NULL,
    weight REAL,
    appetite TEXT, -- Poor, Normal, Good
    water_intake TEXT,
    activity TEXT, -- Poor, Normal, Good
    droppings TEXT, -- Normal, Abnormal
    feather_condition TEXT,
    beak_legs_condition TEXT,
    notes TEXT,
    photo_path TEXT,
    created_at TEXT,
    FOREIGN KEY(bird_id) REFERENCES birds(id) ON DELETE CASCADE
);

-- Diary Entries Table
CREATE TABLE diary_entries (
    id TEXT PRIMARY KEY,
    bird_id TEXT NOT NULL,
    date TEXT NOT NULL,
    title TEXT,
    content TEXT,
    photo_paths TEXT, -- JSON array of image paths
    created_at TEXT,
    FOREIGN KEY(bird_id) REFERENCES birds(id) ON DELETE CASCADE
);

-- Foods Table (Pre-populated Knowledge Database)
CREATE TABLE foods (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    english_name TEXT,
    category TEXT NOT NULL, -- Safe, Limit, Dangerous
    food_group TEXT NOT NULL, -- Vegetables, Fruits, Seeds, Dangerous, etc.
    portion TEXT,
    preparation TEXT,
    warnings TEXT,
    description TEXT
);

-- Articles Table (Pre-populated Offline Knowledge)
CREATE TABLE articles (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    category TEXT NOT NULL, -- Basics, Nutrition, Hygiene, Health, Behavior
    content TEXT NOT NULL,
    read_time_minutes INTEGER
);

-- Reminders Table
CREATE TABLE reminders (
    id TEXT PRIMARY KEY,
    bird_id TEXT,
    title TEXT NOT NULL,
    time TEXT NOT NULL, -- HH:mm
    repeat_days TEXT, -- JSON array e.g. [1,2,3,4,5,6,7]
    is_enabled INTEGER NOT NULL DEFAULT 1,
    category TEXT NOT NULL -- Feed, Water, Clean, Bath, Custom
);

-- Breeding Pairs & Egg Logs Table
CREATE TABLE breeding_pairs (
    id TEXT PRIMARY KEY,
    male_id TEXT NOT NULL,
    female_id TEXT NOT NULL,
    pair_date TEXT NOT NULL,
    status TEXT NOT NULL, -- Active, Paused, Separated
    notes TEXT
);

CREATE TABLE breeding_eggs (
    id TEXT PRIMARY KEY,
    pair_id TEXT NOT NULL,
    egg_number INTEGER NOT NULL,
    laid_date TEXT NOT NULL,
    hatch_date TEXT,
    status TEXT NOT NULL, -- Incubating, Hatched, Infertile, Broken
    notes TEXT,
    offspring_bird_id TEXT
);
```

---

## 4. Feature Specifications

### 4.1 Home Dashboard
- Welcome header with daily greetings and quick bird selector.
- Today's Care Checklist: Feeding, Water replacement, Cage cleaning, Bathing with checkable state persisted locally.
- Quick health summary cards and rule-engine alert triggers (e.g. Weight drop warning).
- Quick Action shortcuts: Add Health Log, Add Photo Diary, Check Safe Foods.

### 4.2 Multi-Bird Profile Management
- Create, view, update, delete bird profiles.
- Detail view showing tabs: Bio & Info, Health Trends, Weight Graph, Photo Timeline, Breeding record, Pedigree.
- Custom avatar picture loading from camera/gallery.

### 4.3 Health Tracker & Offline Rule Engine
- Standardized logging form for weight (g), appetite, water, activity, droppings, and physical condition.
- Interactive weight line chart over time (7 days, 30 days, all time).
- Rule Engine Evaluation:
  - Trigger ⚠️ Alert: If weight drops > 10% within 7 days.
  - Trigger ⚠️ Notice: If appetite logged as "Poor" for 2+ consecutive logs.

### 4.4 Photo Diary Timeline
- Visual gallery timeline ordered by date.
- Multiple photo upload per entry, stored safely in `app_documents/photos/`.
- Search & filter diary entries by bird or keyword.

### 4.5 Offline Food Safety Database
- Curated list of 40+ foods categorized into 🟢 Safe (Can Eat), 🟡 Limit (Caution), 🔴 Dangerous (Do Not Feed).
- Search bar with instant filter and category tabs.
- Detailed breakdown per food: preparation instructions, portion guides, specific bird species warnings.

### 4.6 Care Knowledge Base
- Structured offline articles covering 5 core categories:
  1. Basics (Welcoming your bird, cage selection, placement, temp & environment)
  2. Nutrition (Seed vs pellet balance, fresh produce, hydration)
  3. Hygiene (Cage sanitization, bathing methods, disinfection)
  4. Health (Recognizing early signs of illness, molt care, first aid)
  5. Behavior (Stress prevention, taming, screeching, biting)
- Article reader with search and estimated reading time.

### 4.7 Local Reminder System
- Schedule recurring notifications for daily tasks (Cho ăn, Thay nước, Vệ sinh lồng, Tắm).
- Custom title and time pickers.
- Toggle reminders on/off.

### 4.8 Breeding & Pedigree Tree
- Pair male and female birds.
- Log clutch eggs (laying date, expected hatch date, status).
- Interactive Pedigree tree viewer showing parents, grandparents, and offspring relationships.

### 4.9 Offline Backup & Restore
- Export complete app database + user uploaded photos into a structured ZIP file (`ChimNha_Backup_YYYYMMDD.zip`).
- Import ZIP file to restore application state cleanly.

---

## 5. UI/UX Design & Aesthetics
- **Theme**: Premium Teal/Emerald & Gold Dark/Light dual themes with rounded Material 3 cards, smooth animations, glassmorphism headers, and custom bird icons.
- **Micro-interactions**: Animated switches, smooth tab transitions, dynamic progress indicators, and celebratory completion micro-animations for care tasks.
