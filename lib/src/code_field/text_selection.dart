import 'dart:math';

import 'package:flutter/widgets.dart';

extension TextSelectionExtension on TextSelection {
  int get length =>
      max(baseOffset, extentOffset) - min(baseOffset, extentOffset);

  TextSelection get reversed {
    return TextSelection(
      baseOffset: extentOffset,
      extentOffset: baseOffset,
      affinity: affinity,
      isDirectional: isDirectional,
    );
  }

  bool get isSelectionNormalized {
    return baseOffset <= extentOffset;
  }
}
