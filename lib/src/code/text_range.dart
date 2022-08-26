import 'dart:ui';

extension MyTextRange on TextRange {
  TextRange get normalized {
    return isNormalized ? this : TextRange(start: end, end: start);
  }

  bool isAfter(TextRange other) => start >= other.end;
}

class NormalizedTextRange extends TextRange {
  const NormalizedTextRange({required super.start, required super.end})
      : assert(
          end >= start,
          'End should be >= start, given end = $end, start = $start',
        );

  /// Returns 1 if the [position] is before the range,
  /// -1 if the [position] is after the range,
  /// and zero if the [position] is within the range.
  int compareToPosition(int position) {
    if (position < start) {
      return 1;
    }

    if (position >= end) {
      return -1;
    }

    return 0;
  }
}
