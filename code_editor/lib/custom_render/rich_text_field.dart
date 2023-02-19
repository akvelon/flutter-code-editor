import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class RichTextFieldV2 extends MultiChildRenderObjectWidget {
  final double letterWidth;
  final double lineHeight;

  RichTextFieldV2({
    super.key,
    required this.letterWidth,
    required this.lineHeight,
    super.children,
  });

  @override
  ContainerRenderObjectMixin createRenderObject(BuildContext context) {
    return RenderRichTextField(
      letterWidth: letterWidth,
      lineHeight: lineHeight,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    super.updateRenderObject(context, renderObject);
  }
}

class RichTextFieldParentData extends ContainerBoxParentData<RenderBox> {
  double lineHeight;
  double letterWidth;

  RichTextFieldParentData({
    required this.letterWidth,
    required this.lineHeight,
  });
}

class RenderRichTextField extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, RichTextFieldParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, RichTextFieldParentData> {
  double letterWidth;
  double lineHeight;

  RenderRichTextField({
    required this.letterWidth,
    required this.lineHeight,
  });

  @override
  bool get isRepaintBoundary => true;

  late final TapGestureRecognizer _tapGestureRecognizer;

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! RichTextFieldParentData) {
      child.parentData = RichTextFieldParentData(
        lineHeight: lineHeight,
        letterWidth: letterWidth,
      );
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);

    _tapGestureRecognizer = TapGestureRecognizer()
      ..onTap = () {
        print('TAP');
      };
  }

  @override
  void performLayout() {
    double width = 0;
    double height = 0;

    RenderBox? child = firstChild;
    Offset childOffset = Offset.zero;

    while (child != null) {
      final parentData = child.parentData as RichTextFieldParentData;

      child.layout(
        BoxConstraints(
          minHeight: lineHeight,
          maxHeight: lineHeight,
        ),
        parentUsesSize: true,
      );

      parentData.offset = childOffset;
      childOffset = Offset(0, childOffset.dy + lineHeight);

      height += lineHeight;
      width = max(width, child.size.width);

      child = parentData.nextSibling;
    }
    size = Size(constraints.maxWidth, height);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    return true;
  }
}
