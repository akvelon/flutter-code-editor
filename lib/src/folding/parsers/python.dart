import 'dart:math';

import 'package:highlight/highlight_core.dart';

import '../../code/code_lines.dart';
import '../foldable_block.dart';
import '../foldable_block_type.dart';
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

    bool isIndentInRange() => indentBlockIndex < indentBlocks.length;

    final result = <FoldableBlock>[];

    while (highlightBlockIndex < highlightBlocks.length || isIndentInRange()) {
      if (highlightBlockIndex >= highlightBlocks.length) {
        result.addAll(indentBlocks.skip(indentBlockIndex));
        break;
      }

      final highlightBlock = highlightBlocks[highlightBlockIndex];

      final indentBlocksToAdd = _getAllBlocksBeforeLine(
        indentBlockIndex,
        indentBlocks,
        highlightBlock.firstLine,
      );
      result.addAll(indentBlocksToAdd);
      indentBlockIndex += indentBlocksToAdd.length;

      bool areBlocksMayBeInEachOther() =>
          highlightBlock.includes(indentBlocks[indentBlockIndex]) ||
          indentBlocks[indentBlockIndex].includes(highlightBlock);

      bool unionHasBeenAdded = false;
      if (isIndentInRange() &&
          areBlocksMayBeInEachOther() &&
          indentBlocks[indentBlockIndex].first == highlightBlock.first) {
        final indentBlock = indentBlocks[indentBlockIndex];
        result.add(
          FoldableBlock(
            firstLine: indentBlock.first,
            lastLine: max(indentBlock.last, highlightBlock.last),
            type: FoldableBlockType.union,
          ),
        );
        unionHasBeenAdded = true;
        indentBlockIndex++;
      }

      while (isIndentInRange() && areBlocksMayBeInEachOther()) {
        indentBlockIndex++;
      }

      if (!unionHasBeenAdded) {
        result.add(highlightBlock);
      }
      highlightBlockIndex++;
    }

    return result;
  }

  /// Returns [blocks] from [startIndex]
  /// while their first lines less than [maxLine].
  List<FoldableBlock> _getAllBlocksBeforeLine(
    int startIndex,
    List<FoldableBlock> blocks,
    int maxLine,
  ) {
    final blocksToAddCount = _getBlocksCountBeforeLineFrom(
      startIndex: startIndex,
      line: maxLine,
      blocks: blocks,
    );
    return blocks.sublist(
      startIndex,
      startIndex + blocksToAddCount,
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