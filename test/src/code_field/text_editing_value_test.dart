import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/lorem_ipsum.dart';

void main() {
  group('TextEditingValue ', () {
    test('wordAtCursorStart', () {
      const examples = [
        //
        _IntExample(
          'Empty -> null',
          value: TextEditingValue.empty,
          expected: null,
        ),

        _IntExample(
          'No selection -> null',
          value: TextEditingValue(text: loremIpsum),
          expected: null,
        ),

        _IntExample(
          'Word start',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 2),
          ),
          expected: 2,
        ),

        _IntExample(
          '1 char',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 3),
          ),
          expected: 2,
        ),

        _IntExample(
          '2 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 4),
          ),
          expected: 2,
        ),

        _IntExample(
          '3 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 5),
          ),
          expected: 2,
        ),

        _IntExample(
          '4 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 6),
          ),
          expected: 2,
        ),

        _IntExample(
          'Just after a word',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 7),
          ),
          expected: 2,
        ),

        _IntExample(
          'Non-collapsed -> null',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection(baseOffset: 3, extentOffset: 4),
          ),
          expected: null,
        ),

        _IntExample(
          'String start',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 0),
          ),
          expected: 0,
        ),

        _IntExample(
          'Non-word string start',
          value: TextEditingValue(
            text: '   ',
            selection: TextSelection.collapsed(offset: 0),
          ),
          expected: null,
        ),

        _IntExample(
          'At the last word',
          value: TextEditingValue(
            text: 'abc def',
            selection: TextSelection.collapsed(offset: 6),
          ),
          expected: 4,
        ),

        _IntExample(
          'After the last word',
          value: TextEditingValue(
            text: 'abc def',
            selection: TextSelection.collapsed(offset: 7),
          ),
          expected: 4,
        ),
      ];

      for (final example in examples) {
        final result = example.value.wordAtCursorStart;

        expect(result, example.expected, reason: example.name);
      }
    });

    test('wordAtCursor', () {
      const examples = [
        //
        _StringExample(
          'Empty -> null',
          value: TextEditingValue.empty,
          expected: null,
        ),

        _StringExample(
          'No selection -> null',
          value: TextEditingValue(text: loremIpsum),
          expected: null,
        ),

        _StringExample(
          'Word start',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 2),
          ),
          expected: 'Lorem',
        ),

        _StringExample(
          '1 char',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 3),
          ),
          expected: 'Lorem',
        ),

        _StringExample(
          '2 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 4),
          ),
          expected: 'Lorem',
        ),

        _StringExample(
          '3 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 5),
          ),
          expected: 'Lorem',
        ),

        _StringExample(
          '4 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 6),
          ),
          expected: 'Lorem',
        ),

        _StringExample(
          'Just after a word',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 7),
          ),
          expected: 'Lorem',
        ),

        _StringExample(
          'Non-collapsed -> null',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection(baseOffset: 3, extentOffset: 4),
          ),
          expected: null,
        ),

        _StringExample(
          'String start',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 0),
          ),
          expected: '1',
        ),

        _StringExample(
          'Non-word string start',
          value: TextEditingValue(
            text: '   ',
            selection: TextSelection.collapsed(offset: 0),
          ),
          expected: null,
        ),

        _StringExample(
          'At the last word',
          value: TextEditingValue(
            text: 'abc def',
            selection: TextSelection.collapsed(offset: 6),
          ),
          expected: 'def',
        ),

        _StringExample(
          'After the last word',
          value: TextEditingValue(
            text: 'abc def',
            selection: TextSelection.collapsed(offset: 7),
          ),
          expected: 'def',
        ),
      ];

      for (final example in examples) {
        final result = example.value.wordAtCursor;

        expect(result, example.expected, reason: example.name);
      }
    });

    test('wordToCursor', () {
      const examples = [
        //
        _StringExample(
          'Empty -> null',
          value: TextEditingValue.empty,
          expected: null,
        ),

        _StringExample(
          'No selection -> null',
          value: TextEditingValue(text: loremIpsum),
          expected: null,
        ),

        _StringExample(
          'Word start -> null',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 2),
          ),
          expected: null,
        ),

        _StringExample(
          '1 char',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 3),
          ),
          expected: 'L',
        ),

        _StringExample(
          '2 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 4),
          ),
          expected: 'Lo',
        ),

        _StringExample(
          '3 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 5),
          ),
          expected: 'Lor',
        ),

        _StringExample(
          '4 chars',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 6),
          ),
          expected: 'Lore',
        ),

        _StringExample(
          'Just after a word -> null',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection.collapsed(offset: 7),
          ),
          expected: null,
        ),

        _StringExample(
          'Non-collapsed -> null',
          value: TextEditingValue(
            text: loremIpsum,
            selection: TextSelection(baseOffset: 3, extentOffset: 4),
          ),
          expected: null,
        ),

        _StringExample(
          'At the last word',
          value: TextEditingValue(
            text: 'abc def',
            selection: TextSelection.collapsed(offset: 6),
          ),
          expected: 'de',
        ),

        _StringExample(
          'After the last word',
          value: TextEditingValue(
            text: 'abc def',
            selection: TextSelection.collapsed(offset: 7),
          ),
          expected: 'def',
        ),
      ];

      for (final example in examples) {
        final result = example.value.wordToCursor;

        expect(result, example.expected, reason: example.name);
      }
    });
  });
}

class _StringExample {
  final String name;
  final TextEditingValue value;
  final String? expected;

  const _StringExample(
    this.name, {
    required this.value,
    required this.expected,
  });
}

class _IntExample {
  final String name;
  final TextEditingValue value;
  final int? expected;

  const _IntExample(
    this.name, {
    required this.value,
    required this.expected,
  });
}
