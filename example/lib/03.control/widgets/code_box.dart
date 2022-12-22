import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

import '../../common/snippets.dart';
import '../../common/themes.dart';
import '../constants/constants.dart';

class CodeBox extends StatefulWidget {
  final String language;
  final String theme;
  final bool shouldContainInitialText;

  const CodeBox({
    super.key,
    required this.language,
    required this.theme,
    required this.shouldContainInitialText,
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
      text: widget.shouldContainInitialText ? javaFactorialSnippet : null,
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
      readOnlySectionNames: {'section1', 'nonexistent'},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = themes[widget.theme];
    setState(() {
      _codeController = CodeController(
        language: builtinLanguages[widget.language],
        text: widget.shouldContainInitialText ? javaFactorialSnippet : null,
        namedSectionParser: const BracketsStartEndNamedSectionParser(),
        readOnlySectionNames: {'section1', 'nonexistent'},
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
