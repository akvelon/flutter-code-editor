import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:highlight/highlight_core.dart';

import '../hidden_ranges/hidden_range.dart';
import '../hidden_ranges/hidden_ranges.dart';
import '../named_sections/named_section.dart';
import '../named_sections/parsers/abstract.dart';
import '../single_line_comments/parser/single_line_comment_parser.dart';
import '../single_line_comments/parser/single_line_comments.dart';
import '../single_line_comments/single_line_comment.dart';
import 'code_edit_result.dart';
import 'code_line.dart';
import 'string.dart';
import 'text_range.dart';
import 'tokens.dart';

class Code {
  final String text;
  final HiddenRanges hiddenRanges;
  final Result? highlighted;
  final List<CodeLine> lines;
  final Map<String, NamedSection> namedSections;
  final Result? visibleHighlighted;
  final String visibleText;

  factory Code({
    required String text,
    Result? highlighted,
    Mode? language,
    AbstractNamedSectionParser? namedSectionParser,
    Set<String> readOnlySectionNames = const {},
  }) {
    final sequences = SingleLineComments.byMode[language] ?? [];

    final commentParser = SingleLineCommentParser.parseHighlighted(
      text: text,
      highlighted: highlighted,
      singleLineCommentSequences: sequences,
    );

    final serviceComments = _filterServiceComments(
      commentParser.comments,
      namedSectionParser: namedSectionParser,
    );

    final lines = _textToCodeLines(
      text: text,
      highlighted: highlighted,
      language: language,
      commentsByLines: commentParser.getCommentsByLines(),
    );

    final sections = namedSectionParser?.parse(
          singleLineComments: commentParser.comments,
        ) ??
        const [];
    final sectionsMap = {for (final s in sections) s.name: s};

    _applyNamedSectionsToLines(
      lines: lines,
      sections: sectionsMap,
      readOnlySectionNames: readOnlySectionNames,
    );

    final hiddenRanges = HiddenRanges(
      ranges: _commentsToHiddenRanges(serviceComments),
      textLength: text.length,
    );

    return Code._(
      text: text,
      hiddenRanges: hiddenRanges,
      highlighted: highlighted,
      lines: lines,
      namedSections: sectionsMap,
      visibleHighlighted:
          highlighted == null ? null : hiddenRanges.cutHighlighted(highlighted),
      visibleText: hiddenRanges.cutString(text, start: 0),
    );
  }

  const Code._({
    required this.text,
    required this.hiddenRanges,
    required this.highlighted,
    required this.lines,
    required this.namedSections,
    required this.visibleHighlighted,
    required this.visibleText,
  });

  static const empty = Code._(
    text: '',
    hiddenRanges: HiddenRanges.empty,
    highlighted: null,
    lines: [],
    namedSections: {},
    visibleHighlighted: null,
    visibleText: '',
  );

  static Iterable<SingleLineComment> _filterServiceComments(
    List<SingleLineComment> comments, {
    required AbstractNamedSectionParser? namedSectionParser,
  }) sync* {
    for (final comment in comments) {
      if (_isServiceComment(comment, namedSectionParser: namedSectionParser)) {
        yield comment;
      }
    }
  }

  static bool _isServiceComment(
    SingleLineComment comment, {
    required AbstractNamedSectionParser? namedSectionParser,
  }) {
    final words = _getCommentWords(comment.innerContent);
    if (words.contains(Tokens.readonly)) {
      return true;
    }

    if (namedSectionParser != null) {
      final namedSections = namedSectionParser.parseUnsorted(
        singleLineComments: [comment],
      );
      if (namedSections.isNotEmpty) {
        return true;
      }
    }

    return false;
  }

