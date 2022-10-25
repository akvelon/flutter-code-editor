import 'dart:math';

import '../code/code_line.dart';
import 'foldable_block.dart';

/// Matches foldable blocks before and after an edit to preserve their
/// folding state.
///
/// Blocks match if they go in the same order and have the same content.
class FoldableBlockMatcher {
  final List<CodeLine> oldLines;
  final List<FoldableBlock> newBlocks;
  final List<CodeLine> newLines;
  final oldToNew = <FoldableBlock, FoldableBlock>{};
  final newFoldedBlocks = <FoldableBlock>{};

  FoldableBlockMatcher({
    required List<FoldableBlock> oldBlocks,
    required this.oldLines,
    required this.newBlocks,
    required this.newLines,
    required Set<FoldableBlock> oldFoldedBlocks,
  }) {
    if (oldBlocks.isEmpty || newBlocks.isEmpty) {
      return;
    }

    // Walk top to bottom until the first mismatch, if any.
    final minLength = min(oldBlocks.length, newBlocks.length);
    int top = 0;

    for (; top < minLength; top++) {
      final oldBlock = oldBlocks[top];
      final newBlock = newBlocks[top];

      if (_match(oldBlock: oldBlock, newBlock: newBlock)) {
        oldToNew[oldBlock] = newBlock;
      } else {
        break;
      }
    }

    // top is now the first mismatch.

    int oldBottom = oldBlocks.length - 1;
    int newBottom = newBlocks.length - 1;

    for (; oldBottom >= top && newBottom >= top; oldBottom--, newBottom--) {
      final oldBlock = oldBlocks[oldBottom];
      final newBlock = newBlocks[newBottom];

      if (_match(oldBlock: oldBlock, newBlock: newBlock)) {
        oldToNew[oldBlock] = newBlock;
      } else {
        break;
      }
    }

    for (final block in oldFoldedBlocks) {
      final newBlock = oldToNew[block];
      if (newBlock != null) {
        newFoldedBlocks.add(newBlock);
      }
    }
  }

  bool _match({
    required FoldableBlock oldBlock,
    required FoldableBlock newBlock,
  }) {
    if (oldBlock.lineCount != newBlock.lineCount) {
      return false;
    }

    // Allow the blocks to differ in the first line.
    // This keeps a block folded when editing its first line.
    int oldLineIndex = oldBlock.firstLine + 1;
    int newLineIndex = newBlock.firstLine + 1;

    while (oldLineIndex <= oldBlock.lastLine) {
      if (oldLines[oldLineIndex].text != newLines[newLineIndex].text) {
        return false;
      }

      oldLineIndex++;
      newLineIndex++;
    }

    return true;
  }
}
