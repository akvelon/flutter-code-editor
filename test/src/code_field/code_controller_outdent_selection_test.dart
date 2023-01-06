// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_final_locals

import 'package:flutter/cupertino.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

void main() {
  group('Unfolded', () {
    const indentLength = 2;
    final indent = ' ' * indentLength;

    test('Selection is collapsed', () {
      final examples = [
        const _Example(
          'WHEN start == -1 && end == -1 SHOULD NOT modify anything',
          initialFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
  aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: -1,
            extentOffset: -1,
          ),
          expectedSelection: TextSelection(
            baseOffset: -1,
            extentOffset: -1,
          ),
        ),
        const _Example(
          'WHEN at the start of the first line '
          'SHOULD modify first line',
          initialFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedFullText: '''
aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 0,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 5,
          ),
        ),
        const _Example(
          'WHEN at the start of a non-first line '
          'SHOULD modify that line',
          initialFullText: '''
  aaaa
    aaaa
aaaa
''',
          expectedFullText: '''
  aaaa
  aaaa
aaaa
''',
          expectedVisibleText: '''
  aaaa
  aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 7,
            extentOffset: 7,
          ),
          expectedSelection: TextSelection(
            baseOffset: 7,
            extentOffset: 14,
          ),
        ),
        _Example(
          'WHEN at the middle of a line SHOULD modify that line',
          initialFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedFullText: '''
aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 4,
            extentOffset: 4,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 5,
          ),
        ),
        const _Example(
          'WHEN indented less than a full indent '
          'SHOULD remove all beginning whitespaces of the line ',
          initialFullText: '''
  aaaa
 aaaa
aaaa
''',
          expectedFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
  aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 8,
            extentOffset: 8,
          ),
          expectedSelection: TextSelection(
            baseOffset: 7,
            extentOffset: 12,
          ),
        ),
        _Example(
          'WHEN at the end of a line '
          'SHOULD modify that line',
          initialFullText: '''
  aaaa
aaaa
aaaa
''',
          expectedFullText: '''
aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
aaaa
aaaa
aaaa
''',
          initialSelection: TextSelection(
            baseOffset: 6,
            extentOffset: 6,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 5,
          ),
        ),
      ];

      for (final example in examples) {
        final controller = CodeController();
        controller.text = example.initialFullText;
        controller.selection = example.initialSelection;
        controller.outdentSelection();

        expect(
          controller.value.text,
          example.expectedVisibleText,
          reason: example.name,
        );
        expect(
          controller.code.text,
          example.expectedFullText,
          reason: example.name,
        );
        expect(
          controller.code.visibleText,
          controller.text,
          reason: example.name,
        );
        expect(
          controller.value.selection,
          example.expectedSelection,
          reason: example.name,
        );
        expect(
          controller.code,
          controller.historyController.lastCode,
        );
        expect(
          controller.value.selection,
          controller.historyController.lastSelection,
        );
      }
    });

    test('Selection is a range', () {
      final examples = [
        _Example(
          'WHEN the entire document is selectd '
          'SHOULD outdent all lines',
          initialFullText: '''
  AAAA
      AAAA
  AAAA''',
          expectedFullText: '''
AAAA
    AAAA
AAAA''',
          expectedVisibleText: '''
AAAA
    AAAA
AAAA''',
          initialSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 24,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 18,
          ),
        ),
        _Example(
          'WHEN unindented lines are selected '
          'SHOULD NOT outdent that lines',
          initialFullText: '''
AAAA
      AAAA
  AAAA
''',
          expectedFullText: '''
AAAA
    AAAA
AAAA
''',
          expectedVisibleText: '''
AAAA
    AAAA
AAAA
''',
          initialSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 22,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 19,
          ),
        ),
        _Example(
          'Outdent SHOULD NOT unfold folded comment at line 0 '
          'and folded imports',
          initialFullText: '''
// comment1
// comment 2
package org.apache.beam.examples;

import java.util.Arrays;

  a;
''',
          expectedFullText: '''
// comment1
// comment 2
package org.apache.beam.examples;

import java.util.Arrays;

a;
''',
          expectedVisibleText: '''
// comment1
package org.apache.beam.examples;

a;
''',
          initialSelection: TextSelection(baseOffset: 47, extentOffset: 52),
          expectedSelection: TextSelection(baseOffset: 47, extentOffset: 50),
        ),
      ];

      for (final example in examples) {
        final controller = CodeController(
          language: java,
        );
        controller.text = example.initialFullText;
        controller.foldCommentAtLineZero();
        controller.foldImports();
        controller.selection = example.initialSelection;
        controller.outdentSelection();

        expect(
          controller.value.text,
          example.expectedVisibleText,
          reason: example.name,
        );
        expect(
          controller.code.text,
          example.expectedFullText,
          reason: example.name,
        );
        expect(
          controller.code.visibleText,
          controller.text,
          reason: example.name,
        );
        expect(
          controller.value.selection,
          example.expectedSelection,
          reason: example.name,
        );
        expect(
          controller.code,
          controller.historyController.lastCode,
        );
        expect(
          controller.value.selection,
          controller.historyController.lastSelection,
        );
      }
    });
  });
}

class _Example {
  final String name;
  final String initialFullText;
  final String expectedFullText;
  final String expectedVisibleText;
  final TextSelection initialSelection;
  final TextSelection expectedSelection;

  const _Example(
    this.name, {
    required this.initialFullText,
    required this.expectedFullText,
    required this.expectedVisibleText,
    required this.initialSelection,
    required this.expectedSelection,
  });
}
