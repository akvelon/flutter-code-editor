import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:highlight/languages/python.dart';

import '../../flutter_code_editor.dart';

class IndentModifier extends CodeModifier {
  final CodeController controller;
  final bool handleBrackets;

  const IndentModifier({
    required this.controller,
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
    var colonCount = 0;

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

      if (text[k] == ':') {
        colonCount = 1;
      }
    }

    if (braceCount > 0 && controller.language != python) {
      spacesCount += params.tabSpaces;
    }

    if (colonCount > 0 && controller.language == python) {
      spacesCount += params.tabSpaces;
    }

    final insert = '\n${' ' * spacesCount}';
    return replace(text, sel.start, sel.end, insert);
  }
}
