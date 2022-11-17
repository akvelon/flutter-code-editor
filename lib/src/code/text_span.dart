import 'package:flutter/painting.dart';

import 'text_style.dart';

extension TextSpanExtension on TextSpan {
  String toStringRecursive([int indent = 0]) {
    final sb = StringBuffer();
    sb.writeln(' ' * 2 * indent + toMapString());
    for (final child in children ?? const <TextSpan>[]) {
      sb.write((child as TextSpan).toStringRecursive(indent + 1));
    }
    return sb.toString();
  }

  String toMapString() {
    final result = {
      'text': text == null ? null : '\'$text\'',
      'style': style?.toMapString(),
      'children': children == null ? 'empty' : null,
    };
    result.removeWhere((key, value) => value == null);
    return result.toString();
  }
}
