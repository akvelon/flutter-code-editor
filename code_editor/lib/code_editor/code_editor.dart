import 'dart:async';
import 'dart:math';

import 'package:example/code_editor/super_painter.dart';
import 'package:example/code_editor/utility/painted_text_notifier.dart';
import 'package:example/code_editor/utility/shortcuts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import '../snippets.dart';

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
  late final FocusNode parentFocusNode = widget.focusNode;
  final FocusNode focusNode = FocusNode();
  late final CodeController controller = widget.controller;
  PaintedTextNotifier notifier = PaintedTextNotifier();

  int linesCount = 0;

  @override
  void initState() {
    focusNode.requestFocus();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final testController = CodeController(language: controller.language);

    testController.value = const TextEditingValue(text: 'a');
    final span =
        testController.buildTextSpan(context: context, withComposing: false);
    final painter = TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout();
    final lineHeight = painter.height;
    final letterWidth = painter.width;

    controller.addListener(() {
      notifier.textSpan = controller.buildTextSpan(context: context);
      setState(() {
        linesCount = controller.code.lines.length;
      });
    });

    return SingleChildScrollView(
      child: Row(
        children: [
          Expanded(
            child: FocusableActionDetector(
              focusNode: parentFocusNode,
              actions: controller.actions,
              shortcuts: shortcuts,
              child: Focus(
                onKey: (node, event) {
                  if (event.logicalKey == LogicalKeyboardKey.keyV &&
                      event.isMetaPressed) {
                    final data = Clipboard.getData(Clipboard.kTextPlain)
                        .then((value) => controller.value = TextEditingValue(
                              text: controller.value.text + (value?.text ?? ''),
                            ));
                  }
                  if (event.logicalKey == LogicalKeyboardKey.enter) {
                    controller.value = TextEditingValue(
                      text: controller.value.text + '\n',
                    );
                  }
                  if (event.character != null) {
                    controller.value = controller.value.copyWith(
                      text: controller.value.text + event.character!,
                    );
                  }
                  return KeyEventResult.ignored;
                },
                focusNode: focusNode,
                child: GestureDetector(
                  child: AnimatedBuilder(
                    animation: notifier,
                    builder: (BuildContext context, Widget? child) {
                      return child!;
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      height: linesCount * lineHeight,
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
            ),
          ),
        ],
      ),
    );
  }
}
