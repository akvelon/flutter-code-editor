import 'package:collection/collection.dart';

import 'code_line.dart';
import 'code_lines.dart';

class CodeLinesBuilder {
  static CodeLines textToCodeLines({
    required String text,
    required Map<int, bool> readonlyCommentsByLine,
  }) {
    final result = <CodeLine>[];
    final lines = _splitText(text);
    int charIndex = 0;

    for (int lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final isReadOnly = _isLineReadonly(
        containsReadonlyComment: readonlyCommentsByLine[lineIndex],
        isLastLine: lineIndex == lines.length - 1,
        isEmptyLine: line.isEmpty,
        isPreviousLineReadonly: result.lastOrNull?.isReadOnly,
      );

      result.add(
        CodeLine.fromTextAndStart(line, charIndex, isReadOnly: isReadOnly),
      );

      charIndex += line.length;
    }

    return CodeLines(result);
  }

  static List<String> _splitText(String text) {
    final lines = text.split('\n');
    final result = <String>[];
    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final line = lines[lineIndex];
      final isLastLine = lineIndex == lines.length - 1;
      final lineText = isLastLine ? line : '$line\n';
      result.add(lineText);
    }
    return result;
  }

  static bool _isLineReadonly({
    required bool? containsReadonlyComment,
    required bool isLastLine,
    required bool isEmptyLine,
    required bool? isPreviousLineReadonly,
  }) {
    bool isReadOnly = containsReadonlyComment ?? false;

    // If last line is empty, it inherits isReadOnly from the previous line.
    // Otherwise, if we wanted a read-only document end, we could
    // not use newline at the end of it as POSIX requires.
    if (isLastLine && isEmptyLine) {
      isReadOnly = isPreviousLineReadonly ?? false;
    }
    return isReadOnly;
  }
}
