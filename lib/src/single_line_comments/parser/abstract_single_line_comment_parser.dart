import '../single_line_comment.dart';

abstract class AbstractSingleLineCommentParser {
  List<SingleLineComment> get comments;

  Map<int, SingleLineComment> getCommentsByLines() =>
      {for (final comment in comments) comment.lineIndex: comment};
}
