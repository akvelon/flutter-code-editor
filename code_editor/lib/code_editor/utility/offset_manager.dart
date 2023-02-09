import 'package:flutter/cupertino.dart';

class OffsetManager {
  Offset get offset => _offset;
  Offset _offset = Offset.zero;

  double lineHeight;

  OffsetManager({
    required this.lineHeight,
  });

  void updateOffset(TextPainter painter) {
    if (painter.plainText.characters.last == '\n') {
      _offset = Offset(0, _offset.dy + lineHeight);
    } else {
      _offset = Offset(_offset.dx + painter.width, _offset.dy);
    }
  }

  void reset() => _offset = Offset.zero;
}
