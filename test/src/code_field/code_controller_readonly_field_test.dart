import 'package:flutter/cupertino.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodeController.readOnly', () {
    test('Setting readonly restricts modification of text', () {
      const initialText = 'Aaa\nAaaa';
      final controller = CodeController(
        text: initialText,
        readOnly: true,
      );

      controller.value = const TextEditingValue(
        text: 'Bbb\nBbbb',
      );

      expect(
        controller.value,
        const TextEditingValue(
          text: initialText,
        ),
      );

      const wholeTextSelection = TextSelection(
        baseOffset: 0,
        extentOffset: initialText.length,
      );
      controller.selection = wholeTextSelection;

      expect(controller.selection, wholeTextSelection);

      controller.indentSelection();
      controller.commentOutOrUncommentSelection();

      expect(controller.value.text, initialText);
      expect(controller.value.selection, wholeTextSelection);
    });
  });
}
