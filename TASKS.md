# Implementation Tasks: Chim Nhà (Bird Care App)

- [x] Task 1: Project Setup & Dependencies Configuration
  - Add required dependencies in `pubspec.yaml` (`sqflite`, `path_provider`, `path`, `fl_chart`, `intl`, `flutter_local_notifications`, `image_picker`, `archive`, `share_plus`, `google_fonts`, `flutter_lints`).
  - Configure assets directory and default pre-loaded database/JSON data.
  - Setup core app structure, themes (Light & Dark), and constants.

- [x] Task 2: Data Models & Database Infrastructure (Clean Architecture)
  - Create SQLite database helper (`DatabaseHelper`) for tables: `birds`, `health_logs`, `diary_entries`, `foods`, `articles`, `reminders`, `breeding_pairs`, `breeding_eggs`.
  - Implement domain models: `Bird`, `HealthLog`, `DiaryEntry`, `FoodItem`, `Article`, `CareReminder`, `BreedingPair`, `BreedingEgg`.
  - Create repository classes and DAOs for local CRUD operations.
  - Implement initial seed data generator for Food Database and Knowledge Base Articles.

- [x] Task 3: Core Business Logic & Rule Engine
  - Implement `HealthRuleEngine` (weight loss calculation >10% over 7 days, poor appetite detection).
  - Implement `PedigreeEngine` (parent-offspring hierarchy tree generator).
  - Implement `BackupRestoreService` (ZIP export/import of SQLite DB + image files).
  - Implement `NotificationService` wrapper for local scheduling.

- [x] Task 4: Home Dashboard & Today's Checklist Feature
  - Build Home screen UI with greeting, bird selector hero card, today's task checklist (Feed, Water, Clean, Bath), quick action buttons, and health alert cards.
  - Add status updates when checking off daily tasks.

- [x] Task 5: Bird Management & Profile Details Feature
  - Build Bird List screen & Add/Edit Bird modal/screen with image picker avatar support.
  - Build Bird Detail screen with tabs: Info & Bio, Weight Trend Chart, Health Logs, Photo Gallery, Pedigree.

- [x] Task 6: Health Tracker & Interactive Weight Chart Feature
  - Build Health Logging Form screen (Weight, Appetite, Water, Activity, Droppings, Feathers, Beak/Legs, Notes).
  - Build Interactive Line Chart widget (`fl_chart` / Custom Painter) for weight history over time.
  - Display Health Rule Engine alerts and warnings on health dashboard.

- [x] Task 7: Photo Diary Feature
  - Build Photo Diary List / Timeline screen.
  - Build Add Diary Entry screen with multiple image attachments saved locally in application storage.
  - Image viewer modal with zoom and date details.

- [x] Task 8: Offline Food Safety Guide Feature
  - Build Food Library screen with Search Bar, Group Filter, and Status Tabs (Safe 🟢, Limit 🟡, Dangerous 🔴).
  - Build Food Detail modal/screen showing portions, prep guide, and species-specific safety warnings.

- [x] Task 9: Care Knowledge Base Feature
  - Build Knowledge Base screen categorized into Basics, Nutrition, Hygiene, Health, and Behavior.
  - Build Article Reader screen with formatted rich text, quick search, and reading time indicator.

- [x] Task 10: Local Reminder Scheduler Feature
  - Build Reminder List screen with toggle switches.
  - Build Add/Edit Reminder dialog with time picker, repeat options, and category icons.
  - Integrate with `NotificationService`.

- [x] Task 11: Breeding & Pedigree Manager Feature
  - Build Breeding Pair Manager screen (pair male/female birds, status).
  - Build Clutch & Egg Tracker (egg number, laying date, incubation status, hatch date).
  - Build Visual Pedigree Tree widget showing lineage.

- [x] Task 12: Backup, Restore & App Settings
  - Build Settings Screen with Theme selector (Dark/Light), Data Summary, Export Backup ZIP, Import Backup ZIP, and Reset Data.
  - Test backup export and import integrity.

- [x] Task 13: App Stabilization, Testing & Error Fixes
  - Run `flutter analyze` and resolve all lint warnings and errors.
  - Run `flutter test` to verify core business logic and database seed helpers.
  - Perform app runtime verification to ensure zero crash on empty/populated states.

- [x] Task 14: Setup Android Signing & Keystore
  - Generate release keystore (`upload-keystore.jks`).
  - Create `key.properties` configuration.
  - Update `android/app/build.gradle` for release signing config.

- [x] Task 15: Build Release Android App Bundle (AAB)
  - Execute `flutter build appbundle --release`.
  - Verify AAB artifact generation in `build/app/outputs/bundle/release/app-release.aab`.

- [x] Task 16: Generate Google Play Store Listing Content
  - Create directory `/store/` (i.e., `store/` in root).
  - Create `app_name.txt` (max 30 chars).
  - Create `short_description.txt` (max 80 chars).
  - Create `full_description.txt` (SEO optimized, 300–2000 chars, highlighting offline capability, privacy, features).

- [x] Task 17: Generate Privacy Policy Website
  - Create directory `/policy/` (i.e., `policy/` in root).
  - Create `privacy_policy.html` complying with Play Store guidelines, stating zero personal data collection and offline privacy guarantee.
