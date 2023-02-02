import 'package:flutter/material.dart';

class MyPainter extends CustomPainter {
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {}
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
