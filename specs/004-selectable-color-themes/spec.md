# Feature Specification: Selectable Color Themes

**Feature Branch**: `feature/add-themes`

**Created**: 2026-09-26

**Status**: Draft

**Input**: User description: "Right now, the app has only on theme, charcoal & lime. Add new themes. Make sure the text and buttons are always well distinguished and readable from the background. Also name each theme by the primary and secondary color. The colors: * A theme based on pink and white * A theme based on charcoal and something like #00f9ff * A theme based on #ffbb39 (mango) and #083c5d"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Choose a color theme in Settings (Priority: P1)

A user opens Settings, sees a "Theme" section listing every available theme by name (for example "Charcoal & Lime"), each with a small color preview. They tap a theme and the whole app immediately switches to it. When they close and reopen the app, the chosen theme is still active.

**Why this priority**: This is the core of the feature. Without a way to pick a theme and keep it, the new themes deliver no value.

**Independent Test**: Open Settings, select each theme in turn, confirm the app recolors immediately, then restart the app and confirm the last choice is still applied.

**Acceptance Scenarios**:

1. **Given** the user is on the Settings screen, **When** they look at the Theme section, **Then** they see four themes: "Charcoal & Lime", "Pink & White", "Charcoal & Cyan" and "Mango & Navy", with the active one clearly marked.
2. **Given** "Charcoal & Lime" is active, **When** the user taps "Mango & Navy", **Then** every screen, dialog, bottom sheet, snackbar and the navigation bar uses the Mango & Navy colors without restarting the app.
3. **Given** the user selected "Pink & White", **When** they fully close and reopen the app, **Then** the app starts in "Pink & White".
4. **Given** a user who has never picked a theme (new install or upgrade from an earlier version), **When** they open the app, **Then** "Charcoal & Lime" is active, so the app looks as it does today (apart from the contrast fixes allowed by SC-005).

---

### User Story 2 - Every theme stays readable (Priority: P1)

Whatever theme is active, a user working out can read all text and tell buttons apart from the background at a glance, including numbers on the tracking screen, labels on primary buttons, hint text in input fields, disabled controls, success/error messages and chart lines in the workout information view.

**Why this priority**: The user explicitly requires readability. A theme that makes buttons or numbers hard to see mid-workout is worse than no theme.

**Independent Test**: For each theme, walk through the main screens (programs, build program, workout, track workout for strength/cardio/hybrid/timed exercises, tracking history, settings, onboarding, and every dialog) and check that no element is hard to read or blends into its background. Measure contrast of each color pair used for text and controls.

**Acceptance Scenarios**:

1. **Given** any theme is active, **When** a primary (filled) button is shown, **Then** its label and icon contrast clearly with the button fill, and the button fill stands out from the surface behind it.
2. **Given** any theme is active, **When** body text, secondary text or numeric readouts are shown on a background, card or dialog, **Then** they meet the contrast levels in FR-006.
3. **Given** "Pink & White" (a light theme) is active, **When** the user views any screen, **Then** no element that used to be white-on-dark in the charcoal themes is rendered white-on-white or otherwise invisible, and the phone's status bar icons are dark so they remain visible.
4. **Given** any theme is active, **When** a success or error message, a destructive (delete) action or a completed-set indicator appears, **Then** its meaning is still recognizable and readable against that theme's background.

---

### User Story 3 - Theme names describe the colors (Priority: P3)

A user scanning the theme list can tell what each theme looks like from its name alone, because every theme is named "<Primary> & <Secondary>".

**Why this priority**: Nice-to-have clarity; the preview swatch already carries most of this information.

**Independent Test**: Read the theme list and confirm each name follows the "<Primary> & <Secondary>" pattern and matches the dominant colors seen when that theme is applied.

**Acceptance Scenarios**:

1. **Given** the Theme section is shown, **When** the user reads the names, **Then** each is of the form "<Primary color> & <Secondary color>" and the two named colors are the ones that visibly dominate that theme.

---

### Edge Cases

