# Implementation Plan: Selectable Color Themes

**Branch**: `feature/add-themes` | **Date**: 2026-09-26 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/004-selectable-color-themes/spec.md`

## Summary

This adds four fixed color themes: Charcoal & Lime (the default), Pink & White, Charcoal &
Cyan and Mango & Navy. Users pick one in a new Theme section on the Settings screen.

**Palettes.** Each theme is a `const AppPalette` of named color roles.

**How colors reach widgets.** `AppColors` keeps its member names, but each member becomes
a getter that reads the active palette. The about 230 existing call sites therefore stay
as they are, apart from dropping `const`. `AppTheme.from(palette)` replaces the hard-coded
`darkTheme`.

**Storing and applying the choice.** `SettingsController` stores the choice in
`SharedPreferences`, like the kg/lbs setting, and applies it before the first frame. The
Settings page rebuilds the app with `Get.forceAppUpdate()`.

**Readability.** A table-driven unit test enforces WCAG contrast rules (4.5:1 for text,
3:1 for fills and boundaries) on every palette. This required three small readability
fixes to Charcoal & Lime (research R5). All 25 hard-coded `Colors.white` / `Colors.black` /
hex literals are mapped to palette roles.

## Technical Context

**Language/Version**: Dart SDK ^3.11, Flutter 3.47.5

**Primary Dependencies**: GetX 4.7.3 (`Get.forceAppUpdate`, `Obx`) and
`shared_preferences`, both already used. No new packages.

**Storage**: One `SharedPreferences` key, `theme_id`. No Drift schema change.

**Testing**: `flutter_test`. There's a util test for palettes and contrast, and extended
`SettingsController` tests using `SharedPreferences.setMockInitialValues`. No widget tests
(Principle V).

**Target Platform**: Android and iOS.

**Project Type**: Mobile app, single Flutter project.

**Performance Goals**: A theme switch completes in one app-wide rebuild, without
perceptible lag (under 300 ms on a mid-range phone).

**Constraints**:
- Every text/background pair is at least 4.5:1, and every fill or boundary is at least
  3:1 (research R4).
- The Charcoal & Lime look is unchanged apart from the R5 fixes.

**Scale/Scope**:
- 1 new util file and 2 changed util/controller files.
- About 22 UI files touched, mostly removing `const` and replacing literal colors.
- 1 new and 1 extended test file.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Check | Status |
|-----------|-------|--------|
| I. GetX | Theme state is `Rx<AppThemeId>` in the existing permanent `SettingsController`. `MainApp` reads it through `Obx`. There's no new screen, so no new controller. | ✅ |
| II. Layered structure | Palettes and the contrast helper go in `lib/utils/`, the state in `lib/controllers/`, and the UI in `lib/pages/settings.dart`. No database access from UI. | ✅ |
| III. Drift-only | No schema change. The preference uses the existing `SharedPreferences` pattern, not sqflite. | ✅ (n/a) |
| IV. Error handling | There's no new failure path. An unknown stored value falls back silently by design (FR-011), and that isn't a swallowed exception. | ✅ |
| V. Testing | `test/utils/app_palette_test.dart` (contrast rules, fallback, ratio helper) and `test/controllers/settings_controller_test.dart` (load, set, persist, fallback). The R5 contrast fixes are covered by the palette test, which fails on the old values. | ✅ |
| VI. Code quality | `///` docs on `AppPalette`, `AppThemeId` and the new methods. No inline comments. `const` palettes. Format and analyze. The existing `// ──` section comments in `app_theme.dart` are pre-existing, and the file is rewritten without inline comments. | ✅ (enforced during implementation) |
| VII. Simplicity | No new packages, no repository layer. Getters are used instead of a `ThemeExtension` to avoid threading `context` through 230 call sites (research R1). | ✅ |
| Implementation constraints | The spec's assumptions about the light theme, naming and navy as background are recorded in the spec. Palette values and the contrast rules are decided in research R4–R6. There are no open questions. | ✅ |

**Post-design re-check**: still passes. `AppColors` members stop being `const`, which is a
source-level change inside the app only. The constitution rule "`const` wherever possible"
is still met, because those expressions can no longer be `const`. Complexity Tracking is
empty.

## Project Structure

### Documentation (this feature)

```text
specs/004-selectable-color-themes/
├── spec.md
├── plan.md              # This file
├── research.md          # R1–R9
├── data-model.md        # AppThemeId, AppPalette values, settings state
├── quickstart.md        # Validation guide
├── contracts/
│   └── theme.md         # AppPalette / AppColors / AppTheme / SettingsController + Settings UI
├── checklists/
│   └── requirements.md
└── tasks.md             # /speckit-tasks (not created here)
```

### Source Code (repository root)

```text
lib/
├── main.dart                              # Obx around GetMaterialApp, AppTheme.from, confetti colors
├── controllers/
│   └── settings_controller.dart           # themeId, palette, setTheme, load theme_id
├── utils/
│   ├── app_palette.dart                   # NEW: AppThemeId, AppPalette, appPalettes,
│   │                                      #   appThemeIdFromName, contrastRatio
│   ├── app_theme.dart                     # AppColors → getters; AppTheme.from(palette)
│   └── error_handler.dart                 # drop const around AppColors
├── pages/
│   ├── settings.dart                      # THEME section with swatch rows
│   ├── programs.dart, build_program.dart, track_workout.dart,
│   │   workout.dart, tracking.dart, onboarding.dart     # const removal + literal → role
└── widgets/
    ├── exercise_workout_card.dart, timed_log_section.dart,
    │   workout_information_dialog.dart, create_exercise_dialog.dart,
    │   edit_exercise_dialog.dart, add_workout_exercise_dialog.dart,
    │   distance_unit_selector.dart, hint_bubble.dart, …  # const removal + literal → role

test/
├── controllers/
│   └── settings_controller_test.dart      # extended
└── utils/
    └── app_palette_test.dart              # NEW
```

**Structure Decision**: The existing layered layout. Palettes are pure data plus a pure
helper, so they go in `lib/utils/` next to `app_theme.dart`.

## Implementation Order (for /speckit-tasks)

1. **Foundation**:
   - `app_palette.dart` with all four palettes, `contrastRatio` and
     `appThemeIdFromName`.
   - `app_palette_test.dart`, which must pass for all four palettes. Tune the hex values
     here if needed.
2. **AppColors/AppTheme refactor**:
   - Turn the `AppColors` members into getters and add `AppTheme.from`.
   - Remove the now-invalid `const` in every file until `flutter analyze` is clean.
   - Charcoal & Lime must look identical, except for the R5 fixes.
3. **Story 1 (select and persist)**:
   - Add `SettingsController.themeId`, `setTheme` and the load step, with their tests.
   - Add `Obx` around `GetMaterialApp`, and the Settings Theme section with
     `forceAppUpdate`.
4. **Story 2 (readable everywhere)**:
   - Replace the hard-coded colors (research R7), including `onPrimary`/`onError`/`onSuccess`
     foregrounds, chart and muscle-map colors, and the empty state.
   - Set the system overlay style per brightness.
5. **Story 3 (names)**: covered by `AppPalette.name` in the Settings rows. Check it against
   the spec.
6. **Polish**: format, analyze and test, then do the quickstart walkthrough in all four
   themes.

## Complexity Tracking

No constitution violations; nothing to justify.
