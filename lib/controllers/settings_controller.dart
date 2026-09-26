import 'package:get/get.dart';
import 'package:reptrack/constants.dart';
import 'package:reptrack/utils/app_palette.dart';
import 'package:reptrack/utils/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes user preferences.
///
/// Registered as a permanent singleton in [main] so the setting survives
/// navigation resets. The unit and theme preferences are persisted via
/// [SharedPreferences].
class SettingsController extends GetxController {
  static const _keyUseImperial = 'use_imperial';
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyExpandDayHintSeen = 'expand_day_hint_seen';
  static const _keyThemeId = 'theme_id';
  final RxBool useImperial = false.obs;
  final RxBool isFirstLaunch = true.obs;

  /// The selected color theme.
  final Rx<AppThemeId> themeId = AppThemeId.charcoalLime.obs;

  /// The palette of the selected color theme.
  AppPalette get palette => appPalettes[themeId.value]!;

  /// Set after onboarding; drives the coach-mark bubble on [ProgramsPage].
  final RxBool showAddProgramHint = false.obs;

  /// Set when the user creates their first program; drives the coach-mark
  /// bubble on [BuildProgramPage].
  final RxBool showAddDayHint = false.obs;

  /// Loads persisted preferences. Must be awaited in [main] before [runApp]
  /// so that [isFirstLaunch] is correct before the first frame is rendered.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    useImperial.value = prefs.getBool(_keyUseImperial) ?? false;
    isFirstLaunch.value = !(prefs.getBool(_keyOnboardingSeen) ?? false);
    themeId.value = appThemeIdFromName(prefs.getString(_keyThemeId));
    AppColors.palette = palette;
    if (prefs.getBool(_keyExpandDayHintSeen) ?? false) {
      showExpandDayHint.value = false;
    }
  }

  /// Marks the onboarding as completed so it is not shown again, and arms
  /// the first coach-mark hint on [ProgramsPage].
  Future<void> markOnboardingSeen() async {
    isFirstLaunch.value = false;
    showAddProgramHint.value = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingSeen, true);
  }

  /// Called when the user taps the add-program FAB; advances to the next hint.
  void dismissAddProgramHint() {
    showAddProgramHint.value = false;
    showAddDayHint.value = true;
  }

  /// Set when the add-day hint is dismissed; drives the expand-tile coach mark.
  final RxBool showExpandDayHint = false.obs;

  /// Called when the user taps the add-day button or dismisses that hint.
  Future<void> dismissAddDayHint() async {
    showAddDayHint.value = false;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_keyExpandDayHintSeen) ?? false)) {
      showExpandDayHint.value = true;
    }
  }

  /// Called when the user expands a workout day tile or dismisses that hint.
  /// Persists the seen state so the hint never shows again across sessions.
  Future<void> dismissExpandDayHint() async {
    showExpandDayHint.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyExpandDayHintSeen, true);
  }

  /// Toggles between kg and lbs and persists the choice.
  Future<void> setImperial(bool value) async {
    useImperial.value = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseImperial, value);
  }

  /// Selects the color theme [id], applies it to [AppColors] and persists it.
  Future<void> setTheme(AppThemeId id) async {
    themeId.value = id;
    AppColors.palette = palette;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeId, id.name);
  }

  /// Converts a kg value to the currently selected display unit.
  double displayWeight(double kg) => useImperial.value ? kg * kKgToLbs : kg;

  /// Converts a value entered in the current display unit back to kg.
  double toKg(double displayValue) =>
      useImperial.value ? displayValue / kKgToLbs : displayValue;

  /// The label for the current unit ('kg' or 'lbs').
  String get unitLabel => useImperial.value ? 'lbs' : 'kg';
}
