import 'package:equatable/equatable.dart';

import 'line_numbering_breakpoint.dart';

class HiddenLineRanges with EquatableMixin {
  final List<LineNumberingBreakpoint> breakpoints;
  final int fullLineCount;
  final int visibleLineCount;

  const HiddenLineRanges({
    required this.breakpoints,
    required this.fullLineCount,
    required this.visibleLineCount,
  });

  static const empty = HiddenLineRanges(
    breakpoints: [],
    fullLineCount: 1,
    visibleLineCount: 1,
  );

  /// Returns the visible line index to which the full [lineIndex] maps
  /// and null if the line is hidden.
  ///
  /// Without breakpoints, returns [lineIndex] unchanged.
  /// At a breakpoint, returns its `visibleLineIndex`.
  /// Otherwise finds a next or previous breakpoint
  /// Before the first breakpoint, returns [lineIndex] unchanged.
  /// Otherwise finds the first preceding breakpoint and uses subtracts
  /// its spread from [lineIndex].
  ///
  /// [lineIndex] can be any integer including negative or >= [fullLineCount].
  int? cutLineIndexIfVisible(int lineIndex) {
    if (breakpoints.isEmpty) {
      return lineIndex;
    }

    int lower = 0;
    int upper = breakpoints.length - 1;

    // Linear interpolation search.
    while (upper > lower) {
      final lowerLineIndex = breakpoints[lower].full;
      final upperLineIndex = breakpoints[upper].full;

      final index = (lower +
              (lineIndex - lowerLineIndex) /
                  (upperLineIndex - lowerLineIndex) *
                  (upper - lower))
          .floor();

      if (index < lower) {
        return breakpoints[lower].cutLineIndexIfVisible(lineIndex);
      }
      if (index > upper) {
        return breakpoints[upper].cutLineIndexIfVisible(lineIndex);
      }

      final breakpoint = breakpoints[index];

      switch ((breakpoint.full - lineIndex).sign) {
        case -1:
          lower = index + 1;
          continue;
        case 1:
          upper = index - 1;
          continue;
      }

      return breakpoint.visible;
    }

    // upper == lower
    final breakpoint = breakpoints[upper];
    return breakpoint.cutLineIndexIfVisible(lineIndex);
  }

  Iterable<int> get visibleLineNumbers sync* {
    int n = 0;
    int? firstReturnedValue;

    for (final breakpoint in breakpoints) {
      final to = breakpoint.fullBefore;

      while (n < to) {
        yield n++;
      }

      n = breakpoint.full;
    }

    while (n < fullLineCount) {
      yield n++;
    }
  }

  @override
  List<Object> get props => [
        breakpoints,
      ];
}
