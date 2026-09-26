# Research: Selectable Color Themes

All Technical Context unknowns are resolved below. Contrast ratios were computed with the
WCAG 2.x relative-luminance formula, the same one Flutter's `Color.computeLuminance`
uses.

## R1 – How widgets get the active colors

**Decision**: Keep the `AppColors` API (`AppColors.primary`, `AppColors.textSecondary`, …)
but turn every member from a `static const` into a `static` getter that reads from
`AppColors.palette`, a static `AppPalette` field. After a theme change,
`Get.forceAppUpdate()` rebuilds every widget.

**Rationale**:
- About 230 call sites across 22 files already use `AppColors.x`. With getters, the call
  sites keep their names, and the only change is removing `const` where it no longer
  compiles. The analyzer finds each of those.
- `CustomPainter`s, `AppSnackbar` and `AppErrorHandler` have no `BuildContext`, and getters
  still work there.
- `Get.forceAppUpdate()` ships with GetX 4.7.3 (`extension_navigation.dart:1058`), so no
  new package is needed (Principle VII).

**Alternatives considered**:
- A `ThemeExtension<AppPalette>` read through `Theme.of(context)`. This is more idiomatic
  and rebuilds automatically. But it means threading `context` into painters, snackbars and
  error dialogs, and rewriting all 230 call sites. That's more churn for no user-visible
  gain.
- Only `ColorScheme` with `Theme.of(context).colorScheme`. The app uses roles that
  `ColorScheme` doesn't have (success, muted text, muscle-map fills), so this would still
  need an extension.

## R2 – Where the selection lives and how it is stored

**Decision**:
- Add `Rx<AppThemeId> themeId` and `Future<void> setTheme(AppThemeId)` to the existing
  permanent `SettingsController`.
- Persist the selection in `SharedPreferences` under the key `theme_id`, as the enum
  `name`.
- `load()` reads the key and sets `AppColors.palette` before `runApp`, so the first frame
  already uses the saved theme.

**Rationale**: This matches how the kg/lbs preference already works. It needs no database
change (Principle III doesn't apply) and no new controller, because Settings already has
one (Principle I).

**Alternatives considered**: A Drift settings table. Rejected because that needs a schema
migration for a device-level preference.

## R3 – Applying a theme change

**Decision**:
- `MainApp` wraps `GetMaterialApp` in `Obx`, with `theme: AppTheme.from(settings.palette)`.
- The Settings page calls `await settings.setTheme(id)` and then `Get.forceAppUpdate()`.

**Rationale**:
- Rebuilding `GetMaterialApp` with a new `ThemeData` updates everything that reads
  `Theme.of`.
- `forceAppUpdate` also rebuilds widgets that read `AppColors` directly.
- Keeping `forceAppUpdate` in the widget layer keeps `SettingsController` unit-testable
  without a running app.

**Alternatives considered**: Calling `Get.changeTheme` inside the controller. Rejected
because it needs a mounted `GetMaterialApp`, which breaks the controller tests.

## R4 – Contrast rules (makes FR-006/FR-008 testable)

**Decision**: A unit test checks every palette against the following rules.

| Foreground | Against | Min ratio |
|---|---|---|
| `textPrimary`, `textSecondary`, `textDisabled` | `background`, `surface`, `surfaceVariant` | 4.5 |
| `primary`, `secondary`, `success`, `error`, `accentMuted` (used as text/icons) | `background`, `surface` | 4.5 |
| same accents (used as fills, borders, selected states) | `surfaceVariant` | 3.0 |
| `onPrimary` / `onSecondary` / `onSuccess` / `onError` | their fill | 4.5 |
| `textPrimary` | `outline` (unsaved set-number badge) | 4.5 |

`outline` and `accentMutedFill` are **decorative** (card borders, dividers, the muscle-map
fill), so they're exempt, as WCAG 1.4.11 allows. Focused input borders use `primary`, and
filled inputs use `surfaceVariant`, so every interactive boundary is covered by the rows
above.

**Rationale**: A table-driven test makes SC-002 verifiable, and a future palette tweak
can't regress readability without the test failing.

## R5 – Current Charcoal & Lime fails some rules (conflict with SC-005)

These existing values fail R4:

| Role | Current | Problem | New |
|---|---|---|---|
| `textDisabled` | `#4A5568` | 1.98–2.51:1. It's used as real text in about 25 places, such as "previous" hints and units. | `#8792A9` (4.76:1 on `surfaceVariant`) |
| `onError` | white | 3.61:1 on `#FF3347` | black (5.82:1) |
| set-number badge text | white on `success` | 1.73:1 | `onSuccess` = black |

**Decision**: Fix these three in Charcoal & Lime too. The spec's SC-005 now reads "no
visual change except these contrast fixes". Every other Charcoal & Lime value stays
byte-identical.

**Rationale**: The user's main requirement is that text is always readable. Keeping known
failures in the default theme would contradict FR-006.

## R6 – Palette values

**Decision**: See the full table in [data-model.md](data-model.md). Key choices:

**Pink & White**
- A light theme: `#FFF5F8` page, white cards, a `#FCE4EE` pink tint for inputs and chips.
- The accent is `#C2185B` with white text on it. The lighter `#D81B60` fails on the pink
  tint (4.12:1).

**Charcoal & Cyan**
- Charcoal backgrounds identical to Charcoal & Lime, with `#00F9FF` as the accent. That
  gives 12.8:1 on the surface, so no adjustment was needed.
- The secondary accent is lavender `#B388FF`, so it stays distinct from the cyan.

**Mango & Navy**
- The page is `#062B42`, a darker step of #083C5D, so cards (`#083C5D`) stand out from the
  page. Inputs use `#0E4B72`.
- The accent is `#FFBB39` with black text on it (12.4:1).
- The error color was lightened from `#FF7A7A` (3.67:1) to `#FF9E9E` (4.69:1).

**Alternatives considered**:
- Making Pink & White pink-dominant with white text. Rejected, because the body text
  contrast was too low.
- Using #083C5D itself as the page color. Rejected, because cards then have no darker
  backdrop to lift off.

## R7 – Hard-coded colors outside `app_theme.dart`

**Decision**: Map every literal to a palette role.

- `Colors.black` on primary fills → `onPrimary`
- `Colors.black` on success fills → `onSuccess`, and the timed-log button switches between `onError` (running, red) and `onPrimary`
- `Colors.white` on error fills or the delete swipe → `onError`
- `Colors.white` set-number badge → `onSuccess` when saved, `textPrimary` on `outline`
  otherwise
- `Colors.white` chart tooltip text → `textPrimary`
- `Colors.white24` / `Colors.white54` empty state → `textDisabled` / `textSecondary`
- Muscle chip `#8AB800` → `accentMuted`
- Muscle map `#CCC6FF00` → `primary` at 80% alpha
- Muscle map `#527700` → `accentMutedFill`
- Confetti white → `textPrimary`
- The hint bubble's black shadow stays black. It's a shadow, not content.

## R8 – System bars and the light theme

**Decision**:
- `AppPalette.brightness` drives `ColorScheme.brightness`.
- It also sets `AppBarTheme.systemOverlayStyle`: `SystemUiOverlayStyle.dark` for light
  palettes and `.light` for dark palettes (FR-010).
- `ThemeMode` isn't used. Only `theme:` is set, so the phone's system light/dark mode never
  overrides the choice.

## R9 – Unknown stored value

**Decision**: `AppThemeId.values.asNameMap()[stored] ?? AppThemeId.charcoalLime`.
Renaming or removing a theme later falls back silently (spec edge case, FR-011).
