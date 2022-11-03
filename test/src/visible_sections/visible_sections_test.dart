import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/dart.dart';

import '../common/create_app.dart';

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
      final controller = createController(
        _twoSectionText,
        language: dart,
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
      final controller = createController(
        '''
// [START section1]
class MyClass {
\tvoid readOnlyMethod() {
\t}
\t
\tvoid method() {
\t}
}// [END section1]''',
        language: dart,
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
      final controller = createController(
        '''
class MyClass {// [START section1]
\tvoid readOnlyMethod() {
\t}
\t
\tvoid method() {
\t}
}// [END section1]''',
        language: dart,
      );
      controller.visibleSectionNames = {'section1'};

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
      final controller = createController(
        _justOpenTextSeparate,
        language: dart,
        visibleSectionNames: {'anotherMethods'},
      );

      expect(controller.value.text, '\n$_method2n3');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [4, 5, 6, 7, 8, 9, 10, 11, 12],
      );
    });

    test('When section opens inline and dont closes works correctly', () {
      final controller = createController(
        _justOpenTextInline,
        language: dart,
        visibleSectionNames: {'anotherMethods'},
      );

      expect(controller.value.text, _method2n3);
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [4, 5, 6, 7, 8, 9, 10, 11],
      );
    });

    test('Block folding works correctly', () {
      final controller = createController(
        _justOpenTextInline,
        language: dart,
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
      final controller = createController(
        _justOpenTextInline,
        language: dart,
        visibleSectionNames: {'anotherMethods'},
      );
      controller.value = TextEditingValue.empty;

      expect(controller.value.text, _method2n3);
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [4, 5, 6, 7, 8, 9, 10, 11],
      );
    });

    test('Code folding works with changing visible sections', () {
      final controller = createController(
        '''
void method1() {// [START method1]
  print('method1');
}// [END method1]

void method2() {// [START method2]
  print('method2');
}// [END method2]''',
        language: dart,
      );

      //Fold and set visible section
      controller.foldAt(4);
      controller.visibleSectionNames = {'method2'};
      expect(controller.value.text, 'void method2() {');

      controller.visibleSectionNames = {};
      expect(controller.value.text, '''
void method1() {
  print('method1');
}

void method2() {''');
    });
  });
}
