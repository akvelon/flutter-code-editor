import 'package:flutter/widgets.dart';

import '../code_controller.dart';

class UndoAction extends Action<UndoTextIntent> {
  final CodeController controller;

  UndoAction({
    required this.controller,
  });

  @override
  Object? invoke(UndoTextIntent intent) {
    controller.historyController.undo();
    return null;
  }
}
