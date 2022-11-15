import 'dart:ui';

import 'package:characters/characters.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'code_line.dart';

@immutable
class CodeLines with EquatableMixin {
  final List<CodeLine> lines;

  const CodeLines(this.lines);

  static const empty = CodeLines([
    CodeLine(
      text: '',
      textRange: TextRange.collapsed(0),
      indent: 0,
    ),
  ]);

  CodeLine operator [](int i) => lines[i];

  int get length => lines.length;

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
      final lowerCharacter = lines[lowerLine].textRange.start;
      final upperCharacter = lines[upperLine].textRange.end;

      if (upperCharacter == lowerCharacter) {
        return lowerLine; // Empty line case, avoid division by zero.
      }

      // Linear interpolation search.
      final lineIndex = lowerLine +
          ((upperLine - lowerLine) *
                  (characterIndex - lowerCharacter) /
                  (upperCharacter - lowerCharacter))
              .floor();

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

  @override
  List<Object> get props => [
        lines,
      ];
}
