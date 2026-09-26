import 'package:flutter_test/flutter_test.dart';
import 'package:reptrack/utils/duration_format.dart';

void main() {
  group('formatDuration', () {
    test('formats zero as 0:00', () {
      expect(formatDuration(0), '0:00');
    });

    test('pads seconds below one minute', () {
      expect(formatDuration(45), '0:45');
    });

    test('formats minutes and seconds', () {
      expect(formatDuration(75), '1:15');
    });

    test('switches to h:mm:ss at one hour', () {
      expect(formatDuration(3600), '1:00:00');
    });

    test('formats hours, minutes and seconds', () {
      expect(formatDuration(4530), '1:15:30');
    });
  });

  group('formatTimedSet', () {
    test('shows the duration alone without a weight', () {
      expect(formatTimedSet(75), '1:15');
    });

    test('appends the weight text', () {
      expect(formatTimedSet(20, weightText: '10 kg'), '0:20 · 10 kg');
    });

    test('shows no time recorded for converted sets', () {
      expect(formatTimedSet(0), 'no time recorded');
    });

    test('keeps the weight of converted sets', () {
      expect(
        formatTimedSet(0, weightText: '20 kg'),
        'no time recorded · 20 kg',
      );
    });
  });

  group('targetProgress', () {
    test('returns the fraction of the target', () {
      expect(targetProgress(30, 60), 0.5);
    });

    test('caps at 1.0 past the target', () {
      expect(targetProgress(90, 60), 1.0);
    });

    test('returns 0.0 at the start', () {
      expect(targetProgress(0, 60), 0.0);
    });

    test('returns null without a target', () {
      expect(targetProgress(30, 0), isNull);
    });
  });
}
