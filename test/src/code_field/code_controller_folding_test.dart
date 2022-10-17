import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/code_controller.dart';
import 'package:flutter_code_editor/src/code_field/text_editing_value.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

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

void main() {
  late CodeController controller;
  late FocusNode focusNode;

  setUp(() {
    controller = CodeController(
      text: _code,
      language: java,
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
    );
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

        controller = CodeController(
          text: text,
          language: java,
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
        );

        controller.foldAt(1);
        controller.unfoldAt(1);

        expect(controller.code.visibleText, text);
      });

      test('Folding does nothing if no foldable block on the line', () {
        final oldCode = controller.code;

        controller.foldAt(3);

        expect(controller.code, oldCode);
      });

      test('Double folding changes nothing', () {
        controller.foldAt(1);
        final oldCode = controller.code;

        controller.foldAt(1);

        expect(controller.code, oldCode);
      });

      test('Unfolding does nothing if no foldable block on the line', () {
        final oldCode = controller.code;

        controller.unfoldAt(3);

        expect(controller.code, oldCode);
      });

      test('Unfolding non-folded changes nothing', () {
        final oldCode = controller.code;

        controller.unfoldAt(1);

        expect(controller.code, oldCode);
      });
    });

    group('Hides text.', () {
      test('Hides highlighted', () {
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
        final textBefore = controller.rawText;

        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

        await wt.selectFromHome(1, offset: 1);
        controller.foldAt(1);

        expect(
          controller.value,
          const TextEditingValue(
            text: _codeFolded1,
            // TODO(alexeyinkin): Selection.
            //selection: TextSelection(baseOffset: 1, extentOffset: 2),
          ),
        );

        controller.unfoldAt(1);

        expect(
          controller.value,
          TextEditingValue(
            text: textBefore,
            // TODO(alexeyinkin): Selection.
            //selection: TextSelection(baseOffset: 1, extentOffset: 2),
          ),
        );
      });
    });

    group('Editing', () {
      testWidgets('above a folded block', (WidgetTester wt) async {
        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

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
            // TODO(alexeyinkin): Selection.
            //selection: TextSelection(baseOffset: 1, extentOffset: 2),
          ),
        );
      });

      testWidgets('the first line of a folded block', (WidgetTester wt) async {
        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

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
            // TODO(alexeyinkin): Selection.
            //selection: TextSelection(baseOffset: 1, extentOffset: 2),
          ),
        );
      });

      testWidgets('between folded blocks', (WidgetTester wt) async {
        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

        controller.foldAt(1);
        controller.foldAt(7);

        // TODO(alexeyinkin): Allow this edit as one pasting, https://github.com/akvelon/flutter-code-editor/issues/82
        await wt.selectFromHome(43);
        controller.value = controller.value.replacedSelection('int n;');
        await wt.selectFromHome(49);
        controller.value = controller.value.replacedSelection('\n');

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
            // TODO(alexeyinkin): Selection.
            //selection: TextSelection(baseOffset: 1, extentOffset: 2),
          ),
        );
      });
    });

    group('Deleting folded blocks.', () {
      testWidgets('First block of the same length', (WidgetTester wt) async {
        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

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
        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

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
          controller = CodeController(
            text: '''
{
if (true) {
}
if (true) {
}
}
''',
            language: java,
            namedSectionParser: const BracketsStartEndNamedSectionParser(),
          );

          await wt.pumpWidget(createApp(controller, focusNode));
          focusNode.requestFocus();

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
    });
  });
}
