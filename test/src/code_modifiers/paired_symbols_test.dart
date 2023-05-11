import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/code_modifiers/paired_symbols.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Paired symbols modifier test', () {
    const examples = [
      //
      _Example(
        'Add paired symbols at the start of the string',
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
        openChar: '{',
        closeString: '}',
      ),

      _Example(
        'Add paired symbols in the middle of the string',
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
        openChar: '(',
        closeString: ')',
      ),

      _Example(
        'Add paired symbols at the end of the string',
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
        openChar: '[',
        closeString: ']',
      ),

      _Example(
        'Add paired symbols with several close chars',
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
        openChar: '1',
        closeString: '23',
      ),

      _Example(
        'Add paired symbols before same close char',
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
        openChar: '(',
        closeString: ')',
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
        openChar: '(',
        closeString: ')',
      ),
    ];

    for (final example in examples) {
      final controller = CodeController();
      final modifier = PairedSymbolsCodeModifier(
        openChar: example.openChar,
        closeString: example.closeString,
      );

      controller.value = example.initialValue;

      final updatedValue = modifier.updateString(
        controller.text,
        controller.selection,
        const EditorParams(),
      );

      expect(
        updatedValue,
        example.expected,
        reason: example.name,
      );
    }
  });
}

class _Example {
  final String name;
  final TextEditingValue initialValue;
  final TextEditingValue expected;
  final String openChar;
  final String closeString;

  const _Example(
    this.name, {
    required this.initialValue,
    required this.expected,
    required this.openChar,
    required this.closeString,
  });
}
