import 'dart:math';

import 'package:flutter/widgets.dart';

import '../code_field/editor_params.dart';
import 'code_modifier.dart';

class CloseBlockModifier extends CodeModifier {
  const CloseBlockModifier() : super('}');

  @override
  TextEditingValue? updateString(
    String text,
    TextSelection sel,
    EditorParams params,
  ) {
    int spaceCount = 0;

    for (var k = min(sel.start, text.length) - 1; k >= 0; k--) {
      if (text[k] == '\n') {
        break;
      }

      if (text[k] != ' ') {
        spaceCount = 0;
        break;
      }

      spaceCount += 1;
    }

    if (spaceCount >= params.tabSpaces) {
      return replace(text, sel.start - params.tabSpaces, sel.end, '}');
    }

    return null;
  }
}
