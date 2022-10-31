import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

extension TextEditingValueTestExtension on TextEditingValue {
  TextEditingValue replacedSelection(String text) {
    return replaced(selection, text);
  }

  TextEditingValue typed(String text) {
    final lengthDiff = text.length - selected.length;

    return replaced(selection, text).copyWith(
      selection: TextSelection.collapsed(offset: selection.end + lengthDiff),
    );
  }
}
