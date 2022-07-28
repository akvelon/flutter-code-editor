import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/scala.dart';

import 'code_line.dart';
import 'text_range.dart';
import 'tokens.dart';

const _slashes = '//';
const _hash = '#';

final _singleLineComments = <Mode, List<String>>{
  java: [_slashes],
  dart: [_slashes],
  go: [_slashes],
  scala: [_slashes],
  python: [_hash],
};

class Code {
  final String text;
  final List<CodeLine> lines;

  factory Code({
    required String text,
    Mode? language,
  }) {
    final singleLineComments = _getCommentsByLanguage(language);
    final lines = _textToCodeLines(text, singleLineComments);
    return Code._(text: text, lines: lines);
  }

  const Code._({
    required this.text,
    required this.lines,
  });

  static const empty = Code._(text: '', lines: []);

  static List<CodeLine> _textToCodeLines(
    String text,
    List<String> singleLineComments,
  ) {
    final result = <CodeLine>[];
    final lines = text.split('\n');
    int linesLeft = lines.length;
    int charIndex = 0;

    for (String line in lines) {
      final words = _getCommentWords(line, singleLineComments);

      String lineText = '$line\n';
      bool isReadOnly = words.contains(Tokens.readonly);

      if (--linesLeft == 0) {
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
    }

    return result;
  }

  static List<String> _getCommentsByLanguage(Mode? language) {
    List<String>? singleLineComment = _singleLineComments[language];
    return singleLineComment ?? [];
  }

  static List<String> _getCommentWords(
    String str,
    List<String> singleLineComments,
  ) {
    for (final singleLineComment in singleLineComments) {
      final commentIndex = str.indexOf(singleLineComment);

      if (commentIndex == -1) {
        continue;
      }

      return str
          .substring(commentIndex + singleLineComment.length)
          .split(RegExp(r'\s+')); // Split by any whitespaces.
    }

      return [];
  }

  /// Returns the 0-based line number of the character at [characterIndex].
  ///
  /// [characterIndex] can be from 0 to length inclusive.
  /// If it is equal to length, it means the cursor at the end of the text.
  ///
  /// Other values throw [RangeError].
  int characterIndexToLineIndex(int characterIndex) {
    int lowerLine = 0;
    int upperLine = lines.length - 1;

    while (true) {
      int lowerCharacter = lines[lowerLine].textRange.start;
      int upperCharacter = lines[upperLine].textRange.end;

      if (upperCharacter == lowerCharacter) {
        return lowerLine; // Empty line case, avoid division by zero.
      }

      // Linear interpolation search.
      int lineIndex = lowerLine +
          ((upperLine - lowerLine) * (characterIndex - lowerCharacter) /
              (upperCharacter - lowerCharacter)).floor();

      final line = lines[lineIndex];

      if (characterIndex < line.textRange.start) {
        // Character is before the current line. Next search before it.
        upperLine = lineIndex - 1;
        continue;
      }

      if (characterIndex > line.textRange.end) {
        // Character is after this line. Next search after it.
        lowerLine = lineIndex + 1;
        continue;
      }

      if (characterIndex == line.textRange.end) {
        if (line.text.characters.lastOrNull == '\n') {
          // Character is just after this string's \n, it is the next line.
          return lineIndex + 1;
        }
      }

      return lineIndex;
    }
  }

  /// Returns whether the current selection has any read-only part.
  bool isReadOnlySelected(TextRange range) {
    final startChar = range.normalized.start;
    final endChar = range.normalized.end;

    final startLine = characterIndexToLineIndex(startChar);
    final endLine = characterIndexToLineIndex(endChar);

    for (int line = startLine; line <= endLine; line++) {
      if (lines[line].isReadOnly) {
        return true;
      }
    }

    return false;
  }
}
