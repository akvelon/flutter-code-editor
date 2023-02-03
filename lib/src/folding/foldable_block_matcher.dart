import 'dart:math';

import '../../flutter_code_editor.dart';
import '../code/code_line.dart';
import 'foldable_block.dart';

/// Matches folded blocks from the old code to the new code.
///
/// Basically adds the folded block to the new code
/// if the content of it is not changed.
class FoldableBlockMatcher {
  final List<CodeLine> oldLines;
  final List<FoldableBlock> newBlocks;
  final List<CodeLine> newLines;
  final oldToNew = <FoldableBlock, FoldableBlock>{};
  final newFoldedBlocks = <FoldableBlock>{};

  FoldableBlockMatcher({
    required this.oldLines,
    required this.newBlocks,
    required this.newLines,
    required Set<FoldableBlock> oldFoldedBlocks,
  }) {
    // If no foldable blocks were folded, there is nothing to match.
    // Because we generate foldable blocks anyway.
    if (oldFoldedBlocks.isEmpty) {
      return;
    }

    // This is basically the line-length of a inserted/removed text.
    final diff = newLines.length - oldLines.length;

    for (final foldedBlock in oldFoldedBlocks) {
      // If the folded block is located before changed part.
      final added = _addIfMatch(foldedBlock, 0);
      if (!added) {
        // If the folded block is located after changed part.
        // 1. Paste text with undefined amount of newlines.
        // 2. Remove/Cut text with undefined amount of newlines.
        _addIfMatch(foldedBlock, diff);
      }
    }
  }

  /// Adds the folded block to newFoldedBlocks if it is a valid match.
  ///
  /// A valid match is when the inner content of a folded block is unchanged.
  /// Lines must differ to exactly [lineDiff] lines.
  bool _addIfMatch(FoldableBlock oldFoldedBlock, int lineDiff) {
    int newLinesIndex = oldFoldedBlock.firstLine + lineDiff;
    int oldLinesIndex = oldFoldedBlock.firstLine;

    // Allow first lines to differ if there is no lineDiff.
    if (lineDiff == 0) {
      newLinesIndex++;
      oldLinesIndex++;
    }

    if (newLinesIndex < 0 || oldLinesIndex < 0) {
      return false;
    }

    while (oldLinesIndex <= oldFoldedBlock.lastLine &&
        validateLinesIndex(oldLinesIndex, newLinesIndex)) {
      if (newLines[newLinesIndex].text != oldLines[oldLinesIndex].text) {
        return false;
      }
      newLinesIndex++;
      oldLinesIndex++;
    }

    if (oldFoldedBlock.type == FoldableBlockType.indent &&
        validateLinesIndex(oldLinesIndex, newLinesIndex) &&
        lineDiff == 0) {
      if (newLines[newLinesIndex].text != oldLines[oldLinesIndex].text) {
        return false;
      }
    }

    newFoldedBlocks.add(oldFoldedBlock.offset(lineDiff));
    return true;
  }

  bool validateLinesIndex(int oldLinesIndex, int newLinesIndex) {
    return newLinesIndex < newLines.length && oldLinesIndex < oldLines.length;
  }
}
