import 'package:flutter/widgets.dart';

import 'code_theme_data.dart';

class CodeTheme extends InheritedWidget {
  const CodeTheme({
    required this.data,
    super.key,
    required super.child,
  });

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
