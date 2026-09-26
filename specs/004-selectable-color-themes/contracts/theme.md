# Contract: Theme API

These are internal Dart APIs. The fields and values are in [data-model.md](../data-model.md).

## lib/utils/app_palette.dart (new)

```dart
/// Identifies one of the built-in color themes.
enum AppThemeId { charcoalLime, pinkWhite, charcoalCyan, mangoNavy }

/// An immutable set of color roles for one theme.
class AppPalette {
  const AppPalette({required this.name, required this.brightness, /* color roles */});
  final String name;
  final Brightness brightness;
  // background, surface, surfaceVariant, outline, outlineVariant,
  // primary, onPrimary, primaryContainer, secondary, onSecondary, secondaryContainer,
  // success, onSuccess, successContainer, error, onError, errorContainer, onErrorContainer,
  // textPrimary, textSecondary, textDisabled, accentMuted, accentMutedFill
}

/// All palettes, keyed by id. Iteration order = display order in Settings.
const Map<AppThemeId, AppPalette> appPalettes = {...};

/// Resolves a stored name to an id; unknown or null → AppThemeId.charcoalLime.
AppThemeId appThemeIdFromName(String? name);

/// WCAG contrast ratio between two opaque colors (1.0–21.0).
double contrastRatio(Color a, Color b);
```

## lib/utils/app_theme.dart (changed)

```dart
abstract final class AppColors {
  /// The palette used by all getters below. Set by SettingsController.
  static AppPalette palette = appPalettes[AppThemeId.charcoalLime]!;

  static Color get background => palette.background;
  // … one getter per AppPalette color role (existing names kept, new: onPrimary,
  //   onSecondary, onSuccess, onError, accentMuted, accentMutedFill)
}

abstract final class AppTheme {
  /// Builds the app ThemeData for [p]. Replaces `darkTheme`.
  static ThemeData from(AppPalette p);
}
```

**Breaking change**: `AppColors.x` is no longer a compile-time constant, so every
`const` expression that contains it loses its `const`. `AppTheme.darkTheme` is removed.

## lib/controllers/settings_controller.dart (changed)

```dart
final Rx<AppThemeId> themeId = AppThemeId.charcoalLime.obs;

/// The palette for [themeId].
AppPalette get palette;

/// load(): also reads 'theme_id' and applies it to AppColors.palette.

/// Selects [id], applies it to AppColors.palette and persists it under 'theme_id'.
Future<void> setTheme(AppThemeId id);
```

| Scenario | Expected |
|---|---|
| `load()` with no `theme_id` | `themeId == charcoalLime`, `AppColors.palette` is Charcoal & Lime |
| `load()` with `theme_id = 'mangoNavy'` | `themeId == mangoNavy`, `AppColors.primary == #FFBB39` |
| `load()` with `theme_id = 'removedTheme'` | falls back to `charcoalLime`, no throw |
| `setTheme(pinkWhite)` | `themeId`, `AppColors.palette` updated; prefs `theme_id == 'pinkWhite'` |
| `setTheme` then new controller + `load()` | restores the same id |
| `setTheme` | `useImperial` and other prefs unchanged |

## UI contract: Settings page

- A new "THEME" section header uses the same style as "UNITS" and sits directly below the
  Units section.
- There's one row per `appPalettes` entry, in order. Each row shows the palette name and a
  preview of three swatches: `background`, `primary` and `secondary`. The active row shows
  a check mark and a `primary` border.
- Tapping a row runs `await settings.setTheme(id)` and then `Get.forceAppUpdate()`.
- `MainApp` wraps `GetMaterialApp` in `Obx` with `theme: AppTheme.from(settings.palette)`.
