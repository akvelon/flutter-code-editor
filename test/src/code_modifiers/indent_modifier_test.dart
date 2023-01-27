import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Indent modifier test', () {
    const examples = [
      //
      _Example(
        'Preserves indentation of the previous line',
        initialValue: TextEditingValue(
          text: '__a',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        editedValue: TextEditingValue(
          text: '__a\n',
          //          \ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        expected: TextEditingValue(
          text: '__a\n__',
          //            \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
      ),

      _Example(
        '`:` adds indentation to the previous indentation',
        initialValue: TextEditingValue(
          text: '__a:',
          //         \ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        editedValue: TextEditingValue(
          text: '__a:\n',
          //           \ cursor
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextEditingValue(
          text: '__a:\n____',
          //               \ cursor
          selection: TextSelection.collapsed(offset: 9),
        ),
      ),

      _Example(
        '`{` adds indentation to the previous indentation',
        initialValue: TextEditingValue(
          text: '__a{',
          //         \ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        editedValue: TextEditingValue(
          text: '__a{\n',
          //           \ cursor
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextEditingValue(
          text: '__a{\n____',
          //               \ cursor
          selection: TextSelection.collapsed(offset: 9),
        ),
      ),

      _Example(
        '`:` is in the middle of the line',
        initialValue: TextEditingValue(
          text: '__a:a',
          //          \ cursor
          selection: TextSelection.collapsed(offset: 5),
        ),
        editedValue: TextEditingValue(
          text: '__a:a\n',
          //            \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
        expected: TextEditingValue(
          text: '__a:a\n__',
          //              \ cursor
          selection: TextSelection.collapsed(offset: 8),
        ),
      ),

      _Example(
        '`{` is in the middle of the line',
        initialValue: TextEditingValue(
          text: '__a{a',
          //          \ cursor
          selection: TextSelection.collapsed(offset: 5),
        ),
        editedValue: TextEditingValue(
          text: '__a{a\n',
          //            \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
        expected: TextEditingValue(
          text: '__a{a\n__',
          //              \ cursor
          selection: TextSelection.collapsed(offset: 8),
        ),
      ),

      _Example(
        'There are spaces after `:`',
        initialValue: TextEditingValue(
          text: '__a:__',
          //           \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
        editedValue: TextEditingValue(
          text: '__a:__\n',
          //             \ cursor
          selection: TextSelection.collapsed(offset: 7),
        ),
        expected: TextEditingValue(
          text: '__a:__\n____',
          //                 \ cursor
          selection: TextSelection.collapsed(offset: 11),
        ),
      ),

      _Example(
        'There are spaces after `{`',
        initialValue: TextEditingValue(
          text: '__a{__',
          //           \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
        editedValue: TextEditingValue(
          text: '__a{__\n',
          //             \ cursor
          selection: TextSelection.collapsed(offset: 7),
        ),
        expected: TextEditingValue(
          text: '__a{__\n____',
          //                 \ cursor
          selection: TextSelection.collapsed(offset: 11),
        ),
      ),

      _Example(
        r'`:` and `{` are on the same line `\n`',
        initialValue: TextEditingValue(
          text: 'a{:',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        editedValue: TextEditingValue(
          text: 'a{:\n',
          //          \ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        expected: TextEditingValue(
          text: 'a{:\n__',
          //            \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
      ),
    ];

    for (final example in examples) {
      final controller = CodeController();
      controller.value = example.initialValue.copyWith(
        text: example.initialValue.text.replaceAll('_', ' '),
      );

      controller.value = example.editedValue.copyWith(
        text: example.editedValue.text.replaceAll('_', ' '),
      );

      expect(
        controller.value,
        example.expected.copyWith(
          text: example.expected.text.replaceAll('_', ' '),
        ),
        reason: example.name,
      );
    }
  });
}

class _Example {
  final String name;
  final TextEditingValue initialValue;
  final TextEditingValue editedValue;
  final TextEditingValue expected;

  const _Example(
    this.name, {
    required this.initialValue,
    required this.editedValue,
    required this.expected,
  });
}
