import 'dart:async';

import 'package:example/code_editor/super_painter.dart';
import 'package:example/code_editor/utility/painted_text_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

class CodeEditor extends StatefulWidget {
  const CodeEditor({
    super.key,
    required this.focusNode,
    required this.controller,
  });

  final FocusNode focusNode;
  final CodeController controller;

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late final FocusNode focusNode = widget.focusNode;
  late final CodeController controller = widget.controller;
  PaintedTextNotifier notifier = PaintedTextNotifier();

  late final double lineHeight;
  late final double letterWidth;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.value = const TextEditingValue(text: 'a');
    final span =
        controller.buildTextSpan(context: context, withComposing: false);
    final painter = TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout();
    lineHeight = painter.height;
    letterWidth = painter.width;
    controller.value = TextEditingValue(text: '');

    controller.addListener(() {
      notifier.textSpan = controller.buildTextSpan(context: context);
    });

    final testText = 'import package \n';
    Timer.periodic(const Duration(seconds: 1), (timer) {
      controller.value = controller.value.copyWith(
        text: controller.value.text + testText,
      );
    });
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Focus(
              focusNode: focusNode,
              child: GestureDetector(
                child: Container(
                  height: controller.code.lines.length * lineHeight,
                  child: CustomPaint(
                    isComplex: true,
                    painter: SuperPainter(
                      letterWidth: letterWidth,
                      lineHeight: lineHeight,
                      repaint: notifier,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
