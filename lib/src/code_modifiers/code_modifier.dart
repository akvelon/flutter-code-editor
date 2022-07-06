import 'package:flutter/material.dart';

import '../code_field/editor_params.dart';

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
    String text,
    TextSelection sel,
    EditorParams params,
  );
}
