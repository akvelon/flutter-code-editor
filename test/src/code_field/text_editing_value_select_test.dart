// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: prefer_const_constructors

import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextEditingValue ', () {
    test('select', () {
      final examples = [
        //
        _Example(
          'Empty value -> null',
          value: TextEditingValue.empty,
          pattern: 'pattern',
          start: 0,
          expected: null,
        ),

        _Example(
          'Empty search -> Error',
          value: TextEditingValue(text: 'text'),
          pattern: '',
          start: 0,
          throws: true,
        ),

        _Example(
          'Not found -> null',
          value: TextEditingValue(text: 'text'),
          pattern: RegExp('not found'),
          start: 0,
          expected: null,
        ),

        _Example(
          'First occurrence',
          value: TextEditingValue(text: 'aba'),
          pattern: 'a',
          start: 0,
          expected: TextEditingValue(
            text: 'aba',
            selection: TextSelection(baseOffset: 0, extentOffset: 1),
          ),
        ),

        _Example(
          'First occurrence starting at, preserves composing',
          value: TextEditingValue(
            text: 'aba',
            composing: TextRange(start: 1, end: 1),
          ),
          pattern: RegExp('a'),
          start: 1,
          expected: TextEditingValue(
            text: 'aba',
            selection: TextSelection(baseOffset: 2, extentOffset: 3),
            composing: TextRange(start: 1, end: 1),
          ),
        ),
      ];

      for (final example in examples) {
        TextEditingValue? call() {
          return example.value.select(example.pattern, example.start);
        }

        if (example.throws) {
          expect(call, throwsAssertionError);
        } else {
          expect(
            call(),
            example.expected,
            reason: example.name,
          );
        }
      }
    });
  });
}

class _Example {
  final String name;

  final TextEditingValue? expected;
  final Pattern pattern;
  final int start;
  final bool throws;
  final TextEditingValue value;

  const _Example(
    this.name, {
    required this.pattern,
    required this.start,
    required this.value,
    this.expected,
    this.throws = false,
  });
}
