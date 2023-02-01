import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highlight/highlight.dart';
import 'package:highlight/languages/java.dart';

FocusNode focusNode = FocusNode();

MaterialApp createApp(CodeController controller, FocusNode focusNode) {
  return MaterialApp(
    home: TestApp(
      controller: controller,
      focusNode: focusNode,
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

class TestApp extends StatefulWidget {
  final CodeController controller;
  final FocusNode focusNode;

  const TestApp({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  late final controller = widget.controller;
  late final focusNode = widget.focusNode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CodeField(
        controller: controller,
        focusNode: focusNode,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}
