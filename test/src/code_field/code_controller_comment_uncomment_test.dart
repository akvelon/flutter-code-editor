// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

void main() {
  group('Selection is collapsed, language: java', () {
    test(
        'WHEN selection is collapsed '
        'SHOULD comment selected line if it is not a comment '
        'and uncomment otherwise '
        'AND select whole lines', () {
      final examples = [
        _Example(
          'Document has only 1 not-commented line and it is selected',
          initialFullText: 'aa',
          initialSelection: TextSelection.collapsed(offset: 0),
          expectedFullText: '// aa',
          expectedSelection: TextSelection(baseOffset: 0, extentOffset: 5),
        ),
        _Example(
          'Document has only 1 commented line with a space after comment',
          initialFullText: '// aa',
          initialSelection: TextSelection.collapsed(offset: 0),
          expectedFullText: 'aa',
          expectedSelection: TextSelection(baseOffset: 0, extentOffset: 2),
        ),
        _Example(
          'Document has only 1 commented line without spaces between comment and text',
          initialFullText: '//aa',
          initialSelection: TextSelection.collapsed(offset: 0),
          expectedFullText: 'aa',
          expectedSelection: TextSelection(baseOffset: 0, extentOffset: 2),
        ),
        _Example(
          'Document has several lines, first line(not comment) is selected',
          initialFullText: '''
aa
aa
''',
          initialSelection: TextSelection.collapsed(offset: 0),
          expectedFullText: '''
// aa
aa
''',
          expectedSelection: TextSelection(baseOffset: 0, extentOffset: 6),
        ),
        _Example(
          'Document has several lines, first line(comment) is selected',
          initialFullText: '''
// aa
aa
''',
          initialSelection: TextSelection.collapsed(offset: 0),
          expectedFullText: '''
aa
aa
''',
          expectedSelection: TextSelection(baseOffset: 0, extentOffset: 3),
        ),
        _Example(
          'Document has several lines, non-first line(not-comment) is selected',
          initialFullText: '''
aa
aa
aa
''',
          initialSelection: TextSelection.collapsed(offset: 3),
          expectedFullText: '''
aa
// aa
aa
''',
          expectedSelection: TextSelection(baseOffset: 3, extentOffset: 9),
        ),
        _Example(
          'Document has several lines, non-first line(comment) is selected',
          initialFullText: '''
aa
// aa
aa
''',
          initialSelection: TextSelection.collapsed(offset: 3),
          expectedFullText: '''
aa
aa
aa
''',
          expectedSelection: TextSelection(baseOffset: 3, extentOffset: 6),
        ),
        _Example(
          'Document has several lines, last line(not comment) is selected',
          initialFullText: '''
aa
aa''',
          initialSelection: TextSelection.collapsed(offset: 3),
          expectedFullText: '''
aa
// aa''',
          expectedSelection: TextSelection(baseOffset: 3, extentOffset: 8),
        ),
        _Example(
          'Document has several lines, last line(comment) is selected',
          initialFullText: '''
aa
// aa''',
          initialSelection: TextSelection.collapsed(offset: 3),
          expectedFullText: '''
aa
aa''',
          expectedSelection: TextSelection(baseOffset: 3, extentOffset: 5),
        ),
      ];

      for (final example in examples) {
        final controller = CodeController(language: java);
        controller.text = example.initialFullText;
        controller.selection = example.initialSelection;

        controller.commentOrUncommentSelection();

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

  group('Selection is a range', () {
    test('Selection is a range that occupies several lines', () {
      final examples = [
        _Example(
          'WHEN all selected lines are uncommented '
          'SHOULD comment all selected lines',
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
          'WHEN all selected lines are commented '
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
          'WHEN first selected line is uncommented, the rest are commented '
          'SHOULD comment all lines',
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
          'WHEN non-first selected line is uncommented, the rest are commented '
          'SHOULD comment all lines',
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
          'WHEN last selected line is uncommented, the rest are commented '
          'SHOULD comment all lines',
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

        controller.commentOrUncommentSelection();

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
