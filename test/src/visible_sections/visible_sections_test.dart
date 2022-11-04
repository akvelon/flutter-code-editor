import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/dart.dart';

import '../common/create_app.dart';

const _twoSectionText = '''
class MyClass {
  void someMethod() {// [START section1]
  }// [END section1]
  // [START section2]
  void method() {
  }// [END section2]
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

const _justEndTextSeparate = '''
void method1() {
  print('method1');
}

void method2() {
  print('method2');
}
// [END anotherMethods]

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

const _justEndTextInline = '''
void method1() {
  print('method1');
}

void method2() {
  print('method2');
}// [END anotherMethods]

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
    test('Whole text as a named section. Separate line', () {
      final controller = createController(
        '''
// [START section1]
class MyClass {
  void readOnlyMethod() {
  }

  void method() {
  }
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

    test('Whole class as named section shows correctly. The same line', () {
      final controller = createController(
        '''
class MyClass {// [START section1]
  void readOnlyMethod() {
  }

  void method() {
  }
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

    test('Non-existent named section -> Empty text', () {
      final controller = createController(
        _twoSectionText,
        language: dart,
        visibleSectionNames: {'section3'},
      );

      expect(controller.value.text, '');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [7],
      );
    });

    test('Start at separate line, no end', () {
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

    test('Start at the same line, no end', () {
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

    test('End on a separate line, no start', () {
      final controller = createController(
        _justEndTextSeparate,
        language: dart,
        visibleSectionNames: {'anotherMethods'},
      );

      expect(controller.value.text, '''
void method1() {
  print('method1');
}

void method2() {
  print('method2');
}

''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [0, 1, 2, 3, 4, 5, 6, 7],
      );
    });

    test('End on the same line, no start', () {
      final controller = createController(
        _justEndTextInline,
        language: dart,
        visibleSectionNames: {'anotherMethods'},
      );

      expect(controller.value.text, '''
void method1() {
  print('method1');
}

void method2() {
  print('method2');
}
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [0, 1, 2, 3, 4, 5, 6],
      );
    });

    test('Start at separate line, end at the same', () {
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

    test('Start and end on a separate line', () {
      final controller = createController(
        '''
void method1() {
  print('method1');
}

// [START section2]
void method2() {
  print('method2');
}
// [END section2]

void method3() {
  print('method3');
}''',
        language: dart,
        visibleSectionNames: {'section2'},
      );

      expect(controller.value.text, '''

void method2() {
  print('method2');
}

''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [4, 5, 6, 7, 8],
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

      final newLineIndexes = '\n'.allMatches(_method2n3).toList();
      for (int i = 0; i < newLineIndexes.length; i++) {
        final index = newLineIndexes[i].start;
        // ignore: prefer_interpolation_to_compose_strings
        final newText = _method2n3.substring(0, index) +
            'some text' +
            _method2n3.substring(index);
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: index),
        );

        expect(controller.value.text, _method2n3);
        expect(
          controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
          [4, 5, 6, 7, 8, 9, 10, 11],
        );
      }
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
