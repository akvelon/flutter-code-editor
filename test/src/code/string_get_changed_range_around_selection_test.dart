import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code/string.dart';
import 'package:flutter_code_editor/src/code_field/text_selection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('String.getChangedRangeAroundSelection', () {
    const examples = [
      //
      _Example(
        'Selection deleted',
        oldValue: TextEditingValue(
          text: 'abcDEFghi',
          //        <->
          selection: TextSelection(baseOffset: 3, extentOffset: 6),
        ),
        newString: 'abcghi',
        expected: TextRange(start: 3, end: 3),
      ),

      _Example(
        'Selection replaced',
        oldValue: TextEditingValue(
          text: 'abcDEFghi',
          //        <->
          selection: TextSelection(baseOffset: 3, extentOffset: 6),
        ),
        newString: 'abcdeghi',
        expected: TextRange(start: 3, end: 5),
      ),

      _Example(
        'Disambiguated insertion before',
        oldValue: TextEditingValue(
          text: 'abcDghi',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        newString: 'abcDDghi',
        //             +
        expected: TextRange(start: 3, end: 4),
      ),

      _Example(
        'Disambiguated insertion after',
        oldValue: TextEditingValue(
          text: 'abcDghi',
          //         \ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        newString: 'abcDDghi',
        //              +
        expected: TextRange(start: 4, end: 5),
      ),

      _Example(
        'Delete non-ambigious',
        oldValue: TextEditingValue(
          text: 'abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newString: 'ac',
        expected: TextRange(start: 1, end: 2),
      ),

      _Example(
        'Delete disambiguated first b',
        oldValue: TextEditingValue(
          text: 'abbc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newString: 'abc',
        expected: TextRange(start: 1, end: 2),
      ),

      _Example(
        'Delete disambiguated second b',
        oldValue: TextEditingValue(
          text: 'abbc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        newString: 'abc',
        expected: TextRange(start: 2, end: 3),
      ),

      _Example(
        'Backspace non-ambigious',
        oldValue: TextEditingValue(
          text: 'abc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        newString: 'ac',
        expected: TextRange(start: 1, end: 2),
      ),

      _Example(
        'Backspace disambiguated first b',
        oldValue: TextEditingValue(
          text: 'abbc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        newString: 'abc',
        expected: TextRange(start: 1, end: 2),
      ),

      _Example(
        'Backspace disambiguated second b',
        oldValue: TextEditingValue(
          text: 'abbc',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        newString: 'abc',
        expected: TextRange(start: 2, end: 3),
      ),

      _Example(
        'Change before selection',
        oldValue: TextEditingValue(
          text: 'abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newString: 'Abc',
        expected: null,
      ),

      _Example(
        'Change after selection',
        oldValue: TextEditingValue(
          text: 'abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newString: 'abC',
        expected: null,
      ),
    ];

    for (final example in examples) {
      expect(
        () =>
            example.newString.getChangedRangeAroundSelection(example.oldValue),
        returnsNormally,
        reason: example.name,
      );

      final range = example.newString.getChangedRangeAroundSelection(
        example.oldValue,
      );
      final reversedRange = example.newString.getChangedRangeAroundSelection(
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
  final String newString;
  final TextRange? expected;

  const _Example(
    this.name, {
    required this.oldValue,
    required this.newString,
    required this.expected,
  });
}
