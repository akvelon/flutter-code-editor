import 'dart:math';

import 'package:equatable/equatable.dart';

import '../util/inclusive_range.dart';
import 'foldable_block_type.dart';

class FoldableBlock extends InclusiveRange with EquatableMixin {
  final int firstLine;
  final int lastLine;
  final FoldableBlockType type;

  @override
  int get first => firstLine;

  @override
  int get last => lastLine;

  const FoldableBlock({
    required this.firstLine,
    required this.lastLine,
    required this.type,
  });

  @override
  List<Object?> get props => [
        firstLine,
        lastLine,
        type,
      ];

  bool includes(FoldableBlock other) {
    return firstLine <= other.firstLine && lastLine >= other.lastLine;
  }

  int get lineCount => lastLine - firstLine + 1;

  bool get isComment {
    // ignore: missing_enum_constant_in_switch
    switch (type) {
      case FoldableBlockType.braces:
      case FoldableBlockType.brackets:
      case FoldableBlockType.parentheses:
      case FoldableBlockType.indent:
      case FoldableBlockType.imports:
      case FoldableBlockType.union:
        return false;
      case FoldableBlockType.singleLineComment:
      case FoldableBlockType.multilineComment:
        return true;
    }
  }

  bool get isImports {
    // ignore: missing_enum_constant_in_switch
    switch (type) {
      case FoldableBlockType.singleLineComment:
      case FoldableBlockType.braces:
      case FoldableBlockType.brackets:
      case FoldableBlockType.parentheses:
      case FoldableBlockType.indent:
      case FoldableBlockType.union:
      case FoldableBlockType.multilineComment:
        return false;
      case FoldableBlockType.imports:
        return true;
    }
  }

  bool isSameLines(FoldableBlock other) {
    return firstLine == other.firstLine && lastLine == other.lastLine;
  }

  FoldableBlock join(FoldableBlock other) {
    return FoldableBlock(
      firstLine: min(firstLine, other.firstLine),
      lastLine: max(lastLine, other.lastLine),
      type: _getJoinType(this, other),
    );
  }

  FoldableBlock offset(int line) {
    return FoldableBlock(
      firstLine: firstLine + line,
      lastLine: lastLine + line,
      type: type,
    );
  }

  static FoldableBlockType _getJoinType(FoldableBlock a, FoldableBlock b) {
    if (a.type == FoldableBlockType.imports) {
      return FoldableBlockType.imports;
    }

    if (b.type == FoldableBlockType.imports) {
      return FoldableBlockType.imports;
    }

    return FoldableBlockType.union;
  }
}

extension FoldableBlockList on List<FoldableBlock> {
  void sortByStartLine() {
    sort((a, b) => a.firstLine - b.firstLine);
  }

  /// Joins intersecting blocks.
  ///
  /// This list must be sorted by firstLine.
  void joinIntersecting() {
    if (length < 2) {
      return;
    }

    // A working list to lay down blocks to compare.
    // As we iterate blocks, it will contain the current nesting hierarchy.
    final ancestors = <FoldableBlock>[];
    final ancestorIndexToOverallIndex = <int>[];

    for (int overallIndex = 0; overallIndex < length; overallIndex++) {
      // The pointer to the block we currently compare with ancestors.
      // If it merges with any ancestor, it is redefined to point
      // to that ancestor (bubbles up).
      FoldableBlock bubble = this[overallIndex];

      // Throw the block into the current nesting hierarchy...
      ancestors.add(bubble);
      ancestorIndexToOverallIndex.add(overallIndex);

      int bubbleIndexInAncestors = ancestors.length - 1;
      int bubbleOverallIndex = overallIndex;

      // And fix every violation of the hierarchy by bubbling the block up,
      // removing non-ancestors from the working list, and joining when needed.
      for (int ancestorIndex = ancestors.length - 2;
          ancestorIndex >= 0;
          ancestorIndex--) {
        final ancestor = ancestors[ancestorIndex];

        if (ancestor.lastLine < bubble.firstLine) {
          // `bubble` is not nested in `ancestor`.
          // Remove `ancestor` from the working list and try the upper one.
          ancestors.removeAt(ancestorIndex);
          ancestorIndexToOverallIndex.removeAt(ancestorIndex);
          bubbleIndexInAncestors--;
          continue;
        }

        final isDuplicate = bubble.isSameLines(ancestor);

        final areIntersecting = ancestor.lastLine >= bubble.firstLine &&
            ancestor.lastLine < bubble.lastLine;

        if (isDuplicate || areIntersecting) {
          final joined = ancestor.join(bubble);

          this[ancestorIndexToOverallIndex[ancestorIndex]] = joined;
          ancestors[ancestorIndex] = joined;

          removeAt(bubbleOverallIndex);
          ancestors.removeAt(bubbleIndexInAncestors);
          ancestorIndexToOverallIndex.removeAt(bubbleIndexInAncestors);
          overallIndex--;

          if (!areIntersecting) {
            // `bubble` was a duplicate lines-wise.
            // Do not go up the hierarchy because it is laid down alright there.
            break; // to the top level, try the next block.
          }

          // Continue bubbling up the new joined block
          // because it may still violate the hierarchy above.
          bubbleIndexInAncestors = ancestorIndex;
          bubbleOverallIndex = ancestorIndexToOverallIndex[ancestorIndex];
          bubble = ancestors[bubbleIndexInAncestors];
        }
      }
    }
  }
}
