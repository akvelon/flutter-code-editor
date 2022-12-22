import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import '../common/snippets.dart';
import '../common/themes.dart';
import 'constants/constants.dart';
import 'widgets/code_box.dart';
import 'widgets/code_editor_appbar.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _language = languageList[0];
  String _theme = themeList[0];

  late final _codeController = CodeController(
    language: builtinLanguages[_language],
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    //readOnlySectionNames: {'section1', 'nonexistent'},
    text: javaFactorialSnippet,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Code Editor by Akvelon"),
        actions: [
          LanguageDropdown(),
          ThemeDropdown(),
        ],
      ),
      // appBar: CodeEditorAppbar(
      //   //height: MediaQuery.of(context).size.height / 13,
      //   languages: languageList,
      //   onLanguageChanged: _setLanguage,
      //   themes: themeList,
      //   onThemeChanged: _setTheme,
      //   selectedLanguage: _language,
      //   selectedTheme: _theme,
      //   onReset: _onReset,
      // ),
      body: SingleChildScrollView(
        child: CodeTheme(
          data: CodeThemeData(styles: themes[_theme]),
          child: CodeField(
            controller: _codeController,
            textStyle: const TextStyle(fontFamily: 'SourceCode'),
            lineNumberStyle: const LineNumberStyle(
              textStyle: TextStyle(
                color: Colors.purple,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setLanguage(String value) {
    setState(() {
      _language = value;
      _codeController.language = builtinLanguages[value];
    });
  }

  void _setTheme(String value) {
    setState(() {
      _theme = value;
    });
  }

  void _onReset() {
    setState(() {
      _setLanguage(languageList[0]);
      _theme = themeList[0];
    });
  }
}
