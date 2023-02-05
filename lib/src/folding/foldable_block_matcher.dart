import '../code/code_line.dart';
import '../code/string.dart';
import 'foldable_block.dart';
import 'foldable_block_type.dart';

/// Matches folded blocks from the old code to the new code.
///
/// Basically adds the folded block to the new code
/// if the content of its hidden part is not changed.
/// IMPORTANT: even if it is no longer a valid block after a change.
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

    var firstDiffLineIndex = 0;
    int oldLinesIndex = 0;
    int newLinesIndex = 0;

    while (lineIndexesAreValid(oldLinesIndex, newLinesIndex)) {
      if (oldLines[oldLinesIndex].text != newLines[newLinesIndex].text) {
        break;
      }
      firstDiffLineIndex++;
      oldLinesIndex++;
      newLinesIndex++;
    }

    // This is basically the line-length of a inserted/removed text.
    final lineDiff = newLines.length - oldLines.length;

    for (final foldedBlock in oldFoldedBlocks) {
      if (foldedBlock.firstLine < firstDiffLineIndex) {
        // If the folded block is located before changed part,
        // the lines must match perfectly.
        _addIfMatch(foldedBlock, 0);
      } else {
        // If the folded block is located after changed part,
        // the lines must differ exactly to the lineDiff.
        // Covers:
        // 1. Paste text with undefined amount of newlines.
        // 2. Remove/Cut text with undefined amount of newlines.
        // 3. Add new line symbol.
        _addIfMatch(foldedBlock, lineDiff);
      }
    }
  }

  /// Adds the folded block to newFoldedBlocks
  /// if its hidden part is not changed.
  ///
  /// A valid match is when the inner content of a folded block is unchanged.
  /// Lines must differ to exactly [lineDiff] lines.
  void _addIfMatch(FoldableBlock oldFoldedBlock, int lineDiff) {
    int newLinesIndex = oldFoldedBlock.firstLine + lineDiff;
    int oldLinesIndex = oldFoldedBlock.firstLine;

    if (oldLinesIndex < 0 || newLinesIndex < 0) {
      return;
    }

    // if the first line is removed completely
    if (newLines[newLinesIndex].text.hasOnlyWhitespaces()) {
      return;
    }

    // Allow blocks content to differ at the first line
    newLinesIndex++;
    oldLinesIndex++;

    while (oldLinesIndex <= oldFoldedBlock.lastLine &&
        lineIndexesAreValid(oldLinesIndex, newLinesIndex)) {
      if (newLines[newLinesIndex].text != oldLines[oldLinesIndex].text) {
        return;
      }
      newLinesIndex++;
      oldLinesIndex++;
    }

    if (newBlocks.any(
      (newBlock) =>
          newBlock.firstLine == oldFoldedBlock.firstLine + lineDiff &&
          newBlock.lineCount != oldFoldedBlock.lineCount,
    )) {
      return;
    }

    newFoldedBlocks.add(oldFoldedBlock.offset(lineDiff));
  }

  bool lineIndexesAreValid(int oldLinesIndex, int newLinesIndex) {
    return newLinesIndex < newLines.length && oldLinesIndex < oldLines.length;
  }
}
