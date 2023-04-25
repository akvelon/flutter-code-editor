import 'package:flutter/services.dart';

import '../code_field/editor_params.dart';
import 'code_modifier.dart';

class PairedSymbolsCodeModifier extends CodeModifier {
  final String openChar;
  final String closeChar;

  const PairedSymbolsCodeModifier({
    required this.openChar,
    required this.closeChar,
  }) : super(openChar);

  @override
  TextEditingValue? updateString(
    String text,
    TextSelection sel,
    EditorParams params,
  ) {
    final replaced = replace(text, sel.start, sel.end, '$openChar$closeChar');

    return replaced.copyWith(
      selection: TextSelection(
        baseOffset: replaced.selection.baseOffset - closeChar.length,
        extentOffset: replaced.selection.extentOffset - closeChar.length,
      ),
    );
  }
}
