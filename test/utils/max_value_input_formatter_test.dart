import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reptrack/utils/app_theme.dart';

void main() {
  group('MaxValueInputFormatter', () {
    TextEditingValue val(String text) => TextEditingValue(text: text);

    group('with integer max of 100', () {
      const formatter = MaxValueInputFormatter(100);

      test('empty new value is always accepted', () {
        final result = formatter.formatEditUpdate(val('50'), val(''));
        expect(result.text, '');
      });

      test('value of 1 is accepted', () {
        final result = formatter.formatEditUpdate(val(''), val('1'));
        expect(result.text, '1');
      });

      test('value equal to max is accepted', () {
        final result = formatter.formatEditUpdate(val('99'), val('100'));
        expect(result.text, '100');
      });

      test('value below max is accepted', () {
        final result = formatter.formatEditUpdate(val('0'), val('50'));
        expect(result.text, '50');
      });

      test('value above max returns old value', () {
        final result = formatter.formatEditUpdate(val('99'), val('101'));
        expect(result.text, '99');
      });

      test('non-numeric text returns old value', () {
        final result = formatter.formatEditUpdate(val('50'), val('abc'));
        expect(result.text, '50');
      });

      test('zero is accepted', () {
        final result = formatter.formatEditUpdate(val(''), val('0'));
        expect(result.text, '0');
      });
    });

    group('with decimal max of 999.9', () {
      const formatter = MaxValueInputFormatter(999.9);

      test('decimal value below max is accepted', () {
        final result = formatter.formatEditUpdate(val('0'), val('999.8'));
        expect(result.text, '999.8');
      });

      test('decimal value equal to max is accepted', () {
        final result = formatter.formatEditUpdate(val('0'), val('999.9'));
        expect(result.text, '999.9');
      });

      test('decimal value above max returns old value', () {
        final result = formatter.formatEditUpdate(val('0'), val('1000.0'));
        expect(result.text, '0');
      });
    });

    group('cursor position preservation', () {
      test('accepted value preserves selection from new value', () {
        const formatter = MaxValueInputFormatter(100);
        const newVal = TextEditingValue(
          text: '50',
          selection: TextSelection.collapsed(offset: 2),
        );
        final result = formatter.formatEditUpdate(val('5'), newVal);
        expect(result.selection, newVal.selection);
      });

      test('rejected value restores old selection', () {
        const formatter = MaxValueInputFormatter(100);
        const oldVal = TextEditingValue(
          text: '99',
          selection: TextSelection.collapsed(offset: 2),
        );
        final result = formatter.formatEditUpdate(oldVal, val('200'));
        expect(result.selection, oldVal.selection);
      });
    });
  });
}
