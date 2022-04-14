import 'dart:convert';

import 'package:flutter/material.dart';

import 'autoRefactorService.dart';
import 'code_text_field.dart';
import 'constants/themes.dart';
import '/languages/all.dart';
import 'src/code_modifier.dart';

class CodeEditor extends StatefulWidget {
  final String language;
  final String theme;
  final Map<String, TextStyle>? patternMap;
  final Map<String, TextStyle>? stringMap;
  final EditorParams params;
  final List<CodeModifier> modifiers;
  final bool webSpaceFix;
  final void Function(String)? onChange;
  
  final int? minLines;
  final int? maxLines;
  final bool wrap;
  final LineNumberStyle lineNumberStyle;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
  final void Function(String)? onChanged;
  final Color? background;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextSelectionThemeData? textSelectionTheme;
  final FocusNode? focusNode;

  final String blocks;
  final String refactorSettings;

  final bool autoRefactoringButton;

  const CodeEditor({
    Key? key, 
    required this.language, 
    required this.theme,
    this.patternMap,
    this.stringMap,
    this.params = const EditorParams(),
    this.modifiers = const <CodeModifier>[
      const IntendModifier(),
      const CloseBlockModifier(),
      const TabModifier(),
    ],
    this.webSpaceFix = true,
    this.onChange,

    this.minLines,
    this.maxLines,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(),
    this.lineNumberStyle = const LineNumberStyle(),
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,

    required this.blocks,
    required this.refactorSettings,

    this.autoRefactoringButton = true
  })
    : super(key: key);

  @override
  CodeEditorState createState() => CodeEditorState();
}

class CodeEditorState extends State<CodeEditor> {
  List<CodeController?> codeControllers = [];
  List<int> numberOfLinesBeforeBlock = [];

  _changeNumber(){
    setState(() { 
      for (int i = 1; i <  codeControllers.length; i++) {
        int numberOfLinesPrevBlock =  codeControllers[i - 1]!.text.split('\n').length;
        numberOfLinesBeforeBlock[i] = numberOfLinesBeforeBlock[i-1] + numberOfLinesPrevBlock;
        codeControllers[i]!.stringsNumber = numberOfLinesBeforeBlock[i];
      }
      int maxNumber = codeControllers[codeControllers.length - 1]!.stringsNumber
                                        + codeControllers[codeControllers.length - 1]!.text.split('\n').length;
      codeControllers.forEach((element) {element!.maxNumber = maxNumber;});
    });
  }

  @override
  void initState() {
    super.initState();
    numberOfLinesBeforeBlock.add(0);
    Map<String, dynamic> blocks = jsonDecode(widget.blocks);
    List<dynamic> blockList = blocks['blocks'];
    for (int i = 0; i < blockList.length; i++) {
        codeControllers.add( CodeController(
        text: blockList[i]['text'].join('\n'),
        language: allLanguages[widget.language],
        theme: THEMES[widget.theme],
        stringsNumber: numberOfLinesBeforeBlock[i],
        enabled: blockList[i]['enabled']!.toLowerCase() == 'true',
        patternMap: widget.patternMap,
        stringMap: widget.stringMap,
        params: widget.params,
        modifiers: widget.modifiers,
        webSpaceFix: widget.webSpaceFix,
        onChange: widget.onChange,
      ));
      numberOfLinesBeforeBlock.add(numberOfLinesBeforeBlock[i] + codeControllers[i]!.text.split('\n').length);
      codeControllers[i]!.addListener(_changeNumber);
    }
  }

  @override
  void dispose() {
    for (int i = 0; i <  codeControllers.length; i++) {
      codeControllers[i]?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color? backgroundColor = widget.decoration == null ? (widget.background ?? 
                                      codeControllers[0]?.theme?['root']?.backgroundColor ?? Colors.grey.shade900) : null;

    Widget blockOfCode(int index){
      return Container(
        key: ValueKey("${numberOfLinesBeforeBlock[index]}"),
        child: CodeField(
          controller: codeControllers[index]!,
          textStyle: widget.textStyle,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          wrap: widget.wrap,
          background: backgroundColor,
          padding: widget.padding,
          lineNumberStyle: widget.lineNumberStyle,
          lineNumberBuilder: widget.lineNumberBuilder,
          cursorColor: widget.cursorColor,
          textSelectionTheme: widget.textSelectionTheme,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
        )
      );
    }

    return Stack(
      children: [
        Container( 
          color: backgroundColor,
          decoration: widget.decoration,
          padding: EdgeInsets.fromLTRB(15,15,0,15),
          child: Align(
            alignment: Alignment.topCenter,
            child: ListView.builder(
              shrinkWrap: true,
              reverse: true,
              itemCount: codeControllers.length,
              itemBuilder: (BuildContext context, int index){
                return blockOfCode(codeControllers.length - index - 1);
              }
            ),
          )
        ),
        Visibility(
          visible: widget.autoRefactoringButton,
          child: Align(
            alignment: Alignment.topRight,
            child: FloatingActionButton(
              child: const Icon(Icons.format_align_left_outlined),
              backgroundColor: Colors.indigo[800],
              onPressed: (){
                setState(() {
                  for (int i = 0; i <  codeControllers.length; i++) {
                    if (codeControllers[i]!.enabled) {
                      codeControllers[i]!.text = autoRefactor( codeControllers[i]!.text, 
                                                            widget.language, widget.refactorSettings);
                    }
                  }
                });
              }
            )
          )
        )
      ]
    );
  }
}
