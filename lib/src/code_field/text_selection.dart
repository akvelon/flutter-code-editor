import 'package:flutter/widgets.dart';

extension TextSelectionExtension on TextSelection {
  int get length => end - start;

  TextSelection get reversed {
    return copyWith(
      baseOffset: extentOffset,
      extentOffset: baseOffset,
    );
  }

  bool get isSelectionNormalized {
    return baseOffset <= extentOffset;
  }
}
