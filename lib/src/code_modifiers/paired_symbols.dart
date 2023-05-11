import 'package:flutter/services.dart';

import '../code_field/editor_params.dart';
import 'code_modifier.dart';

class PairedSymbolsCodeModifier extends CodeModifier {
  final String openChar;
  final String closeString;

  const PairedSymbolsCodeModifier({
    required this.openChar,
    required this.closeString,
  }) : super(openChar);

  @override
  TextEditingValue? updateString(
    String text,
    TextSelection sel,
    EditorParams params,
  ) {
    final replaced = replace(text, sel.start, sel.end, '$openChar$closeString');

    return replaced.copyWith(
      selection: TextSelection(
        baseOffset: replaced.selection.baseOffset - closeString.length,
        extentOffset: replaced.selection.extentOffset - closeString.length,
      ),
    );
  }
}
