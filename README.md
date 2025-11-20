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
- Xcode (for iOS/macOS), Android Studio or command-line tools (for Android), or Chrome (for web)
- A device or emulator/simulator

### Install Dependencies
```sh
cd /Users/thanyathip/SmartExpense
flutter pub get
```

### Run the App
```sh
flutter run            # Auto-detects a connected device
flutter run -d macos   # macOS desktop
flutter run -d chrome  # Web
```

### Run Tests
```sh
flutter test
```

---

## Local Database

SmartExpense initializes its schema the first time the app runs:

```41:101:lib/services/database_helper.dart
Future _createDB(Database db, int version) async {
  await db.execute('CREATE TABLE accounts (...)');
  await db.execute('CREATE TABLE transactions (...)');
  await _createAdvancedTables(db);
  await db.insert('accounts', {'name': 'Cash', 'initial_balance': 0});
  await db.insert('accounts', {'name': 'Bank', 'initial_balance': 0});
}

Future _createAdvancedTables(Database db) async {
  await db.execute('CREATE TABLE IF NOT EXISTS budgets (...)');
  await db.execute('CREATE TABLE IF NOT EXISTS recurring_transactions (...)');
}
```

All reads/writes go through `DatabaseHelper`, which exposes a `ValueNotifier` so screens refresh whenever data changes.

---

## Recurring Transactions Automation

On launch, due recurring entries are converted into concrete transactions before the UI loads:

```9:47:lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await _processRecurringTransactions();
  runApp(const SmartExpenseApp());
}

Future<void> _processRecurringTransactions() async {
  final dueTransactions = await dbHelper.getDueRecurringTransactions(today);
  for (var tx in dueTransactions) {
    await dbHelper.insertTransaction(newTransaction);
    await dbHelper.updateRecurringTransactionNextDate(tx.id!, nextDate);
  }
}
```

This keeps monthly bills or subscriptions up to date even if the app was closed for a while.

---

## Troubleshooting & Tips
- If Flutter can’t find a device, run `flutter doctor -v` and resolve the reported issues.
- Delete the `smart_expense.db` file (simulator/emulator data directory) if you need a clean slate during development.
- For release builds, update `pubspec.yaml` metadata (`name`, `description`) and platform-specific bundle identifiers.

---

## Roadmap Ideas
- CSV export/import using the existing `csv` + `path_provider` dependencies.
- Budget views for daily/weekly/yearly tabs (currently placeholders).
- Editable categories and richer recurring transaction forms.
- Secure backups (cloud sync or encrypted local export).

---

## License
Add your preferred license (e.g., MIT, Apache 2.0) here.
