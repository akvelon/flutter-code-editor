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

    for (final span in repaint.textSpan.children ?? []) {
      if ((span as TextSpan).text == '') {
        continue;
      }

      var offset = _offsetManager.offset;
      final painter = _cache.get(span as TextSpan);
      painter.paint(canvas, offset);
      _offsetManager.updateOffset(painter);
    }

    // repaint.textSpan.visitChildren((span) {
    //   assert(span is TextSpan, 'Only TextSpans are acceptable');

    // if ((span as TextSpan).text == '') {
    //   return true;
    // }

    // var offset = _offsetManager.offset;
    // final painter = _cache.get(span as TextSpan);
    // painter.paint(canvas, offset);
    // _offsetManager.updateOffset(painter);

    // return true;
    // });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
