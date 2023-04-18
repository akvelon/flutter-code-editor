import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  testWidgets(
      'Backspace or delete at a folded block collapse point '
      '=> Do nothing.', (wt) async {
    final examples = [
      //
      const _Example(
        'Backspace after newline after folded block',
        initialFullText: 'int main(){\n}\n',
        //                                \
        initialSelection: TextSelection.collapsed(offset: 12),
        foldedBlocks: [0],
        finalVisibleText: 'int main(){\n',
        key: LogicalKeyboardKey.backspace,
      ),

      const _Example(
        'Delete at the collapsed position of a folded block',
        initialFullText: 'int main(){\n}\n',
        //                           \
        initialSelection: TextSelection.collapsed(offset: 11),
        foldedBlocks: [0],
        finalVisibleText: 'int main(){\n',
        key: LogicalKeyboardKey.delete,
      ),
    ];

    for (final example in examples) {
      final controller = await pumpController(wt, example.initialFullText);
      // ignore: prefer_foreach
      for (final foldingLineIndex in example.foldedBlocks) {
        controller.foldAt(foldingLineIndex);
      }

      controller.selection = example.initialSelection;
      await wt.sendKeyEvent(example.key);

      expect(controller.value.text, example.finalVisibleText);
    }
  });
}

class _Example {
  final String name;
  final String initialFullText;
  final TextSelection initialSelection;
  final List<int> foldedBlocks;
  final String finalVisibleText;
  final LogicalKeyboardKey key;

  const _Example(
    this.name, {
    required this.initialFullText,
    required this.foldedBlocks,
    required this.finalVisibleText,
    required this.key,
    required this.initialSelection,
  });
}
