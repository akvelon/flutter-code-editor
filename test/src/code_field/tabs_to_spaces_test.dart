import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/text_editing_value.dart';
import 'package:flutter_test/flutter_test.dart';

const _codeWithTabs = '''
class Foo {
\tint field;
\tvoid method() {
\t\tint a;
\t}
}
''';
const _codeWithDoubleSpaces = '''
class Foo {
  int field;
  void method() {
    int a;
  }
}
''';
const _spaceCount = 2;

void main() {
  group('TextEditingValue.tabsToSpaces.', () {
    void expectSame(TextEditingValue value) {
      var actual = value;
      final expected = value.copyWith();

      actual = actual.tabsToSpaces(_spaceCount);

      expect(actual, expected);
    }

    group('Empty', () {
      test('without selection do not changes', () {
        expectSame(TextEditingValue.empty);
      });

      test('with cursor at start do not changes', () {
        expectSame(
          TextEditingValue.empty.copyWith(
            selection: const TextSelection.collapsed(offset: 0),
          ),
        );
      });
    });

    group('Code without tabs', () {
      test('without selection', () {
        expectSame(
          const TextEditingValue(text: _codeWithDoubleSpaces),
        );
      });

      test('with cursor at the start', () {
        expectSame(
          const TextEditingValue(
            text: _codeWithDoubleSpaces,
            selection: TextSelection.collapsed(offset: 0),
          ),
        );
      });

      test('with cursor at the middle', () {
        expectSame(
          const TextEditingValue(
            text: _codeWithDoubleSpaces,
            selection: TextSelection.collapsed(
              offset: 5,
              affinity: TextAffinity.upstream,
            ),
          ),
        );
      });

      test('with cursor at the end', () {
        expectSame(
          const TextEditingValue(
            text: _codeWithDoubleSpaces,
            selection:
                TextSelection.collapsed(offset: _codeWithDoubleSpaces.length),
          ),
        );
      });

      test('with non-empty normalized selection', () {
        expectSame(
          const TextEditingValue(
            text: _codeWithDoubleSpaces,
            selection: TextSelection(
              baseOffset: 5,
              extentOffset: 10,
              isDirectional: true,
            ),
          ),
        );
      });

      test('with non-enpty reversed selection', () {
        expectSame(
          const TextEditingValue(
            text: _codeWithDoubleSpaces,
            selection: TextSelection(
              baseOffset: 10,
              extentOffset: 5,
            ),
          ),
        );
      });
    });

    group('Code with tabs', () {
      test('without selection', () {
        TextEditingValue value = const TextEditingValue(text: _codeWithTabs);
        const expected = TextEditingValue(text: _codeWithDoubleSpaces);

        value = value.tabsToSpaces(_spaceCount);

        expect(value, expected);
      });

      test('with cursor at the start', () {
        TextEditingValue value = const TextEditingValue(
          text: _codeWithTabs,
          selection: TextSelection.collapsed(offset: 0),
        );
        final expected = value.copyWith(text: _codeWithDoubleSpaces);

        value = value.tabsToSpaces(_spaceCount);

        expect(value, expected);
      });

      test('with cursor at the middle', () {
        const cursorPosition = 31;
        TextEditingValue value = const TextEditingValue(
          text: _codeWithTabs,
          selection: TextSelection.collapsed(offset: cursorPosition),
        );
        final expected = value.copyWith(
          text: _codeWithDoubleSpaces,
          selection: const TextSelection.collapsed(offset: 33),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value, expected);
      });

      test('with cursor at the end', () {
        const cursorPosition = _codeWithTabs.length;
        TextEditingValue value = const TextEditingValue(
          text: _codeWithTabs,
          selection: TextSelection.collapsed(
            offset: cursorPosition,
            affinity: TextAffinity.upstream,
          ),
        );
        final tabsCount = RegExp('\t').allMatches(_codeWithTabs).length;
        final expected = value.copyWith(
          text: _codeWithDoubleSpaces,
          selection: value.selection.copyWith(
            baseOffset: cursorPosition + tabsCount,
            extentOffset: cursorPosition + tabsCount,
          ),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value, expected);
      });

      test('with non-empty normalized selection', () {
        TextEditingValue value = const TextEditingValue(
          text: _codeWithTabs,
          selection: TextSelection(
            baseOffset: 24,
            extentOffset: 59,
            isDirectional: true,
          ),
        );
        final expected = value.copyWith(
          text: _codeWithDoubleSpaces,
          selection: value.selection.copyWith(baseOffset: 25, extentOffset: 64),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value, expected);
      });

      test('with non-empty reversed selection', () {
        TextEditingValue value = const TextEditingValue(
          text: _codeWithTabs,
          selection: TextSelection(
            baseOffset: 59,
            extentOffset: 24,
          ),
        );
        final expected = value.copyWith(
          text: _codeWithDoubleSpaces,
          selection: const TextSelection(baseOffset: 64, extentOffset: 25),
        );

        value = value.tabsToSpaces(_spaceCount);

        expect(value, expected);
      });
    });
  });
}
