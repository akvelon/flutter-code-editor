import 'dart:math';

import 'package:highlight/highlight_core.dart';

import '../../code/code_line.dart';
import '../foldable_block.dart';
import 'abstract.dart';
import 'highlight.dart';
import 'indent.dart';

///A parser for foldable blocks for python
class PythonFoldableBlockParser extends AbstractFoldableBlockParser {
  @override
  List<FoldableBlock> parse({
    required Result highlighted,
    required Set<Object?> serviceCommentsSources,
    required List<CodeLine> lines,
  }) {
    final highlightBlocks = _getBlocksFromParser(
      HighlightFoldableBlockParser(),
      highlighted,
      serviceCommentsSources,
      lines,
    );
    final indentBlocks = _getBlocksFromParser(
      IndentFoldableBlockParser(),
      highlighted,
      serviceCommentsSources,
      lines,
    );

    return _combineBlocks(highlightBlocks, indentBlocks);
  }

  List<FoldableBlock> _getBlocksFromParser(
    AbstractFoldableBlockParser parser,
    Result highlighted,
    Set<Object?> serviceCommentsSources,
    List<CodeLine> lines,
  ) {
    parser.parse(
      highlighted: highlighted,
      serviceCommentsSources: serviceCommentsSources,
      lines: lines,
    );
    invalidBlocks.addAll(parser.invalidBlocks);
    return parser.blocks;
  }

  /// Compares two lists of blocks and combines them into one list
  /// with priority to highlight blocks if blocks intersect.
  ///
  /// Lets consider this python code for example:
  /// a = [     # 0
  ///     1,    # 1
  ///     2,    # 2
  ///     3,    # 3
  ///     4,]   # 4
  /// Highlight block will return [0, 4].
  /// Indent block will return [1, 3] block.
  /// We need to skip [1, 3] block because it is inside [0, 4] block.
  List<FoldableBlock> _combineBlocks(
    List<FoldableBlock> highlightBlocks,
    List<FoldableBlock> indentBlocks,
  ) {
    if (indentBlocks.isEmpty) {
      return highlightBlocks;
    }

    final lastLine = _getLastLine(highlightBlocks, indentBlocks);

    final areLinesContainsHighlightBlock =
        _findLinesContainingHighlightBlocks(lastLine + 1, highlightBlocks);

    int highlightBlockIndex = 0;
    int indentBlockIndex = 0;

    final result = <FoldableBlock>[];

    for (int i = 0; i < lastLine; i++) {
      final highlightStartLine = highlightBlockIndex < highlightBlocks.length
          ? highlightBlocks[highlightBlockIndex].startLine
          : null;
      final indentsStartLine = indentBlockIndex < indentBlocks.length
          ? indentBlocks[indentBlockIndex].startLine
          : null;

      if (i == highlightStartLine && i == indentsStartLine) {
        result.add(highlightBlocks[highlightBlockIndex]);
        highlightBlockIndex++;
        indentBlockIndex++;
        continue;
      }

      if (i == highlightStartLine) {
        result.add(highlightBlocks[highlightBlockIndex]);
        highlightBlockIndex++;
      }

      if (i == indentsStartLine && !areLinesContainsHighlightBlock[i]) {
        result.add(indentBlocks[indentBlockIndex]);
        indentBlockIndex++;
      }
    }

    return result;
  }

  int _getLastLine(
    List<FoldableBlock> highlightBlocks,
    List<FoldableBlock> indentsBlocks,
  ) {
    if (highlightBlocks.isEmpty) {
      return _getMaxFoldableBlockEndLine(indentsBlocks);
    }
    if (indentsBlocks.isEmpty) {
      return _getMaxFoldableBlockEndLine(highlightBlocks);
    }

    return max(
      _getMaxFoldableBlockEndLine(highlightBlocks),
      _getMaxFoldableBlockEndLine(indentsBlocks),
    );
  }

  int _getMaxFoldableBlockEndLine(List<FoldableBlock> blocks) {
    var maxLine = 0;
    for (final block in blocks) {
      maxLine = max(maxLine, block.endLine);
    }
    return maxLine;
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
      for (int j = currentBlock.startLine; j <= currentBlock.endLine; j++) {
        result[j] = true;
      }
    }

    return result;
  }
}
