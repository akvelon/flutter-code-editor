import 'dart:ui';

import 'package:flutter/material.dart';

class TextFieldPainter extends CustomPainter {
  final TextPainter painter;
  const TextFieldPainter({super.repaint, required this.painter});

  @override
  bool shouldRepaint(covariant CustomPainter) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var offset = Offset.zero;
    for (int i = 0; i < 500; i++) {
      painter.paint(canvas, offset);
      offset = Offset(0, offset.dy + painter.height);
    }
  }

  @override
  bool hitTest(Offset position) {
    return true;
  }
}
