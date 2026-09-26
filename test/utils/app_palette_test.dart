import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reptrack/utils/app_palette.dart';

void main() {
  group('contrastRatio', () {
    test('black on white is 21', () {
      expect(
        contrastRatio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21, 0.01),
      );
    });

    test('identical colors give 1', () {
      expect(
        contrastRatio(const Color(0xFF8B97B0), const Color(0xFF8B97B0)),
        closeTo(1, 0.0001),
      );
    });

    test('is symmetric', () {
      const a = Color(0xFFC6FF00);
      const b = Color(0xFF1A1D26);
      expect(contrastRatio(a, b), contrastRatio(b, a));
    });

    test('old Charcoal & Lime values fail the text rule', () {
      expect(
        contrastRatio(const Color(0xFF4A5568), const Color(0xFF232733)),
        lessThan(4.5),
      );
      expect(
        contrastRatio(const Color(0xFFFFFFFF), const Color(0xFFFF3347)),
        lessThan(4.5),
      );
      expect(
        contrastRatio(const Color(0xFFFFFFFF), const Color(0xFF39E07C)),
        lessThan(4.5),
      );
    });
  });

  group('appThemeIdFromName', () {
    test('null falls back to charcoalLime', () {
      expect(appThemeIdFromName(null), AppThemeId.charcoalLime);
    });

    test('unknown name falls back to charcoalLime', () {
      expect(appThemeIdFromName('unknown'), AppThemeId.charcoalLime);
    });

    test('known name resolves', () {
      expect(appThemeIdFromName('mangoNavy'), AppThemeId.mangoNavy);
    });
  });

  group('appPalettes', () {
    test('has a palette for every theme id in enum order', () {
      expect(appPalettes.keys.toList(), AppThemeId.values);
    });

    test('names follow "Primary & Secondary"', () {
      final names = appPalettes.values.map((p) => p.name).toList();
      expect(names, [
        'Charcoal & Lime',
        'Pink & White',
        'Charcoal & Cyan',
        'Mango & Navy',
      ]);
      for (final name in names) {
        expect(name, matches(RegExp(r'^[A-Z][a-z]+ & [A-Z][a-z]+$')));
      }
    });

    test('Pink & White is light, the others are dark', () {
      for (final entry in appPalettes.entries) {
        expect(
          entry.value.brightness,
          entry.key == AppThemeId.pinkWhite
              ? Brightness.light
              : Brightness.dark,
          reason: entry.value.name,
        );
      }
    });
  });

  group('contrast rules', () {
    for (final palette in appPalettes.values) {
      void check(String pair, Color fg, Color bg, double min) {
        final ratio = contrastRatio(fg, bg);
        expect(
          ratio,
          greaterThanOrEqualTo(min),
          reason:
              '${palette.name}: $pair is ${ratio.toStringAsFixed(2)}:1, '
              'needs $min:1',
        );
      }

      test('${palette.name} text roles meet 4.5:1 on all backgrounds', () {
        final texts = {
          'textPrimary': palette.textPrimary,
          'textSecondary': palette.textSecondary,
          'textDisabled': palette.textDisabled,
        };
        final backgrounds = {
          'background': palette.background,
          'surface': palette.surface,
          'surfaceVariant': palette.surfaceVariant,
        };
        for (final t in texts.entries) {
          for (final b in backgrounds.entries) {
            check('${t.key}/${b.key}', t.value, b.value, 4.5);
          }
        }
      });

      test('${palette.name} accents meet 4.5:1 on background and surface '
          'and 3:1 on surfaceVariant', () {
        final accents = {
          'primary': palette.primary,
          'secondary': palette.secondary,
          'success': palette.success,
          'error': palette.error,
          'accentMuted': palette.accentMuted,
        };
        for (final a in accents.entries) {
          check('${a.key}/background', a.value, palette.background, 4.5);
          check('${a.key}/surface', a.value, palette.surface, 4.5);
          check('${a.key}/surfaceVariant', a.value, palette.surfaceVariant, 3);
        }
      });

      test('${palette.name} content colors meet 4.5:1 on their fills', () {
        check('onPrimary/primary', palette.onPrimary, palette.primary, 4.5);
        check(
          'onSecondary/secondary',
          palette.onSecondary,
          palette.secondary,
          4.5,
        );
        check('onSuccess/success', palette.onSuccess, palette.success, 4.5);
        check('onError/error', palette.onError, palette.error, 4.5);
        check(
          'onErrorContainer/errorContainer',
          palette.onErrorContainer,
          palette.errorContainer,
          4.5,
        );
        check('textPrimary/outline', palette.textPrimary, palette.outline, 4.5);
      });
    }
  });
}
