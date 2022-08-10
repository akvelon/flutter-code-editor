import 'package:meta/meta.dart';

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
    required int lineCount,
  }) {
    final unsorted = parseUnsorted(
      singleLineComments: singleLineComments,
      lineCount: lineCount,
    );

    return unsorted
        .where((section) => _isValid(section, lineCount))
        .toList(growable: false)
      ..sort((a, b) => a.startLine - b.startLine);
  }

  @protected
  List<NamedSection> parseUnsorted({
    required List<SingleLineComment> singleLineComments,
    required int lineCount,
  });

  bool _isValid(NamedSection section, int lineCount) {
    return section.startLine >= 0 &&
        section.endLine < lineCount &&
        section.startLine <= section.endLine;
  }
}
