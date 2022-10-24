import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: prefer_const_constructors

void main() {
  group('HiddenText.', () {
    test('start >= 0', () {
      HiddenRange(0, 3, firstLine: 0, lastLine: 0, wholeFirstLine: true);

      expect(
        () =>
            HiddenRange(-1, 3, firstLine: 0, lastLine: 0, wholeFirstLine: true),
        throwsAssertionError,
      );
    });

    test('end > start', () {
      HiddenRange(2, 3, firstLine: 0, lastLine: 0, wholeFirstLine: true);

      expect(
        () => HiddenRange(
          2,
          2,
          firstLine: 0,
          lastLine: 0,
          wholeFirstLine: true,
        ),
        throwsAssertionError,
      );
      expect(
        () => HiddenRange(
          3,
          2,
          firstLine: 0,
          lastLine: 0,
          wholeFirstLine: true,
        ),
        throwsAssertionError,
      );
    });
  });
}
