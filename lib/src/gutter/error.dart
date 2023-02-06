import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../analyzer/api/models/issue.dart';
import 'clickable.dart';

const errorIcon = Icon(
  Icons.cancel,
  color: Colors.red,
  size: 16,
);

class GutterErrorWidget extends StatefulWidget {
  final Issue issue;
  final TextStyle popupTextStyle;

  const GutterErrorWidget(
    this.issue,
    this.popupTextStyle,
  );

  @override
  State<GutterErrorWidget> createState() => _GutterErrorWidgetState();
}

class _GutterErrorWidgetState extends State<GutterErrorWidget> {
  OverlayEntry? _entry;
  bool _mouseEnteredPopup = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _mouseEnteredPopup = false;
          if (_entry != null) {
            return;
          }
          _entry = _getErrorPopup();
          final overlay = Overlay.of(context);
          overlay.insert(_entry!);
        });
      },
      onExit: (event) {
        // Delay event here to keep overlay
        // if mouse has exited the icon and entered popup.
        Future.delayed(
          const Duration(milliseconds: 50),
          () {
            setState(() {
              if (!_mouseEnteredPopup) {
                _entry?.remove();
                _entry = null;
              }
            });
          },
        );
      },
      child: errorIcon,
    );
  }

  OverlayEntry _getErrorPopup() {
    final style = widget.popupTextStyle;
    final issue = widget.issue;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return OverlayEntry(builder: (context) => Container());
    }
    final width = renderBox.size.width;
    final offset = renderBox.localToGlobal(Offset.zero);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx + width,
          top: offset.dy,
          child: MouseRegion(
            onEnter: (event) => setState(() {
              _mouseEnteredPopup = true;
            }),
            onExit: (event) => setState(() {
              _mouseEnteredPopup = false;
              _entry?.remove();
              _entry = null;
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
                        color: style.color!,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          issue.message,
                        ),
                        if (issue.url != null) ...[
                          ClickableWidget(
                            child: Text(issue.url!),
                            onTap: () {
                              unawaited(launchUrlString(issue.url!));
                            },
                          ),
                        ],
                        if (issue.suggestion != null) ...[
                          Divider(
                            color: style.color,
                          ),
                          Text(issue.suggestion!),
                        ],
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
