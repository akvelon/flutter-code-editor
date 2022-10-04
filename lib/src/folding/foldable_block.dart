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
    final minStartLine = min(startLine, other.startLine);
    final maxStartLine = max(startLine, other.startLine);
    final minEndLine = min(endLine, other.endLine);
    final maxEndLine = max(endLine, other.endLine);
    return maxStartLine <= minEndLine &&
        minStartLine <= maxEndLine &&
        !includes(other) &&
        !other.includes(this);
  }
}

extension FoldableBlockList on List<FoldableBlock> {
  void sortByStartLine() {
    sort((a, b) => a.startLine - b.startLine);
  }

  void joinIntersectedBlocks() {
    if (length < 2) {
      return;
    }

    _joinExistingIntersectedBlocks();

    if (_containIntersectsBlocks()) {
      joinIntersectedBlocks();
    }
  }

  void _joinExistingIntersectedBlocks() {
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
        i--;
      }
    }
  }

  bool _containIntersectsBlocks() {
    for (int i = 1; i < length; i++) {
      final currentBlock = this[i];
      final previousBlock = this[i - 1];
      if (currentBlock.intersects(previousBlock)) {
        return true;
      }
    }
    return false;
  }
}
