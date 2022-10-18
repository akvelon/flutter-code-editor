import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/text_editing_value.dart';
import 'package:flutter_test/flutter_test.dart';

const _codeRowWithoutTabs = 'int a = 1;';
const _codeWithTabs = '''
class Foo {
\tint field;
\tvoid method() {
\t\tprint(field);
\t}
}
''';
const _codeWithDoubleSpaces = '''
class Foo {
  int field;
  void method() {
    print(field);
  }
}
''';
const _spaceCount = 2;


void main() {
  group('Replace tabs with spaces', () {
    test('Empty without selection', () {
      TextEditingValue value = TextEditingValue.empty;
      value = value.tabsToSpaces(_spaceCount);
      
      expect(value.text, '');
      expect(value.selection.baseOffset, -1);
      expect(value.selection.extentOffset, -1);
    });

    test('Empty with cursor at start', () {
      TextEditingValue value = TextEditingValue.empty.copyWith(
        selection: const TextSelection.collapsed(offset: 0),
      );

      value = value.tabsToSpaces(_spaceCount);
      
      expect(value.text, '');
      expect(value.selection.baseOffset, 0);
      expect(value.selection.extentOffset, 0);
    });

    test('Code row without tabs without selection', () {
      TextEditingValue value = const TextEditingValue(text: _codeRowWithoutTabs);
      
      value = value.tabsToSpaces(_spaceCount);
      
      expect(value.text, _codeRowWithoutTabs);
      expect(value.selection.baseOffset, -1);
      expect(value.selection.extentOffset, -1);
    });

    test('Code row without tabs with cursor at start', () {
      TextEditingValue value = const TextEditingValue(
        text: _codeRowWithoutTabs,
        selection: TextSelection.collapsed(offset: 0),
      );
      
      value = value.tabsToSpaces(_spaceCount);
      
      expect(value.text, _codeRowWithoutTabs);
      expect(value.selection.baseOffset, 0);
      expect(value.selection.extentOffset, 0);
    });

    test('Code row without tabs with cursor at middle', () {
      const cursorPosition = 5;
      TextEditingValue value = const TextEditingValue(
        text: _codeRowWithoutTabs,
        selection: TextSelection.collapsed(offset: cursorPosition),
      );

      value = value.tabsToSpaces(_spaceCount);

      expect(value.text, _codeRowWithoutTabs);
      expect(value.selection.baseOffset, cursorPosition);
      expect(value.selection.extentOffset, cursorPosition);
    });

    test('Code row without tabs with cursor at end', () {
      const cursorPosition = _codeRowWithoutTabs.length;
      TextEditingValue value = const TextEditingValue(
        text: _codeRowWithoutTabs,
        selection: TextSelection.collapsed(offset: cursorPosition),
      );

      value = value.tabsToSpaces(_spaceCount);

      expect(value.text, _codeRowWithoutTabs);
      expect(value.selection.baseOffset, cursorPosition);
      expect(value.selection.extentOffset, cursorPosition);
    });

    test('Code row without tabs with selection', () {
      const selectionStart = 5;
      const selectionEnd = 10;
      TextEditingValue value = const TextEditingValue(
        text: _codeRowWithoutTabs,
        selection: TextSelection(
          baseOffset: selectionStart,
          extentOffset: selectionEnd,
        ),
      );

      value = value.tabsToSpaces(_spaceCount);

      expect(value.text, _codeRowWithoutTabs);
      expect(value.selection.baseOffset, selectionStart);
      expect(value.selection.extentOffset, selectionEnd);
    });

    test('Code row without tabs with reversed selection', () {
      const selectionStart = 10;
      const selectionEnd = 5;
      TextEditingValue value = const TextEditingValue(
        text: _codeRowWithoutTabs,
        selection: TextSelection(
          baseOffset: selectionStart,
          extentOffset: selectionEnd,
        ),
      );

      value = value.tabsToSpaces(_spaceCount);

      expect(value.text, _codeRowWithoutTabs);
      expect(value.selection.baseOffset, selectionStart);
      expect(value.selection.extentOffset, selectionEnd);
    });

    test('Code with tabs without selection', () {
      TextEditingValue value = const TextEditingValue(text: _codeWithTabs);
      
      value = value.tabsToSpaces(_spaceCount);
      
      expect(value.text, _codeWithDoubleSpaces);
      expect(value.selection.baseOffset, -1);
      expect(value.selection.extentOffset, -1);
    });

    test('Code with tabs with cursor at start', () {
      TextEditingValue value = const TextEditingValue(
        text: _codeWithTabs,
        selection: TextSelection.collapsed(offset: 0),
      );
      
      value = value.tabsToSpaces(_spaceCount);
      
      expect(value.text, _codeWithDoubleSpaces);
      expect(value.selection.baseOffset, 0);
      expect(value.selection.extentOffset, 0);
    });

    test('Code with tabs with cursor at middle', () {
      const cursorPosition = _codeWithTabs.length ~/ 2;
      TextEditingValue value = const TextEditingValue(
        text: _codeWithTabs,
        selection: TextSelection.collapsed(offset: cursorPosition),
      );

      value = value.tabsToSpaces(_spaceCount);

      expect(value.text, _codeWithDoubleSpaces);
      expect(value.selection.baseOffset, 33); //calculated manually
      expect(value.selection.extentOffset, 33);
    });

    test('Code with tabs with cursor at end', () {
      const cursorPosition = _codeWithTabs.length;
      TextEditingValue value = const TextEditingValue(
        text: _codeWithTabs,
        selection: TextSelection.collapsed(offset: cursorPosition),
      );

      value = value.tabsToSpaces(_spaceCount);

      final tabsCount = RegExp('\t').allMatches(_codeWithTabs).length;
      expect(value.text, _codeWithDoubleSpaces);
      expect(value.selection.baseOffset, cursorPosition + tabsCount);
      expect(value.selection.extentOffset, cursorPosition + tabsCount);
    });

    test('Code with tabs with selection', () {
      const selectionStart = 24;
      const selectionEnd = 59;
      TextEditingValue value = const TextEditingValue(
        text: _codeWithTabs,
        selection: TextSelection(
          baseOffset: selectionStart,
          extentOffset: selectionEnd,
        ),
      );

      value = value.tabsToSpaces(_spaceCount);

      expect(value.text, _codeWithDoubleSpaces);
      expect(value.selection.baseOffset, selectionStart + 1);
      expect(value.selection.extentOffset, selectionEnd + 5);
    });

    test('Code with tabs with reversed selection', () {
      const selectionStart = 59;
      const selectionEnd = 24;
      TextEditingValue value = const TextEditingValue(
        text: _codeWithTabs,
        selection: TextSelection(
          baseOffset: selectionStart,
          extentOffset: selectionEnd,
        ),
      );

      value = value.tabsToSpaces(_spaceCount);

      expect(value.text, _codeWithDoubleSpaces);
      expect(value.selection.baseOffset, selectionStart + 5);
      expect(value.selection.extentOffset, selectionEnd + 1);
    });
  });
}
