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
    String? lastChar;

    for (var k = min(sel.start, text.length) - 1; k >= 0; k--) {
      if (text[k] == '\n') {
        break;
      }

      if (text[k] == ' ') {
        spacesCount += 1;
      } else {
        lastChar ??= text[k];
        spacesCount = 0;
      }
    }

    if (lastChar == ':' || lastChar == '{') {
      spacesCount += params.tabSpaces;
    }

    final insert = '\n${' ' * spacesCount}';
    return replace(text, sel.start, sel.end, insert);
  }
}
