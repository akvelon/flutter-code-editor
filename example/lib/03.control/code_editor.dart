import 'package:flutter/material.dart';

import 'constants/constants.dart';
import 'widgets/code_box.dart';
import 'widgets/code_editor_appbar.dart';

class CodeEditor extends StatefulWidget {
  final String language;
  final String theme;
  final bool reset;
  const CodeEditor({
    super.key,
    required this.language,
    required this.theme,
    required this.reset,
  });

  @override
  State<CodeEditor> createState() => _CodeEditorState();
}

class _CodeEditorState extends State<CodeEditor> {
  late String language;
  late String theme;
  late bool reset;

  @override
  void initState() {
    language = widget.language;
    theme = widget.theme;
    reset = widget.reset;

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
          shouldContainInitialText: true,
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
      language = languageList[0] ?? language;
      theme = themeList[0] ?? theme;
    });
  }
}
