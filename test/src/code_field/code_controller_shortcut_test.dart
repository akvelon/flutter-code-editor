import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';
import '../common/widget_tester.dart';

const _text = '''
class MyClass {
  void method() {// [START section1]
  }// [END section1]
}
''';

const _visibleText = '''
class MyClass {
  void method() {
}
''';

const _copiedText = '''
void method() {// [START section1]
  }// [END section1]
''';

const _visibleTextAfterCut = '''
class MyClass {
  }
''';

void main() {
  final calls = <MethodCall>[];

  void mockClipboardHandler() {
    calls.clear();

    SystemChannels.platform.setMockMethodCallHandler((MethodCall call) async {
      calls.add(call);
    });
  }

  group('CodeController. Shortcuts.', () {
    testWidgets('Select all', (WidgetTester wt) async {
      final controller = await pumpController(wt, _text);
      controller.foldAt(1);

      await wt.sendKeyDownEvent(LogicalKeyboardKey.control);
      await wt.sendKeyEvent(LogicalKeyboardKey.keyA);
      await wt.sendKeyUpEvent(LogicalKeyboardKey.control);

      expect(
        controller.value,
        const TextEditingValue(
          text: _visibleText,
          selection: TextSelection(
            baseOffset: 0,
            extentOffset: _visibleText.length,
          ),
        ),
      );
    });

    testWidgets('Copy, Cut', (WidgetTester wt) async {
      final examples = [
        //
        _CopyExample(
          'Copy with Ctrl-C',
          act: () async {
            await wt.sendKeyDownEvent(LogicalKeyboardKey.control);
            await wt.sendKeyEvent(LogicalKeyboardKey.keyC);
            await wt.sendKeyUpEvent(LogicalKeyboardKey.control);
          },
          visibleTextAfter: _visibleText,
        ),

        _CopyExample(
          'Copy with Ctrl-Insert',
          act: () async {
            await wt.sendKeyDownEvent(LogicalKeyboardKey.control);
            await wt.sendKeyEvent(LogicalKeyboardKey.insert);
            await wt.sendKeyUpEvent(LogicalKeyboardKey.control);
          },
          visibleTextAfter: _visibleText,
        ),

        _CopyExample(
          'Cut with Ctrl-X',
          act: () async {
            await wt.sendKeyDownEvent(LogicalKeyboardKey.control);
            await wt.sendKeyEvent(LogicalKeyboardKey.keyX);
            await wt.sendKeyUpEvent(LogicalKeyboardKey.control);
          },
          visibleTextAfter: _visibleTextAfterCut,
        ),

        _CopyExample(
          'Cut with Shift-Delete',
          act: () async {
            await wt.sendKeyDownEvent(LogicalKeyboardKey.shift);
            await wt.sendKeyEvent(LogicalKeyboardKey.delete);
            await wt.sendKeyUpEvent(LogicalKeyboardKey.shift);
          },
          visibleTextAfter: _visibleTextAfterCut,
        ),
      ];

      final controller = await pumpController(wt, '');

      for (final example in examples) {
        controller.value = const TextEditingValue(text: _text);
        controller.foldAt(1);
        await wt.selectFromHome(18, offset: 16);
        mockClipboardHandler();

        await example.act();

        expect(calls.length, 1);
        expect(calls[0].method, 'Clipboard.setData');
        expect(calls[0].arguments, {'text': _copiedText});
        expect(controller.text, example.visibleTextAfter);
      }
    });
  });
}

class _CopyExample {
  final String name;
  final Future<void> Function() act;
  final String visibleTextAfter;

  const _CopyExample(
    this.name, {
    required this.act,
    required this.visibleTextAfter,
  });
}
