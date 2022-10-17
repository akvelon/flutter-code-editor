import 'package:flutter/material.dart';

// TODO(alexeyinkin): Rename to GutterStyle when we break compatibility.
class LineNumberStyle {
  /// Width of the line number column.
  final double width;

  /// Alignment of the numbers in the column.
  final TextAlign textAlign;

  /// Style of the numbers.
  ///
  /// [TextStyle.fontSize] and [TextStyle.fontFamily] are ignored
  /// and taken from the widget style or [TextTheme.subtitle1] for consistency
  /// with lines. Everything else applies.
  ///
  /// Of omitted, the widget or theme value is used with the color of
  /// half the opacity.
  final TextStyle? textStyle;

  /// Background of the line number column
  final Color? background;

  /// Central horizontal margin between the numbers and the code.
  final double margin;

  const LineNumberStyle({
    this.width = 70.0,
    this.textAlign = TextAlign.right,
    this.margin = 10.0,
    this.textStyle,
    this.background,
  });

  LineNumberStyle copyWith({
    TextStyle? textStyle,
  }) =>
      LineNumberStyle(
        width: width,
        textAlign: textAlign,
        textStyle: textStyle ?? this.textStyle,
        background: background,
        margin: margin,
      );
}
