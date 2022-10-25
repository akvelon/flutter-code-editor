import 'package:flutter_code_editor/src/hidden_ranges/hidden_line_ranges.dart';
import 'package:flutter_code_editor/src/hidden_ranges/line_numbering_breakpoint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const noBreakpointsRanges = HiddenLineRanges(
    breakpoints: [],
    fullLineCount: 10,
    visibleLineCount: 10,
  );

  const midBreakpointsRanges = HiddenLineRanges(
    breakpoints: [
      LineNumberingBreakpoint(full: 4, visible: 2, spreadBefore: 0),
      LineNumberingBreakpoint(full: 9, visible: 5, spreadBefore: 2),
      LineNumberingBreakpoint(full: 100, visible: 12, spreadBefore: 4),
    ],
    fullLineCount: 110,
    visibleLineCount: 22,
  );

  const startEndHiddenRanges = HiddenLineRanges(
    breakpoints: [
      LineNumberingBreakpoint(full: 3, visible: 0, spreadBefore: 0),
      LineNumberingBreakpoint(full: 10, visible: 5, spreadBefore: 3),
    ],
    fullLineCount: 10,
    visibleLineCount: 5,
  );

  group('HiddenLineRanges.', () {
    group('cutLineIndexIfVisible', () {
      test('No breakpoints -> Continuous', () {
        for (int i = -1; i <= noBreakpointsRanges.fullLineCount; i++) {
          expect(noBreakpointsRanges.cutLineIndexIfVisible(i), i);
        }
      });

      test('Mid breakpoints', () {
        expect(midBreakpointsRanges.cutLineIndexIfVisible(-1), -1);
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
        expect(midBreakpointsRanges.cutLineIndexIfVisible(200), 112);
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
