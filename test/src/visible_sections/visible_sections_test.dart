import 'package:flutter_code_editor/src/code_field/code_controller.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/dart.dart';

const _twoSectionText = '''
class MyClass {
\tvoid readOnlyMethod() {// [START section1]
\t}// [END section1]
\t// [START section2]
\tvoid method() {
\t}// [END section2]
}
''';

const _section2Text = '''
  
  void method() {
  }
''';

const _justOpenTextSeparate = '''
void method1() {
  print('method1');
}

// [START anotherMethods]
void method2() {
  print('method2');
}

void method3() {
  print('method3');
}
''';

const _justOpenTextInline = '''
void method1() {
  print('method1');
}

void method2() {// [START anotherMethods]
  print('method2');
}

void method3() {
  print('method3');
}
''';

const _method2n3 = '''
void method2() {
  print('method2');
}

void method3() {
  print('method3');
}
''';

void main() {
  group('Visible sections', () {
    test('One function in class shows correctly', () {
      final controller = _buildController(
        text: _twoSectionText,
        visibleSectionNames: {'section2'},
      );

      expect(controller.value.text, _section2Text);
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [3, 4, 5],
      );
    });

    test('Whole class as named section shows correctly. Start at separate line',
        () {
      final controller = _buildController(
        text: '''
// [START section1]
class MyClass {
\tvoid readOnlyMethod() {
\t}
\t
\tvoid method() {
\t}
}// [END section1]''',
        visibleSectionNames: {'section1'},
      );

      expect(controller.value.text, '''

class MyClass {
  void readOnlyMethod() {
  }
  
  void method() {
  }
}''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [0, 1, 2, 3, 4, 5, 6, 7],
      );
    });

    test('Whole class as named section shows correctly. Start at the same line',
        () {
      final controller = _buildController(
        text: '''
class MyClass {// [START section1]
\tvoid readOnlyMethod() {
\t}
\t
\tvoid method() {
\t}
}// [END section1]''',
        visibleSectionNames: {'section1'},
      );

      expect(controller.value.text, '''
class MyClass {
  void readOnlyMethod() {
  }
  
  void method() {
  }
}''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [0, 1, 2, 3, 4, 5, 6],
      );
    });

    test('When section opens at separate line and dont closes works correctly',
        () {
      final controller = _buildController(
        text: _justOpenTextSeparate,
        visibleSectionNames: {'anotherMethods'},
      );

      expect(controller.value.text, '\n$_method2n3');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [4, 5, 6, 7, 8, 9, 10, 11, 12],
      );
    });

    test('When section opens inline and dont closes works correctly', () {
      final controller = _buildController(
        text: _justOpenTextInline,
        visibleSectionNames: {'anotherMethods'},
      );

      expect(controller.value.text, _method2n3);
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [4, 5, 6, 7, 8, 9, 10, 11],
      );
    });

    test('Block folding works correctly', () {
      final controller = _buildController(
        text: _justOpenTextInline,
        visibleSectionNames: {'anotherMethods'},
      );
      controller.foldAt(4);

      expect(controller.value.text, '''
void method2() {

void method3() {
  print('method3');
}
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [4, 7, 8, 9, 10, 11],
      );
    });

    test('Code containing visible sections is readonly', () {
      final controller = _buildController(
        text: _justOpenTextInline,
        visibleSectionNames: {'anotherMethods'},
      );
      controller.value = TextEditingValue.empty;

      expect(controller.value.text, _method2n3);
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [4, 5, 6, 7, 8, 9, 10, 11],
      );
    });
  });
}

CodeController _buildController({
  required String text,
  required Set<String> visibleSectionNames,
}) {
  return CodeController(
    language: dart,
    text: text,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    visibleSectionsNames: visibleSectionNames,
  );
}
