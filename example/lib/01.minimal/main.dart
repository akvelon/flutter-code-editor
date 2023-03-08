// This is the minimal example.
// It uses CodeController with an ordinary TextField.

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/themes/monokai-sublime.dart';

import '../common/snippets.dart';

void main() {
  runApp(const CodeEditor());
}

final controller = CodeController(
  text: javaFactorialSnippet,
  language: java,
);

class CodeEditor extends StatelessWidget {
  const CodeEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: SingleChildScrollView(
            child: TextField(
              controller: controller,
              maxLines: null,
            ),
          ),
        ),
      ),
    );
  }
}
