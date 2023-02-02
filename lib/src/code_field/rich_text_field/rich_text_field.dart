import 'dart:async';

import 'package:flutter/material.dart';

import '../../../flutter_code_editor.dart';
import 'text_field_painter.dart';

class RichTextField extends StatefulWidget {
  const RichTextField({super.key});

  @override
  State<RichTextField> createState() => _RichTextFieldState();
}

class _RichTextFieldState extends State<RichTextField> {
  ValueNotifier<bool> repaint = ValueNotifier(false);

  TextEditingController controller = CodeController(text: 'aaaaaaaaaa');
  late final TextPainter _painter = TextPainter(
      text: controller.buildTextSpan(
    context: context,
    withComposing: false,
  ))..layout();

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (e) {
      repaint.value = !repaint.value;

      controller.value = TextEditingValue(
        text: '${controller.value.text}\n${controller.value.text}',
      );
    });

    controller.addListener(() {
      _painter.text = controller.buildTextSpan(
        context: context,
        withComposing: false,
      );
      _painter.layout();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
            ),
            height: _painter.height,
            width: _painter.width,
            child: CustomPaint(
              painter: TextFieldPainter(
                painter: _painter,
                repaint: repaint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
