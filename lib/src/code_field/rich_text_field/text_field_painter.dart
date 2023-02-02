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
    painter.paint(canvas, Offset.zero);
  }
}
