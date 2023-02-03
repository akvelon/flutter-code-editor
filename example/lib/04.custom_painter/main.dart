import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/java.dart';

import '../common/snippets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ValueNotifier<bool> repaint = ValueNotifier(true);
  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(milliseconds: 50), (e) {});
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(styles: monokaiSublimeTheme),
          child: Builder(
            builder: (context) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    RepaintBoundary(child: RichTextField()),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
