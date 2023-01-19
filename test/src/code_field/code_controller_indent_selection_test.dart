// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

void main() {
  group('CodeController.indentSelection() => Unfolded text', () {
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
        _Example(
          'WHEN start == 0 && end == 0 '
          'SHOULD add indentation to the cursor location',
          initialFullText: '''
aaaa
aaaa
aaaa
''',
          expectedFullText: '''
${indent}aaaa
aaaa
aaaa
''',
          expectedVisibleText: '''
${indent}aaaa
aaaa
aaaa
''',
          initialSelection: const TextSelection(
            baseOffset: 0,
            extentOffset: 0,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0 + indentLength,
            extentOffset: 0 + indentLength,
          ),
        ),
        _Example(
          'WHEN collapsed at start of a non-first line '
          'SHOULD add indentation to the cursor location',
          initialFullText: '''
aaaa
aaaa
aaaa
''',
          expectedFullText: '''
aaaa
${indent}aaaa
aaaa
''',
          expectedVisibleText: '''
aaaa
${indent}aaaa
aaaa
''',
          initialSelection: const TextSelection(
            baseOffset: 5,
            extentOffset: 5,
          ),
          expectedSelection: TextSelection(
            baseOffset: 5 + indentLength,
            extentOffset: 5 + indentLength,
          ),
        ),
        const _Example(
          'WHEN at a column that is not a multiple of indent_length '
          'SHOULD add spaces to adjust indentation to its multiple',
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
            baseOffset: 8 + 1,
            extentOffset: 8 + 1,
          ),
        ),
        _Example(
          'WHEN at a column that is a multiple of indent_length '
          'SHOULD add full indentation to the cursor location',
          initialFullText: '''
aaaa
  aaaa
aaaa
''',
          expectedFullText: '''
aaaa
  ${indent}aaaa
aaaa
''',
          expectedVisibleText: '''
aaaa
  ${indent}aaaa
aaaa
''',
          initialSelection: const TextSelection(
            baseOffset: 7,
            extentOffset: 7,
          ),
          expectedSelection: TextSelection(
            baseOffset: 7 + indentLength,
            extentOffset: 7 + indentLength,
          ),
        ),
        _Example(
          'WHEN at the end of a document '
          'SHOULD add indentation to the cursor location',
          initialFullText: '''
aaaa
aaaa
aaaa
''',
          expectedFullText: '''
aaaa
aaaa
aaaa$indent
''',
          expectedVisibleText: '''
aaaa
aaaa
aaaa$indent
''',
          initialSelection: const TextSelection(
            baseOffset: 14,
            extentOffset: 14,
          ),
          expectedSelection: TextSelection(
            baseOffset: 14 + indentLength,
            extentOffset: 14 + indentLength,
          ),
        ),
      ];

      for (final example in examples) {
        final controller = CodeController();
        controller.text = example.initialFullText;
        controller.selection = example.initialSelection;
        controller.indentSelection();

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
          'WHEN non-collapsed selection, two lines, not first, not last. '
          'SHOULD add indentation to the selected lines '
          'and select the whole lines',
          initialFullText: '''
aaaa
aaAA
AAAa
aaaa
''',
          expectedFullText: '''
aaaa
${indent}aaAA
${indent}AAAa
aaaa
''',
          expectedVisibleText: '''
aaaa
${indent}aaAA
${indent}AAAa
aaaa
''',
          initialSelection: const TextSelection(
            baseOffset: 7,
            extentOffset: 13,
          ),
          expectedSelection: TextSelection(
            baseOffset: 5,
            extentOffset: 19,
          ),
        ),
        _Example(
          'WHEN entire document is selected without new line at the end '
          'SHOULD add indentation to all lines',
          initialFullText: '''
AAA
AAA
AAA''',
          expectedFullText: '''
${indent}AAA
${indent}AAA
${indent}AAA''',
          expectedVisibleText: '''
${indent}AAA
${indent}AAA
${indent}AAA''',
          initialSelection: const TextSelection(
            baseOffset: 0,
            extentOffset: 11,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 17,
          ),
        ),
        _Example(
          'WHEN entire document is selected with new line at the end '
          'SHOULD add indentation to all lines',
          initialFullText: '''
AAA
AAA
AAA
''',
          expectedFullText: '''
${indent}AAA
${indent}AAA
${indent}AAA
''',
          expectedVisibleText: '''
${indent}AAA
${indent}AAA
${indent}AAA
''',
          initialSelection: const TextSelection(
            baseOffset: 0,
            extentOffset: 12,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 18,
          ),
        ),
        _Example(
          'Indent SHOULD NOT unfold folded comment at line 0 '
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
          initialSelection: TextSelection(baseOffset: 47, extentOffset: 49),
          expectedSelection: TextSelection(baseOffset: 47, extentOffset: 52),
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

        controller.indentSelection();

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

  group('Readonly blocks', () {
    final language = java;
    const readonlySectionName = 'readonlySection'; // length = 15

    test(
        'If the there is at least 1 readonly line selected, '
        'entire modification should be cancelled', () {
      final examples = [
        _Example(
          'Selection is within readonly section',
          initialFullText: '''
// [START $readonlySectionName]
aAA{
  AAAA();
  AAaa();
}
// [END $readonlySectionName]
''',
          initialVisibleText: '''

aAA{
  AAAA();
  AAaa();
}

''',
          expectedFullText: '''
// [START $readonlySectionName]
aAA{
  AAAA();
  AAaa();
}
// [END $readonlySectionName]
''',
          expectedVisibleText: '''

aAA{
  AAAA();
  AAaa();
}

''',
          initialSelection: TextSelection(baseOffset: 2, extentOffset: 20),
          expectedSelection: TextSelection(baseOffset: 2, extentOffset: 20),
        ),
        _Example(
          'Selection goes through readonly section',
          initialFullText: '''
aAA{

}
// [START $readonlySectionName]
AAA{
  AAAA();
  AAAA();
}
// [END $readonlySectionName]
Aaa{

}
''',
          initialVisibleText: '''
aAA{

}

AAA{
  AAAA();
  AAAA();
}

Aaa{

}
''',
          expectedFullText: '''
aAA{

}
// [START $readonlySectionName]
AAA{
  AAAA();
  AAAA();
}
// [END $readonlySectionName]
Aaa{

}
''',
          expectedVisibleText: '''
aAA{

}

AAA{
  AAAA();
  AAAA();
}

Aaa{

}
''',
          initialSelection: TextSelection(baseOffset: 1, extentOffset: 38),
          expectedSelection: TextSelection(baseOffset: 1, extentOffset: 38),
        ),
      ];

      for (final example in examples) {
        final controller = CodeController(
          language: language,
          namedSectionParser: BracketsStartEndNamedSectionParser(),
          readOnlySectionNames: {readonlySectionName},
        );
        controller.text = example.initialFullText;
        controller.selection = example.initialSelection;

        expect(
          controller.value.text,
          example.initialVisibleText,
        );

        controller.indentSelection();

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
  final String? initialVisibleText;
  final String expectedFullText;
  final String expectedVisibleText;
  final TextSelection initialSelection;
  final TextSelection expectedSelection;

  const _Example(
    this.name, {
    required this.initialFullText,
    this.initialVisibleText,
    required this.expectedFullText,
    required this.expectedVisibleText,
    required this.initialSelection,
    required this.expectedSelection,
  });
}
