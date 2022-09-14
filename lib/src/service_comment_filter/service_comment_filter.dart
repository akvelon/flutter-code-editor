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

  static List<String> _getCommentWords(
    String? comment,
  ) {
    // Split by any whitespaces.
    return comment?.split(RegExp(r'\s+')) ?? const <String>[];
  }
}
