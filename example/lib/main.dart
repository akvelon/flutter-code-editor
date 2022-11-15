import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:highlight/languages/java.dart';

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
          language: 'java',
          theme: 'monokai-sublime',
        ),
      ),
    );
  }
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _controller =
  CodeController(
      text: 'The quick brown fox jumps over the lazy \uffff dog.', language: java);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: TextField(
          controller: _controller,
          maxLines: null,
        ),
      ),
    );
  }
}

// class WidgetSpanTextEditingController extends TextEditingController {
//   WidgetSpanTextEditingController({String? text})
//       : super.fromValue(text == null
//       ? TextEditingValue.empty
//       : TextEditingValue(text: text));
//
//   @override
//   TextSpan buildTextSpan(
//       {required BuildContext context,
//         TextStyle? style,
//         required bool withComposing}) {
//
//     TextRange? matchedRange;
//
//     if (text.contains('\uffff')) {
//       matchedRange = _findMatchedRange(text);
//     }
//
//     if (matchedRange != null) {
//       return TextSpan(
//         children: [
//           TextSpan(text: matchedRange.textBefore(text)),
//           const WidgetSpan(child: FlutterLogo()),
//           TextSpan(text: matchedRange.textAfter(text)),
//         ],
//         style: style,
//       );
//     }
//
//     return TextSpan(text: text, style: style);
//   }
//
//   TextRange _findMatchedRange(String text) {
//     final RegExp matchPattern = RegExp(RegExp.escape('\uffff'));
//     late TextRange matchedRange;
//
//     for (final Match match in matchPattern.allMatches(text)) {
//       matchedRange = TextRange(start: match.start, end: match.end);
//     }
//
//     return matchedRange;
//   }
// }