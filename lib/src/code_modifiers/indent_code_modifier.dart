import 'dart:math';

import 'package:flutter/widgets.dart';

import '../code_field/editor_params.dart';
import 'code_modifier.dart';

class IndentModifier extends CodeModifier {
  final bool handleBrackets;

  const IndentModifier({
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

    final indexOfLastChar = sel.start - 1;
    final lastchar = indexOfLastChar >= 0 ? text[indexOfLastChar] : null;

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
    } else if (lastchar == ':') {
      spacesCount += params.tabSpaces;
    }

    final insert = '\n${' ' * spacesCount}';
    return replace(text, sel.start, sel.end, insert);
  }
}
