import 'dart:ui';

import 'package:charcode/ascii.dart';
import 'package:meta/meta.dart';

@immutable
class CodeLine {
  final String text;

  final TextRange textRange;
  final bool isReadOnly;
  late final indent = _calculateIndent();

  CodeLine({
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

  CodeLine copyWith({bool? isReadOnly}) {
    return CodeLine(
      text: text,
      textRange: textRange,
      isReadOnly: isReadOnly ?? this.isReadOnly,
    );
  }

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

  int _calculateIndent() {
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
