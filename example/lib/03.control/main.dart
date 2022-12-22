// This example expands 02.code_field.dart by using CustomCodeBox
// instead of a CodeField.
// This adds customization of the code_field
// by providing an opportunity to change language and theme.

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/java.dart';

import '../common/snippets.dart';
import 'code_editor.dart';
import 'constants/constants.dart';

void main() {
  runApp(const MyApp());
}

final controller = CodeController(
  text: javaFactorialSnippet,
  language: java,
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CodeEditor(
        language: languageList[0]!,
        theme: themeList[0]!,
        reset: false,
      ),
    );
  }
}
