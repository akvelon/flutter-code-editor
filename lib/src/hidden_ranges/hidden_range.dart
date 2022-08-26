import 'package:meta/meta.dart';

import '../code/text_range.dart';

@immutable
class HiddenRange extends NormalizedTextRange {
  final String text;

  const HiddenRange({
    required super.start,
    required super.end,
    required this.text,
  })  : assert(start >= 0, 'Start should be >= 0, $start given'),
        assert(
          text.length == end - start,
          'Length of $text is not equal to $end - $start',
        );

  const HiddenRange.fromStartAndText(int start, this.text)
      : super(
          start: start,
          end: start + text.length,
        );

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        text,
      );

  @override
  bool operator ==(Object other) {
    return super == other && other is HiddenRange && text == other.text;
  }
}
