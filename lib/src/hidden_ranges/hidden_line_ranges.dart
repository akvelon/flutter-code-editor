import 'package:equatable/equatable.dart';

import 'line_numbering_breakpoint.dart';

class HiddenLineRanges with EquatableMixin {
  final List<LineNumberingBreakpoint> breakpoints;
  final int fullLineCount;

  final List<int?> _fullToVisible;
  final List<int> _visibleToFull;

  factory HiddenLineRanges({
    required List<LineNumberingBreakpoint> breakpoints,
    required int fullLineCount,
  }) {
    final fullToVisible = List<int?>.filled(fullLineCount, null);
    final visibleToFull = List<int>.filled(fullLineCount, 0);

    int n = 0;

    var fullToVisibleIndex = 0;
    var visibleToFullIndex = 0;

    for (final breakpoint in breakpoints) {
      final to = breakpoint.fullBefore;

      while (n < to) {
        visibleToFull[visibleToFullIndex] = n++;
        fullToVisible[fullToVisibleIndex++] = visibleToFullIndex++;
      }

      fullToVisibleIndex = breakpoint.full;

      n = breakpoint.full;
    }

    while (n < fullLineCount) {
      visibleToFull[visibleToFullIndex] = n++;
      fullToVisible[fullToVisibleIndex++] = visibleToFullIndex++;
    }

    return HiddenLineRanges._(
      fullLineCount: fullLineCount,
      breakpoints: breakpoints,
      fullToVisible: fullToVisible,
      visibleToFull: visibleToFull.sublist(0, visibleToFullIndex),
    );
  }

  const HiddenLineRanges._({
    required this.breakpoints,
    required this.fullLineCount,
    required List<int?> fullToVisible,
    required List<int> visibleToFull,
  })  : _fullToVisible = fullToVisible,
        _visibleToFull = visibleToFull;

  static const empty = HiddenLineRanges._(
    breakpoints: [],
    fullLineCount: 1,
    fullToVisible: [0],
    visibleToFull: [0],
  );

  int? cutLineIndexIfVisible(int lineIndex) {
    return _fullToVisible[lineIndex];
  }

  int recoverLineIndex(int visibleLineIndex) {
    return _visibleToFull[visibleLineIndex];
  }

  Iterable<int> get visibleLineNumbers => _visibleToFull;

  @override
  List<Object> get props => [
        breakpoints,
      ];
}
