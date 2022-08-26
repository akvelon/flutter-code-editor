import 'package:flutter/material.dart';

import 'custom_code_box.dart';

void main() {
  runApp(const CodeEditor());
}

class CodeEditor extends StatelessWidget {
  const CodeEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CustomCodeBox(
          language: 'dart',
          theme: 'monokai-sublime',
        ),
      ),
    );
  }
}
