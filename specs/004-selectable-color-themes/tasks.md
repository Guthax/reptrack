---

description: "Task list for selectable color themes"
---

# Tasks: Selectable Color Themes

**Input**: Design documents from `/specs/004-selectable-color-themes/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [contracts/theme.md](contracts/theme.md),
[quickstart.md](quickstart.md)

**Tests**: Required. Constitution Principle V requires tests for controller and util logic.

- Use `SharedPreferences.setMockInitialValues`, `Get.testMode = true` and
  `tearDown(Get.reset)`, as in the existing `test/controllers/settings_controller_test.dart`.
- Any test that changes `AppColors.palette` resets it to
  `appPalettes[AppThemeId.charcoalLime]!` in `tearDown`.
- No widget tests.

**Organization**: Grouped by the spec's user stories. US1 (select in Settings) and US2
(readable) are P1, and US3 (names) is P3. The Foundational phase does the `AppColors`
refactor that every story needs.

**Rules for every task** (Constitution VI and CLAUDE.md):
- Every new class, enum, field and method has a `///` doc comment.
- No `//` comments inside function bodies or trailing code.
- Use `const` wherever it still compiles.
- Run `dart format` on edited files.
- Widgets never call `AppDatabase`.
- No new packages.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on unfinished tasks)
- **[Story]**: The user story the task belongs to (US1–US3 from spec.md)

---

## Phase 1: Setup

- [X] T001 Run `flutter analyze` and `flutter test` from the repository root. Record the baseline issue count and passing test count in the Notes section at the bottom of `specs/004-selectable-color-themes/tasks.md`.

---

## Phase 2: Foundational (blocks all stories)

**Purpose**: Introduce palettes and make `AppColors` read the active palette, while
Charcoal & Lime stays active and looks unchanged apart from research R5.

- [X] T002 Create `lib/utils/app_palette.dart`, following [contracts/theme.md](contracts/theme.md) and [data-model.md](data-model.md):
  - `enum AppThemeId { charcoalLime, pinkWhite, charcoalCyan, mangoNavy }`.
  - `class AppPalette` with a `const` constructor. Its fields are `String name`, `Brightness brightness` and the required `Color` fields `background, surface, surfaceVariant, outline, outlineVariant, primary, onPrimary, primaryContainer, secondary, onSecondary, secondaryContainer, success, onSuccess, successContainer, error, onError, errorContainer, onErrorContainer, textPrimary, textSecondary, textDisabled, accentMuted, accentMutedFill`.
  - `const Map<AppThemeId, AppPalette> appPalettes`, with the four palettes using exactly the hex values in the data-model table, in enum order.
  - `AppThemeId appThemeIdFromName(String? name)`, which returns `AppThemeId.values.asNameMap()[name] ?? AppThemeId.charcoalLime`.
  - `double contrastRatio(Color a, Color b)`, which uses `computeLuminance()` and returns `(lighter + 0.05) / (darker + 0.05)`.
- [X] T003 [P] Create `test/utils/app_palette_test.dart`:
  - `contrastRatio(black, white)` is 21 within 0.01, and `contrastRatio(x, x)` is 1.
  - `appPalettes` has a palette for every `AppThemeId`.
  - `appThemeIdFromName` gives `null → charcoalLime`, `'unknown' → charcoalLime` and `'mangoNavy' → mangoNavy`.
  - A `for` loop over `appPalettes` checks every rule in the [research R4](research.md) table, with a message naming the palette, the role pair and the ratio:
    - `textPrimary/textSecondary/textDisabled` vs `background/surface/surfaceVariant` ≥ 4.5
    - `primary/secondary/success/error/accentMuted` vs `background/surface` ≥ 4.5
    - the same five vs `surfaceVariant` ≥ 3.0
    - `onPrimary/primary`, `onSecondary/secondary`, `onSuccess/success`, `onError/error` ≥ 4.5
    - `textPrimary/outline` ≥ 4.5
  - Add an explicit regression test: the old Charcoal & Lime values `textDisabled #4A5568` on `#232733` and white on `#FF3347` are below 4.5. This documents why R5 changed them.
