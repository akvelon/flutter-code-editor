import 'package:flutter/widgets.dart';

import '../code_field/editor_params.dart';
import 'code_modifier.dart';

class TabModifier extends CodeModifier {
  const TabModifier() : super('\t');

  @override
  TextEditingValue? updateString(
    String text,
    TextSelection sel,
    EditorParams params,
  ) {
    final tmp = replace(text, sel.start, sel.end, ' ' * params.tabSpaces);
    return tmp;
  }
}
