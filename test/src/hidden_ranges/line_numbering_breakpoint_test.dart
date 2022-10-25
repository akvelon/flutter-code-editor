import 'package:flutter_code_editor/src/hidden_ranges/line_numbering_breakpoint.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LineNumberingBreakpoint', () {
    group('cutLineIndex', () {
      const breakpoint = LineNumberingBreakpoint(
        full: 100,
        visible: 12,
        spreadBefore: 4,
      );

      test('way before', () {
        expect(breakpoint.cutLineIndex(-10), -14);
      });

      test('last line before', () {
        expect(breakpoint.cutLineIndex(15), 11);
      });

      test('first hidden line', () {
        expect(breakpoint.cutLineIndex(16), 11);
      });

      test('mid hidden line', () {
        expect(breakpoint.cutLineIndex(50), 11);
      });

      test('last hidden line', () {
        expect(breakpoint.cutLineIndex(99), 11);
      });

      test('first line after', () {
        expect(breakpoint.cutLineIndex(100), 12);
      });

      test('way after', () {
        expect(breakpoint.cutLineIndex(200), 112);
      });
    });

    group('cutLineIndexIfVisible', () {
      const breakpoint = LineNumberingBreakpoint(
        full: 100,
        visible: 12,
        spreadBefore: 4,
      );

      test('way before', () {
        expect(breakpoint.cutLineIndexIfVisible(-10), -14);
      });

      test('last line before', () {
        expect(breakpoint.cutLineIndexIfVisible(15), 11);
      });

      test('first hidden line', () {
        expect(breakpoint.cutLineIndexIfVisible(16), null);
      });

      test('mid hidden line', () {
        expect(breakpoint.cutLineIndexIfVisible(50), null);
      });

      test('last hidden line', () {
        expect(breakpoint.cutLineIndexIfVisible(99), null);
      });

      test('first line after', () {
        expect(breakpoint.cutLineIndexIfVisible(100), 12);
      });

      test('way after', () {
        expect(breakpoint.cutLineIndexIfVisible(200), 112);
      });
    });
  });
}
