import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

import '../common/create_app.dart';

const _text = '''
// [START section2]
void method() {
}
''';

final _language = java;

void main() {
  group('CodeController. Value vs Code.', () {
    test('With no service comments, value == code', () {
      const text = '''
public class MyClass {
  public void main() {// comment
  }
}
''';

      final controller = CodeController(text: text, language: java);
      final initialValue = controller.value;
      controller.fullText = '$text//';
      final changedValue = controller.value;

      expect(initialValue, const TextEditingValue(text: text));
      expect(changedValue, const TextEditingValue(text: '$text//'));
    });

    test('With service comments, value == code less service_comments', () {
      const text = '''
public class MyClass {// readonly
  public void main() {// comment
  }
}
''';
      const textLessComments = '''
public class MyClass {
  public void main() {// comment
  }
}
''';

      final controller = CodeController(text: text, language: java);
      final initialValue = controller.value;
      controller.fullText = '$text//';
      final changedValue = controller.value;

      expect(initialValue, const TextEditingValue(text: textLessComments));
      expect(changedValue, const TextEditingValue(text: '$textLessComments//'));
    });
  });

  group('CodeController. Edits around hidden rages.', () {
    testWidgets(
      'Cannot get text into the hidden range comment, delete the range instead',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: _text,
          language: _language,
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the beginning.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        await wt.sendKeyEvent(LogicalKeyboardKey.delete);

        expect(
          controller.value,
          const TextEditingValue(
            text: 'void method() {\n}\n',
            //     \ cursor
            selection: TextSelection.collapsed(offset: 0),
          ),
        );
        expect(
          controller.fullText,
          'void method() {\n}\n',
        );
      },
    );

    testWidgets(
      'Indent new line before hidden range',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: '''
class MyClass {
  void method() {// [START section2]
  }// [END section2]
}
''',
          language: _language,
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the beginning.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        for (int i = 37; --i >= 0;) {
          await wt.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        }

        controller.value = controller.value.replacedSelection('\n');

        expect(
          controller.value,
          const TextEditingValue(
            text: 'class MyClass {\n  void method() {\n  }\n  \n}\n',
            //                                        cursor /
            selection: TextSelection.collapsed(offset: 40),
          ),
        );
        expect(
          controller.fullText,
          '''
class MyClass {
  void method() {// [START section2]
  }
  // [END section2]
}
''', // The new line is empty
        );
      },
    );

    testWidgets(
      'A typed-in service comment becomes a hidden range',
      (WidgetTester wt) async {
        final controller = CodeController(
          text: _text,
          language: _language,
          namedSectionParser: const BracketsStartEndNamedSectionParser(),
        );
        final focusNode = FocusNode();

        await wt.pumpWidget(createApp(controller, focusNode));
        focusNode.requestFocus();

        // Go to the beginning.
        await wt.sendKeyDownEvent(LogicalKeyboardKey.alt);
        await wt.sendKeyEvent(LogicalKeyboardKey.arrowUp);
        await wt.sendKeyUpEvent(LogicalKeyboardKey.alt);

        await wt.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        controller.value = controller.value.replacedSelection('//readonly ');

        expect(
          controller.value,
          const TextEditingValue(
            text: '\n\n}\n',
            //       \ cursor
            selection: TextSelection.collapsed(offset: 1),
          ),
        );
        expect(
          controller.fullText,
          '// [START section2]\n//readonly void method() {\n}\n',
        );
      },
    );
  });
}
