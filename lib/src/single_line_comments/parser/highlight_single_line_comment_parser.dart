import 'package:highlight/highlight.dart';

import '../single_line_comment.dart';
import 'abstract_single_line_comment_parser.dart';

class HighlightSingleLineCommentParser extends AbstractSingleLineCommentParser {
  final String text;
  final Result highlighted;
  final List<String> singleLineCommentSequences;

  @override
  final comments = <SingleLineComment>[];

  HighlightSingleLineCommentParser({
    required this.text,
    required this.highlighted,
    required this.singleLineCommentSequences,
  }) {
    _parse();
  }

  void _parse() {
    int lineIndex = 0;

    for (final node in highlighted.nodes ?? const <Node>[]) {
      if (node.className == 'comment') {
        final value = node.children?[0].value ?? '';

        if (_isSingleLineCommentText(value)) {
          comments.add(
            SingleLineComment.cut(
              value,
              lineIndex: lineIndex,
              sequences: singleLineCommentSequences,
            ),
          );
        }
      }

      lineIndex += node.getNewLineCount();
    }
  }

  bool _isSingleLineCommentText(String commentText) {
    for (final prefix in singleLineCommentSequences) {
      if (commentText.startsWith(prefix)) {
        return true;
      }
    }

    return false;
  }
}

extension _NewLineCount on Node {
  int getNewLineCount() {
    int result = '\n'.allMatches(value ?? '').length;

    for (final child in children ?? const <Node>[]) {
      result += child.getNewLineCount();
    }

    return result;
  }
}
