import 'package:flutter/cupertino.dart';

import '../../../flutter_code_editor.dart';

class OutdentIntent extends Intent {
  const OutdentIntent();
}

class OutdentIntentAction extends Action<OutdentIntent> {
  final CodeController controller;

  OutdentIntentAction({
    required this.controller,
  });

  int get tabSpaces => controller.params.tabSpaces;

  @override
  Object? invoke(OutdentIntent intent) {
    controller.outdentSelection();

    return null;
  }
}
