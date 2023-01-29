import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/src/code_theme/code_theme.dart';
import 'package:flutter_code_editor/src/code_theme/code_theme_data.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../analyzer/api/models/issue.dart';

class GutterErrorWidget extends StatefulWidget {
  final Issue issue;
  final TextStyle style;

  const GutterErrorWidget(
    this.issue, {
    required this.style,
  });

  @override
  State<GutterErrorWidget> createState() => _GutterErrorWidgetState();
}

class _GutterErrorWidgetState extends State<GutterErrorWidget> {
  Offset? mouseEnter;
  OverlayEntry? entry;

  @override
  Widget build(BuildContext context) {
    final theme = CodeTheme.of(context) ??
        CodeThemeData(
          styles: monokaiSublimeTheme,
        );
    final backgroundColor = theme.styles['root']?.backgroundColor;
    final color = theme.styles['root']?.color;
    final style = widget.style.copyWith(
      fontSize: 16,
      color: color,
      backgroundColor: backgroundColor,
      fontStyle: FontStyle.normal,
    );
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          mouseEnter = event.position;
          final overlay = Overlay.of(context);
          final temp = OverlayEntry(
            builder: (context) {
              return Positioned(
                left: mouseEnter?.dx,
                top: mouseEnter?.dy,
                child: DefaultTextStyle(
                  style: style,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        constraints: const BoxConstraints(
                          minWidth: 100,
                          maxWidth: 500,
                        ),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          border: Border.all(
                            color: color ??
                                const Color.fromARGB(107, 255, 255, 255),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.issue.message,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          overlay.insert(temp);
          overlay.build(context);
          entry = temp;
        });
      },
      onExit: (event) {
        setState(() {
          mouseEnter = null;
          entry?.remove();
        });
      },
      child: const Icon(
        Icons.cancel,
        color: Colors.red,
        size: 16,
      ),
    );
  }
}
