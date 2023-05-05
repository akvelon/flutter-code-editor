import 'package:flutter/widgets.dart';

class IgnoreIntent extends Intent {
  const IgnoreIntent();
}

class IgnoreAction extends Action<IgnoreIntent> {
  @override
  Object? invoke(IgnoreIntent intent) {
    return null;
  }
}
