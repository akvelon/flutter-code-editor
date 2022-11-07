import 'package:equatable/equatable.dart';

import 'line_numbering_breakpoint.dart';

class HiddenLineRanges with EquatableMixin {
  final List<LineNumberingBreakpoint> breakpoints;
  final int fullLineCount;

  const HiddenLineRanges({
    required this.breakpoints,
    required this.fullLineCount,
  });

  static const empty = HiddenLineRanges(
    breakpoints: [],
    fullLineCount: 1,
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
    if (lineIndex <= breakpoints.first.full) {
      return breakpoints.first.cutLineIndexIfVisible(lineIndex);
    }
    if (lineIndex >= breakpoints.last.full) {
      return breakpoints.last.cutLineIndexIfVisible(lineIndex);
    }

    // At this point, we always have a breakpoint before and after.

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

      final breakpoint = breakpoints[index];

      switch ((breakpoint.full - lineIndex).sign) {
        case -1: // We are after this breakpoint.
          final nextBreakpoint = breakpoints[index + 1];
          if (nextBreakpoint.full > lineIndex) {
            // ... and before the next one.
            return nextBreakpoint.cutLineIndexIfVisible(lineIndex);
          }
          lower = index + 1;
          continue;

        case 1: // We are before this breakpoint.
          final previousBreakpoint = breakpoints[index - 1];
          if (previousBreakpoint.full < lineIndex) {
            // ... and after the previous one.
            return breakpoint.cutLineIndexIfVisible(lineIndex);
          }
          upper = index - 1;
          continue;
      }

      return breakpoint.visible;
    }

    throw Exception('Never get here');
  }

  Iterable<int> get visibleLineNumbers sync* {
    int n = 0;

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
