/// Formats [seconds] as `m:ss` below one hour and `h:mm:ss` from one hour up.
String formatDuration(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = (seconds % 60).toString().padLeft(2, '0');
  if (h > 0) return '$h:${m.toString().padLeft(2, '0')}:$s';
  return '$m:$s';
}

/// Formats a logged timed set for history lists.
///
/// Returns "no time recorded" for converted sets with a [durationSeconds] of
/// 0, otherwise the formatted duration followed by ` · [weightText]` when a
/// weight text is given.
String formatTimedSet(int durationSeconds, {String? weightText}) {
  if (durationSeconds == 0) {
    return weightText == null
        ? 'no time recorded'
        : 'no time recorded · $weightText';
  }
  final duration = formatDuration(durationSeconds);
  return weightText == null ? duration : '$duration · $weightText';
}

/// Returns the fraction of [targetSeconds] reached by [seconds], clamped to
/// 0–1, or null when there is no target.
double? targetProgress(int seconds, int targetSeconds) {
  if (targetSeconds <= 0) return null;
  return (seconds / targetSeconds).clamp(0.0, 1.0);
}
