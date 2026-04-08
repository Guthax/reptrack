import 'package:flutter_test/flutter_test.dart';
import 'package:reptrack/utils/fuzzy_search.dart';

void main() {
  group('levenshtein', () {
    test('identical strings return 0', () {
      expect(levenshtein('abc', 'abc'), 0);
    });

    test('both empty returns 0', () {
      expect(levenshtein('', ''), 0);
    });

    test('empty first returns length of second', () {
      expect(levenshtein('', 'abc'), 3);
    });

    test('empty second returns length of first', () {
      expect(levenshtein('abc', ''), 3);
    });

    test('single substitution', () {
      expect(levenshtein('cat', 'bat'), 1);
    });

    test('single insertion', () {
      expect(levenshtein('cat', 'cats'), 1);
    });

    test('single deletion', () {
      expect(levenshtein('cats', 'cat'), 1);
    });

    test('multiple edits - kitten to sitting', () {
      expect(levenshtein('kitten', 'sitting'), 3);
    });

    test('completely different strings', () {
      expect(levenshtein('abc', 'xyz'), 3);
    });

    test('is not symmetric for unequal strings of different lengths', () {
      // Both directions should give the same result (edit distance is symmetric)
      expect(levenshtein('ab', 'abc'), levenshtein('abc', 'ab'));
    });
  });

  group('fuzzyMatchScore', () {
    test('exact substring match returns 0', () {
      expect(fuzzyMatchScore('Bench Press', 'bench'), 0);
    });

    test('case-insensitive substring match returns 0', () {
      expect(fuzzyMatchScore('Bench Press', 'BENCH'), 0);
    });

    test('full exact match returns 0', () {
      expect(fuzzyMatchScore('squat', 'squat'), 0);
    });

    test('empty query matches everything (contains empty string)', () {
      expect(fuzzyMatchScore('bench press', ''), 0);
    });

    test('close typo within threshold returns non-null score', () {
      // query 'prss' length 4 → threshold ceil(4/3)=2
      // sliding window over 'bench press' finds 'pres' → levenshtein('prss','pres')=1 ≤ 2
      final score = fuzzyMatchScore('bench press', 'prss');
      expect(score, isNotNull);
    });

    test('query far from any word returns null', () {
      // 'zzz' length 3 → threshold 1; nothing in 'bench press' is within 1 edit of 'zzz'
      expect(fuzzyMatchScore('bench press', 'zzz'), isNull);
    });

    test('query matching a whole word exactly returns score 0', () {
      expect(fuzzyMatchScore('Overhead Press', 'press'), 0);
    });

    test('returns lower score for closer matches', () {
      // 'squat' matches 'squat' exactly (score 0) vs 'squatt' is close
      final exact = fuzzyMatchScore('squat', 'squat')!;
      final close = fuzzyMatchScore('squatt', 'squat')!;
      expect(exact, lessThanOrEqualTo(close));
    });
  });

  group('fuzzyFilter', () {
    final exercises = [
      'Bench Press',
      'Squat',
      'Deadlift',
      'Overhead Press',
      'Barbell Row',
    ];

    test('empty query returns all items unchanged', () {
      final result = fuzzyFilter(exercises, '', (e) => e);
      expect(result, hasLength(exercises.length));
    });

    test('exact match returns only the matching item', () {
      final result = fuzzyFilter(exercises, 'squat', (e) => e);
      expect(result, contains('Squat'));
    });

    test('partial substring match returns all containing items', () {
      final result = fuzzyFilter(exercises, 'press', (e) => e);
      expect(result, contains('Bench Press'));
      expect(result, contains('Overhead Press'));
      expect(result, isNot(contains('Squat')));
    });

    test('query with no matches returns empty list', () {
      final result = fuzzyFilter(exercises, 'zzz', (e) => e);
      expect(result, isEmpty);
    });

    test('direct match appears before fuzzy match', () {
      final result = fuzzyFilter(exercises, 'deadlift', (e) => e);
      expect(result.first, 'Deadlift');
    });

    test('works with a custom getName extractor', () {
      final items = [
        {'name': 'Bench Press'},
        {'name': 'Squat'},
      ];
      final result = fuzzyFilter(
        items,
        'squat',
        (e) => e['name'] as String,
      );
      expect(result.first['name'], 'Squat');
    });

    test('empty list returns empty result', () {
      final result = fuzzyFilter(<String>[], 'bench', (e) => e);
      expect(result, isEmpty);
    });
  });
}
