import 'dart:math';

import 'package:equatable/equatable.dart';

import 'foldable_block_type.dart';

class FoldableBlock with EquatableMixin {
  final int firstLine;
  final int lastLine;
  final FoldableBlockType type;

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
}

extension FoldableBlockList on List<FoldableBlock> {
  void sortByStartLine() {
    sort((a, b) => a.firstLine - b.firstLine);
  }

  /// Joins intersecting blocks in list.
  /// Expected that list is sorted by start line.
  void joinIntersecting() {
    if (length < 2) {
      return;
    }

    for (int i = 1; i < length; i++) {
      final currentBlock = this[i];
      final previousBlock = this[i - 1];
      final areIntersected = previousBlock.lastLine >= currentBlock.firstLine &&
          previousBlock.lastLine < currentBlock.lastLine;
      if (areIntersected) {
        this[i - 1] = FoldableBlock(
          firstLine: previousBlock.firstLine,
          lastLine: currentBlock.lastLine,
          type: FoldableBlockType.union,
        );
        removeAt(i);
        i = max(i - 2, 0);
      }
    }
  }
}
