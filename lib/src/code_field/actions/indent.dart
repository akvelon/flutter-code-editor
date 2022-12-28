import 'package:flutter/cupertino.dart';

import '../../../flutter_code_editor.dart';

class IndentIntent extends Intent {
  const IndentIntent();
}

class IndentIntentAction extends Action<IndentIntent> {
  final CodeController controller;
  String get tab => ' ' * controller.params.tabSpaces;

  IndentIntentAction({
    required this.controller,
  });

  bool get isSomeTextSelected =>
      controller.selection.isNormalized &&
      controller.selection.start != controller.selection.end;

  bool get isSelectionCollapsed =>
      controller.selection.isNormalized &&
      controller.selection.start == controller.selection.end;

  @override
  Object? invoke(IndentIntent intent) {
    controller.indentSelection();
    return null;
  }
}
