import 'package:collection/collection.dart';
import 'package:highlight/highlight.dart';

import '../../flutter_code_editor.dart';
import '../single_line_comments/single_line_comment.dart';

class CodeLineBuilder {
  static List<CodeLine> textToCodeLines({
    required String text,
    required Result? highlighted,
    required Map<int, SingleLineComment> commentsByLines,
  }) {
    final result = <CodeLine>[];
    final lines = text.split('\n');
    int charIndex = 0;

    int lineIndex = 0;
    final lastLineIndex = lines.length - 1;

    for (final line in lines) {
      final comment = commentsByLines[lineIndex];
      final words = _getCommentWords(comment?.innerContent);

      String lineText = '$line\n';
      bool isReadOnly = words.contains(Tokens.readonly);

      if (lineIndex == lastLineIndex) {
        // The last line is special. It has no newline at the end.
        // If it's empty, it inherits isReadOnly from the previous line.
        // Otherwise, if we wanted a read-only document end, we could
        // not use newline at the end of it as POSIX requires.
        lineText = line;
        if (line == '') {
          isReadOnly = result.lastOrNull?.isReadOnly ?? false;
        }
      }

      result.add(
        CodeLine.fromTextAndStart(
          lineText,
          charIndex,
          isReadOnly: isReadOnly,
        ),
      );

      charIndex += line.length + 1;
      lineIndex++;
    }

    return result;
  }

  static List<String> _getCommentWords(
    String? comment,
  ) {
    // Split by any whitespaces.
    return comment?.split(RegExp(r'\s+')) ?? const <String>[];
  }
}
