import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../analyzer/api/models/issue.dart';
import '../code_theme/code_theme.dart';
import '../code_theme/code_theme_data.dart';

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
  OverlayEntry? entry;
  bool enteredPopup = false;
  bool showErrorDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = CodeTheme.of(context) ??
        CodeThemeData(
          styles: monokaiSublimeTheme,
        );
    final backgroundColor = theme.styles['root']?.backgroundColor;
    final color = theme.styles['root']?.color;
    final style = widget.style.copyWith(
      fontSize: 14,
      color: color,
      backgroundColor: backgroundColor,
      fontStyle: FontStyle.normal,
    );
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          showErrorDetails = true;
          enteredPopup = false;
          if (entry != null) {
            return;
          }
          entry = getErrorPopup(
            widget.issue,
            offset: event.position.translate(-5, -5),
            style: style,
          );
          final overlay = Overlay.of(context);
          overlay.insert(entry!);
          overlay.build(context);
        });
      },
      onExit: (event) {
        Future.delayed(
          const Duration(milliseconds: 50),
          () {
            setState(() {
              showErrorDetails = false;
              if (!enteredPopup) {
                entry?.remove();
                entry = null;
              }
            });
          },
        );
      },
      child: const Icon(
        Icons.cancel,
        color: Colors.red,
        size: 16,
      ),
    );
  }

  OverlayEntry getErrorPopup(
    Issue issue, {
    required Offset offset,
    required TextStyle style,
  }) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final width = renderBox?.size.width ?? 16;
    final newOffset = renderBox?.localToGlobal(Offset.zero) ?? offset;
    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: newOffset.dx + width,
          top: newOffset.dy,
          child: MouseRegion(
            onEnter: (event) => setState(() {
              enteredPopup = true;
            }),
            onExit: (event) => setState(() {
              entry?.remove();
              entry = null;
            }),
            child: DefaultTextStyle(
              style: style,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(
                      minWidth: 100,
                      maxWidth: 500,
                    ),
                    decoration: BoxDecoration(
                      color: style.backgroundColor,
                      border: Border.all(
                        color: style.color ??
                            const Color.fromARGB(107, 255, 255, 255),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          issue.message,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
