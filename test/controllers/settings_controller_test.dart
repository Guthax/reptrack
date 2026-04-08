import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:reptrack/constants.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
  });

  tearDown(Get.reset);

  SettingsController make() => SettingsController();

  group('displayWeight', () {
    test('returns same value in metric mode', () {
      final c = make()..useImperial.value = false;
      expect(c.displayWeight(80.0), 80.0);
    });

    test('converts kg to lbs in imperial mode', () {
      final c = make()..useImperial.value = true;
      expect(c.displayWeight(1.0), closeTo(kKgToLbs, 0.0001));
    });

    test('zero weight is always zero', () {
      final c = make()..useImperial.value = true;
      expect(c.displayWeight(0.0), 0.0);
    });
  });

  group('toKg', () {
    test('returns same value in metric mode', () {
      final c = make()..useImperial.value = false;
      expect(c.toKg(80.0), 80.0);
    });

    test('converts lbs back to kg in imperial mode', () {
      final c = make()..useImperial.value = true;
      expect(c.toKg(kKgToLbs), closeTo(1.0, 0.0001));
    });

    test('displayWeight and toKg are inverse operations', () {
      final c = make()..useImperial.value = true;
      const kg = 75.0;
      expect(c.toKg(c.displayWeight(kg)), closeTo(kg, 0.0001));
    });
  });

  group('unitLabel', () {
    test('returns "kg" in metric mode', () {
      final c = make()..useImperial.value = false;
      expect(c.unitLabel, 'kg');
    });

    test('returns "lbs" in imperial mode', () {
      final c = make()..useImperial.value = true;
      expect(c.unitLabel, 'lbs');
    });
  });

  group('setImperial', () {
    test('updates useImperial reactive value to true', () async {
      final c = make();
      await c.setImperial(true);
      expect(c.useImperial.value, isTrue);
    });

    test('updates useImperial reactive value to false', () async {
      final c = make()..useImperial.value = true;
      await c.setImperial(false);
      expect(c.useImperial.value, isFalse);
    });

    test('persists value so a new controller loads it', () async {
      final c = make();
      await c.setImperial(true);
      final c2 = make();
      await c2.load();
      expect(c2.useImperial.value, isTrue);
    });
  });

  group('load', () {
    test('defaults to metric when no value is stored', () async {
      final c = make();
      await c.load();
      expect(c.useImperial.value, isFalse);
    });

    test('isFirstLaunch is true when onboarding not yet seen', () async {
      final c = make();
      await c.load();
      expect(c.isFirstLaunch.value, isTrue);
    });

    test('isFirstLaunch is false after markOnboardingSeen', () async {
      final c = make();
      await c.markOnboardingSeen();
      final c2 = make();
      await c2.load();
      expect(c2.isFirstLaunch.value, isFalse);
    });
  });

  group('onboarding hint chain', () {
    test('markOnboardingSeen arms the add-program hint', () async {
      final c = make();
      await c.markOnboardingSeen();
      expect(c.showAddProgramHint.value, isTrue);
    });

    test('dismissAddProgramHint advances to add-day hint', () {
      final c = make()..showAddProgramHint.value = true;
      c.dismissAddProgramHint();
      expect(c.showAddProgramHint.value, isFalse);
      expect(c.showAddDayHint.value, isTrue);
    });

    test('dismissAddDayHint hides add-day hint', () async {
      final c = make()..showAddDayHint.value = true;
      await c.dismissAddDayHint();
      expect(c.showAddDayHint.value, isFalse);
    });

    test('dismissExpandDayHint hides expand-day hint', () async {
      final c = make()..showExpandDayHint.value = true;
      await c.dismissExpandDayHint();
      expect(c.showExpandDayHint.value, isFalse);
    });

    test('expand-day hint does not reappear after being dismissed', () async {
      final c = make();
      await c.dismissExpandDayHint();
      // A subsequent dismissAddDayHint should NOT re-arm the expand-day hint
      // because the 'seen' key is already stored.
      await c.dismissAddDayHint();
      expect(c.showExpandDayHint.value, isFalse);
    });
  });
}
