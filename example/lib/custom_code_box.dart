import 'package:flutter/material.dart';

import 'package:code_text_field/code_editor.dart';
import 'package:code_text_field/constants/constants.dart';

class CustomCodeBox extends StatefulWidget {
  final String language;
  final String theme;
  final String blocks;
  final String refactorSettings;

  const CustomCodeBox({Key? key, required this.language, required this.theme, 
                                                              required this.blocks, required this.refactorSettings})
      : super(key: key);

  @override
  _CustomCodeBoxState createState() => _CustomCodeBoxState();
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
    java,
    go,
    python,
    scala,
    dart
  ];

  List<String?> themeList  = <String>[
    "monokai-sublime",
    "a11y-dark",
    "an-old-hope",
    "vs2015",
    "vs",
    "atom-one-dark"
  ];

  Widget buildDropdown(Iterable<String?> choices, String value, IconData icon,
      Function(String?) onChanged) {
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
      icon: Icon(Icons.delete, color: Colors.white), 
      label: Text('Reset', style: TextStyle(color: Colors.white)),
      onPressed: () {
        setState(() {
          reset = (!reset!);
        });
      }, 
    );

    Widget codeField(String blocks, String refactorSettings) => CodeEditor(
      key: ValueKey("$language - $theme - $reset"),
      language: language!,
      theme: theme!,
      blocks: blocks,
      refactorSettings: refactorSettings,
      autoRefactoringButton: true,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[900],
        title: Text('Code editor', style: TextStyle(color: Colors.white)),
        actions: [
          codeDropdown,
          SizedBox(width: MediaQuery.of(context).size.width/60),
          themeDropdown,
          resetButton
        ],
      ),
      body: codeField(widget.blocks, widget.refactorSettings),
    );
  }
}
