# 🏋️ RepTrack

A Flutter workout tracker that helps you build programs, log sessions, and visualise your strength progress — all stored locally on-device with no account required.

---

## ✨ Features

- **Program builder** — create multiple training programs, each with named workout days and a custom exercise list
- **Exercise library** — add exercises with muscle group tags and equipment variants; edit or delete at any time
- **Active workout** — swipe through exercises, log sets with weight & reps, swap exercises on the fly, and rest-timer alerts when a set is done
- **Progress tracking** — per-exercise weight progress charts with equipment filter chips
- **Muscle diagram** — tap the ℹ️ icon on any workout day to see a front/back body diagram highlighting primary and secondary muscles

---

## 📱 How to Use

### 1. Create a Program
1. Open the **Programs** tab
2. Tap **＋** and give your program a name (e.g. *Push Pull Legs*)
3. Inside the program, tap **＋** again to add a workout day (e.g. *Push Day*)
4. Tap **Add Exercise** inside a day, search the library, pick equipment and configure sets/reps

### 2. Start a Workout
1. Switch to the **Workout** tab
2. Select a **Program** and a **Workout Day** from the dropdowns
3. Tap **START WORKOUT**
4. Swipe left/right to move between exercises; tap a set row to log it
5. Tap **FINISH** when done

### 3. Track Progress
1. Open the **Track** tab
2. Search for an exercise and tap it
3. Use the equipment filter chips to scope the chart to a specific variant

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| State management | [GetX](https://pub.dev/packages/get) — reactive (`Rx` / `Obx`) |
| Persistence | [Drift](https://drift.simonbinder.eu/) (SQLite) |
| Charts | [fl_chart](https://pub.dev/packages/fl_chart) |
| SVG icons | [flutter_svg](https://pub.dev/packages/flutter_svg) |

---

## 🚀 Getting Started

**Prerequisites:** Flutter ≥ 3.x, Dart ≥ 3.x

```bash
# Install dependencies
flutter pub get

# Generate Drift database code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

---

## 🤝 Contributing

Contributions are welcome! Here's how to get started:

1. **Fork** this repository and clone your fork
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Follow the existing code style:
   - Use `///` Dart documentation on all public classes and methods
   - No inline `//` comments — if something needs explaining, it belongs in a docstring
   - Use `const` constructors wherever possible
   - Prefer `GetxController` + `Obx` over `StatefulWidget` for business state
   - Run `dart format lib/` before committing
4. Write or update tests where applicable: `flutter test`
5. Open a **Pull Request** against `master` with a clear description of what changed and why

### Project Structure

```
lib/
├── controllers/   # GetxControllers — all business logic lives here
├── pages/         # Full-screen views (StatelessWidget + GetView)
├── widgets/       # Reusable dialogs and card widgets
├── persistance/   # Drift database, tables, composites, seed data
└── utils/         # Theme, fuzzy search, shared helpers
```

### Reporting Bugs

Open an issue with:
- Steps to reproduce
- Expected vs. actual behaviour
- Flutter/Dart version (`flutter --version`)
- Device or emulator details
