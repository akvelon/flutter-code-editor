// ignore_for_file: missing_whitespace_between_adjacent_strings

import 'package:flutter/cupertino.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Arrange Global
  String modifierCallback(String str) => '**$str';
  CodeController controller = CodeController();

  setUp(() {
    controller = CodeController();
  });

  group('Document doesn\'t contain folded blocks', () {
    test(
      'WHEN CodeField has no selection '
      'SHOULD NOT modify any line',
      () {
        // arrange
        const initialText = '''
aaaaaaaaaaa
aaaaaaaaaaa
aaaaaaaaaaa
''';
        const expectedText = initialText;
        const initialSelection =
            TextSelection(baseOffset: -1, extentOffset: -1);
        const expectedSelection = initialSelection;

        controller.selection = initialSelection;
        controller.text = initialText;

        // act
        controller.modifySelectedLines(modifierCallback);

        // assert
        assert(
          controller.value.text == expectedText,
          'Text is not modified',
        );
        assert(
          controller.value.selection == expectedSelection,
          'Selection is not modified',
        );
      },
    );

    group('Selection is collapsed, its location is:', () {
      test(
        'WHEN At the start of the document '
        'SHOULD modify the first line',
        () {
          // arrange
          const initialText = '''
aaaaaaaa
aaaaaaaa
aaaaaaaa
''';
          const expectedText = '''
**aaaaaaaa
aaaaaaaa
aaaaaaaa
''';
          const initialSelection =
              TextSelection(baseOffset: 0, extentOffset: 0);
          const expectedSelection =
              TextSelection(baseOffset: 2, extentOffset: 2);
          controller.text = initialText;
          controller.selection = initialSelection;

          // act
          controller.modifySelectedLines(modifierCallback);

          // assert
          assert(
            controller.value.text == expectedText,
            'Text is modified',
          );
          assert(
            controller.value.selection == expectedSelection,
            'Selection is modified',
          );
        },
      );

      test(
        'WHEN At start of a non-first line '
        'SHOULD modify that line',
        () {
          // arrange
          const initialText = '''
aaaa
aaaa
aaaa
''';
          const expectedText = '''
aaaa
**aaaa
aaaa
''';
          const initialSelection =
              TextSelection(baseOffset: 5, extentOffset: 5);
          const expectedSelection =
              TextSelection(baseOffset: 7, extentOffset: 7);
          controller.text = initialText;
          controller.selection = initialSelection;

          // act
          controller.modifySelectedLines(modifierCallback);

          // assert
          assert(
            controller.value.text == expectedText,
            'Text is modified',
          );
          assert(
            controller.value.selection == expectedSelection,
            'Selection is modified',
          );
        },
      );

      test(
        'WHEN at the end of the document '
        'SHOULD modify the last line',
        () {
          // arrange
          const initialText = '''
aaaa
aaaa
aaaa
''';
          const expectedText = '''
aaaa
aaaa
**aaaa
''';
          const initialSelection =
              TextSelection(baseOffset: 14, extentOffset: 14);
          const expectedSelection =
              TextSelection(baseOffset: 16, extentOffset: 16);
          controller.text = initialText;
          controller.selection = initialSelection;

          // act
          controller.modifySelectedLines(modifierCallback);

          // assert
          assert(
            controller.value.text == expectedText,
            'Text is modified',
          );
          assert(
            controller.value.selection == expectedSelection,
            'Selection is modified',
          );
        },
      );
    });

    group('Selection is not collapsed', () {
      test(
        'WHEN entire multiline document is selected '
        'SHOULD modify all lines',
        () {
          // arrange
          const initialText = '''
AAAA
AAAA
AAAA
AAAA
''';
          const expectedText = '''
**AAAA
**AAAA
**AAAA
**AAAA
''';
          const initialSelection =
              TextSelection(baseOffset: 0, extentOffset: 19);
          const expectedSelection =
              TextSelection(baseOffset: 0 + 2, extentOffset: 19 + 8);
          controller.text = initialText;
          controller.selection = initialSelection;

          // act
          controller.modifySelectedLines(modifierCallback);

          // assert
          assert(
            controller.value.text == expectedText,
            'Text is modified',
          );
          assert(
            controller.value.selection == expectedSelection,
            'Selection is modified',
          );
        },
      );

      test(
        'WHEN 2 lines in the middle of the document are selected'
        'SHOULD modify that 2 lines',
        () {
          // arrange
          const initialText = '''
aaaa
aaAA
AAaa
aaaa
''';
          const expectedText = '''
aaaa
**aaAA
**AAaa
aaaa
''';
          const initialSelection =
              TextSelection(baseOffset: 7, extentOffset: 12);
          const expectedSelection =
              TextSelection(baseOffset: 7 + 2, extentOffset: 12 + 4);
          controller.text = initialText;
          controller.selection = initialSelection;

          // act
          controller.modifySelectedLines(modifierCallback);

          // assert
          assert(
            controller.value.text == expectedText,
            'Text is modified',
          );
          assert(
            controller.value.selection == expectedSelection,
            'Selection is modified',
          );
        },
      );
    });
  });

  group('Contains folded blocks', () {});
}