- [X] T004 Run `flutter test test/utils/app_palette_test.dart`. If a palette rule fails, change only that hex value in `lib/utils/app_palette.dart` until it passes, never the rule. Then update the value in the table in `specs/004-selectable-color-themes/data-model.md` to match.
  - **Pre-check**: every data-model value was checked against these rules while planning, including `textPrimary/outline` (≥ 6.49) and `accentMuted` (≥ 4.07 on `surfaceVariant`). Expect all rules to pass on the first run.
- [X] T005 Rewrite `AppColors` in `lib/utils/app_theme.dart`:
  - Add `static AppPalette palette = appPalettes[AppThemeId.charcoalLime]!;`.
  - Replace every `static const Color x = …` with `static Color get x => palette.x;`, keeping the existing names `background, surface, surfaceVariant, outline, primary, secondary, success, error, textPrimary, textSecondary, textDisabled`.
  - Add getters for `onPrimary, onSecondary, onSuccess, onError, accentMuted, accentMutedFill`.
  - Update the class doc comment so it no longer says "charcoal + Electric Lime".
- [X] T006 In `lib/utils/app_theme.dart`, replace `static ThemeData get darkTheme` with `static ThemeData from(AppPalette p)`, building the same `ThemeData` from palette roles:
  - `ColorScheme`: `brightness: p.brightness` and `onPrimary: p.onPrimary`. `primaryContainer`, `secondaryContainer` and `tertiaryContainer` use `p.primaryContainer`, `p.secondaryContainer` and `p.successContainer`. Use `onError: p.onError`, `errorContainer: p.errorContainer`, `onErrorContainer: p.onErrorContainer`, `outlineVariant: p.outlineVariant` and `inversePrimary: p.primaryContainer`.
  - Every `Colors.black` used as a foreground on a primary fill (ElevatedButton, FilledButton, FAB, chip `secondaryLabelStyle`) becomes `p.onPrimary`.
  - `appBarTheme.systemOverlayStyle` is `p.brightness == Brightness.light ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light` (research R8).
  - Remove the `// ──` section comments and the other inline comments inside the method.
  - Keep `const` on sub-objects that don't reference `p`.
- [X] T007 In `lib/main.dart`, change `theme: AppTheme.darkTheme` to `theme: AppTheme.from(AppColors.palette)`. Remove `const` from the confetti `colors:` list, which contains `AppColors`.
- [X] T008 [P] Remove `const` that no longer compiles because of `AppColors` getters in `lib/utils/error_handler.dart` and `lib/utils/app_theme.dart` (`AppSnackbar`). Keep `const` on inner nodes that still compile.
- [X] T009 [P] Remove `const` that no longer compiles because of `AppColors` in `lib/pages/programs.dart`, `lib/pages/build_program.dart`, `lib/pages/settings.dart`, `lib/pages/onboarding.dart`, `lib/pages/tracking.dart` and `lib/pages/track_workout.dart`.
- [X] T010 [P] Remove `const` that no longer compiles because of `AppColors` in:
  - `lib/widgets/exercise_workout_card.dart`
  - `lib/widgets/timed_log_section.dart`
  - `lib/widgets/exercise_history_card_widget.dart`
- [X] T011 [P] Remove `const` that no longer compiles because of `AppColors` in:
  - `lib/widgets/create_exercise_dialog.dart`
  - `lib/widgets/edit_program_exercise_dialog.dart`
  - `lib/widgets/add_exercise_dialog.dart`
  - `lib/widgets/edit_exercise_dialog.dart`
  - `lib/widgets/add_workout_exercise_dialog.dart`
  - `lib/widgets/swap_exercise_dialog.dart`
  - `lib/widgets/timed_sets_editor.dart`
  - `lib/widgets/distance_unit_selector.dart`
  - `lib/widgets/hint_bubble.dart`
  - `lib/widgets/workout_information_dialog.dart`

  This includes the `const primaryColor = AppColors.primary;` at about line 290, which becomes `final`.
- [X] T012 Run `dart format lib test`, `flutter analyze` and `flutter test`. Analysis must be at the baseline or better, with no new errors, and all tests must pass. Check that `grep -rn "darkTheme" lib test` returns nothing.

