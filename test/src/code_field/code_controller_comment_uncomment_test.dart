// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/php.dart';

void main() {
  group('Comment Out / Uncomment', () {
    group('Language: java', () {
      test(
          'WHEN selection is collapsed '
          'SHOULD comment out the selected line if it is not a comment '
          'and uncomment otherwise '
          'AND select whole lines', () {
        final examples = [
          //
          _Example(
            'Document has only 1 not-commented line and it is selected',
            initialFullText: 'aa',
            initialSelection: TextSelection.collapsed(offset: 0),
            expectedFullText: '// aa',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 5),
          ),

          _Example(
            'Document has only 1 commented out line with a space after comment',
            initialFullText: '// aa',
            initialSelection: TextSelection.collapsed(offset: 0),
            expectedFullText: 'aa',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 2),
          ),

          _Example(
            'Document has only 1 commented out line '
            'without spaces between comment and text',
            initialFullText: '//aa',
            initialSelection: TextSelection.collapsed(offset: 0),
            expectedFullText: 'aa',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 2),
          ),
        ];

        for (final example in examples) {
          final controller = CodeController(language: java);
          controller.text = example.initialFullText;
          controller.selection = example.initialSelection;

          controller.commentOutOrUncommentSelection();

          expect(
            controller.value.text,
            example.expectedFullText,
            reason: example.name,
          );
          expect(
            controller.code.text,
            example.expectedFullText,
            reason: example.name,
          );
          expect(
            controller.value.selection,
            example.expectedSelection,
            reason: example.name,
          );
        }
      });

      test('Selection is a range that occupies several lines', () {
        final examples = [
          //
          _Example(
            'WHEN all selected lines are uncommented '
            'SHOULD comment out all selected lines',
            initialFullText: '''
aA
AA
Aa
''',
            initialSelection: TextSelection(baseOffset: 1, extentOffset: 7),
            expectedFullText: '''
// aA
// AA
// Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 18),
          ),

          _Example(
            'WHEN all selected lines are commented out '
            'SHOULD uncomment all selected lines',
            initialFullText: '''
// aA
// AA
// Aa
''',
            initialSelection: TextSelection(baseOffset: 4, extentOffset: 16),
            expectedFullText: '''
aA
AA
Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 9),
          ),

          _Example(
            'WHEN first selected line is uncommented, '
            'the rest are commented out '
            'SHOULD comment all lines out',
            initialFullText: '''
aA
// AA
// Aa
''',
            initialSelection: TextSelection(baseOffset: 1, extentOffset: 13),
            expectedFullText: '''
// aA
// // AA
// // Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 24),
          ),

          _Example(
            'WHEN non-first selected line is uncommented, '
            'the rest are commented out '
            'SHOULD comment out all lines',
            initialFullText: '''
// aA
AA
// Aa
''',
            initialSelection: TextSelection(baseOffset: 4, extentOffset: 13),
            expectedFullText: '''
// // aA
// AA
// // Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 24),
          ),

          _Example(
            'WHEN last selected line is uncommented, '
            'the rest are commented out '
            'SHOULD comment out all lines',
            initialFullText: '''
// aA
// AA
Aa
''',
            initialSelection: TextSelection(baseOffset: 4, extentOffset: 13),
            expectedFullText: '''
// // aA
// // AA
// Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 24),
          ),
        ];

        for (final example in examples) {
          final controller = CodeController(language: java);
          controller.text = example.initialFullText;
          controller.selection = example.initialSelection;

          controller.commentOutOrUncommentSelection();

          expect(
            controller.value.text,
            example.expectedFullText,
            reason: example.name,
          );
          expect(
            controller.code.text,
            example.expectedFullText,
            reason: example.name,
          );
          expect(
            controller.value.selection,
            example.expectedSelection,
            reason: example.name,
          );
        }
      });
    });

    group('Language: PHP', () {
      test('Selection is collapsed', () {
        final examples = [
          //
          _Example(
            'WHEN selection is invalid '
            'SHOULD do nothing',
            initialFullText: '''
a
''',
            initialSelection: TextSelection.collapsed(offset: -1),
            expectedFullText: '''
a
''',
            expectedSelection: TextSelection.collapsed(offset: -1),
          ),

          _Example(
            'WHEN line is not commented out '
            'SHOULD comment it out with the first sequence in the list',
            initialFullText: '''
a
''',
            initialSelection: TextSelection.collapsed(offset: 0),
            expectedFullText: '''
// a
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 5),
          ),

          _Example(
            'WHEN line is commented out with the first type of comment '
            'SHOULD uncomment it',
            initialFullText: '''
// a
''',
            initialSelection: TextSelection.collapsed(offset: 0),
            expectedFullText: '''
a
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 2),
          ),

          _Example(
            'WHEN line is commented out with the second type of comment '
            'SHOULD uncomment it',
            initialFullText: '''
# a
''',
            initialSelection: TextSelection.collapsed(offset: 0),
            expectedFullText: '''
a
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 2),
          ),

          _Example(
            'WHEN line is empty '
            'SHOULD only change selection',
            initialFullText: '''

''',
            initialSelection: TextSelection.collapsed(offset: 0),
            expectedFullText: '''

''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 1),
          ),
        ];

        for (final example in examples) {
          final controller = CodeController(language: php);
          controller.text = example.initialFullText;
          controller.selection = example.initialSelection;

          controller.commentOutOrUncommentSelection();

          expect(
            controller.value.text,
            example.expectedFullText,
            reason: example.name,
          );
          expect(
            controller.code.text,
            example.expectedFullText,
            reason: example.name,
          );
          expect(
            controller.value.selection,
            example.expectedSelection,
            reason: example.name,
          );
        }
      });

      test('Selection is a range', () {
        final examples = [
          //
          _Example(
            'WHEN every selected line '
            'has different type of single line comments '
            'SHOULD uncomment all of them',
            initialFullText: '''
// aA
# AA
// AA
# Aa
''',
            initialSelection: TextSelection(baseOffset: 4, extentOffset: 19),
            expectedFullText: '''
aA
AA
AA
Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 12),
          ),

          _Example(
            'WHEN every selected line '
            'has different type of single line comments '
            'and one line inbetween is empty '
            'SHOULD uncomment all commented lines and do not affect empty line',
            initialFullText: '''
// aA
# AA

# Aa
''',
            initialSelection: TextSelection(baseOffset: 4, extentOffset: 15),
            expectedFullText: '''
aA
AA

Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 10),
          ),

          _Example(
            'WHEN every selected line '
            'has different type of single line comments '
            'but one of them is not commented '
            'SHOULD comment out all lines',
            initialFullText: '''
// aA
AA

# Aa
''',
            initialSelection: TextSelection(baseOffset: 4, extentOffset: 13),
            expectedFullText: '''
// // aA
// AA

// # Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 24),
          ),

          _Example(
            'WHEN every selected line '
            'has different type of single line comments '
            'and they have different indentation '
            'SHOULD uncomment all commented out lines '
            'and do not affect empty line',
            initialFullText: '''
    // aA
  # AA

      # Aa
''',
            initialSelection: TextSelection(baseOffset: 8, extentOffset: 27),
            expectedFullText: '''
    aA
  AA

      Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 22),
          ),

          _Example(
            'WHEN every selected line '
            'has different type of single line comments '
            'and they have different indentation '
            'SHOULD uncomment all commented lines and do not affect empty line',
            initialFullText: '''
  // aA
    # AA

      # Aa
''',
            initialSelection: TextSelection(baseOffset: 6, extentOffset: 27),
            expectedFullText: '''
  aA
    AA

      Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 22),
          ),

          _Example(
            'WHEN every selected line '
            'has different type of single line comments '
            'and they have different indentation '
            'SHOULD uncomment all commented lines and do not affect empty line',
            initialFullText: '''
    // aA
  # AA

# Aa
''',
            initialSelection: TextSelection(baseOffset: 8, extentOffset: 21),
            expectedFullText: '''
    aA
  AA

Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 16),
          ),

          _Example(
            'WHEN non-commented lines have different indentation '
            'SHOULD comment out all lines and do not affect empty line',
            initialFullText: '''
    aA
  AA

      Aa
''',
            initialSelection: TextSelection(baseOffset: 5, extentOffset: 20),
            expectedFullText: '''
//     aA
//   AA

//       Aa
''',
            expectedSelection: TextSelection(baseOffset: 0, extentOffset: 31),
          ),

          _Example(
            'WHEN there are deselected lines '
            'SHOULD only comment selected lines.',
            initialFullText: '''
a
A
A
a
''',
            initialSelection: TextSelection(baseOffset: 2, extentOffset: 5),
            expectedFullText: '''
a
// A
// A
a
''',
            expectedSelection: TextSelection(baseOffset: 2, extentOffset: 12),
          ),
        ];

        for (final example in examples) {
          final controller = CodeController(language: php);
          controller.text = example.initialFullText;
          controller.selection = example.initialSelection;

          controller.commentOutOrUncommentSelection();

          expect(
            controller.value.text,
            example.expectedFullText,
            reason: example.name,
          );
          expect(
            controller.code.text,
            example.expectedFullText,
            reason: example.name,
          );
          expect(
            controller.value.selection,
            example.expectedSelection,
            reason: example.name,
          );
        }
      });
    });
  });
}

class _Example {
  final String name;
  final String initialFullText;
  final TextSelection initialSelection;
  final String expectedFullText;
  final TextSelection expectedSelection;

  const _Example(
    this.name, {
    required this.initialFullText,
    required this.initialSelection,
    required this.expectedFullText,
    required this.expectedSelection,
  });
}
