import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:highlight/languages/java.dart';

import '../../../flutter_code_editor.dart';
import 'text_field_painter.dart';

class RichTextField extends StatefulWidget {
  const RichTextField({super.key});

  @override
  State<RichTextField> createState() => _RichTextFieldState();
}

class _RichTextFieldState extends State<RichTextField> {
  ValueNotifier<bool> repaint = ValueNotifier(false);
  double height = 0.0;
  double width = 0.0;

  TextEditingController controller = CodeController(
    text: 'import package return () {} /*   */ // comment\n',
    language: java,
  );
  late final TextPainter _painter = TextPainter(
    text: TextSpan(text: ''),
    textDirection: TextDirection.ltr,
  );

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (e) {
      repaint.value = !repaint.value;

      controller.value = TextEditingValue(
        text: '${controller.value.text}\naaaaaaaaaa',
      );
    });

    controller.addListener(() {
      var textSpan = _painter.text = controller.buildTextSpan(
        context: context,
        withComposing: false,
      );
      _painter.layout();

      textSpan.visitChildren((span) {
        print((span as TextSpan).text);
        return true;
      });

      setState(() {
        height = _painter.height * 500;
        width = _painter.width;
      });
    });

    _painter.layout();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
              ),
            ),
            height: height,
            width: width,
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
