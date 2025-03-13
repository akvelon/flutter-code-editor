import 'package:flutter/services.dart';
import 'package:flutter_code_editor/src/code_field/editor_params.dart';
import 'package:flutter_code_editor/src/code_modifiers/insertion.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InsertionCodeModifier', () {
    const modifier = InsertionCodeModifier(openChar: '1', closeString: '23');
    const editorParams = EditorParams();

    test('inserts at the start of string correctly', () {
      const text = 'Hello World';
      final selection =
          TextSelection.fromPosition(const TextPosition(offset: 0));

      final result = modifier.updateString(text, selection, editorParams);

      expect(result!.text, '123Hello World');
      expect(result.selection.baseOffset, 1);
      expect(result.selection.extentOffset, 1);
    });

    test('inserts in the middle of string correctly', () {
      const text = 'Hello World';
      final selection =
          TextSelection.fromPosition(const TextPosition(offset: 5));

      final result = modifier.updateString(text, selection, editorParams);

      expect(result!.text, 'Hello123 World');
      expect(result.selection.baseOffset, 6);
      expect(result.selection.extentOffset, 6);
    });

    test('inserts at the end of string correctly', () {
      const text = 'Hello World';
      final selection =
          TextSelection.fromPosition(const TextPosition(offset: text.length));

      final result = modifier.updateString(text, selection, editorParams);

      expect(result!.text, 'Hello World123');
      expect(result.selection.baseOffset, text.length + 1);
      expect(result.selection.extentOffset, text.length + 1);
    });

    test('inserts in the middle of string with selection correctly', () {
      const text = 'Hello World';
      const selection = TextSelection(
        baseOffset: 5,
        extentOffset: 7,
      );

      final result = modifier.updateString(text, selection, editorParams);

      expect(result!.text, 'Hello123orld');
      expect(result.selection.baseOffset, 6);
      expect(result.selection.extentOffset, 6);
    });

    test('inserts at empty string correctly', () {
      const text = '';
      final selection =
          TextSelection.fromPosition(const TextPosition(offset: 0));

      final result = modifier.updateString(text, selection, editorParams);

      expect(result!.text, '123');
      expect(result.selection.baseOffset, 1);
      expect(result.selection.extentOffset, 1);
    });
  });
}
