import 'dart:math';

import '../foldable_block.dart';

///A parser for foldable blocks for python
class PythonParser {
  List<FoldableBlock> parse(
    List<FoldableBlock> highlightBlocks,
    List<FoldableBlock> spacesBlocks,
  ) {
    if (spacesBlocks.isEmpty) {
      return highlightBlocks;
    }

    final lastLine = _getLastLine(highlightBlocks, spacesBlocks);

    final isLinesContainsHighlightBlock =
        _findLinesContainingHighlightBlocks(lastLine + 1, highlightBlocks);

    int highlightBlockIndex = 0;
    int spacesBlockIndex = 0;

    final result = List<FoldableBlock>.empty(growable: true);

    for (int i = 0; i < lastLine; i++) {
      final highlightStartLine = highlightBlockIndex < highlightBlocks.length
          ? highlightBlocks[highlightBlockIndex].startLine
          : -1;
      final spacesStartLine = spacesBlockIndex < spacesBlocks.length
          ? spacesBlocks[spacesBlockIndex].startLine
          : -1;

      if (i == highlightStartLine && i == spacesStartLine) {
        result.add(highlightBlocks[highlightBlockIndex]);
        highlightBlockIndex++;
        spacesBlockIndex++;
        continue;
      }

      if (i == highlightStartLine) {
        result.add(highlightBlocks[highlightBlockIndex]);
        highlightBlockIndex++;
      }

      if (i == spacesStartLine && !isLinesContainsHighlightBlock[i]) {
        result.add(spacesBlocks[spacesBlockIndex]);
        spacesBlockIndex++;
      }
    }

    return result;
  }

  int _getLastLine(
    List<FoldableBlock> highlightBlocks,
    List<FoldableBlock> spacesBlocks,
  ) {
    if (highlightBlocks.isEmpty) {
      return spacesBlocks.last.endLine;
    }
    if (spacesBlocks.isEmpty) {
      return highlightBlocks.last.endLine;
    }
    return max(spacesBlocks.last.endLine, highlightBlocks.last.endLine);
  }

  List<bool> _findLinesContainingHighlightBlocks(
    int linesCount,
    List<FoldableBlock> highlightBlocks,
  ) {
    final result = List<bool>.generate(
      linesCount,
      (_) => false,
      growable: false,
    );

    for (int i = 0; i < highlightBlocks.length; i++) {
      final currentBlock = highlightBlocks[i];
      for (int j = currentBlock.startLine; j < currentBlock.endLine; j++) {
        result[j] = true;
      }
    }

    return result;
  }
}
