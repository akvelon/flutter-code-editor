import 'package:meta/meta.dart';

import '../code/tokens.dart';

@immutable
class SingleLineComment {
  /// Zero-based index of the first character from the beginning of the text.
  final int characterIndex;

  /// The comment text without the characters signifying the comment.
  final String innerContent;

  /// Zero-based index of the line at which this comment is found.
  final int lineIndex;

  /// The comment text with the characters signifying the comment.
  final String outerContent;

  /// The object this comment was parsed from, if any.
  ///
  /// The object class is specific to the parser.
  final Object? source;

  late final isReadonly = _checkIfReadonly();

  SingleLineComment({
    required this.innerContent,
    required this.lineIndex,
    this.characterIndex = 0,
    this.outerContent = '',
    this.source,
  });

  /// Creates the object from [outerContent] by extracting [innerContent]
  /// from it.
  SingleLineComment.cut(
    String outerContent, {
    required int characterIndex,
    required int lineIndex,
    required List<String> sequences,
    Object? source,
  }) : this(
          characterIndex: characterIndex,
          innerContent: _cutSequence(
            outerContent: outerContent,
            sequences: sequences,
          ),
          lineIndex: lineIndex,
          outerContent: outerContent,
          source: source,
        );

  @override
  int get hashCode => Object.hash(
        characterIndex,
        innerContent,
        lineIndex,
        outerContent,
      );

  @override
  bool operator ==(Object other) {
    return other is SingleLineComment &&
        characterIndex == other.characterIndex &&
        innerContent == other.innerContent &&
        lineIndex == other.lineIndex &&
        outerContent == other.outerContent;
  }

  @override
  String toString() => 'Line $lineIndex: "$outerContent"';

  bool _checkIfReadonly() {
    final words = innerContent.split(RegExp(r'\s+'));
    return words.contains(Tokens.readonly);
  }

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

extension SingleLineCommentIterable on Iterable<SingleLineComment> {
  Set<Object?> get sources => {...map((e) => e.source)};
}
