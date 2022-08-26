import 'package:flutter/widgets.dart';

@immutable
class CodeEditResult {
  final String fullTextAfter;
  final TextRange linesChanged;

  const CodeEditResult({
    required this.fullTextAfter,
    required this.linesChanged,
  });

  @override
  String toString() {
    final buffer = StringBuffer();

    buffer.write('fullTextAfter: $fullTextAfter, ');
    buffer.write('linesChanged: $linesChanged');

    return buffer.toString();
  }

  @override
  int get hashCode => Object.hash(
        fullTextAfter.hashCode,
        linesChanged.hashCode,
      );

  @override
  bool operator ==(Object other) {
    return other is CodeEditResult &&
        fullTextAfter == other.fullTextAfter &&
        linesChanged == other.linesChanged;
  }
}
