import 'package:flutter/material.dart';

import '../code_controller.dart';

class CustomDismissAction extends Action<DismissIntent> {
  final CodeController controller;

  CustomDismissAction({
    required this.controller,
  });

  @override
  Object? invoke(DismissIntent intent) {
    controller.dismiss();

    return null;
  }
}
