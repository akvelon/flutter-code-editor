import 'package:flutter/widgets.dart';

import '../code_field/editor_params.dart';
import 'code_modifier.dart';

/// A marker passed to CodeController to replace tabs with spaces.
// TODO(alexeyinkin): A better flag for this.
class TabModifier extends CodeModifier {
  const TabModifier() : super('\t');

  @override
  TextEditingValue? updateString(
    String text,
    TextSelection sel,
    EditorParams params,
  ) {
    return null;
  }
}
