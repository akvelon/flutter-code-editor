import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

const _editableBeginningEnd = '''
abc
ro//readonly
ro//readonly
abc
''';

const _editableBetween = '''
ro//readonly
abc
ro//readonly
''';

final _language = java;

void main() {
  group('CodeController Read-only', () {
    testWidgets(
      'Can edit at editable beginning of the document',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: _editableBeginningEnd,
          language: _language,
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(_createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the beginning.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\nro//readonly\nro//readonly\nabc\n',
            //     \ cursor
            selection: TextSelection.collapsed(offset: 0),
          ),
          reason: 'Backspace - No effect',
        );

        await wt.sendKeyEvent(LogicalKeyboardKey.delete);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'bc\nro//readonly\nro//readonly\nabc\n',
            //     \ cursor
            selection: TextSelection.collapsed(offset: 0),
          ),
          reason: 'Delete - OK',
        );

        // TODO(alexeyinkin): Simulate keyboard entry, https://github.com/akvelon/flutter-code-editor/issues/30
        controller.value = controller.value.replacedSelection('a\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'a\nbc\nro//readonly\nro//readonly\nabc\n',
            //        \ cursor
            selection: TextSelection.collapsed(offset: 2),
          ),
          reason: 'Type - OK',
        );
      },
    );

    testWidgets(
      'Can edit at editable end of the document',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: _editableBeginningEnd,
          language: _language,
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(_createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the beginning.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        await wt.sendKeyEvent(LogicalKeyboardKey.delete);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\nro//readonly\nro//readonly\nabc\n',
            //                                   cursor /
            selection: TextSelection.collapsed(
              offset: 34,
              affinity: TextAffinity.upstream,
            ),
          ),
          reason: 'Delete - no effect',
        );

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\nro//readonly\nro//readonly\nabc',
            //                                 cursor /
            selection: TextSelection.collapsed(offset: 33),
          ),
          reason: 'Backspace - OK',
        );

        // TODO(alexeyinkin): Simulate keyboard entry, https://github.com/akvelon/flutter-code-editor/issues/30
        controller.value = controller.value.replacedSelection('d\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\nro//readonly\nro//readonly\nabcd\n',
            //                                    cursor /
            selection: TextSelection.collapsed(offset: 35),
          ),
          reason: 'Type - OK',
        );
      },
    );

    testWidgets(
      'Junction of editable and read-only',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: _editableBeginningEnd,
          language: _language,
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(_createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the end of the editable line before a read-only line.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        await wt.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        await wt.sendKeyEvent(LogicalKeyboardKey.delete);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\nro//readonly\nro//readonly\nabc\n',
            //        \ cursor
            selection: TextSelection.collapsed(offset: 3),
          ),
          reason: 'Delete EOL before readonly - No effect',
        );

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'ab\nro//readonly\nro//readonly\nabc\n',
            //       \ cursor
            selection: TextSelection.collapsed(offset: 2),
          ),
          reason: 'Backspace before EOL before readonly - OK',
        );

        // TODO(alexeyinkin): Simulate keyboard entry, https://github.com/akvelon/flutter-code-editor/issues/30
        controller.value = controller.value.replacedSelection('c\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\n\nro//readonly\nro//readonly\nabc\n',
            //          \ cursor
            selection: TextSelection.collapsed(offset: 4),
          ),
          reason: 'Type before EOL before readonly - OK',
        );

        await wt.sendKeyEvent(LogicalKeyboardKey.arrowRight);

        await wt.sendKeyEvent(LogicalKeyboardKey.delete);
        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);

        // TODO(alexeyinkin): Simulate keyboard entry, https://github.com/akvelon/flutter-code-editor/issues/30
        controller.value = controller.value.replacedSelection('y\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\n\nro//readonly\nro//readonly\nabc\n',
            //          \ cursor
            selection: TextSelection.collapsed(offset: 5),
          ),
          reason: 'Delete Backspace Type at beginning of readonly - No effect',
        );
      },
    );

    testWidgets(
      'Junction of and read-only and editable',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: _editableBeginningEnd,
          language: _language,
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(_createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the beginning of the editable line after a read-only line.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        await wt.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        await wt.sendKeyEvent(LogicalKeyboardKey.delete);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\nro//readonly\nro//readonly\nbc\n',
            //                              cursor /
            selection: TextSelection.collapsed(offset: 30),
          ),
          reason: 'Delete at beginning of first editable line - OK',
        );

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\nro//readonly\nro//readonly\nbc\n',
            //                              cursor /
            selection: TextSelection.collapsed(offset: 30),
          ),
          reason: 'Backspace at beginning of first editable line - No effect',
        );

        // TODO(alexeyinkin): Simulate keyboard entry, https://github.com/akvelon/flutter-code-editor/issues/30
        controller.value = controller.value.replacedSelection('a\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'abc\nro//readonly\nro//readonly\na\nbc\n',
            //                                 cursor /
            selection: TextSelection.collapsed(offset: 32),
          ),
          reason: 'Type at beginning of first editable line - OK',
        );
      },
    );

    testWidgets(
      'Read-only beginning of the document',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: _editableBetween,
          language: _language,
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(_createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the beginning.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);
        await wt.sendKeyEvent(LogicalKeyboardKey.delete);

        // TODO(alexeyinkin): Simulate keyboard entry, https://github.com/akvelon/flutter-code-editor/issues/30
        controller.value = controller.value.replacedSelection('a\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'ro//readonly\nabc\nro//readonly\n',
            //     \ cursor
            selection: TextSelection.collapsed(offset: 0),
          ),
          reason: 'Backspace Delete Type - No effect',
        );
      },
    );

    testWidgets(
      'Read-only end of the document',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: _editableBetween,
          language: _language,
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(_createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the end.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);
        await wt.sendKeyEvent(LogicalKeyboardKey.delete);

        // TODO(alexeyinkin): Simulate keyboard entry, https://github.com/akvelon/flutter-code-editor/issues/30
        controller.value = controller.value.replacedSelection('a\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'ro//readonly\nabc\nro//readonly\n',
            //                              cursor /
            selection: TextSelection.collapsed(offset: 30, affinity: TextAffinity.upstream),
          ),
          reason: 'Backspace Delete Type at last empty line - No effect',
        );

        await wt.sendKeyEvent(LogicalKeyboardKey.arrowLeft);

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);
        await wt.sendKeyEvent(LogicalKeyboardKey.delete);

        // TODO(alexeyinkin): Simulate keyboard entry, https://github.com/akvelon/flutter-code-editor/issues/30
        controller.value = controller.value.replacedSelection('a\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'ro//readonly\nabc\nro//readonly\n',
            //                            cursor /
            selection: TextSelection.collapsed(offset: 29),
          ),
          reason: 'Backspace Delete Type before last empty line - No effect',
        );
      },
    );
  });
}

MaterialApp _createApp(CodeController controller, FocusNode focusNode) {
  return MaterialApp(
    home: Scaffold(
      body: CodeField(
        controller: controller,
        focusNode: focusNode,
      ),
    ),
  );
}
