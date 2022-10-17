import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: prefer_const_constructors

void main() {
  group('HiddenText.', () {
    test('start >= 0', () {
      HiddenRange(start: 0, end: 3);

      expect(
        () => HiddenRange(start: -1, end: 3),
        throwsAssertionError,
      );
    });

    test('end > start', () {
      HiddenRange(start: 2, end: 3);

      expect(
        () => HiddenRange(start: 2, end: 2),
        throwsAssertionError,
      );
      expect(
        () => HiddenRange(start: 3, end: 2),
        throwsAssertionError,
      );
    });
  });
}
