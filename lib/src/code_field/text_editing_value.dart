import 'package:flutter/widgets.dart';

extension ReplacedSelection on TextEditingValue {
  TextEditingValue replacedSelection(String value) {
    return replaced(selection, value);
  }
}
