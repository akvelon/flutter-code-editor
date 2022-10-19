import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/text_editing_value.dart';
import 'package:flutter_test/flutter_test.dart';

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
  group('Replace tabs with spaces.', () {
    group('Empty', () {
      test('without selection do not changes', () {
        TextEditingValue value = TextEditingValue.empty;
        value = value.tabsToSpaces(_spaceCount);

        expect(value, TextEditingValue.empty);
      });

      test('with cursor at start do not changes', () {
        TextEditingValue value = TextEditingValue.empty.copyWith(
          selection: const TextSelection.collapsed(offset: 0),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, '');
        expect(value.selection, const TextSelection.collapsed(offset: 0));
      });
    });

    group('Code without tabs', () {
      test('without selection', () {
        TextEditingValue value =
            const TextEditingValue(text: _codeWithDoubleSpaces);

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(value.selection, const TextSelection.collapsed(offset: -1));
      });

      test('with cursor at the start', () {
        TextEditingValue value = const TextEditingValue(
          text: _codeWithDoubleSpaces,
          selection: TextSelection.collapsed(offset: 0),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(value.selection, const TextSelection.collapsed(offset: 0));
      });

      test('with cursor at the middle', () {
        const cursorPosition = 5;
        TextEditingValue value = const TextEditingValue(
          text: _codeWithDoubleSpaces,
          selection: TextSelection.collapsed(
            offset: cursorPosition,
            affinity: TextAffinity.upstream,
          ),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(
          value.selection,
          const TextSelection.collapsed(
            offset: cursorPosition,
            affinity: TextAffinity.upstream,
          ),
        );
      });

      test('with cursor at the end', () {
        const cursorPosition = _codeWithDoubleSpaces.length;
        TextEditingValue value = TextEditingValue(
          text: _codeWithDoubleSpaces,
          selection: const TextSelection.collapsed(offset: cursorPosition)
              .copyWith(isDirectional: true),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(
          value.selection,
          const TextSelection.collapsed(offset: cursorPosition)
              .copyWith(isDirectional: true),
        );
      });

      test('with non-empty normalized selection', () {
        const selectionStart = 5;
        const selectionEnd = 10;
        TextEditingValue value = const TextEditingValue(
          text: _codeWithDoubleSpaces,
          selection: TextSelection(
            baseOffset: selectionStart,
            extentOffset: selectionEnd,
          ),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(value.selection.baseOffset, selectionStart);
        expect(value.selection.extentOffset, selectionEnd);
      });

      test('with non-enpty reversed selection', () {
        const selectionStart = 10;
        const selectionEnd = 5;
        TextEditingValue value = const TextEditingValue(
          text: _codeWithDoubleSpaces,
          selection: TextSelection(
            baseOffset: selectionStart,
            extentOffset: selectionEnd,
          ),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(value.selection.baseOffset, selectionStart);
        expect(value.selection.extentOffset, selectionEnd);
      });
    });

    group('Code with tabs', () {
      test('without selection', () {
        TextEditingValue value = const TextEditingValue(text: _codeWithTabs);

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(value.selection, const TextSelection.collapsed(offset: -1));
      });

      test('with cursor at the start', () {
        TextEditingValue value = const TextEditingValue(
          text: _codeWithTabs,
          selection: TextSelection.collapsed(offset: 0),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(value.selection.baseOffset, 0);
        expect(value.selection.extentOffset, 0);
      });

      test('with cursor at the middle', () {
        const cursorPosition = 31;
        TextEditingValue value = const TextEditingValue(
          text: _codeWithTabs,
          selection: TextSelection.collapsed(offset: cursorPosition),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value.text, _codeWithDoubleSpaces);
        expect(value.selection, const TextSelection.collapsed(offset: 33));
      });

      test('with cursor at the end', () {
        const cursorPosition = _codeWithTabs.length;
        TextEditingValue value = const TextEditingValue(
          text: _codeWithTabs,
          selection: TextSelection.collapsed(offset: cursorPosition),
        );

        value = value.tabsToSpaces(_spaceCount);

        final tabsCount = RegExp('\t').allMatches(_codeWithTabs).length;
        expect(value.text, _codeWithDoubleSpaces);
        expect(
          value.selection,
          TextSelection.collapsed(
            offset: cursorPosition + tabsCount,
          ),
        );
      });

      test('with non-empty normalized selection', () {
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

      test('with non-empty reversed selection', () {
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
  });
}
