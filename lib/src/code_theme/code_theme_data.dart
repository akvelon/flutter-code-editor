import 'package:flutter/widgets.dart';

class CodeThemeData {
  final Map<String, TextStyle> styles;

  const CodeThemeData({
    required this.styles,
  });

  @override
  int get hashCode => styles.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is CodeThemeData && styles == other.styles;
  }
}
