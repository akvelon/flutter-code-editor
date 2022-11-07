// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/src/code_field/code_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/dart.dart';

import '../common/create_app.dart';

const _fullText = '''
class MyClass {//    0 [START whole]
  //                 1 [START separate_start_no_end][START separate_start_separate_end][START separate_start_trailing_end]
  void method() {//  2 [START trailing_start_no_end][START trailing_start_separate_end][START trailing_start_trailing_end]
  }//                3 [END separate_start_trailing_end][END trailing_start_trailing_end][END no_start_trailing_end]
  //                 4 [END separate_start_separate_end][END trailing_start_separate_end][END no_start_separate_end]
}//                  5 [END whole]''';

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
      final controller = createTestController({'separate_start_no_end'});

      expect(controller.value.text, '''
  
$_method
  
}''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [1, 2, 3, 4, 5],
      );
    });

    test('Separate start separate end', () {
      final controller = createTestController({'separate_start_separate_end'});

      expect(controller.value.text, '''
  
$_method
  
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [1, 2, 3, 4],
      );
    });

    test('Separate start trailing end', () {
      final controller = createTestController({'separate_start_trailing_end'});

      expect(controller.value.text, '''
  
$_method
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [1, 2, 3],
      );
    });

    test('Trailing start no end', () {
      final controller = createTestController({'trailing_start_no_end'});

      expect(controller.value.text, '''
$_method
  
}''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [2, 3, 4, 5],
      );
    });

    test('Trailing start separate end', () {
      final controller = createTestController({'trailing_start_separate_end'});

      expect(controller.value.text, '''
$_method
  
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [2, 3, 4],
      );
    });

    test('Trailing start trailing end', () {
      final controller = createTestController({'trailing_start_trailing_end'});

      expect(controller.value.text, '''
$_method
''');
      expect(
        controller.code.hiddenLineRanges.visibleLineNumbers.toList(),
        [2, 3],
      );
    });

    test('No start separate end', () {
      final controller = createTestController({'no_start_separate_end'});

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
      final controller = createTestController({'no_start_trailing_end'});

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
