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

  const InsertionCodeModifier.backticks()
      : this(openChar: '`', closeString: '`');

  const InsertionCodeModifier.braces() : this(openChar: '{', closeString: '}');

  const InsertionCodeModifier.brackets()
      : this(openChar: '[', closeString: ']');

  const InsertionCodeModifier.doubleQuotes()
      : this(openChar: '"', closeString: '"');

  const InsertionCodeModifier.parentheses()
      : this(openChar: '(', closeString: ')');

  const InsertionCodeModifier.singleQuotes()
      : this(openChar: '\'', closeString: '\'');

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
