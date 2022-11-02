import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/languages/java.dart';

FocusNode focusNode = FocusNode();

MaterialApp createApp(CodeController controller, FocusNode focusNode) {
  return MaterialApp(
    home: Scaffold(
      body: CodeField(
        controller: controller,
        focusNode: focusNode,
      ),
    ),
  );
}

Future<CodeController> pumpController(WidgetTester wt, String text) async {
  final controller = createController(text);

  focusNode = FocusNode();
  await wt.pumpWidget(createApp(controller, focusNode));
  focusNode.requestFocus();

  return controller;
}

CodeController createController(String text) {
  return CodeController(
    text: text,
    language: java,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
  );
}
