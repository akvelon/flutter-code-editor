import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/python.dart';

import '../common/create_app.dart';
import '../common/snippets.dart';
import '../common/text_editing_value.dart';
import '../common/widget_tester.dart';

const _commentsCode = '''
private class MyClass {
  //comment1
  //comment2
  void method() {}
}
''';

void main() {
  group('CodeController. Folding.', () {
    group('Editing', () {
      group('Folded block is still recognizable after edit', () {
        group('Java', () {
          testWidgets('above a folded block', (WidgetTester wt) async {
            final controller = await pumpController(wt, TwoMethodsSnippet.full);
            controller.foldAt(1);
            await wt.selectFromHome(0, offset: 7);

            controller.value = controller.value.replacedSelection('public');

            expect(
              controller.value,
              const TextEditingValue(
                text: '''
public class MyClass {
  void method1() {

  void method2() {
    return;
  }
}
''',
                selection: TextSelection(baseOffset: 0, extentOffset: 6),
              ),
            );

            controller.unfoldAt(1);

            expect(
              controller.value,
              const TextEditingValue(
                text: '''
public class MyClass {
  void method1() {
    if (false) {
      return;
    }
  }

  void method2() {
    return;
  }
}
''',
                selection: TextSelection(baseOffset: 0, extentOffset: 6),
              ),
            );
          });

          testWidgets('the first line of a folded block',
              (WidgetTester wt) async {
            final controller = await pumpController(wt, TwoMethodsSnippet.full);
            controller.foldAt(0);
            await wt.selectFromHome(0, offset: 7);

            controller.value = controller.value.replacedSelection('public');

            expect(
              controller.value,
              const TextEditingValue(
                text: '''
public class MyClass {
''',
                selection: TextSelection(baseOffset: 0, extentOffset: 6),
              ),
            );

            controller.unfoldAt(0);

            expect(
              controller.value,
              const TextEditingValue(
                text: '''
public class MyClass {
  void method1() {
    if (false) {
      return;
    }
  }

  void method2() {
    return;
  }
}
''',
                selection: TextSelection(baseOffset: 0, extentOffset: 6),
              ),
            );
          });

          testWidgets('between folded blocks', (WidgetTester wt) async {
            final controller = await pumpController(wt, TwoMethodsSnippet.full);
            controller.foldAt(1);
            controller.foldAt(7);

            await wt.selectFromHome(43);
            controller.value = controller.value.replacedSelection('int n;\n');

            expect(
              controller.value,
              const TextEditingValue(
                text: '''
private class MyClass {
  void method1() {
int n;

  void method2() {
}
''',
                selection: TextSelection.collapsed(offset: 50),
              ),
            );

            controller.unfoldAt(1);
            controller.unfoldAt(8);

            expect(
              controller.value,
              const TextEditingValue(
                text: '''
private class MyClass {
  void method1() {
    if (false) {
      return;
    }
  }
int n;

  void method2() {
    return;
  }
}
''',
                selection: TextSelection.collapsed(offset: 91),
              ),
            );
          });

          testWidgets('Add multiline text before and after a folded block',
              (wt) async {
            const visibleText = '\nmethod1(){\n';
            const example = '\nmethod1(){\n  if (true) return;\n}\n';
            const insertedText = 'a\na\na\n';

            final controller = await pumpController(wt, example);

            controller.foldAt(1);

            await wt.cursorHome();

            controller.value = controller.value.replacedSelection(insertedText);

            const insertedBeforeExpected = TextEditingValue(
              text: insertedText + visibleText,
              selection: TextSelection.collapsed(offset: 6),
            );

            expect(controller.value, insertedBeforeExpected);

            await wt.cursorEnd();
            controller.value = controller.value.replacedSelection(insertedText);

            const insertedAfterExpected = TextEditingValue(
              text: insertedText + visibleText + insertedText,
              selection: TextSelection.collapsed(offset: 24),
            );

            expect(controller.value, insertedAfterExpected);
          });

          testWidgets('Remove multiline text before folded block', (wt) async {
            const example = 'a\na\na\nmethod1(){\n  if (true) return;\n}\n';

            final controller = await pumpController(wt, example);
            controller.foldAt(3);
            await wt.selectFromHome(0, offset: 6);

            const expected = TextEditingValue(
              text: 'method1(){\n',
              selection: TextSelection.collapsed(offset: 0),
            );

            controller.value = controller.value.replacedSelection('');
            expect(controller.value, expected);
          });

          testWidgets('Adding an import after folded imports -> Unfold',
              (wt) async {
            const example = 'package example;\nimport java.util.Date;\n';
            const inserted = 'import java.util.ArrayList;';
            final controller = await pumpController(wt, example);

            controller.foldImports();
            expect(controller.code.foldedBlocks.length, 1);

            await wt.cursorEnd();
            controller.value = controller.value.replacedSelection(inserted);
            // TODO(yescorp): Fix selection, then fix tests
            //  https://github.com/akvelon/flutter-code-editor/issues/182
            expect(controller.value.text, example + inserted);
            expect(controller.code.foldedBlocks.length, 0);
          });

          testWidgets(
              'Adding non-import after folded imports -> Does not unfold',
              (wt) async {
            const example = 'package example;\nimport java.util.Date;\n';
            const visible = 'package example;\n';
            const inserted = 'a';
            final controller = await pumpController(wt, example);

            controller.foldImports();
            expect(controller.code.foldedBlocks.length, 1);

            await wt.cursorEnd();
            controller.value = controller.value.replacedSelection(inserted);

            expect(controller.value.text, visible + inserted);
            expect(controller.code.foldedBlocks.length, 1);
            await wt.moveCursor(-1); // Reset timer.
          });

          testWidgets('Add comment after folded comments block -> Unfold',
              (wt) async {
            const example = '// comment 1\n// comment 2\n';
            const inserted = '// comment 3';
            final controller = await pumpController(wt, example);

            controller.foldAt(0);
            expect(controller.code.foldedBlocks.length, 1);

            await wt.cursorEnd();
            controller.value = controller.value.replacedSelection(inserted);
            // TODO(yescorp): Fix selection, then fix tests
            //  https://github.com/akvelon/flutter-code-editor/issues/182
            expect(controller.value.text, example + inserted);
            expect(controller.code.foldedBlocks.length, 0);
          });

          testWidgets(
              'Add non-comment after folded comments -> Does not unfold',
              (wt) async {
            const example = '// comment 1\n// comment 2\n';
            const visible = '// comment 1\n';
            const inserted = 'a';
            final controller = await pumpController(wt, example);

            controller.foldAt(0);
            expect(controller.code.foldedBlocks.length, 1);

            await wt.cursorEnd();
            controller.value = controller.value.replacedSelection(inserted);
            expect(controller.value.text, visible + inserted);
            expect(controller.code.foldedBlocks.length, 1);

            await wt.moveCursor(-1); // Reset timer.
          });
        });

        group('Python', () {
          testWidgets(
              'Indent block is opened '
              'if the next line is being edited to be a part of this block',
              (wt) async {
            const example = 'a:\n  aaaa\n';
            final controller = await pumpController(
              wt,
              example,
              language: python,
            );
            controller.foldAt(0);

            expect(controller.value.text, 'a:\n');
            //                                 \ selection
            await wt.selectFromHome(3);
            controller.value = controller.value.replacedSelection('  bbbb');

            const expectedText = 'a:\n  aaaa\n  bbbb';

            expect(controller.value.text, expectedText);
            expect(controller.code.foldedBlocks.length, 0);
          });

          testWidgets(
              'Indent block is not opened if the next line is edited '
              'but it is not part of the block yet', (wt) async {
            const example = 'a:\n  aaaa\n';
            final controller = await pumpController(
              wt,
              example,
              language: python,
            );
            controller.foldAt(0);

            expect(controller.value.text, 'a:\n');
            //                                 \ selection
            await wt.selectFromHome(3);
            controller.value = controller.value.replacedSelection('bbbb');

            const expectedText = 'a:\nbbbb';

            expect(controller.value.text, expectedText);
            expect(controller.code.foldedBlocks.length, 1);

            controller.unfoldAt(0);

            expect(controller.value.text, 'a:\n  aaaa\nbbbb');
            expect(controller.code.foldedBlocks.length, 0);
          });

          testWidgets(
              'Indent block is not opened '
              'if the newline char was inserted to the next line', (wt) async {
            const example = 'a:\n  aaaa\n\n';
            final controller = await pumpController(
              wt,
              example,
              language: python,
            );

            controller.foldAt(0);

            expect(controller.value.text, 'a:\n\n');
            //                                 \ selection
            await wt.selectFromHome(3);

            controller.value = controller.value.replacedSelection('\n');

            const expectedText = 'a:\n\n\n';

            expect(controller.value.text, expectedText);
            expect(controller.code.foldedBlocks.length, 1);
            await wt.moveCursor(-1); // Reset timer.
          });
        });
      });

      group('Folded block is no longer recognizable', () {
        group('Miltiline comment that started before folded block', () {
          testWidgets('Does not unfold the block', (wt) async {
            const example = '\na{\n}';
            //               \ starting selection
            final controller = await pumpController(wt, example);
            controller.foldAt(1);

            await wt.selectFromHome(0);
            controller.value = controller.value.replacedSelection('/*');
            const expected = TextEditingValue(
              text: '/*\na{',
              //       \ selection after insertion
              selection: TextSelection.collapsed(offset: 2),
            );
            expect(controller.value, expected);
          });

          testWidgets('The block is still unfoldable manually', (wt) async {
            const example = '\na{\n}';
            //               \ starting selection
            final controller = await pumpController(wt, example);
            controller.foldAt(1);

            await wt.selectFromHome(0);
            controller.value = controller.value.replacedSelection('/*');
            const expected = TextEditingValue(
              text: '/*\na{',
              //       \ selection after insertion
              selection: TextSelection.collapsed(offset: 2),
            );
            expect(controller.value, expected);

            controller.unfoldAt(1);
            const unfoldedResult = TextEditingValue(
              text: '/*\na{\n}',
              //       \ selection
              selection: TextSelection.collapsed(offset: 2),
            );
            expect(controller.value, unfoldedResult);
            expect(controller.code.foldedBlocks.length, 0);
          });

          testWidgets('The block is deletable', (wt) async {
            const example = '\na{\n}\n';
            //               \ starting selection
            final controller = await pumpController(wt, example);
            controller.foldAt(1);

            await wt.selectFromHome(0);
            controller.value = controller.value.replacedSelection('/*');
            const expected = TextEditingValue(
              text: '/*\na{\n',
              //       \ selection after insertion
              selection: TextSelection.collapsed(offset: 2),
            );
            expect(controller.value, expected);

            // select everything
            await wt.selectFromHome(
              2,
              offset: controller.value.text.length - 2,
            );
            controller.value = controller.value.replacedSelection('');
            const deletedResult = TextEditingValue(
              text: '/*',
              selection: TextSelection.collapsed(offset: 2),
            );
            expect(controller.value, deletedResult);
            expect(controller.code.foldedBlocks.length, 0);
          });
        });

        group('Multiline String', () {
          testWidgets('Does not unfold the block', (wt) async {
            const example = '\na{\n}';
            //               \ starting selection
            final controller = await pumpController(
              wt,
              example,
              language: python,
            );
            controller.foldAt(1);

            await wt.selectFromHome(0);
            controller.value = controller.value.replacedSelection('"""');
            const expected = TextEditingValue(
              text: '"""\na{',
              //       \ selection after insertion
              selection: TextSelection.collapsed(offset: 3),
            );
            expect(controller.value, expected);
          });

          testWidgets('The block is still unfoldable manually', (wt) async {
            const example = '\na{\n}';
            //               \ starting selection
            final controller = await pumpController(
              wt,
              example,
              language: python,
            );
            controller.foldAt(1);

            await wt.selectFromHome(0);
            controller.value = controller.value.replacedSelection('"""');
            const expected = TextEditingValue(
              text: '"""\na{',
              //       \ selection after insertion
              selection: TextSelection.collapsed(offset: 3),
            );
            expect(controller.value, expected);

            controller.unfoldAt(1);
            const unfoldedResult = TextEditingValue(
              text: '"""\na{\n}',
              //       \ selection
              selection: TextSelection.collapsed(offset: 3),
            );
            expect(controller.value, unfoldedResult);
            expect(controller.code.foldedBlocks.length, 0);
          });

          testWidgets('The block is deletable', (wt) async {
            const example = '\na{\n}\n';
            //               \ starting selection
            final controller = await pumpController(
              wt,
              example,
              language: python,
            );
            controller.foldAt(1);

            await wt.selectFromHome(0);
            controller.value = controller.value.replacedSelection('"""');
            const expected = TextEditingValue(
              text: '"""\na{\n',
              //       \ selection after insertion
              selection: TextSelection.collapsed(offset: 3),
            );
            expect(controller.value, expected);

            // select everything
            await wt.selectFromHome(
              3,
              offset: controller.value.text.length - 3,
            );
            controller.value = controller.value.replacedSelection('');
            const deletedResult = TextEditingValue(
              text: '"""',
              selection: TextSelection.collapsed(offset: 3),
            );
            expect(controller.value, deletedResult);
            expect(controller.code.foldedBlocks.length, 0);
          });
        });
      });
    });

    group('Deleting folded blocks.', () {
      testWidgets('First block of the same length', (WidgetTester wt) async {
        final controller = await pumpController(wt, TwoMethodsSnippet.full);
        controller.foldAt(1);

        await wt.selectFromHome(41, offset: 2);
        // private class MyClass {\n  void method1() {
        //                                           \ cursor
        controller.value = controller.value.replacedSelection(';');

        expect(
          controller.value,
          const TextEditingValue(
            text: '''
private class MyClass {
  void method1() ;
  void method2() {
    return;
  }
}
''',
            // TODO(alexeyinkin): Selection.
            selection: TextSelection(baseOffset: 41, extentOffset: 42),
          ),
        );
      });

      testWidgets('Second block of the same length', (WidgetTester wt) async {
        final controller = await pumpController(wt, TwoMethodsSnippet.full);
        controller.foldAt(7);
        await wt.selectFromHome(102, offset: 2);
        // ...void method2() {
        //                   \ cursor

        controller.value = controller.value.replacedSelection(';');

        expect(
          controller.value,
          const TextEditingValue(
            text: '''
private class MyClass {
  void method1() {
    if (false) {
      return;
    }
  }

  void method2() ;}
''',
            // TODO(alexeyinkin): Selection.
            selection: TextSelection(baseOffset: 102, extentOffset: 103),
          ),
        );
      });

      // TODO(alexeyinkin): Fix, https://github.com/akvelon/flutter-code-editor/issues/83
      testWidgets(
        'When deleting 2nd identical folded block, 1st one incorrectly folds',
        (WidgetTester wt) async {
          final controller = await pumpController(wt, '''
{
if (true) {
}
if (true) {
}
}
''');
          controller.foldAt(3);
          await wt.selectFromHome(26, offset: 2);
          // {\nif (true) {\n}\nif (true) {}\n\n
          //                              \ cursor

          controller.value = controller.value.replacedSelection(';');

          expect(
            controller.value,
            const TextEditingValue(
              text: '''
{
if (true) {
if (true) ;}
''',
              // TODO(alexeyinkin): Selection.
              selection: TextSelection.collapsed(offset: 13),
            ),
          );
        },
      );

      testWidgets('Deleting folded comments', (WidgetTester wt) async {
        final controller = await pumpController(wt, _commentsCode);
        controller.foldAt(1);
        await wt.selectFromHome(26, offset: 13);
        // private class MyClass {\n  //comment1\n  void method...
        //                            \--selected-->

        controller.value = controller.value.replacedSelection('');

        expect(
          controller.value,
          const TextEditingValue(
            text: '''
private class MyClass {
  void method() {}
}
''',
            selection: TextSelection.collapsed(offset: 26),
          ),
        );
      });

      testWidgets('Inserting after folded comments', (WidgetTester wt) async {
        final controller = await pumpController(wt, _commentsCode);
        controller.foldAt(1);
        await wt.selectFromHome(37);
        // private class MyClass {\n  //comment1\n  void method...
        //                                        \ cursor

        controller.value = controller.value.replacedSelection('  int n;\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: '''
private class MyClass {
  //comment1
  int n;
  void method() {}
}
''',
            selection: TextSelection.collapsed(offset: 46),
          ),
        );
      });
    });
  });
}
