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
    // When the popup with suggestions is shown
    // we insert that word into the code field
    if (controller.isPopupShown) {
      controller.insertSelectedWord();
      return null;
    }

    // When some area is selected
    // we add 1 level of tabulation to all rows contained in the selection
    if (isSomeTextSelected) {
      controller.modifySelectedRows(_incrementTabulation);
      return null;
    }

    // When selection is collapsed (start and end are at one point)
    // we add some number of spaces to the current cursor.
    if (isSelectionCollapsed) {
      controller.insertStr(tab);
      return null;
    }

    return null;
  }

  String _incrementTabulation(String row){
    if(row == '\n'){
      return row;
    }

    return tab + row;
  }
}
