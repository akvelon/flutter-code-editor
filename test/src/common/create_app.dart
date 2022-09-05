import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

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
