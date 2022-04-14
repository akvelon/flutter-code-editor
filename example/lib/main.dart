//File only for testing. Later file will be deleted.
import 'package:flutter/material.dart';

import 'package:code_text_field/constants/constants.dart';
import 'custom_code_box.dart';

void main() {
  runApp(const CodeEditor());
}

class CodeEditor extends StatelessWidget {
  const CodeEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CustomCodeBox(
            language: dart,
            theme: 'monokai-sublime',
          ),
      ) 
    );
  }
}