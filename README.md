# SmartExpense

SmartExpense is an offline-first personal finance tracker built with Flutter. It helps you record expenses and income, visualize spending, keep budgets on track, and automate recurring bills without relying on a remote backend.

---

## Feature Highlights
- **Unified dashboard** – shows total balance across accounts and the latest monthly activity.
- **Quick transaction entry** – configurable categories, account picker, custom numpad, and edit flow.
- **Account insights** – per-account balance cards, income/expense split, and historical transactions.
- **Budget tracking** – monthly category budgets with color-coded progress bars and edit dialogs.
- **Recurring automation** – due recurring items become real transactions when the app starts.
- **Visual reports** – FL Chart-based pie charts for daily/weekly/monthly/yearly spending.
- **Offline data** – powered by a local SQLite database via `sqflite`, so everything works without connectivity.

---

## Architecture & Tech Stack
- **Flutter** 3.3+ (Material theming, custom widgets, `IndexedStack` navigation)
- **Local persistence:** `sqflite`, `path`, `path_provider`
- **Charts & formatting:** `fl_chart`, `intl`
- **Permissions & exports:** `permission_handler`, `csv` (for future export features)

Key dependencies live in `pubspec.yaml`:

```15:29:pubspec.yaml
  intl: ^0.19.0
  sqflite: ^2.3.3+1
  fl_chart: ^0.68.0
  csv: ^6.0.0
  path_provider: ^2.1.3
  permission_handler: ^11.3.1
```

---

## Project Structure
```
lib/
  main.dart                  # App entry; bootstraps DB + recurring jobs
  main_navigation.dart       # Bottom navigation & screen registry
  screens/                   # UI flows (dashboard, budgets, reports, etc.)
  models/                    # Plain Dart models for accounts, budgets, transactions
  services/database_helper.dart
                             # SQLite layer + data access helpers
  widgets/                   # Reusable cards, list items, custom numpad
  theme.dart                 # Centralized color + typography settings
```

---

## Getting Started

### Prerequisites
- Flutter SDK `>= 3.3.3`
- An Emulator

### Install Dependencies
```sh
Clone this git repo 
flutter pub get
```

### Run the App (Use Adroid Emulator ONLY)
```sh
flutter run        
```

---

## Troubleshooting & Tips
- Restart and Reload
- If Flutter can’t find a device, run `flutter doctor -v` and resolve the reported issues.
- Delete the `smart_expense.db` file (simulator/emulator data directory) if you need a clean slate during development.
- For release builds, update `pubspec.yaml` metadata (`name`, `description`) and platform-specific bundle identifiers.

