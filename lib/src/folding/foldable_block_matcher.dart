import '../code/code_line.dart';
import '../code/string.dart';
import 'foldable_block.dart';

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
  final newFoldableBlocksMap = <int, FoldableBlock>{};

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

    for (final block in newBlocks) {
      newFoldableBlocksMap.addAll({
        block.firstLine: block,
      });
    }

    var firstDiffLineIndex = 0;
    int oldLinesIndex = 0;
    int newLinesIndex = 0;

    while (oldLinesIndex < oldLines.length && newLinesIndex < newLines.length) {
      if (oldLines[oldLinesIndex].text != newLines[newLinesIndex].text) {
        break;
      }
      firstDiffLineIndex++;
      oldLinesIndex++;
      newLinesIndex++;
    }

    // This is basically the line-length of a inserted/removed text.
    final lineCountDelta = newLines.length - oldLines.length;

    for (final foldedBlock in oldFoldedBlocks) {
      if (foldedBlock.firstLine < firstDiffLineIndex) {
        // If the folded block is located before changed part,
        // the lines must match perfectly.
        _addIfMatch(foldedBlock, 0);
      } else {
        // If the folded block is located after changed part,
        // the lines must differ exactly to the lineCountDelta.
        // Covers:
        // 1. Paste text with undefined amount of newlines.
        // 2. Remove/Cut text with undefined amount of newlines.
        // 3. Add new line symbol.
        _addIfMatch(foldedBlock, lineCountDelta);
      }
    }
  }

  /// Adds the folded block to newFoldedBlocks
  /// if its hidden part is not changed.
  ///
  /// A valid match is when the inner content of a folded block is unchanged.
  /// Lines must differ to exactly [lineCountDelta] lines.
  void _addIfMatch(FoldableBlock oldFoldedBlock, int lineCountDelta) {
    int newLinesIndex = oldFoldedBlock.firstLine + lineCountDelta;
    int oldLinesIndex = oldFoldedBlock.firstLine;

    if (oldLinesIndex < 0 || newLinesIndex < 0) {
      return;
    }

    // If the first line is removed completely, destroy the block.
    if (newLines[newLinesIndex].text.hasOnlyWhitespaces()) {
      return;
    }

    // Allow blocks content to differ at the first line
    newLinesIndex++;
    oldLinesIndex++;

    while (oldLinesIndex <= oldFoldedBlock.lastLine &&
        newLinesIndex < newLines.length) {
      if (newLines[newLinesIndex].text != oldLines[oldLinesIndex].text) {
        return;
      }
      newLinesIndex++;
      oldLinesIndex++;
    }

    final newBlockFirstLine = oldFoldedBlock.firstLine + lineCountDelta;
    final newBlockOnSameLine = newFoldableBlocksMap[newBlockFirstLine];
    if (newBlockOnSameLine?.lineCount != null &&
        newBlockOnSameLine?.lineCount != oldFoldedBlock.lineCount) {
      // If the new code has foldable block on the same line,
      // that differs in lineCount with old folded block.
      // E.g. add new import after folded imports block.
      return;
    }

    newFoldedBlocks.add(oldFoldedBlock.offset(lineCountDelta));
  }
}
