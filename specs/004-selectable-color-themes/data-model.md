# Data Model: Selectable Color Themes

No database entities. All state is in memory, plus one `SharedPreferences` key.

## AppThemeId (enum)

| Value | Display name | Brightness |
|---|---|---|
| `charcoalLime` (default) | Charcoal & Lime | dark |
| `pinkWhite` | Pink & White | light |
| `charcoalCyan` | Charcoal & Cyan | dark |
| `mangoNavy` | Mango & Navy | dark |

- Persisted as `AppThemeId.name` under the `SharedPreferences` key `theme_id`.
- An unknown or missing value becomes `charcoalLime` (research R9).
- The enum order is the order shown in Settings.

## AppPalette (immutable, `const` constructor)

One instance per `AppThemeId`. All fields are required `Color`s except `name` and
`brightness`.

| Field | Charcoal & Lime | Pink & White | Charcoal & Cyan | Mango & Navy |
|---|---|---|---|---|
| name | Charcoal & Lime | Pink & White | Charcoal & Cyan | Mango & Navy |
| brightness | dark | light | dark | dark |
| background | #0F1117 | #FFF5F8 | #0F1117 | #062B42 |
| surface | #1A1D26 | #FFFFFF | #1A1D26 | #083C5D |
| surfaceVariant | #232733 | #FCE4EE | #232733 | #0E4B72 |
| outline | #2E3347 | #F0C6D6 | #2E3347 | #1D5E86 |
| outlineVariant | #1E2233 | #F8DDE8 | #1E2233 | #0A3653 |
| primary | #C6FF00 | #C2185B | #00F9FF | #FFBB39 |
| onPrimary | #000000 | #FFFFFF | #000000 | #000000 |
| primaryContainer | #3D5200 | #FFD6E5 | #004D52 | #5C4000 |
| secondary | #00E5FF | #7B1F4F | #B388FF | #7FD4FF |
| onSecondary | #000000 | #FFFFFF | #000000 | #000000 |
| secondaryContainer | #004F59 | #F3D1E2 | #3A2A66 | #0F5E8A |
| success | #39E07C | #176B33 | #39E07C | #5BE39A |
| onSuccess | #000000 | #FFFFFF | #000000 | #000000 |
| successContainer | #00422A | #CDEBD6 | #00422A | #0B5A3A |
| error | #FF3347 | #C62828 | #FF3347 | #FF9E9E |
| onError | #000000 ⚠ | #FFFFFF | #000000 | #000000 |
| errorContainer | #5C0A14 | #FFD9D9 | #5C0A14 | #6B1F2A |
| onErrorContainer | #FF8A8A | #8C1414 | #FF8A8A | #FFC7C7 |
| textPrimary | #F0F4FF | #2B1520 | #F0F4FF | #F2F7FA |
| textSecondary | #8B97B0 | #5E3F4F | #8B97B0 | #C4D8E5 |
| textDisabled | #8792A9 ⚠ | #7D5C6A | #8792A9 | #A0BFD2 |
| accentMuted | #8AB800 | #AD1457 | #00B8BD | #E0A030 |
| accentMutedFill | #527700 | #F48FB1 | #00585C | #8A5F12 |

⚠ = changed from the current app, see research R5.

- **Role semantics**:
  - `accentMuted` is a dimmer primary that's still readable as text. It's used for
    secondary-muscle chips.
  - `accentMutedFill` is decorative only and is used for the secondary-muscle fill on the
    body map.
- **Validation**: The rules in research R4 are enforced by `test/utils/app_palette_test.dart`
  for every `AppPalette`. If a value in the table above fails, the test is the source of
  truth. Adjust the hex value until it passes, and don't relax the rule.

## Derived: ThemeData

`AppTheme.from(AppPalette p)` builds the `ThemeData` exactly as `AppTheme.darkTheme` does
today, with every constant replaced by the matching palette role. It also sets:

- `colorScheme.brightness` and `systemOverlayStyle` from `p.brightness` (research R8).
- Button, FAB and selected-chip foregrounds to `p.onPrimary` instead of `Colors.black`.

## SettingsController additions (state)

| Field | Type | Initial | Persisted |
|---|---|---|---|
| `themeId` | `Rx<AppThemeId>` | `charcoalLime` | yes, `theme_id` |

State transition: `setTheme(id)` → `themeId = id`, `AppColors.palette = palettes[id]`,
and a write to prefs. No other state is affected (FR-012).
