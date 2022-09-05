import 'package:equatable/equatable.dart';

import 'foldable_block.dart';
import 'foldable_block_type.dart';

/// Anything that failed to be a [FoldableBlock] due to missing
/// the opposite pair character.
class InvalidFoldableBlock with EquatableMixin {
  final int? startLine;
  final int? endLine;
  final FoldableBlockType type;

  const InvalidFoldableBlock({
    required this.type,
    this.startLine,
    this.endLine,
  });

  @override
  List<Object?> get props => [
        startLine,
        endLine,
        type,
      ];
}

extension InvalidFoldableBlockList on List<InvalidFoldableBlock> {
  void sortByStartOrEndLine() {
    sort(
      (a, b) =>
          (a.startLine ?? a.endLine ?? 0) - (b.startLine ?? b.endLine ?? 0),
    );
  }
}