**Checkpoint**: The app builds and runs in Charcoal & Lime, with the R5 muted-text,
error-button and theme-button foreground changes.

---

## Phase 3: User Story 1 – Choose a color theme in Settings (P1) 🎯 MVP

**Goal**: A Theme section in Settings lists the four themes. Tapping one recolors the app
straight away, and the choice survives a restart.

**Independent Test**: Open Settings, tap each theme and see the app recolor. Kill and
relaunch the app, and it starts in the last theme. The unit tests below pass.

### Tests for User Story 1

- [X] T013 [US1] Add a `group('theme', …)` to `test/controllers/settings_controller_test.dart` with one test per row of the SettingsController table in [contracts/theme.md](contracts/theme.md):
  - `load()` with no key gives `charcoalLime`, and `AppColors.palette == appPalettes[charcoalLime]`.
  - `load()` with `{'theme_id': 'mangoNavy'}` gives `mangoNavy`, and `AppColors.primary == const Color(0xFFFFBB39)`.
  - `load()` with `{'theme_id': 'removedTheme'}` gives `charcoalLime` and doesn't throw.
  - `setTheme(pinkWhite)` updates `themeId` and `AppColors.palette`, and `(await SharedPreferences.getInstance()).getString('theme_id') == 'pinkWhite'`.
  - After `setTheme(charcoalCyan)`, a new `SettingsController()` plus `load()` restores `charcoalCyan`.
  - `setTheme` leaves `useImperial` unchanged.
  - Reset `AppColors.palette` in `tearDown`.

### Implementation for User Story 1

- [X] T014 [US1] In `lib/controllers/settings_controller.dart`:
  - Add `static const _keyThemeId = 'theme_id';`.
  - Add `final Rx<AppThemeId> themeId = AppThemeId.charcoalLime.obs;`.
  - Add `AppPalette get palette => appPalettes[themeId.value]!;`.
  - In `load()`, set `themeId.value = appThemeIdFromName(prefs.getString(_keyThemeId))` and `AppColors.palette = palette`.
  - Add `Future<void> setTheme(AppThemeId id)`, which sets `themeId`, sets `AppColors.palette`, and does `prefs.setString(_keyThemeId, id.name)`.
  - Add `///` docs to each, and update the class doc comment to mention the theme preference.
  - T013 must pass.
- [X] T015 [US1] In `lib/main.dart`, wrap the `GetMaterialApp` in `MainApp.build` in `Obx(() => GetMaterialApp(... theme: AppTheme.from(settings.palette) ...))`. Keep the existing `home:` logic. This depends on T014.
- [X] T016 [US1] In `lib/pages/settings.dart`, add a THEME section directly after the Units section's `Divider`:
  - A section header in the same style as the 'UNITS' header, with the text `'THEME'`.
  - One row per entry of `appPalettes`, in map order, inside an `Obx`. Each row shows:
    - A preview of three 20×20 rounded swatches for `background`, `primary` and `secondary`, each with a 1px `AppColors.outline` border.
    - The palette `name` in `titleMedium`.
    - A trailing `Icons.check_circle` in `AppColors.primary` when `settings.themeId.value == id`.
    - A 1.5px `AppColors.primary` border on the selected row, and `AppColors.outline` otherwise.
  - `onTap: () async { await settings.setTheme(id); await Get.forceAppUpdate(); }`.
  - End the section with a `Divider`.
  - Keep the widget code in this file, following the existing single-file pattern of the page. If it grows past about 60 lines, add a private `_ThemeOption` `StatelessWidget` in the same file.

**Checkpoint**: US1 works end-to-end. Themes switch and persist, although a few
hard-coded colors may still look wrong in non-default themes until US2 is done.

---

## Phase 4: User Story 2 – Every theme stays readable (P1)

**Goal**: No element keeps a hard-coded color that fails in some theme. Light-theme system
bars are dark (research R7, R8).

**Independent Test**: The palette test (T003) passes, `grep` finds no stray color literals
(T024), and the quickstart walkthrough in all four themes finds no unreadable element.

