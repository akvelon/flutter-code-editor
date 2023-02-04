import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
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

Future<CodeController> pumpController(
  WidgetTester wt,
  String text, {
  Mode? language,
}) async {
  final controller = createController(text, language: language);

  focusNode = FocusNode();
  await wt.pumpWidget(createApp(controller, focusNode));
  focusNode.requestFocus();

  return controller;
}

CodeController createController(
  String text, {
  Mode? language,
  Set<String> visibleSectionNames = const {},
}) {
  return CodeController(
    text: text,
    language: language ?? java,
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    visibleSectionNames: visibleSectionNames,
  );
}
