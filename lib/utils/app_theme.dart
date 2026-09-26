import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:reptrack/utils/app_palette.dart';

/// Shows styled success and error snackbars.
///
/// The [_errorHandler] hook is intended for tests only — override it in a
/// `setUp` block and reset it in `tearDown`.
abstract final class AppSnackbar {
  static void Function(String)? _errorHandler;

  /// Replaces the error snackbar with [handler] for testing.
  ///
  /// Must be paired with [resetForTest] in `tearDown`.
  @visibleForTesting
  static void overrideErrorForTest(void Function(String) handler) {
    _errorHandler = handler;
  }

  /// Restores the default production behaviour after a test.
  @visibleForTesting
  static void resetForTest() {
    _errorHandler = null;
  }

  /// Shows [message] as a user-fixable validation error.
  static void error(String message) {
    if (_errorHandler != null) {
      _errorHandler!(message);
      return;
    }
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      messageText: const SizedBox.shrink(),
      backgroundColor: AppColors.surface,
      borderColor: AppColors.error,
      borderWidth: 1,
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  static void success(String message) {
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      messageText: const SizedBox.shrink(),
      backgroundColor: AppColors.surface,
      borderColor: AppColors.success,
      borderWidth: 1,
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

/// Rejects input when the parsed numeric value exceeds [maxValue].
///
/// Use alongside [FilteringTextInputFormatter.digitsOnly] (or a decimal
/// regex formatter) so that the text is always a valid number before
/// this formatter inspects it.
class MaxValueInputFormatter extends TextInputFormatter {
  final num maxValue;

  const MaxValueInputFormatter(this.maxValue);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final parsed = num.tryParse(newValue.text);
    if (parsed == null || parsed > maxValue) return oldValue;
    return newValue;
  }
}

/// Color roles of the active theme.
///
/// Every getter reads from [palette], which [SettingsController] sets when the
/// theme is loaded or changed.
abstract final class AppColors {
  /// The palette all getters read from.
  static AppPalette palette = appPalettes[AppThemeId.charcoalLime]!;

  /// Page background.
  static Color get background => palette.background;

  /// Cards, dialogs, sheets and the navigation bar.
  static Color get surface => palette.surface;

  /// Input fields, chips and other raised elements on a surface.
  static Color get surfaceVariant => palette.surfaceVariant;

  /// Decorative borders and dividers.
  static Color get outline => palette.outline;

  /// Primary action color; use [onPrimary] for content on top of it.
  static Color get primary => palette.primary;

  /// Content color on [primary].
  static Color get onPrimary => palette.onPrimary;

  /// Secondary accent for highlights and info states.
  static Color get secondary => palette.secondary;

  /// Content color on [secondary].
  static Color get onSecondary => palette.onSecondary;

  /// Completion and success state.
  static Color get success => palette.success;

  /// Content color on [success].
  static Color get onSuccess => palette.onSuccess;

  /// Danger, error and destructive state.
  static Color get error => palette.error;

  /// Content color on [error].
  static Color get onError => palette.onError;

  /// Main text color.
  static Color get textPrimary => palette.textPrimary;

  /// Secondary text color for labels and supporting text.
  static Color get textSecondary => palette.textSecondary;

  /// Muted text color for hints and inactive content.
  static Color get textDisabled => palette.textDisabled;

  /// Dimmer variant of [primary] that is still readable as text.
  static Color get accentMuted => palette.accentMuted;

  /// Decorative fill variant of [primary].
  static Color get accentMutedFill => palette.accentMutedFill;
}

/// Builds the app-wide [ThemeData] for a palette.
abstract final class AppTheme {
  /// Returns the [ThemeData] for [p]; apply it as `theme:` in the app.
  static ThemeData from(AppPalette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.brightness == Brightness.dark
          ? p.primary
          : p.textPrimary,
      secondary: p.secondary,
      onSecondary: p.onSecondary,
      secondaryContainer: p.secondaryContainer,
      onSecondaryContainer: p.brightness == Brightness.dark
          ? p.secondary
          : p.textPrimary,
      tertiary: p.success,
      onTertiary: p.onSuccess,
      tertiaryContainer: p.successContainer,
      onTertiaryContainer: p.brightness == Brightness.dark
          ? p.success
          : p.textPrimary,
      error: p.error,
      onError: p.onError,
      errorContainer: p.errorContainer,
      onErrorContainer: p.onErrorContainer,
      surface: p.surface,
      onSurface: p.textPrimary,
      surfaceContainerHighest: p.surfaceVariant,
      onSurfaceVariant: p.textSecondary,
      outline: p.outline,
      outlineVariant: p.outlineVariant,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: p.textPrimary,
      onInverseSurface: p.background,
      inversePrimary: p.primaryContainer,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        systemOverlayStyle: p.brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: p.textSecondary),
        actionsIconTheme: IconThemeData(color: p.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: p.outline),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.outline,
          disabledForegroundColor: p.textDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.textSecondary,
          side: BorderSide(color: p.outline),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: p.primary,
        foregroundColor: p.onPrimary,
        elevation: 4,
        shape: const CircleBorder(),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: p.primary,
        unselectedItemColor: p.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.outline),
        ),
        labelStyle: TextStyle(color: p.textSecondary),
        hintStyle: TextStyle(color: p.textDisabled),
        prefixIconColor: p.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceVariant,
        selectedColor: p.primary,
        disabledColor: p.outline,
        labelStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: p.onPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: p.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dividerTheme: DividerThemeData(color: p.outline, thickness: 1, space: 1),
      listTileTheme: ListTileThemeData(
        iconColor: p.textSecondary,
        textColor: p.textPrimary,
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.outline,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: p.outline),
        ),
        titleTextStyle: TextStyle(
          color: p.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: TextStyle(color: p.textSecondary, fontSize: 14),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: p.textSecondary,
        collapsedIconColor: p.textSecondary,
        textColor: p.textPrimary,
        collapsedTextColor: p.textPrimary,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      iconTheme: IconThemeData(color: p.textSecondary, size: 22),
      textTheme: _textTheme(p),
    );
  }

  /// Returns the app typography colored for [p].
  ///
  /// Headings use heavy weights; `labelLarge` is used for numeric readouts
  /// such as sets, reps, weights and timers.
  static TextTheme _textTheme(AppPalette p) {
    return TextTheme(
      displayLarge: TextStyle(
        color: p.textPrimary,
        fontSize: 57,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
      ),
      displayMedium: TextStyle(
        color: p.textPrimary,
        fontSize: 45,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
      ),
      displaySmall: TextStyle(
        color: p.textPrimary,
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        color: p.textPrimary,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: p.textPrimary,
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      headlineSmall: TextStyle(
        color: p.textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        color: p.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        color: p.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: p.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      bodyLarge: TextStyle(
        color: p.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: p.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: p.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: p.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      labelMedium: TextStyle(
        color: p.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        color: p.textDisabled,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
      ),
    );
  }
}
