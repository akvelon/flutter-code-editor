import 'package:meta/meta.dart';

@immutable
class SingleLineComment {
  /// Zero-based index of the line at which this comment is found.
  final int lineIndex;

  /// The comment text without the characters signifying the comment.
  final String innerContent;

  /// The comment text with the characters signifying the comment.
  final String outerContent;

  const SingleLineComment({
    required this.lineIndex,
    required this.innerContent,
    this.outerContent = '',
  });

  SingleLineComment.cut(
    String outerContent, {
    required int lineIndex,
    required List<String> sequences,
  }) : this(
          lineIndex: lineIndex,
          outerContent: outerContent,
          innerContent: _cutSequence(
            outerContent: outerContent,
            sequences: sequences,
          ),
        );

  @override
  int get hashCode => Object.hash(
        lineIndex,
        innerContent,
        outerContent,
      );

  @override
  bool operator ==(Object other) {
    return other is SingleLineComment &&
        lineIndex == other.lineIndex &&
        innerContent == other.innerContent &&
        outerContent == other.outerContent;
  }

  @override
  String toString() => 'Line $lineIndex: "$outerContent"';

  static String _cutSequence({
    required String outerContent,
    required List<String> sequences,
  }) {
    for (final sequence in sequences) {
      if (outerContent.startsWith(sequence)) {
        return outerContent.substring(sequence.length);
      }
    }

    throw Exception('$outerContent does not start with any of $sequences');
  }
}
