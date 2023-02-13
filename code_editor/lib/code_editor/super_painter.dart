import 'package:example/code_editor/utility/cache.dart';
import 'package:example/code_editor/utility/painted_text_notifier.dart';
import 'package:flutter/material.dart';

import 'utility/offset_manager.dart';

class SuperPainter extends CustomPainter {
  final List<String> lines = [];
  final List<TextPainter> painters = [];
  final TextPainterCache _cache = TextPainterCache();
  late final OffsetManager _offsetManager =
      OffsetManager(lineHeight: lineHeight);

  final PaintedTextNotifier repaint;

  final double lineHeight;
  final double letterWidth;

  SuperPainter({
    required PaintedTextNotifier repaint,
    required this.lineHeight,
    required this.letterWidth,
  }) : repaint = repaint;

  @override
  void paint(Canvas canvas, Size size) {
    _offsetManager.reset();

    repaint.textSpan.visitChildren((span) {
      final textSpan = span as TextSpan?;
      if (textSpan == null || textSpan.text == '') {
        return true;
      }
        var offset = _offsetManager.offset;
        final painter = _cache.get(textSpan);
        painter.paint(canvas, offset);
        _offsetManager.updateOffset(painter);
      return true;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
