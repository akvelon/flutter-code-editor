import 'package:flutter/services.dart';

import '../code_field/editor_params.dart';
import 'code_modifier.dart';

class InsertionCodeModifier extends CodeModifier {
  final String openChar;
  final String closeString;

  const InsertionCodeModifier({
    required this.openChar,
    required this.closeString,
  }) : super(openChar);

  static const backticks =
      InsertionCodeModifier(openChar: '`', closeString: '`');

  static const braces = InsertionCodeModifier(openChar: '{', closeString: '}');

  static const brackets =
      InsertionCodeModifier(openChar: '[', closeString: ']');

  static const doubleQuotes =
      InsertionCodeModifier(openChar: '"', closeString: '"');

  static const parentheses =
      InsertionCodeModifier(openChar: '(', closeString: ')');

  static const singleQuotes =
      InsertionCodeModifier(openChar: '\'', closeString: '\'');

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
