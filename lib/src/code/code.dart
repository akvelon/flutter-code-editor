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

final List<Mode> slashCommentSignLanguages = [java, dart, go, scala];

class Code {
  final String text;
  final List<CodeLine> lines;

  factory Code({
    required String text,
    required Mode? language,
  }) {
    final singleLineComment = _getCommentSignByLanguage(language);
    final lines = _textToCodeLines(text, singleLineComment);
    return Code._(
      text: text,
      lines: lines,
    );
  }

  const Code._({
    required this.text,
    required this.lines,
  });

  static const empty = Code._(text: '', lines: []);

  static List<CodeLine> _textToCodeLines(
    String text,
    String? singleLineComment,
  ) {
    final result = <CodeLine>[];
    final lines = text.split('\n');
    int linesLeft = lines.length;
    int charIndex = 0;

    for (String line in lines) {
      final words = _getCommentWords(line, singleLineComment);

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

  static String? _getCommentSignByLanguage(Mode? language) {
    String? commentSign;
    if (slashCommentSignLanguages.contains(language)) {
      commentSign = '//';
    } else if (language == python) {
      commentSign = '#';
    }
    return commentSign;
  }

  static List<String> _getCommentWords(String str, String? singleLineComment) {
    if (singleLineComment != null && str.contains(singleLineComment)) {
      final commentIndex = str.indexOf(singleLineComment);

      return str
          .substring(commentIndex + singleLineComment.length)
          .split(RegExp(r'\s+')); // Split by any whitespaces.
    } else {
      return [];
    }
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
