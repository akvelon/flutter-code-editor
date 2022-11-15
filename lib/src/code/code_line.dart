import 'dart:ui';

import 'package:charcode/ascii.dart';
import 'package:meta/meta.dart';

@immutable
class CodeLine {
  final String text;

  final TextRange textRange;
  final bool isReadOnly;
  final int indent;

  const CodeLine({
    required this.text,
    required this.textRange,
    required this.indent,
    this.isReadOnly = false,
  });

  CodeLine.fromTextAndRange({
    required this.text,
    required this.textRange,
    this.isReadOnly = false,
  }) : indent = _calculateIndent(text);

  CodeLine.fromTextAndStart(
    this.text,
    int start, {
    this.isReadOnly = false,
  })  : textRange = TextRange(start: start, end: start + text.length),
        indent = _calculateIndent(text);

  @override
  String toString() =>
      'CodeLine(ro: $isReadOnly, textRange: $textRange, text: "$text")';

  CodeLine copyWith({
    String? text,
    TextRange? textRange,
    bool? isReadOnly,
  }) =>
      CodeLine(
        text: text ?? this.text,
        textRange: textRange ?? this.textRange,
        isReadOnly: isReadOnly ?? this.isReadOnly,
        indent: text == null ? 0 : _calculateIndent(text),
      );

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

  static int _calculateIndent(String text) {
    int indentation = 0;
    for (final character in text.runes) {
      if (character == $space || character == $tab || character == $lf) {
        indentation++;
      } else {
        break;
      }
    }

    return indentation;
  }
}
