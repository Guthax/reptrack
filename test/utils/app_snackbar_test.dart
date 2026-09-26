import 'package:flutter_test/flutter_test.dart';
import 'package:reptrack/utils/app_theme.dart';

void main() {
  tearDown(AppSnackbar.resetForTest);

  group('AppSnackbar.overrideErrorForTest', () {
    test('routes error messages to the provided handler', () {
      final messages = <String>[];
      AppSnackbar.overrideErrorForTest(messages.add);
      AppSnackbar.error('Enter a duration');
      expect(messages, ['Enter a duration']);
    });
  });
}
