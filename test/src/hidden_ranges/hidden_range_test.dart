import 'package:code_text_field/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: prefer_const_constructors

void main() {
  group('HiddenText.', () {
    test('text length = end - stat', () {
      HiddenRange(start: 0, end: 3, text: '123');

      expect(
        () => HiddenRange(start: 0, end: 3, text: '12'),
        throwsAssertionError,
      );
    });

    test('start >= 0', () {
      HiddenRange(start: 0, end: 3, text: '123');

      expect(
        () => HiddenRange(start: -1, end: 3, text: '1234'),
        throwsAssertionError,
      );
    });
  });
}
