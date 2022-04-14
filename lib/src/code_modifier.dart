import 'dart:math';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';

abstract class CodeModifier {
  final String char;

  const CodeModifier(this.char);

  // Helper to insert [str] in [text] between [start] and [end]
  TextEditingValue replace(String text, int start, int end, String str) {
    final len = str.length;
    return TextEditingValue(
      text: text.replaceRange(start, end, str),
      selection: TextSelection(
        baseOffset: start + len,
        extentOffset: start + len,
      ),
    );
  }

  TextEditingValue? updateString(
      String text, TextSelection sel, EditorParams params);
}

class IntendModifier extends CodeModifier {
  final bool handleBrackets;

  const IntendModifier({
    this.handleBrackets = true,
  }) : super('\n');

  @override
  TextEditingValue? updateString(
      String text, TextSelection sel, EditorParams params) {
    var spacesCount = 0;
    var braceCount = 0;
    for (var k = min(sel.start, text.length) - 1; k >= 0; k--) {
      if (text[k] == "\n") break;
      if (text[k] == " ")
        spacesCount += 1;
      else
        spacesCount = 0;
      if (text[k] == "{")
        braceCount += 1;
      else if (text[k] == "}") braceCount -= 1;
    }
    if (braceCount > 0) spacesCount += params.tabSpaces;
    final insert = "\n" + " " * spacesCount;
    return replace(text, sel.start, sel.end, insert);
  }
}

class CloseBlockModifier extends CodeModifier {
  const CloseBlockModifier() : super('}');

  @override
  TextEditingValue? updateString(
      String text, TextSelection sel, EditorParams params) {
    int spaceCount = 0;
    for (var k = min(sel.start, text.length) - 1; k >= 0; k--) {
      if (text[k] == "\n") break;
      if (text[k] != " ") {
        spaceCount = 0;
        break;
      }
      spaceCount += 1;
    }
    if (spaceCount >= params.tabSpaces)
      return replace(text, sel.start - params.tabSpaces, sel.end, "}");
    return null;
  }
}

class TabModifier extends CodeModifier {
  const TabModifier() : super('\t');

  @override
  TextEditingValue? updateString(
      String text, TextSelection sel, EditorParams params) {
    final tmp = replace(text, sel.start, sel.end, " " * params.tabSpaces);
    return tmp;
  }
}
