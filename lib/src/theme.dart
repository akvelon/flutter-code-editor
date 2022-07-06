import 'package:flutter/widgets.dart';

class CodeThemeData {
  final Map<String, TextStyle> styles;

  CodeThemeData({
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

class CodeTheme extends InheritedWidget {
  const CodeTheme({
    required this.data,
    Key? key,
    required Widget child,
  }) : super(key: key, child: child);

  final CodeThemeData? data;

  static CodeThemeData? of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<CodeTheme>();
    return widget?.data;
  }

  @override
  bool updateShouldNotify(covariant CodeTheme oldWidget) {
    return oldWidget.data != data;
  }
}
