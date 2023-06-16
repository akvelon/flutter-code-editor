import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/text_editing_value.dart';
import 'package:flutter_code_editor/src/code_field/text_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TextEditingValue.getChangedRange', () {
    const examples = [
      //
      _Example(
        'Selection deleted',
        oldValue: TextEditingValue(
          text: 'abcDEFghi',
          //        <->
          selection: TextSelection(baseOffset: 3, extentOffset: 6),
        ),
        newValue: TextEditingValue(
          text: 'abcghi',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        expected: TextRange(start: 3, end: 3),
      ),

      _Example(
        'Selection replaced',
        oldValue: TextEditingValue(
          text: 'abcDEFghi',
          //        <->
          selection: TextSelection(baseOffset: 3, extentOffset: 6),
        ),
        newValue: TextEditingValue(
          text: 'abcdeghi',
          //         \ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        expected: TextRange(start: 3, end: 5),
      ),

      _Example(
        'Disambiguated insertion before',
        oldValue: TextEditingValue(
          text: 'abcDghi',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        newValue: TextEditingValue(
          text: 'abcDDghi',
          //        +\ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        expected: TextRange(start: 3, end: 4),
      ),

      _Example(
        'Disambiguated insertion after',
        oldValue: TextEditingValue(
          text: 'abcDghi',
          //         \ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        newValue: TextEditingValue(
          text: 'abcDDghi',
          //         +\ cursor
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextRange(start: 4, end: 5),
      ),

      _Example(
        'Delete disambiguated first b',
        oldValue: TextEditingValue(
          text: 'abbc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newValue: TextEditingValue(
          text: 'abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        expected: TextRange(start: 1, end: 1),
      ),

      _Example(
        'Delete disambiguated second b',
        oldValue: TextEditingValue(
          text: 'abbc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        newValue: TextEditingValue(
          text: 'abc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        expected: TextRange(start: 2, end: 2),
      ),

      _Example(
        'Backspace disambiguated first b',
        oldValue: TextEditingValue(
          text: 'abbc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        newValue: TextEditingValue(
          text: 'abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        expected: TextRange(start: 1, end: 1),
      ),

      _Example(
        'Backspace disambiguated second b',
        oldValue: TextEditingValue(
          text: 'abbc',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        newValue: TextEditingValue(
          text: 'abc',
          selection: TextSelection.collapsed(offset: 2),
        ),
        expected: TextRange(start: 2, end: 2),
      ),

      _Example(
        'Change before selection',
        oldValue: TextEditingValue(
          text: 'abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newValue: TextEditingValue(
          text: 'Abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1), // any
        ),
        expected: null,
      ),

      _Example(
        'Change after selection',
        oldValue: TextEditingValue(
          text: 'abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newValue: TextEditingValue(
          text: 'abC',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1), // any
        ),
        expected: null,
      ),
    ];

    for (final example in examples) {
      expect(
        () => example.newValue.getChangedRange(example.oldValue),
        returnsNormally,
        reason: example.name,
      );

      final range = example.newValue.getChangedRange(
        example.oldValue,
      );
      final reversedRange = example.newValue.getChangedRange(
        example.oldValue.copyWith(
          selection: example.oldValue.selection.reversed,
        ),
      );

      expect(
        range,
        example.expected,
        reason: example.name,
      );
      expect(
        reversedRange,
        example.expected,
        reason: example.name,
      );
    }
  });
}

class _Example {
  final String name;
  final TextEditingValue oldValue;
  final TextEditingValue newValue;
  final TextRange? expected;

  const _Example(
    this.name, {
    required this.oldValue,
    required this.newValue,
    required this.expected,
  });
}
