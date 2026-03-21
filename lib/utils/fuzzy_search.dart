int levenshtein(String a, String b) {
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  final dp = List.generate(a.length + 1, (i) => List.filled(b.length + 1, 0));
  for (int i = 0; i <= a.length; i++) {
    dp[i][0] = i;
  }
  for (int j = 0; j <= b.length; j++) {
    dp[0][j] = j;
  }
  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1];
      } else {
        dp[i][j] =
            1 +
            [
              dp[i - 1][j],
              dp[i][j - 1],
              dp[i - 1][j - 1],
            ].reduce((x, y) => x < y ? x : y);
      }
    }
  }
  return dp[a.length][b.length];
}

/// Returns a match score (lower = better) or null if the query is too distant.
/// Score 0 means a direct substring match.
int? fuzzyMatchScore(String name, String query) {
  final n = name.toLowerCase();
  final q = query.toLowerCase();
  if (n.contains(q)) return 0;

  int best = 999;
  final qLen = q.length;

  // Check each word in the name
  for (final word in n.split(' ')) {
    final compareLen = word.length < qLen ? word.length : qLen;
    final dist = levenshtein(q, word.substring(0, compareLen));
    if (dist < best) best = dist;
  }

  // Sliding window over full name
  if (qLen <= n.length) {
    for (int i = 0; i <= n.length - qLen; i++) {
      final dist = levenshtein(q, n.substring(i, i + qLen));
      if (dist < best) best = dist;
    }
  }

  final threshold = (qLen / 3).ceil();
  return best <= threshold ? best : null;
}

/// Filters and sorts [items] by fuzzy match score against [query].
List<T> fuzzyFilter<T>(
  List<T> items,
  String query,
  String Function(T) getName,
) {
  if (query.isEmpty) return items;
  final scored = <MapEntry<T, int>>[];
  for (final item in items) {
    final score = fuzzyMatchScore(getName(item), query);
    if (score != null) scored.add(MapEntry(item, score));
  }
  scored.sort((a, b) => a.value.compareTo(b.value));
  return scored.map((e) => e.key).toList();
}
