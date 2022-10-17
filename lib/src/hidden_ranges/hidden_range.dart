import '../code/text_range.dart';

class HiddenRange extends NormalizedTextRange {
  const HiddenRange({
    required super.start,
    required super.end,
  })  : assert(start >= 0, 'Start should be >= 0, $start given'),
        assert(end > start, 'Range should not be empty, $start-$end given');

  const HiddenRange.fromStartAndText(int start, String text)
      : super(
          start: start,
          end: start + text.length,
        );

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
}
