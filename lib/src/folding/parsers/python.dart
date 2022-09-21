import 'dart:math';

import 'package:highlight/highlight.dart';

import '../../../flutter_code_editor.dart';
import 'abstract.dart';
import 'indent.dart';

///A parser for foldable blocks for python
class PythonFoldableBlockParser extends AbstractFoldableBlockParser {
  @override
  List<FoldableBlock> parse(
    Result highlighted,
    Set<Object?> serviceCommentsSources,
    List<CodeLine> lines,
  ) {
    final highlightBlocks = getBlocksFromParser(
      HighlightFoldableBlockParser(),
      highlighted,
      serviceCommentsSources,
      lines,
    );
    final indentBlocks = getBlocksFromParser(
      IndentFoldableBlockParser(),
      highlighted,
      serviceCommentsSources,
      lines,
    );

    if (indentBlocks.isEmpty) {
      return highlightBlocks;
    }

    final lastLine = _getLastLine(highlightBlocks, indentBlocks);

    final isLinesContainsHighlightBlock =
        _findLinesContainingHighlightBlocks(lastLine + 1, highlightBlocks);

    int highlightBlockIndex = 0;
    int spacesBlockIndex = 0;

    final result = List<FoldableBlock>.empty(growable: true);

    for (int i = 0; i < lastLine; i++) {
      final highlightStartLine = highlightBlockIndex < highlightBlocks.length
          ? highlightBlocks[highlightBlockIndex].startLine
          : -1;
      final spacesStartLine = spacesBlockIndex < indentBlocks.length
          ? indentBlocks[spacesBlockIndex].startLine
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
        result.add(indentBlocks[spacesBlockIndex]);
        spacesBlockIndex++;
      }
    }

    return result;
  }

  List<FoldableBlock> getBlocksFromParser(
    AbstractFoldableBlockParser parser,
    Result highlighted,
    Set<Object?> serviceCommentsSources,
    List<CodeLine> lines,
  ) {
    parser.parse(
      highlighted,
      serviceCommentsSources,
      lines,
    );
    invalidBlocks.addAll(parser.invalidBlocks);
    return parser.blocks;
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
