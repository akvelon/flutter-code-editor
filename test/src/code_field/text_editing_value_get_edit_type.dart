import 'package:flutter/services.dart';
import 'package:flutter_code_editor/src/code_field/text_editing_value.dart';
import 'package:flutter_code_editor/src/util/edit_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TextEditingValue.getEditType', () {
    const examples = [
      //
      _Example(
        'No change, collapsed',
        oldValue: TextEditingValue(
          text: 'abc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2), // any
        ),
        newValue: TextEditingValue(
          text: 'abc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2), // any
        ),
        expected: EditType.unchanged,
      ),

      _Example(
        'No change, non-collapsed',
        oldValue: TextEditingValue(
          text: 'abc',
          //      <>
          selection: TextSelection(baseOffset: 1, extentOffset: 3),
        ),
        newValue: TextEditingValue(
          text: 'abc',
          //      <>
          selection: TextSelection(baseOffset: 1, extentOffset: 3),
        ),
        expected: EditType.unchanged,
      ),

      _Example(
        'Backspace, collapsed',
        oldValue: TextEditingValue(
          text: 'abc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        newValue: TextEditingValue(
          text: 'ac',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        expected: EditType.backspaceBeforeCollapsedSelection,
      ),

      _Example(
        'Delete, collapsed',
        oldValue: TextEditingValue(
          text: 'abc',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newValue: TextEditingValue(
          text: 'ac',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        expected: EditType.deleteAfterCollapsedSelection,
      ),

      _Example(
        'Backspace, collapsed, disambiguated',
        oldValue: TextEditingValue(
          text: 'aa',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newValue: TextEditingValue(
          text: 'a',
          //     \ cursor
          selection: TextSelection.collapsed(offset: 0),
        ),
        expected: EditType.backspaceBeforeCollapsedSelection,
      ),

      _Example(
        'Delete, collapsed, disambiguated',
        oldValue: TextEditingValue(
          text: 'aa',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newValue: TextEditingValue(
          text: 'a',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        expected: EditType.deleteAfterCollapsedSelection,
      ),

      _Example(
        'Invalid disambiguation, moved home',
        oldValue: TextEditingValue(
          text: 'aaaa',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        newValue: TextEditingValue(
          text: 'aaa',
          //     \ cursor
          selection: TextSelection.collapsed(offset: 0),
        ),
        expected: EditType.other,
      ),

      _Example(
        'Invalid disambiguation, moved to end',
        oldValue: TextEditingValue(
          text: 'aaaa',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        newValue: TextEditingValue(
          text: 'aaa',
          //        \ cursor
          selection: TextSelection.collapsed(offset: 3),
        ),
        expected: EditType.other,
      ),

      _Example(
        'Backspace or delete, non-collapsed',
        oldValue: TextEditingValue(
          text: 'abcd',
          //      <>
          selection: TextSelection(baseOffset: 1, extentOffset: 3),
        ),
        newValue: TextEditingValue(
          text: 'ad',
          selection: TextSelection.collapsed(offset: 1),
        ),
        expected: EditType.deleteSelection,
      ),

      _Example(
        'Partially deleted selection',
        oldValue: TextEditingValue(
          text: 'abcd',
          //      <>
          selection: TextSelection(baseOffset: 1, extentOffset: 3),
        ),
        newValue: TextEditingValue(
          text: 'acd',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        expected: EditType.replaceSelection,
      ),

      _Example(
        'Replace with non-empty',
        oldValue: TextEditingValue(
          text: 'abcd',
          //      <>
          selection: TextSelection(baseOffset: 1, extentOffset: 3),
        ),
        newValue: TextEditingValue(
          text: 'aBCd',
          selection: TextSelection.collapsed(offset: 3),
        ),
        expected: EditType.replaceSelection,
      ),

      _Example(
        'Typed at collapsed',
        oldValue: TextEditingValue(
          text: 'ac',
          //      \ cursor
          selection: TextSelection.collapsed(offset: 1),
        ),
        newValue: TextEditingValue(
          text: 'abc',
          //       \ cursor
          selection: TextSelection.collapsed(offset: 2),
        ),
        expected: EditType.insertAtCollapsedSelection,
      ),

      _Example(
        'Replace non-selected',
        oldValue: TextEditingValue(
          text: 'a',
          //     \ cursor
          selection: TextSelection.collapsed(offset: 0),
        ),
        newValue: TextEditingValue(
          text: 'b',
          //     \ cursor
          selection: TextSelection.collapsed(offset: 0),
        ),
        expected: EditType.other,
      ),
    ];

    for (final example in examples) {
      final result = example.newValue.getEditType(example.oldValue);
      expect(result, example.expected, reason: example.name);
    }
  });
}

class _Example {
  const _Example(
    this.name, {
    required this.oldValue,
    required this.newValue,
    required this.expected,
  });

  final String name;
  final TextEditingValue oldValue;
  final TextEditingValue newValue;
  final EditType expected;
}
