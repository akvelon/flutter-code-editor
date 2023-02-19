import 'package:example/custom_render/rich_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/rendering/box.dart';
import 'package:flutter/src/rendering/object.dart';

class TextLine extends LeafRenderObjectWidget {
  final TextSpan content;

  const TextLine({
    required this.content,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderTextLine(
      content: content,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderTextLine renderObject) {
    renderObject..content = content;
    super.updateRenderObject(context, renderObject);
  }
}

class RenderTextLine extends RenderBox {
  TextSpan get content => _content;
  TextSpan _content;
  set content(TextSpan value) {
    if (value == _content) {
      return;
    }
    _content = value;
    painter.text = value;
  }

  RenderTextLine({
    required TextSpan content,
  }) : _content = content;

  @override
  bool get isRepaintBoundary => true;

  @override
  bool get sizedByParent => true;

  late final TextPainter painter;

  @override
  RichTextFieldParentData? get parentData {
    assert(super.parentData is RichTextFieldParentData?);
    if (super.parentData == null) {
      return null;
    }

    return super.parentData as RichTextFieldParentData;
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);

    painter = TextPainter(textDirection: TextDirection.ltr, text: content)
      ..layout();
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    painter.layout();
    return Size(painter.width, parentData!.lineHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final canvas = context.canvas;
    painter.paint(canvas, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return true;
  }
}
