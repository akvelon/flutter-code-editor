import 'package:flutter/cupertino.dart';

class TextPainterCache {
  Map<TextSpan, TextPainter> _map = {};

  TextPainter get(TextSpan key) {
    final value = _map[key];
    if (value == null) {
      return _map[key] =
          TextPainter(text: key, textDirection: TextDirection.ltr)..layout();
    }

    return value;
  }
}
