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

    if (indentBlocks.isEmpty) {
      return highlightBlocks;
    }

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
    int highlightBlockIndex = 0;
    int indentBlockIndex = 0;

    final result = <FoldableBlock>[];

    while (highlightBlockIndex < highlightBlocks.length ||
        indentBlockIndex < indentBlocks.length) {
      if (highlightBlockIndex >= highlightBlocks.length) {
        result.addAll(indentBlocks.skip(indentBlockIndex));
        break;
      }

      final highlightBlock = highlightBlocks[highlightBlockIndex];

      indentBlockIndex = _addAllPossibleIndentBlocks(
        indentBlockIndex,
        indentBlocks,
        highlightBlock.startLine,
        result,
      );

      while (indentBlockIndex < indentBlocks.length &&
          highlightBlock.includes(indentBlocks[indentBlockIndex])) {
        indentBlockIndex++;
      }

      result.add(highlightBlock);
      highlightBlockIndex++;
    }

    return result;
  }

  int _addAllPossibleIndentBlocks(
    int indentBlockIndex,
    List<FoldableBlock> indentBlocks,
    int highlightBlockStartLine,
    List<FoldableBlock> result,
  ) {
    final indentBlocksBeforeHighlight = _getBlocksCountBeforeLineFrom(
      startIndex: indentBlockIndex,
      line: highlightBlockStartLine,
      blocks: indentBlocks,
    );
    final possibleToAddBlocks = indentBlocks.sublist(
      indentBlockIndex,
      indentBlockIndex + indentBlocksBeforeHighlight,
    );
    result.addAll(possibleToAddBlocks);
    return indentBlockIndex + indentBlocksBeforeHighlight;
  }

  int _getBlocksCountBeforeLineFrom({
    required int startIndex,
    required int line,
    required List<FoldableBlock> blocks,
  }) {
    int result = 0;
    for (int i = startIndex; i < blocks.length; i++) {
      final indentBlock = blocks[i];
      if (indentBlock.startLine < line) {
        result++;
      } else {
        break;
      }
    }
    return result;
  }
}
