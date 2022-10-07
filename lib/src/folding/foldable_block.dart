import 'dart:math';

import 'package:equatable/equatable.dart';

import 'foldable_block_type.dart';

class FoldableBlock with EquatableMixin {
  final int startLine;
  final int endLine;
  final FoldableBlockType type;

  const FoldableBlock({
    required this.startLine,
    required this.endLine,
    required this.type,
  });

  @override
  List<Object?> get props => [
        startLine,
        endLine,
        type,
      ];

  bool includes(FoldableBlock other) {
    return startLine <= other.startLine && endLine >= other.endLine;
  }

  bool intersects(FoldableBlock other) {
    return other.endLine >= startLine &&
        other.endLine < endLine &&
        !includes(other);
  }

  FoldableBlock copy() {
    return FoldableBlock(
      startLine: startLine,
      endLine: endLine,
      type: type,
    );
  }
}

extension FoldableBlockList on List<FoldableBlock> {
  void sortByStartLine() {
    sort((a, b) => a.startLine - b.startLine);
  }

  void joinIntersecting() {
    if (length < 2) {
      return;
    }

    for (int i = 1; i < length; i++) {
      final currentBlock = this[i];
      final previousBlock = this[i - 1];
      if (currentBlock.intersects(previousBlock)) {
        this[i - 1] = FoldableBlock(
          startLine: previousBlock.startLine,
          endLine: currentBlock.endLine,
          type: FoldableBlockType.union,
        );
        removeAt(i);
        i = max(i - 2, 0);
      }
    }
  }
}
