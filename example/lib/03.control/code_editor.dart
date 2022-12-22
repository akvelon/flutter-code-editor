import 'package:flutter/material.dart';

import 'constants/constants.dart';
import 'widgets/code_box.dart';
import 'widgets/code_editor_appbar.dart';

class CodeEditor extends StatefulWidget {
  final String language;
  final String theme;

  const CodeEditor({
    required this.language,
    required this.theme,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  String language = languageList[0];
  String theme = themeList[0];

  @override
  void initState() {
    language = widget.language;
    theme = widget.theme;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CodeEditorAppbar(
        height: MediaQuery.of(context).size.height / 13,
        languages: languageList,
        onLanguageChanged: _onLanguageChanged,
        themes: themeList,
        onThemeChanged: _onThemeChanged,
        selectedLanguage: language,
        selectedTheme: theme,
        onReset: _onReset,
      ),
      body: SingleChildScrollView(
        child: CodeBox(
          language: language,
          theme: theme,
        ),
      ),
    );
  }

  void _onLanguageChanged(String? value) {
    setState(() {
      language = value ?? language;
    });
  }

  void _onThemeChanged(String? value) {
    setState(() {
      theme = value ?? theme;
    });
  }

  void _onReset() {
    setState(() {
      language = languageList[0];
      theme = themeList[0];
    });
  }
}
