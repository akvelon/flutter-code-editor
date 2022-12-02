import 'package:collection/collection.dart';

import '../single_line_comment.dart';
import 'abstract_single_line_comment_parser.dart';

class TextSingleLineCommentParser extends AbstractSingleLineCommentParser {
  final String text;
  final List<String> singleLineCommentSequences;

  @override
  final comments = <SingleLineComment>[];

  TextSingleLineCommentParser({
    required this.text,
    required this.singleLineCommentSequences,
  }) {
    _parse();
  }

  void _parse() {
    final lines = text.split('\n');
    int lineIndex = 0;
    int characterIndex = 0;

    for (final line in lines) {
      final column = _getCommentColumn(line);

      if (column != null) {
        comments.add(
          SingleLineComment.cut(
            line.substring(column),
            lineIndex: lineIndex,
            characterIndex: characterIndex + column,
            sequences: singleLineCommentSequences,
            source: lineIndex,
          ),
        );
      }

      lineIndex++;
      characterIndex += line.length + 1;
    }
  }

  int? _getCommentColumn(String line) {
    final columns = <int>[];

    for (final sequence in singleLineCommentSequences) {
      final column = line.indexOf(sequence);

      if (column != -1) {
        columns.add(column);
      }
    }

    return columns.minOrNull;
  }
}
