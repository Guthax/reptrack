import 'package:get/get.dart';
import 'package:reptrack/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes user preferences.
///
/// Registered as a permanent singleton in [main] so the setting survives
/// navigation resets. The unit preference is persisted via [SharedPreferences].
class SettingsController extends GetxController {
  static const _keyUseImperial = 'use_imperial';
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyExpandDayHintSeen = 'expand_day_hint_seen';

  final RxBool useImperial = false.obs;
  final RxBool isFirstLaunch = true.obs;

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

  /// Converts a kg value to the currently selected display unit.
  double displayWeight(double kg) => useImperial.value ? kg * kKgToLbs : kg;

  /// Converts a value entered in the current display unit back to kg.
  double toKg(double displayValue) =>
      useImperial.value ? displayValue / kKgToLbs : displayValue;

  /// The label for the current unit ('kg' or 'lbs').
  String get unitLabel => useImperial.value ? 'lbs' : 'kg';
}
