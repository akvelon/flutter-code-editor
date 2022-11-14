import 'package:flutter_code_editor/src/hidden_ranges/hidden_line_ranges.dart';
import 'package:flutter_code_editor/src/hidden_ranges/line_numbering_breakpoint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final emptyTextBreakpointRanges = HiddenLineRanges(
    breakpoints: [],
    fullLineCount: 1,
    visibleLineCount: 1,
  );

  final noBreakpointsRanges = HiddenLineRanges(
    breakpoints: [],
    fullLineCount: 10,
    visibleLineCount: 10,
  );

  final midBreakpointsRanges = HiddenLineRanges(
    breakpoints: const [
      LineNumberingBreakpoint(full: 4, visible: 2, spreadBefore: 0),
      LineNumberingBreakpoint(full: 9, visible: 5, spreadBefore: 2),
      LineNumberingBreakpoint(full: 100, visible: 12, spreadBefore: 4),
    ],
    fullLineCount: 110,
    visibleLineCount: 22,
  );

  final startEndHiddenRanges = HiddenLineRanges(
    breakpoints: const [
      LineNumberingBreakpoint(full: 3, visible: 0, spreadBefore: 0),
      LineNumberingBreakpoint(full: 10, visible: 5, spreadBefore: 3),
    ],
    fullLineCount: 10,
    visibleLineCount: 5,
  );

  group('HiddenLineRanges.', () {
    group('cutLineIndexIfVisible, recoverLineIndex', () {
      test('Empty text', () {
        expect(emptyTextBreakpointRanges.cutLineIndexIfVisible(0), 0);
        expect(emptyTextBreakpointRanges.recoverLineIndex(0), 0);
      });

      test('No breakpoints -> Continuous', () {
        for (int i = 0; i < noBreakpointsRanges.fullLineCount; i++) {
          expect(noBreakpointsRanges.cutLineIndexIfVisible(i), i);
          expect(noBreakpointsRanges.recoverLineIndex(i), i);
        }
      });

      test('Mid breakpoints', () {
        expect(midBreakpointsRanges.cutLineIndexIfVisible(0), 0);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(1), 1);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(2), null);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(3), null);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(4), 2);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(5), 3);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(6), 4);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(7), null);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(8), null);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(9), 5);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(10), 6);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(11), 7);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(15), 11);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(16), null);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(99), null);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(100), 12);
        expect(midBreakpointsRanges.cutLineIndexIfVisible(101), 13);

        expect(midBreakpointsRanges.recoverLineIndex(0), 0);
        expect(midBreakpointsRanges.recoverLineIndex(1), 1);
        expect(midBreakpointsRanges.recoverLineIndex(2), 4);
        expect(midBreakpointsRanges.recoverLineIndex(3), 5);
        expect(midBreakpointsRanges.recoverLineIndex(4), 6);
        expect(midBreakpointsRanges.recoverLineIndex(5), 9);
        expect(midBreakpointsRanges.recoverLineIndex(6), 10);
        expect(midBreakpointsRanges.recoverLineIndex(7), 11);
        expect(midBreakpointsRanges.recoverLineIndex(11), 15);
        expect(midBreakpointsRanges.recoverLineIndex(12), 100);
        expect(midBreakpointsRanges.recoverLineIndex(13), 101);
      });
    });

    group('visibleLineNumbers', () {
      test('No breakpoints -> Continuous', () {
        expect(
          noBreakpointsRanges.visibleLineNumbers,
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        );
      });

      test('Mid breakpoints', () {
        expect(
          midBreakpointsRanges.visibleLineNumbers,
          [
            //
            0, 1,
            4, 5, 6,
            9, 10, 11, 12, 13, 14, 15,
            100, 101, 102, 103, 104, 105, 106, 107, 108, 109,
          ],
        );
      });

      test('Start+End hidden ranges', () {
        expect(
          startEndHiddenRanges.visibleLineNumbers,
          [3, 4, 5, 6, 7],
        );
      });
    });
  });
}
