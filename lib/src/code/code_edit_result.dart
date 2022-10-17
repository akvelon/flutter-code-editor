import 'package:flutter/widgets.dart';

@immutable
class CodeEditResult {
  final String fullTextAfter;
  final TextRange linesChanged;
  final TextRange charactersChanged;

  const CodeEditResult({
    required this.fullTextAfter,
    required this.linesChanged,
    required this.charactersChanged,
  });

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('fullTextAfter: $fullTextAfter, ');
    buffer.write('linesChanged: $linesChanged');
    buffer.write('charactersChanged: $charactersChanged');

    return buffer.toString();
  }

  @override
  int get hashCode => Object.hash(
        fullTextAfter.hashCode,
        linesChanged.hashCode,
        charactersChanged.hashCode,
      );

  @override
  bool operator ==(Object other) {
    return other is CodeEditResult &&
        fullTextAfter == other.fullTextAfter &&
        linesChanged == other.linesChanged &&
        charactersChanged == other.charactersChanged;
  }
}
