// ignore_for_file: avoid_redundant_argument_values, prefer_final_locals, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unfolded', () {
    CodeController controller = CodeController(
      params: const EditorParams(tabSpaces: 2),
    );
    final indentLength = controller.params.tabSpaces;
    final indent = ' ' * indentLength;

    test('Selection is collapsed', () {
      final examples = [
        const _Example(
          name: 'WHEN start == -1 && end == -1 SHOULD NOT modify anything',
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
          name: 'WHEN at the start of the first line '
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
          name: 'WHEN at the start of a non-first line '
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
          name: 'WHEN at the middle of a line SHOULD modify that line',
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
          name: 'WHEN at the beginning whiteSpace '
              'that is not a full indent '
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
          name: 'WHEN at the end of a line '
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
      }
    });

    test('Selection is a range', () {
      final examples = [
        _Example(
          name: 'WHEN the entire document is selectd '
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
          name: 'WHEN lines that doesn\'t have indent are selected '
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
      ];

      for (final example in examples) {
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
  final List<int>? blockIndexesToFold;
  final TextSelection initialSelection;
  final TextSelection expectedSelection;

  const _Example({
    required this.name,
    required this.initialFullText,
    this.initialVisibleText,
    required this.expectedFullText,
    required this.expectedVisibleText,
    this.blockIndexesToFold,
    required this.initialSelection,
    required this.expectedSelection,
  });
}
