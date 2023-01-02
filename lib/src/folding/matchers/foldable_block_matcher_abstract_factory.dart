import '../../../flutter_code_editor.dart';
import 'abstract_foldable_block_matcher.dart';
import 'default_foldable_block_matcher.dart';
import 'foldable_block_matcher_type.dart';
import 'multiline_edit_foldable_block_matcher.dart';

class FoldableBlockMatcherAbstractFactory {
  static final Map<
      FoldableBlockMatcherType,
      AbstractFoldableBlockMatcher Function(
    Code oldCode,
    Code newCode,
  )> _instanceFactoryMaps = {
    FoldableBlockMatcherType.defaultFoldableBlockMatcher: (
      oldCode,
      newCode,
    ) =>
        DefaultFoldableBlockMatcher(
          oldCode: oldCode,
          newCode: newCode,
        ),
    FoldableBlockMatcherType.multilineIndentOutdentFoldableBlockMatcher: (
      oldCode,
      newCode,
    ) =>
        MultilineIndentOutdentFoldableBlockMatcher(
          oldCode: oldCode,
          newCode: newCode,
        ),
  };

  static Set<FoldableBlock> getNewFoldableBlocks({
    required Code oldCode,
    required Code newCode,
    required FoldableBlockMatcherType matcherType,
  }) {
    return _instanceFactoryMaps[matcherType]
            ?.call(oldCode, newCode)
            .newFoldedBlocks ??
        {};
  }
}
