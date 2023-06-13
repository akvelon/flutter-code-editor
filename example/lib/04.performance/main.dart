// This web-only app is used to assess the performance.
// It allowed us to file this issue: https://github.com/flutter/flutter/issues/128575
// And to see how much overhead our editor adds on top of
// the Flutter's raw widget and controller.

// ignore_for_file: avoid_print

import 'dart:js' as js; // ignore: avoid_web_libraries_in_flutter
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:highlight/languages/java.dart';

const attempts = 5;
const maxKLines = 10;
const text = 'int efghijklmnopqrstuvwxy;\n';
final texts = [
  for (int i = 0; i <= maxKLines; i++) text * i * 1000,
];

const span = TextSpan(
  children: [
    TextSpan(text: 'int', style: TextStyle(color: Colors.red)),
    TextSpan(
      text: ' efghijklmnopqrstuvwxy;\n',
      style: TextStyle(color: Colors.grey),
    ),
  ],
);
final spans = [
  for (int i = 0; i <= maxKLines; i++)
    TextSpan(children: List.filled(i * 1000, span)),
];

final controllers = {
  'TextEditingController': TextEditingController(),
  'TextEditingController + colors': ColoredTextEditingController(),
  'CodeController, no lang': CodeController(),
  'CodeController, Java': CodeController(language: java),
};

typedef FieldFactory = Widget Function({
  required TextEditingController controller,
  required bool expands,
});

final fieldFactories = <String, FieldFactory>{
  'TextField': ({required controller, required expands}) => TextField(
        controller: controller,
        maxLines: null,
        expands: expands,
      ),
  'CodeField': ({required controller, required expands}) => CodeField(
        controller: controller as CodeController,
        expands: expands,
      ),
};

final renderer = js.context['flutterCanvasKit'] == null ? 'HTML' : 'CanvasKit';

void main() {
  runApp(CodeEditor());
}

class CodeEditor extends StatefulWidget {
  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  bool _expands = false;

  String _controllerKey = controllers.keys.first;
  TextEditingController _controller = controllers.values.first;

  String _fieldFactoryKey = fieldFactories.keys.first;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          actions: [
            for (int i = 0; i <= maxKLines; i++)
              ElevatedButton(
                child: Text('${i}k'),
                onPressed: () async => _setText(i),
              ),
            ElevatedButton(
              onPressed: _setTexts,
              child: const Text('1-${maxKLines}k'),
            ),
            ElevatedButton(
              onPressed: _runAll,
              child: const Text('All'),
            ),
          ],
        ),
        body: CodeTheme(
          data: CodeThemeData(styles: vs2015Theme),
          child: _getWidget(),
        ),
      ),
    );
  }

  Widget _getWidget() {
    final field = fieldFactories[_fieldFactoryKey]!(
      controller: _controller,
      expands: _expands,
    );

    return _expands ? field : SingleChildScrollView(child: field);
  }

  String _getName() {
    return '$renderer, $_fieldFactoryKey, $_controllerKey, expands=$_expands';
  }

  Future<double> _setText(int klines) async {
    final sw = Stopwatch();
    sw.start();

    for (int attempt = attempts; --attempt >= 0;) {
      _controller.text = '';
      _controller.text = texts[klines];

      // Give up the control to render.
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final result = sw.elapsed.inMilliseconds / attempts;
    print('Set ${klines}k lines in $result ms');
    return result;
  }

  Future<String> _setTexts() async {
    final durations = <double>[];

    for (int i = 1; i <= maxKLines; i++) {
      durations.add(await _setText(i));
    }

    final name = _getName();
    final result = '$name\t${durations.join('\t')}';
    print(result);
    return result;
  }

  Future<void> _runAll() async {
    final results = <String>[];

    for (final controllerKey in controllers.keys) {
      for (final fieldFactoryKey in fieldFactories.keys) {
        for (final expands in [/*true,*/ false]) {
          final controller = controllers[controllerKey]!;

          if (['CodeField'].contains(fieldFactoryKey) &&
              controller is! CodeController) {
            continue; // CodeField can only work with CodeController.
          }

          setState(() {
            _controllerKey = controllerKey;
            _controller = controller;
            _fieldFactoryKey = fieldFactoryKey;
            _expands = expands;
          });

          controller.text = '';
          await Future.delayed(const Duration(milliseconds: 100));

          print(_getName());
          results.add(await _setTexts());
        }
      }
    }

    print('');
    print(results.join('\n'));
  }
}

class ColoredTextEditingController extends TextEditingController {
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final klines = (this.text.length / 27 / 1000).floor();
    return spans[klines];
  }
}
