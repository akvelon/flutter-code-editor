import 'dart:math';

import 'package:flutter/widgets.dart';

import '../code_field/editor_params.dart';
import 'code_modifier.dart';

class IntendModifier extends CodeModifier {
  final bool handleBrackets;

  const IntendModifier({
    this.handleBrackets = true,
  }) : super('\n');

  @override
  TextEditingValue? updateString(
    String text,
    TextSelection sel,
    EditorParams params,
  ) {
    var spacesCount = 0;
    var braceCount = 0;

    for (var k = min(sel.start, text.length) - 1; k >= 0; k--) {
      if (text[k] == '\n') {
        break;
      }

      if (text[k] == ' ') {
        spacesCount += 1;
      } else {
        spacesCount = 0;
      }

      if (text[k] == '{') {
        braceCount += 1;
      } else if (text[k] == '}') {
        braceCount -= 1;
      }
    }

    if (braceCount > 0) {
      spacesCount += params.tabSpaces;
    }

    final insert = '\n${' ' * spacesCount}';
    return replace(text, sel.start, sel.end, insert);
  }
}
