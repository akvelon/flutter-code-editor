import 'package:equatable/equatable.dart';

import 'line_numbering_breakpoint.dart';

class HiddenLineRanges with EquatableMixin {
  final List<LineNumberingBreakpoint> breakpoints;
  final int fullLineCount;
  final int visibleLineCount;

  final List<int?> _fullToVisible;
  final List<int> _visibleToFull;

  factory HiddenLineRanges({
    required List<LineNumberingBreakpoint> breakpoints,
    required int fullLineCount,
    required int visibleLineCount,
  }) {
    final fullToVisible = <int?>[];
    final visibleToFull = <int>[];

    int n = 0;

    for (final breakpoint in breakpoints) {
      final to = breakpoint.fullBefore;

      while (n < to) {
        visibleToFull.add(n++);
        fullToVisible.add(visibleToFull.length - 1);
      }

      fullToVisible.addAll(List.generate(breakpoint.full - n, (index) => null));

      n = breakpoint.full;
    }

    while (n < fullLineCount) {
      visibleToFull.add(n++);
      fullToVisible.add(visibleToFull.length - 1);
    }

    return HiddenLineRanges._(
      fullLineCount: fullLineCount,
      visibleLineCount: visibleLineCount,
      breakpoints: breakpoints,
      fullToVisible: fullToVisible,
      visibleToFull: visibleToFull,
    );
  }

  const HiddenLineRanges._({
    required this.breakpoints,
    required this.fullLineCount,
    required this.visibleLineCount,
    required List<int?> fullToVisible,
    required List<int> visibleToFull,
  })  : _fullToVisible = fullToVisible,
        _visibleToFull = visibleToFull;

  static const empty = HiddenLineRanges._(
    breakpoints: [],
    fullLineCount: 1,
    visibleLineCount: 1,
    fullToVisible: [0],
    visibleToFull: [],
  );

  int? cutLineIndexIfVisible(int lineIndex) {
    return _fullToVisible[lineIndex];
  }

  int recoverLineIndex(int visibleLineIndex) {
    return _visibleToFull[visibleLineIndex];
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
