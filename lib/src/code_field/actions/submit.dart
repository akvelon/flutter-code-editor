import 'package:flutter/material.dart';

import '../../../flutter_code_editor.dart';

class SubmitIntent extends Intent {
  const SubmitIntent();
}

class SubmitAction extends Action<SubmitIntent> {
  final CodeController controller;
  SubmitAction({
    required this.controller,
  });

  @override
  Object? invoke(SubmitIntent intent) {
    controller.submit();
    return null;
  }
}
