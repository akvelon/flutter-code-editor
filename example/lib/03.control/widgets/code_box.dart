import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import '../../common/snippets.dart';
import '../../common/themes.dart';
import '../constants/constants.dart';

class CodeBox extends StatefulWidget {
  final String language;
  final String theme;

  const CodeBox({
    required this.language,
    required this.theme,
  });

  @override
  State<CodeBox> createState() => _CodeBoxState();
}

class _CodeBoxState extends State<CodeBox> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      language: builtinLanguages[widget.language],
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
      readOnlySectionNames: {'section1', 'nonexistent'},
      text: javaFactorialSnippet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = themes[widget.theme];
    setState(() {
      _codeController = CodeController(
        language: builtinLanguages[widget.language],
        namedSectionParser: const BracketsStartEndNamedSectionParser(),
        readOnlySectionNames: {'section1', 'nonexistent'},
        text: javaFactorialSnippet,
      );
    });

    return Container(
      color: theme?['root']?.backgroundColor,
      height: MediaQuery.of(context).size.height / 13 * 12,
      child: CodeTheme(
        data: CodeThemeData(styles: theme),
        child: Stack(
          children: [
            SingleChildScrollView(
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
