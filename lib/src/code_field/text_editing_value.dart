import 'package:flutter/widgets.dart';

import '../code/string.dart';

extension ReplacedSelection on TextEditingValue {
  TextEditingValue replacedSelection(String value) {
    return replaced(selection, value);
  }

  TextEditingValue replacedText(String newText) {
    if (newText == text) {
      return this;
    }

    final rangeAfter = newText.getChangedRange(
      text,
      attributeChangeTo: TextAffinity.upstream,
    );

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: rangeAfter.start),
    );
  }
}
