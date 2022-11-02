import '../../single_line_comments/single_line_comment.dart';
import '../named_section.dart';

/// Parses named sections from tags like [START name]...[END name].
///
/// Subclasses must implement [parseUnsorted] for parsing.
///
/// This class does the following with the parsed sections:
///
/// 1. Validates. A section is invalid if any of these is true:
///    - It starts before the line 0.
///    - It ends after the last line (lineCount - 1).
///    - The end line is before the start line.
/// 2. Sorts by the start lines.
abstract class AbstractNamedSectionParser {
  const AbstractNamedSectionParser();

  List<NamedSection> parse({
    required List<SingleLineComment> singleLineComments,
  }) {
    final unsorted = parseUnsorted(
      singleLineComments: singleLineComments,
    );

    return unsorted.where(_isValid).toList(growable: false)
      ..sort((a, b) => a.firstLine - b.firstLine);
  }

  List<NamedSection> parseUnsorted({
    required List<SingleLineComment> singleLineComments,
  });

  bool _isValid(NamedSection section) {
    final lastLine = section.lastLine;
    return section.firstLine >= 0 &&
        (lastLine == null || section.firstLine <= lastLine);
  }
}
