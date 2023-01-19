import 'package:flutter/widgets.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

extension TextEditingValueTestExtension on TextEditingValue {
  TextEditingValue replacedSelection(String text) {
    return replaced(selection, text);
  }
}
