import '../../highlight/keyword_semantics.dart';

/// The semantics of a line from the perspective of a sequence
/// of similar lines that can form a foldable block.
enum LineSemantics {
  /// A blank line or line with only whitespace characters.
  blank,

  /// A line with only a single-line comment and possibly
  /// whitespace characters before it.
  singleLineComment,

  /// A line that is completely inside of a multiline comment.
  /// And possibly whitespaces around it.
  multilineComment,

  /// A line containing any keyword with [KeywordSemantics.import]
  /// and possibly other entities that do not terminate an import block.
  import,

  /// A line containing any keyword with [KeywordSemantics.possibleImport]
  /// but not [KeywordSemantics.import], and possibly other entities
  /// that do not terminate an import block.
  possibleImport,

  /// Content that can terminate a single-line comment sequence
  /// and an import sequence.
  /// These are:
  /// - Keywords without [KeywordSemantics.import] or
  ///   [KeywordSemantics.possibleImport].
  /// - Multiline comments.
  singleLineCommentAndImportTerminator,

  /// Content that can terminate a single-line comment sequence
  /// but cannot terminate an import sequence.
  /// These are any non-whitespace characters.
  singleLineCommentTerminator,
}
