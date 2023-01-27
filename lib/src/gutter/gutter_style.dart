import 'package:flutter/material.dart';

class GutterStyle {
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

  /// Whether to show line numbers column
  final bool showLineNumbers;

  /// Whether to show errors column
  final bool showErrors;

  /// Whether to show folding handles column
  final bool showFoldingHandles;

  bool get showGutter => showLineNumbers || showErrors || showFoldingHandles;

  const GutterStyle({
    this.margin = 10.0,
    this.textAlign = TextAlign.right,
    this.showErrors = true,
    this.showFoldingHandles = true,
    this.showLineNumbers = true,
    this.width = 80.0,
    this.background,
    this.textStyle,
  });

  GutterStyle copyWith({
    TextStyle? textStyle,
  }) =>
      GutterStyle(
        width: width,
        textAlign: textAlign,
        textStyle: textStyle ?? this.textStyle,
        background: background,
        margin: margin,
        showErrors: showErrors,
        showFoldingHandles: showFoldingHandles,
        showLineNumbers: showLineNumbers,
      );
}

@Deprecated('Renamed to GutterStyle')
typedef LineNumberStyle = GutterStyle;
