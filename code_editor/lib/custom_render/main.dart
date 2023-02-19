import 'package:example/custom_render/text_line.dart';
import 'package:example/snippets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:highlight/languages/dart.dart';
import 'package:highlight/languages/java.dart';

import 'rich_text_field.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final controller = CodeController(
    language: dart,
  );
  final focusNode = FocusNode();

  List<Widget> widgets = [];

  @override
  void initState() {
    controller.text = dartSnippet;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    controller.setLineTextSpans(context);
    focusNode.requestFocus();

    return MaterialApp(
      home: CodeTheme(
        data: CodeThemeData(styles: monokaiSublimeTheme),
        child: Builder(builder: (context) {
          return Focus(
            focusNode: focusNode,
            onKey: (node, event) {
              if (event.logicalKey == LogicalKeyboardKey.keyV &&
                  event.isMetaPressed) {
                final data = Clipboard.getData(Clipboard.kTextPlain)
                    .then((value) => controller.value = TextEditingValue(
                          text: controller.value.text + (value?.text ?? ''),
                        ));
              }
              if (event.logicalKey == LogicalKeyboardKey.enter) {
                controller.value = TextEditingValue(
                  text: controller.value.text + '\n',
                );
              }
              if (event.character != null) {
                controller.value = controller.value.copyWith(
                  text: controller.value.text + event.character!,
                );
              }
              return KeyEventResult.ignored;
            },
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                controller.setLineTextSpans(context);
                return Directionality(
                  textDirection: TextDirection.ltr,
                  child: CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return RichText(text: controller.lineTexts[index]);
                          },
                          childCount: controller.lineTexts.length,
                          addRepaintBoundaries: true,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }),
      ),
    );

    // return MaterialApp(
    //   home: SingleChildScrollView(
    //     child: Focus(
    //       focusNode: focusNode,
    //       onKey: (node, event) {
    //         if (event.logicalKey == LogicalKeyboardKey.keyV &&
    //             event.isMetaPressed) {
    //           final data = Clipboard.getData(Clipboard.kTextPlain)
    //               .then((value) => controller.value = TextEditingValue(
    //                     text: controller.value.text + (value?.text ?? ''),
    //                   ));
    //         }
    //         if (event.logicalKey == LogicalKeyboardKey.enter) {
    //           controller.value = TextEditingValue(
    //             text: controller.value.text + '\n',
    //           );
    //         }
    //         if (event.character != null) {
    //           controller.value = controller.value.copyWith(
    //             text: controller.value.text + event.character!,
    //           );
    //         }
    //         return KeyEventResult.ignored;
    //       },
    //       child: Container(
    //         decoration: BoxDecoration(
    //           border: Border.all(color: Colors.black),
    //         ),
    //         child: RichTextFieldV2(
    //           letterWidth: 10,
    //           lineHeight: 20,
    //           children: controller.lineTexts
    //               .map<Widget>(
    //                 (e) => AnimatedBuilder(
    //                   animation: controller,
    //                   builder: (context, child) => TextLine(content: e),
    //                 ),
    //               )
    //               .toList(),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
