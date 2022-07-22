import 'dart:ui';

import 'package:meta/meta.dart';

@immutable
class CodeLine {
  final String text;

  final TextRange textRange;
  final bool isReadOnly;

  const CodeLine({
    required this.text,
    required this.textRange,
    this.isReadOnly = false,
  });

  CodeLine.fromTextAndStart(
    this.text,
    int start, {
    this.isReadOnly = false,
  }) : textRange = TextRange(start: start, end: start + text.length);

  @override
  String toString() =>
      'CodeLine(ro: $isReadOnly, textRange: $textRange, text: "$text")';

  @override
  bool operator ==(Object other) {
    return other is CodeLine &&
        text == other.text &&
        textRange == other.textRange &&
        isReadOnly == other.isReadOnly;
  }

  @override
  int get hashCode => Object.hash(
        text,
        textRange,
        isReadOnly,
      );
}
