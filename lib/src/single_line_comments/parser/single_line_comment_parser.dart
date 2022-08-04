import 'package:highlight/highlight_core.dart';

import 'abstract_single_line_comment_parser.dart';
import 'highlight_single_line_comment_parser.dart';
import 'text_single_line_comment_parser.dart';

class SingleLineCommentParser {
  static AbstractSingleLineCommentParser parseHighlighted({
    required String text,
    required Result? highlighted,
    required List<String> singleLineCommentSequences,
  }) {
    if (highlighted?.language != null) {
      return HighlightSingleLineCommentParser(
        text: text,
        highlighted: highlighted!,
        singleLineCommentSequences: singleLineCommentSequences,
      );
    }

    return TextSingleLineCommentParser(
      text: text,
      singleLineCommentSequences: singleLineCommentSequences,
    );
  }
}
