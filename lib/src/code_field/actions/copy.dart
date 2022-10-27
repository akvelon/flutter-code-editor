import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../code_controller.dart';
import '../text_editing_value.dart';

class CopyAction extends Action<CopySelectionTextIntent> {
  final CodeController controller;

  CopyAction({
    required this.controller,
  });

  @override
  Future<void> invoke(CopySelectionTextIntent intent) async {
    final selection = controller.code.hiddenRanges.recoverSelection(
      controller.value.selection,
    );

    await Clipboard.setData(
      ClipboardData(text: selection.textInside(controller.code.text)),
    );

    if (intent.collapseSelection) {
      controller.value = controller.value.deleteSelection();
    }
  }
}