- [X] T017 [P] [US2] Error buttons: replace `foregroundColor: Colors.white` next to `backgroundColor: AppColors.error` with `foregroundColor: AppColors.onError` in:
  - `lib/pages/programs.dart` (about line 104)
  - `lib/pages/build_program.dart` (about lines 201 and 386)
  - `lib/pages/track_workout.dart` (about line 166)
- [X] T018 [P] [US2] Primary-fill foregrounds: replace `foregroundColor: Colors.black` with `foregroundColor: AppColors.onPrimary` in:
  - `lib/pages/track_workout.dart` (about lines 59 and 135)
  - `lib/widgets/edit_exercise_dialog.dart` (about line 258)
  - `lib/widgets/timed_log_section.dart` (about line 359)
  - `lib/widgets/add_workout_exercise_dialog.dart` (about line 95)
  - `lib/widgets/create_exercise_dialog.dart` (about line 313)

  For each one, check that the matching background is `AppColors.primary`. If it's `AppColors.secondary`, use `onSecondary`. If it's `success`, use `onSuccess`.
- [X] T019 [P] [US2] Selected-state text: replace `isSelected ? Colors.black : …` / `selected ? Colors.black : …` with `AppColors.onPrimary` in:
  - `lib/pages/tracking.dart` (about line 187)
  - `lib/widgets/edit_exercise_dialog.dart` (about line 194)
  - `lib/widgets/create_exercise_dialog.dart` (about line 261)
  - `lib/widgets/distance_unit_selector.dart` (about line 29)
  - `lib/widgets/exercise_workout_card.dart` (about line 887)

  First check that the selected fill in each is `AppColors.primary`. If not, use the matching `on…` role.
- [X] T020 [P] [US2] Delete swipe and badge colors in `lib/widgets/exercise_workout_card.dart` and `lib/widgets/timed_log_section.dart`:
  - The delete icons on an `AppColors.error` background (card about lines 289 and 786, timed about line 577) become `AppColors.onError`.
  - The set-number badges (card about lines 1085 and 1297):
    - text becomes `isSaved ? AppColors.onSuccess : AppColors.textPrimary`
    - the unsaved badge background stays `AppColors.outline`
- [X] T021 [P] [US2] In `lib/pages/tracking.dart`, the chart tooltip `TextStyle(color: Colors.white)` (about line 794) becomes `AppColors.textPrimary`. In `lib/pages/workout.dart`:
  - the empty-state icon `Colors.white24` (about line 41) becomes `AppColors.textDisabled`
  - the text `Colors.white54` (about line 52) becomes `AppColors.textSecondary`
- [X] T022 [P] [US2] In `lib/widgets/workout_information_dialog.dart`:
  - `secondaryColor = Color(0xFF8AB800)` (about line 291) becomes `AppColors.accentMuted`.
  - The primary muscle fill `const Color(0xCCC6FF00)` (about line 374) becomes `AppColors.primary.withValues(alpha: 0.8)`.
  - The secondary muscle fill `const Color(0xFF527700)` (about line 379) becomes `AppColors.accentMutedFill`.
  - Check that the `CustomPainter`'s `shouldRepaint` returns `true`, or compares colors, so a theme switch repaints it.
- [X] T023 [P] [US2] In `lib/main.dart`, the confetti `Colors.white` (about line 111) becomes `AppColors.textPrimary`. Leave the `Colors.black` shadow in `lib/widgets/hint_bubble.dart` as it is, because it's a shadow, not content (research R7).
- [X] T024 [US2] Audit with `grep -rnE "Colors\.(white|black)|Color\(0x" lib --include=*.dart | grep -v lib/utils/app_palette.dart`. Every remaining hit must be a shadow or scrim, or `Colors.transparent`. Map anything else to a palette role, following the rules in research R7. Also grep `lib/` for `AppColors.textDisabled` used as a fill, and for `AppColors.outline` used behind text. Make sure each such text pair is covered by an R4 rule, or switch it to a covered role.
- [ ] T025 [US2] Run `flutter test test/utils/app_palette_test.dart`. It must pass for all four palettes. Then on a device, open Track Workout, the exercise info dialog and Tracking in Pink & White and Mango & Navy, and fix any element still unreadable by mapping it to the right role. The status bar icons must be dark in Pink & White.

