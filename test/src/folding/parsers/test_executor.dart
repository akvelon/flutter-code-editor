import 'package:flutter_code_editor/src/folding/foldable_block.dart';
import 'package:flutter_code_editor/src/folding/foldable_block_type.dart';
import 'package:flutter_code_editor/src/folding/invalid_foldable_block.dart';
import 'package:flutter_code_editor/src/folding/parsers/highlight.dart';
import 'package:flutter_code_editor/src/named_sections/parsers/brackets_start_end.dart';
import 'package:flutter_code_editor/src/service_comment_filter/service_comment_filter.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comment_parser.dart';
import 'package:flutter_code_editor/src/single_line_comments/parser/single_line_comments.dart';
import 'package:flutter_code_editor/src/single_line_comments/single_line_comment.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight_core.dart';

/// Shorter alias for [FoldableBlock] to avoid line breaks.
typedef FB = FoldableBlock;

/// Shorter alias for [FoldableBlockType] to avoid line breaks.
typedef FBT = FoldableBlockType;

class HighlightParserTestExecutor {
  static void parseAndCheck({
    required Mode mode,
    required String code,
    required List<FoldableBlock> expected,
    List<InvalidFoldableBlock> invalid = const [],
  }) {
    highlight.registerLanguage('language', mode);
    final highlighted = highlight.parse(code, language: 'language');
    final parser = HighlightFoldableBlockParser();

    final sequences = SingleLineComments.byMode[mode] ?? [];

    final commentParser = SingleLineCommentParser.parseHighlighted(
      text: code,
      highlighted: highlighted,
      singleLineCommentSequences: sequences,
    );

    final serviceComments = ServiceCommentFilter.filter(
      commentParser.comments,
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
    );

    parser.parse(
      highlighted: highlighted,
      serviceCommentsSources: serviceComments.sources,
    );

    expect(parser.blocks, expected);
    expect(parser.invalidBlocks, invalid);
  }
}
