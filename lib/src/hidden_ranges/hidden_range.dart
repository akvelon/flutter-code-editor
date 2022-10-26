import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../code/text_range.dart';

@immutable
class HiddenRange extends NormalizedTextRange with EquatableMixin {
  final int firstLine;
  final int lastLine;
  final bool wholeFirstLine;

  const HiddenRange(
    int start,
    int end, {
    required this.firstLine,
    required this.lastLine,
    required this.wholeFirstLine,
  })  : assert(start >= 0, 'Start should be >= 0, $start given'),
        assert(end > start, 'Range should not be empty, $start-$end given'),
        assert(
          lastLine >= firstLine,
          'lastLine must be >= firstLine, $firstLine-$lastLine given',
        ),
        super(start: start, end: end);

  int get length => end - start;

  /// Sorts by [start], then by [end].
  static int sort(HiddenRange a, HiddenRange b) {
    switch ((a.start - b.start).sign) {
      case -1:
        return -1;
      case 1:
        return 1;
    }

    return a.end - b.end;
  }

  @override
  bool operator ==(Object other) {
    return other is HiddenRange &&
        start == other.start &&
        end == other.end &&
        firstLine == other.firstLine &&
        lastLine == other.lastLine &&
        wholeFirstLine == other.wholeFirstLine;
  }

  //override hashCode
  @override
  int get hashCode => Object.hash(
        start,
        end,
        firstLine,
        lastLine,
        wholeFirstLine,
      );

  @override
  List<Object> get props => [
        start,
        end,
        firstLine,
        lastLine,
        wholeFirstLine,
      ];
}
