import 'package:flutter/material.dart';

import '../code_controller.dart';

class EnterKeyIntent extends Intent {
  const EnterKeyIntent();
}

class EnterKeyAction extends Action<EnterKeyIntent> {
  final CodeController controller;
  EnterKeyAction({
    required this.controller,
  });

  @override
  Object? invoke(EnterKeyIntent intent) {
    controller.onEnterKeyAction();
    return null;
  }
}