- A stored theme choice that no longer matches any available theme (e.g., a theme is renamed or removed in a later version) falls back to "Charcoal & Lime" without an error.
- The theme is switched while a workout is in progress (e.g., the timed stopwatch is running or a rest countdown is showing): the workout state is unaffected; only colors change.
- The theme is switched while a snackbar or dialog is open: newly opened UI uses the new theme; nothing crashes.
- Colors that are currently fixed regardless of theme (e.g., black text on lime buttons, white icons on red swipe-to-delete backgrounds, lime chart lines in the workout information view) must follow the active theme so they remain readable in every theme.
- The phone's own light/dark system setting does not override the chosen theme.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The app MUST offer four themes: "Charcoal & Lime" (the current look, unchanged), "Pink & White", "Charcoal & Cyan" and "Mango & Navy".
- **FR-002**: Each theme MUST be named "<Primary> & <Secondary>", where the primary is the main accent/action color or dominant tone and the secondary is the supporting color.
- **FR-003**: Theme palettes MUST be based on the requested colors:
  - "Pink & White": a light theme with white/near-white backgrounds and pink as the accent color for primary actions and highlights.
  - "Charcoal & Cyan": a dark theme with the same charcoal backgrounds as the current theme and a cyan close to #00F9FF as the accent color.
  - "Mango & Navy": a dark theme with deep navy (#083C5D) as the background tone and mango (#FFBB39) as the accent color.
- **FR-004**: Users MUST be able to select a theme from a "Theme" section on the Settings screen, shown alongside the existing "Units" section; each option MUST show its name and a color preview, and the active theme MUST be visibly marked.
- **FR-005**: Selecting a theme MUST apply it to the entire app immediately, without restarting, and MUST be persisted so it is restored on the next launch.
- **FR-006**: In every theme, all text and icon colors MUST meet at least a 4.5:1 contrast ratio against the background they appear on (3:1 for large text of 18pt+ or 14pt+ bold), and button fills, input borders of focused fields, selected chips/segments and other interactive boundaries MUST meet at least 3:1 against their adjacent background.
- **FR-007**: In every theme, the content color on a filled accent element (primary button, FAB, selected chip, selected segment) MUST be chosen per theme for contrast with that fill (e.g., dark text on lime, mango or cyan; the color that satisfies FR-006 on pink).
- **FR-008**: Success, error/destructive and disabled states MUST remain distinguishable from each other and from normal content in every theme, and meet FR-006.
- **FR-009**: Every screen, dialog, bottom sheet, snackbar, navigation bar, onboarding page, coach-mark hint bubble and chart MUST take its colors from the active theme; no element may keep a color that fails FR-006 in any theme.
- **FR-010**: For light themes, system status bar and navigation bar icons MUST be dark; for dark themes they MUST be light.
- **FR-011**: When no theme has been chosen, or a stored choice is not recognized, the app MUST use "Charcoal & Lime".
- **FR-012**: Switching themes MUST NOT change or lose any workout, program or tracking data, nor interrupt an in-progress workout.

### Key Entities

- **Theme**: A named, fixed color palette. Attributes: display name ("<Primary> & <Secondary>"), light or dark base, background/surface colors, accent colors, text colors, state colors (success, error, disabled), and the matching content colors for each filled element.
- **Theme preference**: The user's selected theme, stored as a device-level setting alongside the existing unit preference.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user can find and switch to any theme in under 15 seconds from the home screen.
- **SC-002**: 100% of text/background and control/background color pairs in all four themes meet the contrast thresholds in FR-006.
- **SC-003**: In a walkthrough of every screen and dialog in each of the four themes, zero elements are found invisible or hard to read.
- **SC-004**: After switching theme and restarting the app, the chosen theme is restored in 100% of attempts.
- **SC-005**: Users who never touch the theme setting see no visual change compared to the current version, except where a current color fails the contrast levels in FR-006 and is corrected (see [research.md R5](research.md#r5--current-charcoal--lime-fails-some-rules-conflict-with-sc-005)).

## Assumptions

- "Pink & White" is interpreted as a light theme (white background, pink accents), because white is only useful as a background color in that pairing; it is the only light theme.
- "#083C5D" is named "Navy" and "#00F9FF" is named "Cyan" for display; the exact cyan shade may be adjusted slightly if needed to meet contrast, as the user said "something like #00f9ff".
- In "Mango & Navy", navy is the background family and mango is the accent; exact surface/card shades are derived from #083C5D so cards stay distinguishable from the page background.
- Success (green) and error (red) colors may be tuned per theme to stay readable; they do not need to be identical across themes.
- The theme choice is stored per device like the existing kg/lbs preference, not synced or tied to program data, so no database change is needed.
- Themes are fixed presets; creating custom themes or picking individual colors is out of scope.
- The app does not follow the phone's system light/dark mode; the user's chosen theme always wins.
- Existing layout, typography, shapes and spacing stay the same in all themes; only colors change.
