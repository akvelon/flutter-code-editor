import 'package:flutter/widgets.dart';

@immutable
class CodeThemeData {
  final Map<String, TextStyle> styles;

  CodeThemeData({
    Map<String, TextStyle>? styles,
    TextStyle? classStyle,
    TextStyle? commentStyle,
    TextStyle? functionStyle,
    TextStyle? keywordStyle,
    TextStyle? paramsStyle,
    TextStyle? quoteStyle,
    TextStyle? titleStyle,
    TextStyle? variableStyle,
  }) : styles = styles ?? {} {
    if (classStyle != null) {
      this.styles['class'] = classStyle;
    }

    if (commentStyle != null) {
      this.styles['comment'] = commentStyle;
    }

    if (functionStyle != null) {
      this.styles['function'] = functionStyle;
    }

    if (keywordStyle != null) {
      this.styles['keyword'] = keywordStyle;
    }

    if (paramsStyle != null) {
      this.styles['params'] = paramsStyle;
    }

    if (quoteStyle != null) {
      this.styles['quote'] = quoteStyle;
    }

    if (titleStyle != null) {
      this.styles['title'] = titleStyle;
    }

    if (variableStyle != null) {
      this.styles['variable'] = variableStyle;
    }
  }

  @override
  int get hashCode => styles.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CodeThemeData && styles == other.styles;
  }
}
