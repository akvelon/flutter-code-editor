import '../../flutter_code_editor.dart';
import '../single_line_comments/single_line_comment.dart';

class ServiceCommentFilter {
  static Iterable<SingleLineComment> filter(
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
    if (comment.isReadonly) {
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
}
