import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/text_editing_value.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';
import '../common/widget_tester.dart';

const _code = '''
private class MyClass {
  void method1() {
    if (false) {// [START section1]
      return;
    }// [END section1]
  }

  void method2() {// [START section2]
    return;
  }// [END section2]
}
''';

const _codeFolded1 = '''
private class MyClass {
  void method1() {

  void method2() {
    return;
  }
}
''';

const _commentsCode = '''
private class MyClass {
  //comment1
  //comment2
  void method() {}
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
        final controller = createController(_code);
        final oldCode = controller.code;

        controller.foldAt(3);

        expect(controller.code, oldCode);
      });

      test('Double folding changes nothing', () {
        final controller = createController(_code);
        controller.foldAt(1);
        final oldCode = controller.code;

        controller.foldAt(1);

        expect(controller.code, oldCode);
      });

      test('Unfolding does nothing if no foldable block on the line', () {
        final controller = createController(_code);
        final oldCode = controller.code;

        controller.unfoldAt(3);

        expect(controller.code, oldCode);
      });

      test('Unfolding non-folded changes nothing', () {
        final controller = createController(_code);
        final oldCode = controller.code;

        controller.unfoldAt(1);

        expect(controller.code, oldCode);
      });
    });

    group('Hides text.', () {
      test('Hides highlighted', () {
        final controller = createController(_code);
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
        final controller = await pumpController(wt, _code);
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

    group('Editing', () {
      testWidgets('above a folded block', (WidgetTester wt) async {
        final controller = await pumpController(wt, _code);
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

      testWidgets('the first line of a folded block', (WidgetTester wt) async {
        final controller = await pumpController(wt, _code);
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
        final controller = await pumpController(wt, _code);
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
    });

    group('Deleting folded blocks.', () {
      testWidgets('First block of the same length', (WidgetTester wt) async {
        final controller = await pumpController(wt, _code);
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
        final controller = await pumpController(wt, _code);
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
