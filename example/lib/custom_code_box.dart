// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/wip/autoRefactorService.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/go.dart';
import 'package:highlight/languages/java.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/scala.dart';

import 'themes.dart';

final builtinLanguages = {
  'go': go,
  'java': java,
  'python': python,
  'scala': scala,
  'dart': dart,
};
final allLanguages = {...builtinLanguages};

class CustomCodeBox extends StatefulWidget {
  final String language;
  final String theme;

  const CustomCodeBox({
    super.key,
    required this.language,
    required this.theme,
  });

  @override
  State<CustomCodeBox> createState() => _CustomCodeBoxState();
}

class _CustomCodeBoxState extends State<CustomCodeBox> {
  String? language;
  String? theme;
  bool? reset;

  @override
  void initState() {
    super.initState();
    language = widget.language;
    theme = widget.theme;
    reset = false;
  }

  List<String?> languageList = <String>[
    'java',
    'go',
    'python',
    'scala',
    'dart',
  ];

  List<String?> themeList = <String>[
    'monokai-sublime',
    'a11y-dark',
    'an-old-hope',
    'vs2015',
    'vs',
    'atom-one-dark',
  ];

  Widget buildDropdown(
    Iterable<String?> choices,
    String value,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return DropdownButton<String>(
      value: value,
      items: choices.map((String? value) {
        return DropdownMenuItem<String>(
          value: value,
          child: value == null
              ? const Divider()
              : Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
      icon: Icon(icon, color: Colors.white),
      onChanged: onChanged,
      dropdownColor: Colors.black87,
    );
  }

  @override
  Widget build(BuildContext context) {
    final codeDropdown =
        buildDropdown(languageList, language!, Icons.code, (val) {
      if (val == null) return;
      setState(() => language = val);
    });
    final themeDropdown =
        buildDropdown(themeList, theme!, Icons.color_lens, (val) {
      if (val == null) return;
      setState(() => theme = val);
    });
    final resetButton = TextButton.icon(
      icon: const Icon(Icons.delete, color: Colors.white),
      label: const Text('Reset', style: TextStyle(color: Colors.white)),
      onPressed: () {
        setState(() {
          reset = !reset!;
        });
      },
    );

    final buttons = Container(
      height: MediaQuery.of(context).size.height / 13,
      color: Colors.deepPurple[900],
      child: Row(
        children: [
          const Spacer(flex: 2),
          const Text(
            'Code Editor by Akvelon',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
          const Spacer(flex: 35),
          codeDropdown,
          const Spacer(),
          themeDropdown,
          const Spacer(),
          resetButton,
        ],
      ),
    );

    final codeField = InnerField(
      key: ValueKey('$language - $theme - $reset'),
      language: language!,
      theme: theme!,
    );

    return Column(
      children: [
        buttons,
        codeField,
      ],
    );
  }
}

class InnerField extends StatefulWidget {
  final String language;
  final String theme;

  const InnerField({
    super.key,
    required this.language,
    required this.theme,
  });

  @override
  State<InnerField> createState() => _InnerFieldState();
}

class _InnerFieldState extends State<InnerField> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      language: allLanguages[widget.language],
      text: '''
class MyClass {
\tvoid readOnlyMethod() {// [START section1]
\t}// [END section1]
\t// [START section2]
\tvoid method() {
\t}// [END section2]
}
''',
      namedSectionParser: const BracketsStartEndNamedSectionParser(),
      readOnlySectionNames: {'section1', 'nonexistent'},
    );
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = themes[widget.theme];

    return Container(
      color: theme?['root']?.backgroundColor,
      height: MediaQuery.of(context).size.height / 13 * 12,
      child: CodeTheme(
        data: CodeThemeData(styles: theme),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: CodeField(
                controller: _codeController!,
                textStyle: const TextStyle(fontFamily: 'SourceCode'),
                lineNumberStyle: const LineNumberStyle(
                  textStyle: TextStyle(
                    fontFamily: 'Tahoma', // Ignored
                    color: Colors.purple,
                    fontSize: 30, // Ignored
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: FloatingActionButton(
                backgroundColor: Colors.indigo[800],
                onPressed: () {
                  setState(() {
                    _codeController!.text =
                        autoRefactor(_codeController!.text, widget.language);
                  });
                },
                child: const Icon(Icons.format_align_left_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
