import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:code_text_field/constants/constants.dart';
import 'custom_code_box.dart';


void main() {
  runApp(const CodeEditor());
}

class CodeEditor extends StatelessWidget {
  const CodeEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FutureBuilder<List<String>>(
          future: Future.wait([loadBlockSettings(), loadRefactorSettings()]),
          builder: (context, AsyncSnapshot<List<String>> async) {
            if (async.connectionState == ConnectionState.done) {
              if (async.hasError) {
                return Center(
                  child: Text("ERROR"),
                );
              } 
              else if (async.hasData) {
                return CustomCodeBox(
                  language: dart,
                  theme: 'monokai-sublime',
                  blocks: async.data![0],
                  refactorSettings: async.data![1],
                );
              }
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        )
      )
    );
  }
}

Future<String> loadBlockSettings() async{
  return await rootBundle.loadString('assets/settings/blockSettings.json');
}

Future<String> loadRefactorSettings() async{
  return await rootBundle.loadString('assets/settings/autoRefactoringSettings.json');
}