// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/code_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/dart.dart';

import '../common/create_app.dart';

//                                    separate      separate      separate      trailing      trailing      trailing      no          no
//                                    start         start         start         start         start         start         start       start
//                                    no            separate      trailing      no            separate      trailing      trailing    separate
//                                    end           end           end           end           end           end           end         end
const _fullText = '''
class MyClass {//    0 [START whole]                                                                                      |           |
  //                 1 |              [START ss_ne] [START ss_se] [START ss_te]                                           |           |
  void method() {//  2 |              |             |             |             [START ts_ne] [START ts_se] [START ts_te] |           |
  }//                3 |              |             |             [END ss_te]   |             |             [END ts_te]   [END ns_te] |
  //                 4 |              |             [END ss_se]                 |             [END ts_se]                             [END ns_se]
}//                  5 [END whole]    |                                         |''';

const _fullVisibleText = '''
class MyClass {
  
  void method() {
  }
  
}''';

const _method = '''
  void method() {
  }''';

void main() {
  CodeController createTestController(Set<String> visibleSections) =>
      createController(
        _fullText,
        language: dart,
        visibleSectionNames: visibleSections,
      );

  group('Visible sections', () {
    test('Non existent visible section', () {
      final controller = createTestController({'while'});
      expect(controller.value.text, '');
      expect(controller.code.hiddenLineRanges.visibleLineNumbers.toList(), [5]);
    });

    test('Whole text as visible section', () {
      final controller = createTestController({'whole'});

      expect(controller.value.text, _fullVisibleText);
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [0, 1, 2, 3, 4, 5],
      );
    });

    test('Separate start no end', () {
      final controller = createTestController({'ss_ne'});

      expect(controller.value.text, '''
  
$_method
  
}''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [1, 2, 3, 4, 5],
      );
    });

    test('Separate start separate end', () {
      final controller = createTestController({'ss_se'});

      expect(controller.value.text, '''
  
$_method
  
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [1, 2, 3, 4],
      );
    });

    test('Separate start trailing end', () {
      final controller = createTestController({'ss_te'});

      expect(controller.value.text, '''
  
$_method
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [1, 2, 3],
      );
    });

    test('Trailing start no end', () {
      final controller = createTestController({'ts_ne'});

      expect(controller.value.text, '''
$_method
  
}''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [2, 3, 4, 5],
      );
    });

    test('Trailing start separate end', () {
      final controller = createTestController({'ts_se'});

      expect(controller.value.text, '''
$_method
  
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [2, 3, 4],
      );
    });

    test('Trailing start trailing end', () {
      final controller = createTestController({'ts_te'});

      expect(controller.value.text, '''
$_method
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [2, 3],
      );
    });

    test('No start separate end', () {
      final controller = createTestController({'ns_se'});

      expect(controller.value.text, '''
class MyClass {
  
$_method
  
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [0, 1, 2, 3, 4],
      );
    });

    test('No start trailing end', () {
      final controller = createTestController({'ns_te'});

      expect(controller.value.text, '''
class MyClass {
  
$_method
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [0, 1, 2, 3],
      );
    });

    test('Block folding works correctly', () {
      final controller = createTestController({'whole'});
      controller.foldAt(2);

      expect(controller.value.text, '''
class MyClass {
  
  void method() {
  
}''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [0, 1, 2, 4, 5],
      );
    });

    test('Code containing visible sections is readonly', () {
      final controller = createTestController({'whole'});

      final newLineIndexes = '\n'.allMatches(_fullVisibleText).toList();
      for (int i = 0; i < newLineIndexes.length; i++) {
        final index = newLineIndexes[i].start;
        // ignore: prefer_interpolation_to_compose_strings
        final newText = _fullVisibleText.substring(0, index) +
            'some text' +
            _fullVisibleText.substring(index);
        controller.value = TextEditingValue(
          text: newText,
          selection: TextSelection.collapsed(offset: index),
        );

        expect(controller.value.text, _fullVisibleText);
        expect(
          controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
          [0, 1, 2, 3, 4, 5],
        );
      }
    });

    test('Code folding works with changing visible sections', () {
      final controller = createController(
        '''
void method1() {// [START method1]
  int a;
}// [END method1]

void method2() {// [START method2]
  int a;
}// [END method2]''',
        language: dart,
      );

      controller.foldAt(4);
      controller.visibleSectionNames = {'method2'};
      expect(controller.value.text, 'void method2() {');

      controller.visibleSectionNames = {};
      expect(controller.value.text, '''
void method1() {
  int a;
}

void method2() {''');
    });

    test('Newline after closing comment on the last line', () {
      final controller = createController(
        '''
//[START show]
//[END show]
''',
        language: dart,
        visibleSectionNames: {'show'},
      );

      expect(controller.value.text, '\n\n');
    });
  });
}
