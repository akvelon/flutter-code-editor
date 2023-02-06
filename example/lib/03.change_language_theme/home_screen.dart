import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import '../common/snippets.dart';
import '../common/themes.dart';
import 'analyzer_implementation/dart_analyzer.dart';
import 'constants.dart';
import 'widgets/dropdown_selector.dart';

const _defaultLanguage = 'dart';
const _defaultTheme = 'monokai-sublime';
const _defaultAnalyzer = 'Default Analyzer';
const _dartAnalyzer = 'Dart Analyzer';

const toggleButtonColor = Color.fromARGB(124, 255, 255, 255);
const toggleButtonActiveColor = Colors.white;

const _analyzersList = [_defaultAnalyzer, _dartAnalyzer];

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _language = _defaultLanguage;
  String _theme = _defaultTheme;
  String _analyzer = _defaultAnalyzer;

  bool _showNumbers = true;
  bool _showErrors = true;
  bool _showFoldingHandles = true;

  final _codeFieldFocusNode = FocusNode();
  late final _codeController = CodeController(
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
          //
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
            onChanged: _setAnalyzer,
            icon: Icons.search,
            value: _analyzer,
            values: _analyzersList,
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
      _analyzer = _defaultAnalyzer;

      _codeFieldFocusNode.requestFocus();
    });
  }

  void _setAnalyzer(String value) {
    if (value == _defaultAnalyzer) {
      setState(() {
        _codeController.resetAnalyzer();
        _analyzer = _defaultAnalyzer;
      });
    }
    if (value == 'Dart Analyzer') {
      setState(() {
        _codeController.analyzer = DartAnalyzer();
        _analyzer = _dartAnalyzer;
      });
    }
  }

  void _setTheme(String value) {
    setState(() {
      _theme = value;
      _codeFieldFocusNode.requestFocus();
    });
  }
}
