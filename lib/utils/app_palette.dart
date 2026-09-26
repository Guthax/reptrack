import 'package:flutter/material.dart';

/// Identifies one of the built-in color themes.
///
/// The declaration order is the order in which themes are listed in Settings.
enum AppThemeId {
  /// Deep charcoal with an electric lime accent (the default).
  charcoalLime,

  /// Light theme with white backgrounds and a pink accent.
  pinkWhite,

  /// Deep charcoal with a cyan accent.
  charcoalCyan,

  /// Deep navy with a mango accent.
  mangoNavy,
}

/// An immutable set of named color roles that together form one theme.
///
/// Every `on…` color is the content color used on top of the matching fill.
class AppPalette {
  /// Display name in the form "Primary & Secondary".
  final String name;

  /// Whether this palette is light or dark.
  final Brightness brightness;

  /// Page background.
  final Color background;

  /// Cards, dialogs, sheets and the navigation bar.
  final Color surface;

  /// Input fields, chips and other raised elements on a surface.
  final Color surfaceVariant;

  /// Decorative borders and dividers.
  final Color outline;

  /// Subtle decorative borders.
  final Color outlineVariant;

  /// Main accent used for primary actions and highlights.
  final Color primary;

  /// Content color on [primary].
  final Color onPrimary;

  /// Tinted container derived from [primary].
  final Color primaryContainer;

  /// Supporting accent used for info states and highlights.
  final Color secondary;

  /// Content color on [secondary].
  final Color onSecondary;

  /// Tinted container derived from [secondary].
  final Color secondaryContainer;

  /// Completion and success state.
  final Color success;

  /// Content color on [success].
  final Color onSuccess;

  /// Tinted container derived from [success].
  final Color successContainer;

  /// Error and destructive state.
  final Color error;

  /// Content color on [error].
  final Color onError;

  /// Tinted container derived from [error].
  final Color errorContainer;

  /// Content color on [errorContainer].
  final Color onErrorContainer;

  /// Main text color.
  final Color textPrimary;

  /// Secondary text color for labels and supporting text.
  final Color textSecondary;

  /// Muted text color for hints and inactive content.
  final Color textDisabled;

  /// Dimmer variant of [primary] that is still readable as text.
  final Color accentMuted;

  /// Decorative fill variant of [primary], not used behind or as text.
  final Color accentMutedFill;

  /// Creates a palette; every color role is required.
  const AppPalette({
    required this.name,
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.accentMuted,
    required this.accentMutedFill,
  });
}

/// All built-in palettes keyed by id, in display order.
const Map<AppThemeId, AppPalette> appPalettes = {
  AppThemeId.charcoalLime: AppPalette(
    name: 'Charcoal & Lime',
    brightness: Brightness.dark,
    background: Color(0xFF0F1117),
    surface: Color(0xFF1A1D26),
    surfaceVariant: Color(0xFF232733),
    outline: Color(0xFF2E3347),
    outlineVariant: Color(0xFF1E2233),
    primary: Color(0xFFC6FF00),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF3D5200),
    secondary: Color(0xFF00E5FF),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF004F59),
    success: Color(0xFF39E07C),
    onSuccess: Color(0xFF000000),
    successContainer: Color(0xFF00422A),
    error: Color(0xFFFF3347),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFF5C0A14),
    onErrorContainer: Color(0xFFFF8A8A),
    textPrimary: Color(0xFFF0F4FF),
    textSecondary: Color(0xFF8B97B0),
    textDisabled: Color(0xFF8792A9),
    accentMuted: Color(0xFF8AB800),
    accentMutedFill: Color(0xFF527700),
  ),
  AppThemeId.pinkWhite: AppPalette(
    name: 'Pink & White',
    brightness: Brightness.light,
    background: Color(0xFFFFF5F8),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFFCE4EE),
    outline: Color(0xFFF0C6D6),
    outlineVariant: Color(0xFFF8DDE8),
    primary: Color(0xFFC2185B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFFFD6E5),
    secondary: Color(0xFF7B1F4F),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF3D1E2),
    success: Color(0xFF176B33),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFCDEBD6),
    error: Color(0xFFC62828),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFFFD9D9),
    onErrorContainer: Color(0xFF8C1414),
    textPrimary: Color(0xFF2B1520),
    textSecondary: Color(0xFF5E3F4F),
    textDisabled: Color(0xFF7D5C6A),
    accentMuted: Color(0xFFAD1457),
    accentMutedFill: Color(0xFFF48FB1),
  ),
  AppThemeId.charcoalCyan: AppPalette(
    name: 'Charcoal & Cyan',
    brightness: Brightness.dark,
    background: Color(0xFF0F1117),
    surface: Color(0xFF1A1D26),
    surfaceVariant: Color(0xFF232733),
    outline: Color(0xFF2E3347),
    outlineVariant: Color(0xFF1E2233),
    primary: Color(0xFF00F9FF),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF004D52),
    secondary: Color(0xFFB388FF),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF3A2A66),
    success: Color(0xFF39E07C),
    onSuccess: Color(0xFF000000),
    successContainer: Color(0xFF00422A),
    error: Color(0xFFFF3347),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFF5C0A14),
    onErrorContainer: Color(0xFFFF8A8A),
    textPrimary: Color(0xFFF0F4FF),
    textSecondary: Color(0xFF8B97B0),
    textDisabled: Color(0xFF8792A9),
    accentMuted: Color(0xFF00B8BD),
    accentMutedFill: Color(0xFF00585C),
  ),
  AppThemeId.mangoNavy: AppPalette(
    name: 'Mango & Navy',
    brightness: Brightness.dark,
    background: Color(0xFF062B42),
    surface: Color(0xFF083C5D),
    surfaceVariant: Color(0xFF0E4B72),
    outline: Color(0xFF1D5E86),
    outlineVariant: Color(0xFF0A3653),
    primary: Color(0xFFFFBB39),
    onPrimary: Color(0xFF000000),
    primaryContainer: Color(0xFF5C4000),
    secondary: Color(0xFF7FD4FF),
    onSecondary: Color(0xFF000000),
    secondaryContainer: Color(0xFF0F5E8A),
    success: Color(0xFF5BE39A),
    onSuccess: Color(0xFF000000),
    successContainer: Color(0xFF0B5A3A),
    error: Color(0xFFFF9E9E),
    onError: Color(0xFF000000),
    errorContainer: Color(0xFF6B1F2A),
    onErrorContainer: Color(0xFFFFC7C7),
    textPrimary: Color(0xFFF2F7FA),
    textSecondary: Color(0xFFC4D8E5),
    textDisabled: Color(0xFFA0BFD2),
    accentMuted: Color(0xFFE0A030),
    accentMutedFill: Color(0xFF8A5F12),
  ),
};

/// Resolves a stored theme [name] to an id, falling back to
/// [AppThemeId.charcoalLime] when [name] is null or unknown.
AppThemeId appThemeIdFromName(String? name) =>
    AppThemeId.values.asNameMap()[name] ?? AppThemeId.charcoalLime;

/// Returns the WCAG contrast ratio between two opaque colors, from 1 to 21.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
