import 'package:flutter/cupertino.dart';

import '../../../flutter_code_editor.dart';

class TabIntent extends Intent {
  const TabIntent();
}

class TabIntentAction extends Action<TabIntent> {
  final CodeController controller;
  late final tab = ' ' * controller.params.tabSpaces;

  TabIntentAction({
    required this.controller,
  });

  bool get isSomeTextSelected =>
      controller.selection.isNormalized &&
      controller.selection.start != controller.selection.end;

  bool get isSelectionCollapsed =>
      controller.selection.isNormalized &&
      controller.selection.start == controller.selection.end;

  @override
  Object? invoke(TabIntent intent) {
    // When the popup with suggestions is shown
    // we insert that word into the code field
    if (controller.isPopupShown) {
      controller.insertSelectedWord();
      return null;
    }

    // When some area is selected
    // we add 1 level of tabulation to all rows contained in the selection
    if (isSomeTextSelected) {
      controller.modifySelectedRows((row) => tab + row);
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
}
