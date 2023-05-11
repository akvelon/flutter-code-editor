import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/code_modifiers/insertion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Insertion modifier test', () {
    const examples = [
      //
      _Example(
        'Add close char at the start of the string',
        initialValue: TextEditingValue(
          text: 'dict',
          //     \ cursor
          selection: TextSelection.collapsed(offset: 0),
        ),
        expected: TextEditingValue(
          text: '{}dict',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        inputChar: '{',
      ),

      _Example(
        'Add close char in the middle of the string',
        initialValue: TextEditingValue(
          text: 'print',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        expected: TextEditingValue(
          text: 'pri()nt',
          //         \ cursor
          selection: TextSelection.collapsed(offset: 4),
        ),
        inputChar: '(',
      ),

      _Example(
        'Add close char at the end of the string',
        initialValue: TextEditingValue(
          text: 'print',
          //          \ cursor
          selection: TextSelection.collapsed(offset: 5),
        ),
        expected: TextEditingValue(
          text: 'print[]',
          //           \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
        inputChar: '[',
      ),

      _Example(
        'Add close with several close chars',
        initialValue: TextEditingValue(
          text: 'string',
          //           \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
        expected: TextEditingValue(
          text: 'string123',
          //            \ cursor
          selection: TextSelection.collapsed(offset: 7),
        ),
        inputChar: '1',
        insertedString: '23',
      ),

      _Example(
        'Add close char before same close char',
        initialValue: TextEditingValue(
          text: 'string)',
          //           \ cursor
          selection: TextSelection.collapsed(offset: 6),
        ),
        expected: TextEditingValue(
          text: 'string())',
          //            \ cursor
          selection: TextSelection.collapsed(offset: 7),
        ),
        inputChar: '(',
      ),

      _Example(
        'Empty initial string',
        initialValue: TextEditingValue(
          // ignore: avoid_redundant_argument_values
          text: '',
          //     \ cursor
          selection: TextSelection.collapsed(offset: 0),
        ),
        expected: TextEditingValue(
          text: '()',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        inputChar: '(',
      ),
    ];

    for (final example in examples) {
      final additionalModifier = example.insertedString != null
          ? InsertionCodeModifier(
              openChar: example.inputChar,
              closeString: example.insertedString!,
            )
          : null;

      if (additionalModifier != null &&
          CodeController.defaultCodeModifiers.any(
            (e) =>
                e is InsertionCodeModifier && e.openChar == example.inputChar,
          )) {
        fail('Modifier for ${example.inputChar} already exists');
      }

      late CodeController controller;

      if (additionalModifier == null) {
        controller = CodeController();
      } else {
        controller = CodeController(
          modifiers: CodeController.defaultCodeModifiers + [additionalModifier],
        );
      }

      controller.value = example.initialValue;

      controller.value = _addCharToSelectedPosition(
        controller.value,
        example.inputChar,
      );

      expect(
        controller.value,
        example.expected,
        reason: example.name,
      );
    }
  });
}

TextEditingValue _addCharToSelectedPosition(
  TextEditingValue value,
  String char,
) {
  final selection = value.selection;
  final text = value.text;

  final newText = text.substring(0, selection.start) +
      char +
      text.substring(selection.start);

  return TextEditingValue(
    text: newText,
    selection: TextSelection.collapsed(
      offset: selection.start + char.length,
    ),
  );
}

class _Example {
  final String name;
  final TextEditingValue initialValue;
  final TextEditingValue expected;
  final String inputChar;
  final String? insertedString;

  const _Example(
    this.name, {
    required this.initialValue,
    required this.expected,
    required this.inputChar,
    this.insertedString,
  });
}
