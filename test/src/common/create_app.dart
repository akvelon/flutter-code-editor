import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';

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
