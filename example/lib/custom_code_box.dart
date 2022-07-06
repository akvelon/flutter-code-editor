import 'package:flutter/material.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:code_text_field/src/wip/languages/all.dart';

import 'package:code_text_field/src/wip/autoRefactorService.dart';
import 'package:code_text_field/src/wip/constants/constants.dart';
import 'package:code_text_field/src/wip/constants/themes.dart';

class CustomCodeBox extends StatefulWidget {
  final String language;
  final String theme;

  const CustomCodeBox({Key? key, required this.language, required this.theme})
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

    final buttons = Container (
      height: MediaQuery.of(context).size.height/13,
      color: Colors.deepPurple[900],
      child: Row(
        children: [
        Spacer(flex: 2),
        Text('Code editor', style: TextStyle(fontSize: 28, color: Colors.white)),
        Spacer(flex: 35),
        codeDropdown,
        Spacer(),
        themeDropdown,
        Spacer(),
        resetButton
        ]
      )
    );
    final codeField = InnerField(
      key: ValueKey("$language - $theme - $reset"),
      language: language!,
      theme: theme!,
    );
    return Column(children: [
      buttons,
      codeField,
    ]);
  }
}

class InnerField extends StatefulWidget {
  final String language;
  final String theme;

  const InnerField({Key? key, required this.language, required this.theme})
      : super(key: key);

  @override
  _InnerFieldState createState() => _InnerFieldState();
}

class _InnerFieldState extends State<InnerField> {
  CodeController? _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      language: allLanguages[widget.language],
      theme: THEMES[widget.theme],
    );
  }

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      color: _codeController!.theme!['root']!.backgroundColor,
      height: MediaQuery.of(context).size.height / 13 * 12,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: CodeField(
              controller: _codeController!,
              textStyle: const TextStyle(fontFamily: 'SourceCode'),
            )
          ),
          Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
              child: const Icon(Icons.format_align_left_outlined),
              backgroundColor: Colors.indigo[800],
              onPressed: (){
                setState(() {
                  _codeController!.text = autoRefactor( _codeController!.text, widget.language);
                });
              }
            )
          )
        ]
      )
    );
  }
}
