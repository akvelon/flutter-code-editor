// ignore_for_file: avoid_redundant_argument_values, prefer_final_locals, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

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
            extentOffset: 0,
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
            extentOffset: 7,
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
            baseOffset: 4 - indentLength,
            extentOffset: 4 - indentLength,
          ),
        ),
        const _Example(
          name: 'WHEN at the beginning whiteSpace '
              'that is not a full indent '
              'SHOULD remove all beginning whitespaces of the line '
              'and sustain selection at the beginning of that line',
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
            extentOffset: 7,
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
            baseOffset: 6 - indentLength,
            extentOffset: 6 - indentLength,
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
            extentOffset: 24,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 24 - indentLength * 3,
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
            extentOffset: 22 - indentLength * 2,
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

  group('Folded', () {
    final language = java;
    CodeController controller = CodeController(
      params: const EditorParams(tabSpaces: 2),
      language: language,
    );
    final indentLength = controller.params.tabSpaces;
    final indent = ' ' * indentLength;

    test('description', () {
      final examples = [
        _Example(
          name: 'Outdentation through a folded block affects and unfolds it',
          initialFullText: '''
class MyClass {
${indent}void getSmth(){

$indent}

${indent}void setSmth(){

$indent}
}
''',
          initialVisibleText: '''
class MyClass {
${indent}void getSmth(){

${indent}void setSmth(){

$indent}
}
''',
          expectedFullText: '''
class MyClass {
void getSmth(){

}

void setSmth(){

$indent}
}
''',
          expectedVisibleText: '''
class MyClass {
void getSmth(){

}

void setSmth(){

$indent}
}
''',
          foldableBlockIndex: 1,
          initialSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 44,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 44 - indentLength * 3 + 5, // 5 -> hidden
          ),
        ),
        _Example(
          name:
              'Indentation before folded blocks does not affect neither open them',
          initialFullText: '''
class MyClass {
${indent}void getSmth(){

$indent}

  void setSmth(){

  }
}
''',
          initialVisibleText: '''
class MyClass {
${indent}void getSmth(){

$indent}

  void setSmth(){
}
''',
          expectedFullText: '''
class MyClass {
void getSmth(){

}

  void setSmth(){

  }
}
''',
          expectedVisibleText: '''
class MyClass {
void getSmth(){

}

  void setSmth(){
}
''',
          foldableBlockIndex: 2,
          initialSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 38,
          ),
          expectedSelection: TextSelection(
            baseOffset: 0,
            extentOffset: 38 - indentLength * 2,
          ),
        ),
      ];

      for (final example in examples) {
        controller.text = example.initialFullText;
        controller.foldAt(
          controller.code.foldableBlocks[example.foldableBlockIndex!].firstLine,
        );
        controller.selection = example.initialSelection;

        expect(
          controller.value.text,
          example.initialVisibleText,
          reason: 'assertion of an arranged data',
        );

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
  final int? foldableBlockIndex;
  final TextSelection initialSelection;
  final TextSelection expectedSelection;

  const _Example({
    required this.name,
    required this.initialFullText,
    this.initialVisibleText,
    required this.expectedFullText,
    required this.expectedVisibleText,
    this.foldableBlockIndex,
    required this.initialSelection,
    required this.expectedSelection,
  });
}
