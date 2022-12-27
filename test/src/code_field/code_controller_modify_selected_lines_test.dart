import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

void main() {
  group('Modify selection', () {
    final language = java;
    test('normal selection', () {
      // Arrange
      const initialText = '''
class MyClass { 
  private int _id;
};
''';

      const expectedText = '''
  class MyClass { 
    private int _id;
};
''';

      final CodeController controller = CodeController(
        text: initialText,
        language: language,
      );

      controller.selection = controller.selection.copyWith(
        baseOffset: 4,
        extentOffset: 21,
      );

      // Act
      controller.modifySelectedRows((row) => '  $row');

      // Assert
      assert(
        controller.value.text == expectedText,
        'First 2 lines should have been modified',
      );
    });

    test('end is at the beginning of a line', () {
      // Arrange
      const initialText = '''
class MyClass {
  private int _id;
};
''';

      const expectedText = '''
  class MyClass {
    private int _id;
};
''';
      final CodeController controller = CodeController(
        text: initialText,
        language: language,
      );

      controller.selection = controller.selection.copyWith(
        baseOffset: 2,
        extentOffset: 17,
      );

      // Act
      controller.modifySelectedRows((row) => '  $row');

      // Assert
      assert(
        controller.value.text == expectedText,
        'first 2 lines should be modified',
      );
    });

    test('when selection is collapsed cursor line is modified', () {
      // Arrange
      const initialText = '''
class MyClass {
  private int _id;
};
''';

      const expectedText = '''
  class MyClass {
  private int _id;
};
''';
      final CodeController controller = CodeController(
        text: initialText,
        language: language,
      );

      controller.selection = controller.selection.copyWith(
        baseOffset: 0,
        extentOffset: 0,
      );

      // Act
      controller.modifySelectedRows((row) => '  $row');

      // Assert
      assert(
        controller.value.text == expectedText,
        'first line should be modified',
      );
    });
  });
}
