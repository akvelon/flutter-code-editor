import 'package:highlight/highlight_core.dart';

import '../../code/code_lines.dart';
import '../foldable_block.dart';
import 'abstract.dart';
import 'highlight.dart';
import 'indent.dart';

///A parser for foldable blocks for python
class PythonFoldableBlockParser extends AbstractFoldableBlockParser {
  @override
  void parse({
    required Result highlighted,
    required Set<Object?> serviceCommentsSources,
    required CodeLines lines,
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

    if (indentBlocks.isEmpty && highlightBlocks.isEmpty) {
      return;
    }

    final combinedBlocks = _combineBlocks(
      highlightBlocks: highlightBlocks,
      indentBlocks: indentBlocks,
    );
    blocks.addAll(combinedBlocks);
    finalize();
  }

  List<FoldableBlock> _getBlocksFromParser(
    AbstractFoldableBlockParser parser,
    Result highlighted,
    Set<Object?> serviceCommentsSources,
    CodeLines lines,
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
  ///     4,    # 4
  ///  ]        # 5
  /// Highlight block will return [0, 5].
  /// Indent block will return [0, 4] block.
  /// We need to skip [0, 4] block because it is inside [0, 5] block.
  List<FoldableBlock> _combineBlocks({
    required List<FoldableBlock> highlightBlocks,
    required List<FoldableBlock> indentBlocks,
  }) {
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

      final indentBlocksToAdd = _getAllBlocksBeforeLine(
        startIndex: indentBlockIndex,
        blocks: indentBlocks,
        maxFirstLine: highlightBlock.firstLine,
      );
      result.addAll(indentBlocksToAdd);
      indentBlockIndex += indentBlocksToAdd.length;

      while (indentBlockIndex < indentBlocks.length &&
          highlightBlock.includes(indentBlocks[indentBlockIndex])) {
        indentBlockIndex++;
      }

      result.add(highlightBlock);
      highlightBlockIndex++;
    }

    return result;
  }

  /// Returns [blocks] from [startIndex]
  /// while their first lines less than [maxFirstLine].
  List<FoldableBlock> _getAllBlocksBeforeLine({
    required int startIndex,
    required List<FoldableBlock> blocks,
    required int maxFirstLine,
  }) {
    final blocksBount = _getBlocksCountBeforeLineFrom(
      startIndex: startIndex,
      line: maxFirstLine,
      blocks: blocks,
    );
    return blocks.sublist(
      startIndex,
      startIndex + blocksBount,
    );
  }

  int _getBlocksCountBeforeLineFrom({
    required int startIndex,
    required int line,
    required List<FoldableBlock> blocks,
  }) {
    int result = 0;
    for (int i = startIndex; i < blocks.length; i++) {
      final block = blocks[i];
      if (block.firstLine < line) {
        result++;
      } else {
        break;
      }
    }
    return result;
  }
}
