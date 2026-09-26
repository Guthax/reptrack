# Quickstart: Validating Selectable Color Themes

## Prerequisites

- Flutter 3.47.5, and a device or emulator (Android or iOS).
- The branch with the feature implemented.

## Automated checks

```bash
dart format lib test
flutter analyze            # must report no issues
flutter test               # includes the new tests below
```

The new or extended tests are:

- `test/utils/app_palette_test.dart`
  - Every palette passes each contrast rule in [research R4](research.md#r4--contrast-rules-makes-fr-006fr-008-testable). This covers SC-002.
  - Every `AppThemeId` has a palette.
  - `appThemeIdFromName` falls back to `charcoalLime` for an unknown name.
  - `contrastRatio` returns 21 for black/white and 1 for identical colors.
- `test/controllers/settings_controller_test.dart`: every row in the contract table in
  [contracts/theme.md](contracts/theme.md).

## Manual walkthrough

This covers SC-001, SC-003, SC-004 and SC-005.

1. **Fresh install**: the app looks like it did before. The only differences are
   brighter muted text, black text on red buttons, and black numbers on green set
   badges (research R5).
2. **Find the setting**: open Settings. The Theme section is below Units and lists four
   themes with swatches. Charcoal & Lime is checked. It should take under 15 seconds to get
   here from the home screen.
3. **Check every theme**: for each theme, tap it and check that the app recolors at once.
   Then visit each of these and look for any text, icon or button that is hard to see:
   - the Programs tab, including the delete dialog
   - Build Program, including the add exercise dialog and delete swipe
   - the Workout tab, including the empty state
   - Track Workout with a strength, cardio, hybrid and timed exercise, including a rest
     countdown, a logged-set badge, the leave dialog and a success snackbar
   - the Tracking tab, including its chart tooltip
   - the exercise info dialog, including the muscle chips and body map
   - an error snackbar, which you can trigger by saving an empty exercise name
4. **Light theme**: in Pink & White, the status bar icons are dark and no white-on-white
   text appears.
5. **Persistence**: pick Mango & Navy, kill the app, and relaunch it. It starts in Mango &
   Navy.
6. **Mid-workout switch**: start a timed set, open Settings, and switch theme. The
   stopwatch keeps running and no logged data changes.