  static List<CodeLine> _textToCodeLines({
    required String text,
    required Result? highlighted,
    required Mode? language,
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

  static void _applyNamedSectionsToLines({
    required List<CodeLine> lines,
    required Map<String, NamedSection> sections,
    required Set<String> readOnlySectionNames,
  }) {
    for (final name in readOnlySectionNames) {
      final section = sections[name];

      if (section == null) {
        continue;
      }

      final lastLineIndex = section.endLine ?? lines.length - 1;

      for (int i = section.startLine; i <= lastLineIndex; i++) {
        lines[i] = lines[i].copyWith(isReadOnly: true);
      }
    }
  }

  static List<HiddenRange> _commentsToHiddenRanges(
    Iterable<SingleLineComment> comments,
  ) {
    return comments
        .map(
          (c) => HiddenRange.fromStartAndText(c.characterIndex, c.outerContent),
        )
        .toList(growable: false);
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

  /// Returns whether the current selection has any read-only part.
  bool isReadOnlySelected(TextRange range) {
    if (range.start == -1 && range.end == -1) {
      return false; // Empty selection.
    }

    final startChar = range.normalized.start;
    final endChar = range.normalized.end;

    return isReadOnlyInLineRange(
      TextRange(
        start: characterIndexToLineIndex(startChar),
        end: characterIndexToLineIndex(endChar),
      ),
    );
  }

  /// Returns whether any of the lines of this range is read-only.
  bool isReadOnlyInLineRange(TextRange lineRange) {
    for (int line = lineRange.start; line <= lineRange.end; line++) {
      if (lines[line].isReadOnly) {
        return true;
      }
    }

    return false;
  }

  CodeEditResult getEditResult(TextEditingValue visibleAfter) {
    final visibleRangeAfter = visibleAfter.text.getChangedRange(
      visibleText,
      attributeChangeTo: TextAffinity.upstream,
    );

    if (visibleRangeAfter.start == -1 && visibleRangeAfter.end == -1) {
      return CodeEditResult(
        fullTextAfter: text,
        linesChanged: TextRange.empty,
      );
    }

    // Recover what exactly was the full old text that was replaced
    // with the new one. For this, inspect the start and end points
    // of the changed part in the old visibleText.
    // If any hidden ranges are collapsed at those points,
    // the trick is to correctly replace them or to correctly preserve them.
    final rangeBefore = TextRange(
      // `end` is responsible for deciding between these two cases when the user
      // entered some text at the point with a hidden range:
      //     text we are adding at the beginning of this line// [START section1]
      //     // [START section1]text we are adding at the beginning of this line
      // We do not want to add that text to the comment and its hidden range.
      // So we must place all hidden ranges collapsed at the end of the diff
      // *after* that diff:
      end: hiddenRanges.recoverPosition(
        visibleText.length - visibleAfter.text.length + visibleRangeAfter.end,
        placeHiddenRanges: TextAffinity.downstream,
      ),

      // If we are inserting (and the old changed part is empty),
      // then using the same `placeHiddenRanges` is straightforward.
      //
      // However, this is also the only option for a non-empty old changed range
      // with a hidden range collapsed at its start. Otherwise we would
      // append to that comment, and the new text will not be visible.
      // Using `TextAffinity.downstream` effectively deletes any such hidden
      // range because it falls into the range of replacement.
      // We may want to reconsider this if we support terminatable hidden range
      // comments like /* ... */ that do not acquire all text to the
      // end of the string.
      start: hiddenRanges.recoverPosition(
        visibleRangeAfter.start,
        placeHiddenRanges: TextAffinity.downstream,
      ),
    );

    final fullTextAfter = rangeBefore.textBefore(text) +
        visibleRangeAfter.textInside(visibleAfter.text) +
        rangeBefore.textAfter(text);

    // The line at [start] has changed for sure.
    // The line at [end - 1] has changed if [end > start].
    // Additionally, the line at [end] has changed if two strings were glued:
    //  - (1) The last old char was '\n' AND
    //  - (2) The char before [start] is not '\n'.
    // We don't need to check (1) because otherwise [end] and [end - 1]
    // are on the same line.
    final lastChar = rangeBefore.end -
        ((rangeBefore.start == 0 || text[rangeBefore.start - 1] == '\n')
            ? 1
            : 0);

    final linesChanged = TextRange(
      start: characterIndexToLineIndex(rangeBefore.start),
      end: characterIndexToLineIndex(max(lastChar, rangeBefore.start)),
    );

    return CodeEditResult(
      fullTextAfter: fullTextAfter,
      linesChanged: linesChanged,
    );
  }
}
