import 'dart:math';

import '../../../flutter_code_editor.dart';
import 'abstract_foldable_block_matcher.dart';

/// Matches foldable blocks before and after an edit to preserve their
/// folding state.
///
/// Blocks match if they go in the same order and have the same content.
class DefaultFoldableBlockMatcher implements AbstractFoldableBlockMatcher{
  @override
  final Set<FoldableBlock> newFoldedBlocks;
  final List<CodeLine> _newLines;
  final List<CodeLine> _oldLines;

  DefaultFoldableBlockMatcher({
    required Code oldCode,
    required Code newCode,
  })  : newFoldedBlocks = <FoldableBlock>{},
        _oldLines = oldCode.lines.lines,
        _newLines = newCode.lines.lines {
    final oldFoldedBlocks = oldCode.foldedBlocks;
    final oldBlocks = oldCode.foldableBlocks;
    final newBlocks = newCode.foldableBlocks;

    final oldToNew = <FoldableBlock, FoldableBlock>{};

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
        continue;
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
      if (_oldLines[oldLineIndex].text != _newLines[newLineIndex].text) {
        return false;
      }

      oldLineIndex++;
      newLineIndex++;
    }

    return true;
  }
}
