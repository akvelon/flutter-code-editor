import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../../../flutter_code_editor.dart';

class UntabIntent extends Intent {
  const UntabIntent();
}

class UntabIntentAction extends Action<UntabIntent> {
  final CodeController controller;

  UntabIntentAction({
    required this.controller,
  });

  int get tabSpaces => controller.params.tabSpaces;

  @override
  Object? invoke(UntabIntent intent) {
    controller.modifySelectedRows(_unTab);

    return null;
  }

  String _unTab(String row) {
    if (row.length < tabSpaces) {
      return row.trimLeft();
    }

    final subStr = row.substring(0, tabSpaces);
    if (subStr == ' ' * tabSpaces) {
      return row.substring(tabSpaces, row.length);
    } else {
      return row.trimLeft();
    }
  }
}
