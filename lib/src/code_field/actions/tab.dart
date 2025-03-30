import 'package:flutter/material.dart';

import '../code_controller.dart';

class TabKeyIntent extends Intent {
  const TabKeyIntent();
}

class TabKeyAction extends Action<TabKeyIntent> {
  final CodeController controller;

  TabKeyAction({
    required this.controller,
  });

  @override
  Object? invoke(TabKeyIntent intent) {
    controller.onTabKeyAction();
    return null;
  }
}
