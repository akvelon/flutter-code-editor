import 'package:flutter/material.dart';

class Test extends RenderBox {}

class MyPainter extends CustomPainter {
  final InlineSpan text;
  MyPainter(this.text, {super.repaint});

  @override
  bool? hitTest(Offset position) {
    return true;
  }

  @override
  bool shouldRepaint(covariant MyPainter oldDelegate) {
    return false;
  }

  static const styles = <TextStyle>[
    TextStyle(fontSize: 18, color: Colors.white),
  ];

  late final painters = [
    TextPainter(text: spans[0], textDirection: TextDirection.ltr)..layout(),
    TextPainter(text: spans[1], textDirection: TextDirection.ltr)..layout(),
  ];

  late final spans = [
    TextSpan(
      children: [
        TextSpan(
          text: 'asdasdasd',
          style: styles[0],
        ),
      ],
    ),
    TextSpan(
      children: [text],
    ),
  ];

  static int paintCount = 0;

  @override
  void paint(Canvas canvas, Size size) {
    paintCount++;

    painters[0]
      ..layout()
      ..paint(canvas, Offset.zero);
    if (true) {
      painters[1]
        ..layout()
        ..paint(canvas, Offset(0, painters[0].height));
    }
  }
}

class EditableTextImpl extends EditableText {
  EditableTextImpl({
    required super.controller,
    required super.focusNode,
    required super.style,
    required super.cursorColor,
    required super.backgroundCursorColor,
  });
  @override
  EditableTextState createState() {
    return EditableTextStateImpl();
  }
}

class EditableTextStateImpl extends EditableTextState {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container();
  }
}