**Checkpoint**: All four themes are readable everywhere.

---

## Phase 5: User Story 3 – Theme names describe the colors (P3)

**Goal**: Each theme is named `<Primary> & <Secondary>`.

**Independent Test**: The name test below passes, and the Settings list shows the four
expected names.

- [X] T026 [US3] In `test/utils/app_palette_test.dart`, add a test that `appPalettes.values.map((p) => p.name)` equals exactly `['Charcoal & Lime', 'Pink & White', 'Charcoal & Cyan', 'Mango & Navy']`, and that each name matches `RegExp(r'^[A-Z][a-z]+ & [A-Z][a-z]+$')`.

---

## Phase 6: Polish & Cross-Cutting

- [X] T027 [P] Check that every new or changed public member in `lib/utils/app_palette.dart`, `lib/utils/app_theme.dart` and `lib/controllers/settings_controller.dart` has a `///` doc comment, and that there are no `//` comments inside method bodies.
- [X] T028 Run `dart format lib test`, `flutter analyze` (no issues beyond the T001 baseline) and `flutter test` (all pass, including the new theme tests).
- [ ] T029 Run the manual walkthrough in [quickstart.md](quickstart.md), steps 1–6, in all four themes, and tick off SC-001, SC-003, SC-004 and SC-005.

---

## Dependencies & Execution Order

- **Setup (T001)** → **Foundational (T002–T012)** → US1, US2 and US3.
- Inside Foundational:
  - T002 comes before T003/T004, which come before T005/T006.
  - T005 and T006 come before T007–T011, and T008–T011 can run in parallel.
  - T012 comes last.
- **US1**: T013 → T014 → T015 and T016.
- **US2**: needs only Foundational, because it touches different lines from US1.
  - T017–T023 can run in parallel, because each touches different files or different lines. T018 and T019 both edit `edit_exercise_dialog.dart` and `create_exercise_dialog.dart`, so do them one after the other if they're run by the same agent.
  - T024 → T025.
- **US3**: needs only T003.
- **Polish**: after all stories.

## Parallel Example

```text
After T006:  T008, T009, T010, T011   (const removal, separate file groups)
After T012:  T013 (US1 tests)  ∥  T017–T023 (US2 literal replacements)  ∥  T026 (US3)
```

## Implementation Strategy

1. **MVP**: Phases 1–3 (T001–T016). Users can pick and keep a theme.
2. **Required before release**: Phase 4 (US2). Without it some hard-coded colors are
   unreadable in Pink & White, so don't ship US1 without US2.
3. Then do Phase 5 and the Polish phase.

## Notes

- Baseline (T001): `flutter analyze` reports 9 info-level issues (none from this feature), and `flutter test` passes 320 tests.
- T004: all four palettes passed every R4 rule on the first run, so no hex values changed. The test also checks `onErrorContainer/errorContainer` ≥ 4.5.
- T008–T011: `const` was removed automatically at each analyzer error, and `dart fix` re-added `const` to inner widgets where valid. `dart fix` also tried to add `sqlite3_flutter_libs` to `pubspec.yaml`. That was reverted because it is out of scope (Principle VII).
- T018: `track_workout.dart` about lines 59 and 135 have a `success` fill, so they use `AppColors.onSuccess`. The timed-log main button switches between `error` (running) and `primary`, so its foreground switches between `onError` and `onPrimary`.
- T022: `BodyDiagramPainter.shouldRepaint` doesn't compare colors, and this was left unchanged. The painter lives in a dialog that can't be open during a theme switch, and `Get.forceAppUpdate()` reassembles every render object anyway.
- T024: the only remaining literals are `shadow`/`scrim` in `app_theme.dart` and the hint-bubble shadow.
- T025: **open**. The automated part passes (palette contrast test). The on-device walkthrough wasn't run, because only the Linux desktop target was available in the implementation session.
- T028: `flutter analyze` reports the 9 baseline infos, and `flutter test` passes all 348 tests (320 baseline + 28 new).
- T029: **open**. The manual quickstart walkthrough needs a phone or emulator.
