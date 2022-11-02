import 'package:flutter/widgets.dart';

import '../code_controller.dart';

class RedoAction extends Action<RedoTextIntent> {
  final CodeController controller;

  RedoAction({
    required this.controller,
  });

  @override
  Object? invoke(RedoTextIntent intent) {
    controller.historyController.redo();
    return null;
  }
}
