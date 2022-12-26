import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import '../common/snippets.dart';
import '../common/themes.dart';
import 'constants.dart';
import 'widgets/dropdown_selector.dart';

const _defaultLanguage = 'java';
const _defaultTheme = 'monokai-sublime';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _language = _defaultLanguage;
  String _theme = _defaultTheme;
  final _codeFieldFocusNode = FocusNode();
  late final _codeController = CodeController(
    language: builtinLanguages[_language],
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    text: javaFactorialSnippet,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themes[_theme]?['root']?.backgroundColor,
      appBar: AppBar(
        title: const Text('Code Editor by Akvelon'),
        actions: [
          DropdownSelector(
            onChanged: _setLanguage,
            icon: Icons.code,
            value: _language,
            values: languageList,
          ),
          const SizedBox(width: 20),
          DropdownSelector(
            onChanged: _setTheme,
            icon: Icons.color_lens,
            value: _theme,
            values: themeList,
          ),
        ],
      ),
      body: ListView(
        children: [
          CodeTheme(
            data: CodeThemeData(styles: themes[_theme]),
            child: CodeField(
              focusNode: _codeFieldFocusNode,
              controller: _codeController,
              textStyle: const TextStyle(fontFamily: 'SourceCode'),
              lineNumberStyle: const LineNumberStyle(
                textStyle: TextStyle(
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFieldFocusNode.dispose();
    super.dispose();
  }

  void _setLanguage(String value) {
    setState(() {
      _language = value;
      _codeController.language = builtinLanguages[value];
      _codeFieldFocusNode.requestFocus();
    });
  }

  void _setTheme(String value) {
    setState(() {
      _theme = value;
      _codeFieldFocusNode.requestFocus();
    });
  }
}
