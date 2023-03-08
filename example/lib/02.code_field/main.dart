// This example expands 01.minimal.dart by using CodeField
// instead of an ordinary TextField.
// This automatically adds the gutter, code folding, and basic autocompletion.

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
    //controller.visibleSectionNames = {'section1'};
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: SingleChildScrollView(
            child: CodeField(
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}
