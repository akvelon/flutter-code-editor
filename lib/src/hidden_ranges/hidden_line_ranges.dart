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

    var fullIndex = 0;
    var visibleIndex = 0;

    for (final breakpoint in breakpoints) {
      final to = breakpoint.fullBefore;

      while (fullIndex < to) {
        visibleToFull[visibleIndex] = fullIndex;
        fullToVisible[fullIndex] = visibleIndex;
        fullIndex++;
        visibleIndex++;
      }

      fullIndex = breakpoint.full;
    }

    while (fullIndex < fullLineCount) {
      visibleToFull[visibleIndex] = fullIndex;
      fullToVisible[fullIndex] = visibleIndex;
      fullIndex++;
      visibleIndex++;
    }

    return HiddenLineRanges._(
      fullLineCount: fullLineCount,
      breakpoints: breakpoints,
      fullToVisible: fullToVisible,
      visibleToFull: visibleToFull.sublist(0, visibleIndex),
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
