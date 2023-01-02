import '../../../flutter_code_editor.dart';

abstract class AbstractFoldableBlockMatcher {
  Set<FoldableBlock> get newFoldedBlocks;

  AbstractFoldableBlockMatcher();
}
