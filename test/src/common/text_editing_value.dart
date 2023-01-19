import 'package:flutter/widgets.dart';

extension TextEditingValueTestExtension on TextEditingValue {
  TextEditingValue replacedSelection(String text) {
    return replaced(selection, text);
  }
}
