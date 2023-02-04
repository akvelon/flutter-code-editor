import 'package:equatable/equatable.dart';

import '../analyzer/api/models/issue.dart';
import '../analyzer/api/models/issue_type.dart';
import 'foldable_block.dart';
import 'foldable_block_type.dart';

/// Anything that failed to be a [FoldableBlock] due to missing
/// the opposite pair character.
class InvalidFoldableBlock with EquatableMixin {
  final int? startLine;
  final int? endLine;
  final Issue issue;
  final FoldableBlockType type;

  InvalidFoldableBlock({
    required this.type,
    this.startLine,
    this.endLine,
  })  : assert(
          startLine != null || endLine != null,
          'startLine or endLine must be non-null',
        ),
        issue = Issue(
          line: startLine ?? endLine ?? 0,
          message: 'Invalid foldable block',
          type: IssueType.error,
        );

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
