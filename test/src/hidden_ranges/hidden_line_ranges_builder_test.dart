// ignore_for_file: use_named_constants

import 'package:flutter_code_editor/src/code/code_lines.dart';
import 'package:flutter_code_editor/src/code/code_lines_builder.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_line_ranges.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_line_ranges_builder.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_code_editor/src/hidden_ranges/line_numbering_breakpoint.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/lorem_ipsum.dart';

void main() {
  final codeLines = CodeLinesBuilder.textToCodeLines(
    text: loremIpsum,
    readonlyCommentsByLine: {},
  );

  group('HiddenLineRangesBuilder.', () {
    test('Empty text -> No breakpoints', () {
      final builder = HiddenLineRangesBuilder(
        codeLines: CodeLines.empty,
        hiddenRanges: HiddenRanges.empty,
      );

      expect(
        builder.hiddenLineRanges,
        const HiddenLineRanges(
          breakpoints: [],
          fullLineCount: 1,
          visibleLineCount: 1,
        ),
      );
    });

    test('No hidden ranges -> No breakpoints', () {
      final builder = HiddenLineRangesBuilder(
        codeLines: codeLines,
        hiddenRanges: HiddenRanges.empty,
      );

      expect(
        builder.hiddenLineRanges,
        const HiddenLineRanges(
          breakpoints: [],
          fullLineCount: 15,
          visibleLineCount: 15,
        ),
      );
    });

    test('Single line ranges only -> No breakpoints', () {
      final builder = HiddenLineRangesBuilder(
        codeLines: codeLines,
        hiddenRanges: HiddenRanges(
          ranges: const [
            HiddenRange(
              10,
              20,
              firstLine: 0,
              lastLine: 0,
              wholeFirstLine: false,
            ),
            HiddenRange(
              130,
              150,
              firstLine: 3,
              lastLine: 3,
              wholeFirstLine: false,
            ),
            HiddenRange(
              290,
              320,
              firstLine: 10,
              lastLine: 10,
              wholeFirstLine: false,
            ),
          ],
          textLength: 0,
        ),
      );

      expect(
        builder.hiddenLineRanges,
        const HiddenLineRanges(
          breakpoints: [],
          fullLineCount: 15,
          visibleLineCount: 15,
        ),
      );
    });

    test('Mid multiline ranges', () {
      final builder = HiddenLineRangesBuilder(
        codeLines: codeLines,
        hiddenRanges: HiddenRanges(
          ranges: const [
            HiddenRange(
              130,
              210,
              firstLine: 3,
              lastLine: 5,
              wholeFirstLine: false,
            ),
            HiddenRange(
              230,
              240,
              firstLine: 8,
              lastLine: 8,
              wholeFirstLine: false,
            ),
            HiddenRange(
              340,
              400,
              firstLine: 11,
              lastLine: 13,
              wholeFirstLine: false,
            ),
          ],
          textLength: 0,
        ),
      );

      expect(
        builder.hiddenLineRanges,
        const HiddenLineRanges(
          breakpoints: [
            LineNumberingBreakpoint(full: 6, visible: 4, spreadBefore: 0),
            LineNumberingBreakpoint(full: 14, visible: 10, spreadBefore: 2),
          ],
          fullLineCount: 15,
          visibleLineCount: 11,
        ),
      );
    });

    test('Start+End multiline ranges', () {
      final builder = HiddenLineRangesBuilder(
        codeLines: codeLines,
        hiddenRanges: HiddenRanges(
          ranges: const [
            HiddenRange(
              0,
              80,
              firstLine: 0,
              lastLine: 2,
              wholeFirstLine: true,
            ),
            HiddenRange(
              230,
              240,
              firstLine: 8,
              lastLine: 8,
              wholeFirstLine: false,
            ),
            HiddenRange(
              340,
              480,
              firstLine: 11,
              lastLine: 15,
              wholeFirstLine: false,
            ),
          ],
          textLength: 0,
        ),
      );

      expect(
        builder.hiddenLineRanges,
        const HiddenLineRanges(
          breakpoints: [
            LineNumberingBreakpoint(full: 2, visible: 0, spreadBefore: 0),
            LineNumberingBreakpoint(full: 15, visible: 10, spreadBefore: 2),
          ],
          fullLineCount: 15,
          visibleLineCount: 9,
        ),
      );
    });
  });
}
