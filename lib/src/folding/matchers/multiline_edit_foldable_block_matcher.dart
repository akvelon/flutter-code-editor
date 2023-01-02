import 'dart:math';

import '../../../flutter_code_editor.dart';
import 'abstract_foldable_block_matcher.dart';

/// Matches foldable blocks before and after an edit to preserve their
/// folding state.
///
/// Blocks match
/// if they go in the same order and have the same start and end lines.
class MultilineIndentOutdentFoldableBlockMatcher
    implements AbstractFoldableBlockMatcher {
  final Code oldCode;
  final Code newCode;
  final Set<FoldableBlock> _newFoldedBlocks;

  @override
  Set<FoldableBlock> get newFoldedBlocks => _newFoldedBlocks;

  MultilineIndentOutdentFoldableBlockMatcher({
    required this.oldCode,
    required this.newCode,
  }) : _newFoldedBlocks = <FoldableBlock>{} {
    final oldFoldedBlocks = oldCode.foldedBlocks;
    final oldBlocks = oldCode.foldableBlocks;
    final newBlocks = newCode.foldableBlocks;

    final oldToNew = <FoldableBlock, FoldableBlock>{};

    if (oldBlocks.isEmpty || newBlocks.isEmpty) {
      return;
    }

    final minLength = min(oldBlocks.length, newBlocks.length);
    int top = 0;

    for (; top < minLength; top++) {
      final oldBlock = oldBlocks[top];
      final newBlock = newBlocks[top];

      if (_match(oldBlock: oldBlock, newBlock: newBlock)) {
        oldToNew[oldBlock] = newBlock;
      } else {
        continue;
      }
    }

    for (final block in oldFoldedBlocks) {
      final newBlock = oldToNew[block];
      if (newBlock != null) {
        _newFoldedBlocks.add(newBlock);
      }
    }
  }

  static bool _match({
    required FoldableBlock oldBlock,
    required FoldableBlock newBlock,
  }) {
    return oldBlock.firstLine == newBlock.firstLine &&
        oldBlock.lastLine == newBlock.lastLine;
  }
}
