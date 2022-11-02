// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';
import '../common/snippets.dart';
import '../common/widget_tester.dart';

const _codeFolded1 = '''
private class MyClass {
  void method1() {

  void method2() {
    return;
  }
}
''';

void main() {
  setUp(() {
    focusNode = FocusNode();
  });

  group('CodeController. Folding.', () {
    group('Trivial.', () {
      test('With no folding blocks, nothing changes', () {
        const text = '''
int a;
int b;
int c;
''';
        final controller = createController(text);

        controller.foldAt(1);
        controller.unfoldAt(2);

        expect(controller.code.visibleText, text);
      });

      test('Folding does nothing if no foldable block on the line', () {
        final controller = createController(TwoMethodsSnippet.full);
        final oldCode = controller.code;

        controller.foldAt(3);

        expect(controller.code, oldCode);
      });

      test('Double folding changes nothing', () {
        final controller = createController(TwoMethodsSnippet.full);
        controller.foldAt(1);
        final oldCode = controller.code;

        controller.foldAt(1);

        expect(controller.code, oldCode);
      });

      test('Unfolding does nothing if no foldable block on the line', () {
        final controller = createController(TwoMethodsSnippet.full);
        final oldCode = controller.code;

        controller.unfoldAt(3);

        expect(controller.code, oldCode);
      });

      test('Unfolding non-folded changes nothing', () {
        final controller = createController(TwoMethodsSnippet.full);
        final oldCode = controller.code;

        controller.unfoldAt(1);

        expect(controller.code, oldCode);
      });
    });

    group('Hides text.', () {
      test('Hides highlighted', () {
        final controller = createController(TwoMethodsSnippet.full);
        final originalHtml = controller.code.visibleHighlighted?.toHtml();

        controller.foldAt(1);
        final foldedHtml = controller.code.visibleHighlighted?.toHtml();
        controller.unfoldAt(1);
        final unfoldedHtml = controller.code.visibleHighlighted?.toHtml();

        expect(
          foldedHtml,
          '''
<span class="hljs-keyword">private</span> <span class="hljs-class"><span class="hljs-keyword">class</span> <span class="hljs-title">MyClass</span> </span>{
  <span class="hljs-function"><span class="hljs-keyword">void</span> <span class="hljs-title">method1</span><span class="hljs-params">()</span> </span>{<span class="hljs-keyword"></span><span class="hljs-keyword"></span><span class="hljs-comment"></span><span class="hljs-keyword"></span><span class="hljs-comment"></span>

  <span class="hljs-function"><span class="hljs-keyword">void</span> <span class="hljs-title">method2</span><span class="hljs-params">()</span> </span>{<span class="hljs-comment"></span>
    <span class="hljs-keyword">return</span>;
  }<span class="hljs-comment"></span>
}
''',
        );
        expect(unfoldedHtml, originalHtml);
      });

      testWidgets('Cursor before', (WidgetTester wt) async {
        final controller = await pumpController(wt, TwoMethodsSnippet.full);
        final textBefore = controller.rawText;
        await wt.selectFromHome(1, offset: 1);

        controller.foldAt(1);

        expect(
          controller.value,
          const TextEditingValue(
            text: _codeFolded1,
            selection: TextSelection(baseOffset: 1, extentOffset: 2),
          ),
        );

        controller.unfoldAt(1);

        expect(
          controller.value,
          TextEditingValue(
            text: textBefore,
            selection: const TextSelection(baseOffset: 1, extentOffset: 2),
          ),
        );
      });
    });

    group('foldCommentAtLineZero', () {
      test('folds single line comments at line 0', () {
        final controller = createController(CommentImportSnippet.full);

        controller.foldCommentAtLineZero();

        expect(
          controller.text,
          '''
// comment1

package mypackage;
import java.util.Arrays;

{
}
''',
        );
      });

      test('folds multiline comments at line 0', () {
        final controller = createController(
          '/*\n*/\n' + CommentImportSnippet.full,
        );

        controller.foldCommentAtLineZero();

        expect(
          controller.text,
          '/*\n' + CommentImportSnippet.visible,
        );
      });

      test('does not fold if the comment is not on line 0', () {
        const prefixes = [
          '\n',
          '{\n}\n',
        ];

        for (final prefix in prefixes) {
          final controller = createController(
            prefix + CommentImportSnippet.full,
          );

          controller.foldCommentAtLineZero();

          expect(
            controller.text,
            prefix + CommentImportSnippet.visible,
            reason: prefix,
          );
        }
      });

      test('does nothing if no foldable comment blocks', () {
        const texts = [
          '',
          'int n;\nint m;',
          '{\n}\n',
        ];

        for (final text in texts) {
          final controller = createController(text);

          controller.foldCommentAtLineZero();

          expect(controller.text, text, reason: text);
        }
      });
    });

    group('foldImports', () {
      test('folds single line comments at line 0', () {
        final controller = createController(CommentImportSnippet.full);

        controller.foldImports();

        expect(
          controller.text,
          '''
// comment1
///comment2

package mypackage;

{
}
''',
        );
      });

      test('does nothing if no import blocks', () {
        const texts = [
          '',
          'int n;\nint m;',
          '{\n}\n',
          '//\n//\n',
        ];

        for (final text in texts) {
          final controller = createController(text);

          controller.foldImports();

          expect(controller.text, text, reason: text);
        }
      });
    });

    group('foldOutsideSections.', () {
      test('No blocks -> Do nothing', () {
        const texts = [
          '',
          'int n;',
        ];

        const sectionLists = <List<String>>[
          [],
          ['nonexistent'],
        ];

        for (final text in texts) {
          for (final sections in sectionLists) {
            final controller = createController(text);

            controller.foldOutsideSections(sections);

            expect(
              controller.code.visibleText,
              text,
              reason: '$text $sections',
            );
          }
        }
      });

      test('No sections -> Fold everything', () {
        const text = '''
{{
}
}
{
}
''';
        const expected = '''
{{
{
''';
        final controller = createController(text);

        controller.foldOutsideSections([]);

        expect(
          controller.code.visibleText,
          expected,
        );
      });

      test('Folds specific sections', () {
        const text = '''
{                                     //  0
  {                                   //  1
  }                                   //  2
                                      //  3
  {//[START matches_block]                4
  }//[END matches_block]                  5
                                      //  6
  {//[START matches_block_fold]           7
  }//[END matches_block_fold]             8
                                      //  9
  {                                   //  10
//[START outlives_block]                  11
  }                                   //  12
//[END outlives_block]                    13
                                      //  14
//[START outlived_by_block]               15
  {                                   //  16
//[END outlived_by_block]                 17
  }                                   //  18
                                      //  19
//[START contains_blocks]                 20
  {                                   //  21
  }                                   //  22
                                      //  23
  {                                   //  24
  }                                   //  25
//[END contains_blocks]                   26
                                      //  27
  {                                   //  28
  }                                   //  29
}                                     //  30
''';

        const foldedVisible = '''
{                                     //  0
  {                                   //  1
                                      //  3
  {
  }
                                      //  6
  {
                                      //  9
  {                                   //  10

  }                                   //  12

                                      //  14

  {                                   //  16

  }                                   //  18
                                      //  19

  {                                   //  21
  }                                   //  22
                                      //  23
  {                                   //  24
  }                                   //  25

                                      //  27
  {                                   //  28
}                                     //  30
''';

        final controller = createController(text);

        controller.foldOutsideSections([
          'matches_block',
          'outlives_block',
          'outlived_by_block',
          'contains_blocks',
          'nonexistent',
        ]);

        expect(
          controller.code.visibleText,
          foldedVisible,
        );
      });
    });
  });
}
