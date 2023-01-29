import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import '../common/snippets.dart';
import '../common/themes.dart';
import 'analyzer_impl/analyzer_impl.dart';
import 'constants.dart';
import 'widgets/dropdown_selector.dart';

const _defaultLanguage = 'dart';
const _defaultTheme = 'monokai-sublime';

const toggleButtonColor = Color.fromARGB(124, 255, 255, 255);
const toggleButtonActiveColor = Colors.white;

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _language = _defaultLanguage;
  String _theme = _defaultTheme;

  bool _showNumbers = true;
  bool _showErrors = true;
  bool _showFoldingHandles = true;

  final _codeFieldFocusNode = FocusNode();
  late final _codeController = CodeController(
    analyzer: AnalyzerImpl(),
    language: builtinLanguages[_language],
    namedSectionParser: const BracketsStartEndNamedSectionParser(),
    text: dartSnippet,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: themes[_theme]?['root']?.backgroundColor,
      appBar: AppBar(
        title: const Text('Code Editor by Akvelon'),
        actions: [
          IconButton(
            color: _showNumbers ? toggleButtonActiveColor : toggleButtonColor,
            onPressed: () => setState(() {
              _showNumbers = !_showNumbers;
            }),
            icon: const Icon(Icons.numbers),
          ),

          IconButton(
            color: _showErrors ? toggleButtonActiveColor : toggleButtonColor,
            onPressed: () => setState(() {
              _showErrors = !_showErrors;
            }),
            icon: const Icon(Icons.cancel),
          ),

          IconButton(
            color: _showFoldingHandles
                ? toggleButtonActiveColor
                : toggleButtonColor,
            onPressed: () => setState(() {
              _showFoldingHandles = !_showFoldingHandles;
            }),
            icon: const Icon(Icons.chevron_right),
          ),
          const SizedBox(width: 20),
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
          const SizedBox(width: 20),
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
              gutterStyle: GutterStyle(
                textStyle: const TextStyle(
                  color: Colors.purple,
                ),
                showLineNumbers: _showNumbers,
                showErrors: _showErrors,
                showFoldingHandles: _showFoldingHandles,
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
