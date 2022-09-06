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
}

extension FoldableBlockList on List<FoldableBlock> {
  void sortByStartLine() {
    sort((a, b) => a.startLine - b.startLine);
  }
}
