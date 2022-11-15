import '../code/code_lines.dart';
import 'hidden_line_ranges.dart';
import 'hidden_ranges.dart';
import 'line_numbering_breakpoint.dart';

class HiddenLineRangesBuilder {
  final HiddenLineRanges hiddenLineRanges;

  factory HiddenLineRangesBuilder({
    required CodeLines codeLines,
    required HiddenRanges hiddenRanges,
  }) {
    final breakpoints = <LineNumberingBreakpoint>[];
    int spread = 0;

    for (final range in hiddenRanges.ranges) {
      final startLine = range.firstLine;
      final endLine = codeLines.characterIndexToLineIndex(range.end);
      final newlines = endLine - startLine;

      if (newlines == 0) {
        continue;
      }

      // If there is anything on the start line before the hidden range,
      // that content is visible so the line is not affected by the breakpoint,
      // and the breakpoint happens on the next line instead.
      //
      // Example 1 ('abc' is in the first line before the hidden range):
      //   0  abcde      0  abcde
      //   1  fghXX  ->  1  fghij
      //   2  XXXXX      2  klmno
      //   3  XXXij
      //   4  klmno
      // maps as 0 -> 0, 1 -> 1, 4 -> 2
      //                           ^- this is the only breakpoint here.
      //
      // Example 2 (the hidden range starts at the beginning of the line):
      //   0  abcde      0  abcde
      //   1  XXXXX  ->  1  ij
      //   2  XXXXX      2  klmno
      //   3  XXXij
      //   4  klmno
      // maps as 0 -> 0, 3 -> 1, 4 -> 2
      //                   ^- this is the only breakpoint here.
      final add = range.wholeFirstLine ? 0 : 1;

      breakpoints.add(
        LineNumberingBreakpoint(
          full: endLine + add,
          visible: endLine + add - spread - newlines,
          spreadBefore: spread,
        ),
      );

      spread += newlines;
    }

    return HiddenLineRangesBuilder._(
      hiddenLineRanges: HiddenLineRanges(
        breakpoints: breakpoints,
        fullLineCount: codeLines.lines.length,
      ),
    );
  }

  const HiddenLineRangesBuilder._({
    required this.hiddenLineRanges,
  });
}
