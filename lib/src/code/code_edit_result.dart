import 'package:flutter/widgets.dart';

@immutable
class CodeEditResult {
  final String fullTextAfter;
  final TextRange linesChanged;
  final TextRange indexesChanged;

  const CodeEditResult({
    required this.fullTextAfter,
    required this.linesChanged,
    required this.indexesChanged,
  });

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('fullTextAfter: $fullTextAfter, ');
    buffer.write('linesChanged: $linesChanged');
    buffer.write('indexesChanged: $indexesChanged');

    return buffer.toString();
  }

  @override
  int get hashCode => Object.hash(
        fullTextAfter.hashCode,
        linesChanged.hashCode,
        indexesChanged.hashCode,
      );

  @override
  bool operator ==(Object other) {
    return other is CodeEditResult &&
        fullTextAfter == other.fullTextAfter &&
        linesChanged == other.linesChanged &&
        indexesChanged == other.indexesChanged;
  }
}

extension TextRangeExtension on TextRange {
  int get length => end - start;
}
