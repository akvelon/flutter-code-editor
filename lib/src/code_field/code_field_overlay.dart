import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../../flutter_code_editor.dart';
import '../sizes.dart';
import '../wip/autocomplete/popup.dart';
import '../wip/autocomplete/popup_controller.dart';
import 'default_styles.dart';

class CodeFieldOverlay extends StatefulWidget {
  final CodeField child;
  late final CodeController controller;

  CodeFieldOverlay({
    super.key,
    required this.child,
  }) {
    controller = child.controller;
  }

  @override
  State<CodeFieldOverlay> createState() => _CodeFieldOverlayState();
}

class _CodeFieldOverlayState extends State<CodeFieldOverlay> {
  late TextStyle textStyle;
  OverlayEntry? _suggestionsPopup;
  Offset _normalPopupOffset = Offset.zero;
  Offset _flippedPopupOffset = Offset.zero;
  Offset? _editorOffset;
  Size? windowSize;
  Color _backgroundCol = Colors.black;

  @override
  void initState() {
    widget.controller.addListener(_onTextChanged);
    widget.controller.addListener(_updatePopupOffset);
    widget.controller.popupController.addListener(_onPopupStateChanged);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const rootKey = 'root';

    final themeData = Theme.of(context);
    final styles = CodeTheme.of(context)?.styles;
    _backgroundCol =
        styles?[rootKey]?.backgroundColor ?? DefaultStyles.backgroundColor;

    final defaultTextStyle = TextStyle(
      color: styles?[rootKey]?.color ?? DefaultStyles.textColor,
      fontSize: themeData.textTheme.titleMedium?.fontSize,
    );

    textStyle = defaultTextStyle.merge(widget.child.textStyle);

    return widget.child;
  }

  void _updatePopupOffset() {
    final textPainter = _getTextPainter(widget.controller.text);
    final caretHeight = _getCaretHeight(textPainter);

    final leftOffset = _getPopupLeftOffset(textPainter);
    final normalTopOffset = _getPopupTopOffset(textPainter, caretHeight);
    final flippedTopOffset = normalTopOffset -
        (Sizes.autocompletePopupMaxHeight + caretHeight + Sizes.caretPadding);

    setState(() {
      _normalPopupOffset = Offset(leftOffset, normalTopOffset);
      _flippedPopupOffset = Offset(leftOffset, flippedTopOffset);
    });
  }

  TextPainter _getTextPainter(String text) {
    return TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text, style: textStyle),
    )..layout();
  }

  Offset _getCaretOffset(TextPainter textPainter) {
    return textPainter.getOffsetForCaret(
      widget.controller.selection.base,
      Rect.zero,
    );
  }

  double _getCaretHeight(TextPainter textPainter) {
    final double? caretFullHeight = textPainter.getFullHeightForCaret(
      widget.controller.selection.base,
      Rect.zero,
    );
    return (widget.controller.selection.base.offset > 0) ? caretFullHeight! : 0;
  }

  double _getPopupLeftOffset(TextPainter textPainter) {
    return max(
      _getCaretOffset(textPainter).dx +
          widget.child.padding.left -
          (_editorOffset?.dx ?? 0),
      0,
    );
  }

  double _getPopupTopOffset(TextPainter textPainter, double caretHeight) {
    return max(
      _getCaretOffset(textPainter).dy +
          caretHeight +
          16 +
          widget.child.padding.top -
          (_editorOffset?.dy ?? 0),
      0,
    );
  }

  void _onPopupStateChanged() {
    final shouldShow =
        widget.controller.popupController.shouldShow && windowSize != null;
    if (!shouldShow) {
      _suggestionsPopup?.remove();
      _suggestionsPopup = null;
      return;
    }

    if (_suggestionsPopup == null) {
      _suggestionsPopup = _buildSuggestionOverlay();
      Overlay.of(context).insert(_suggestionsPopup!);
    }

    _suggestionsPopup!.markNeedsBuild();
  }

  OverlayEntry _buildSuggestionOverlay() {
    return OverlayEntry(
      builder: (context) {
        return Popup(
          normalOffset: _normalPopupOffset,
          flippedOffset: _flippedPopupOffset,
          controller: widget.controller.popupController,
          editingWindowSize: windowSize!,
          style: textStyle,
          backgroundColor: Colors.black,
          parentFocusNode: widget.child.focusNode!,
          editorOffset: _editorOffset,
        );
      },
    );
  }

  void _onTextChanged() {
    final box = context.findRenderObject() as RenderBox?;
    _editorOffset = box?.localToGlobal(Offset.zero);

    rebuild();
  }

  void rebuild() {
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final double width = context.size!.width;
        final double height = context.size!.height;
        windowSize = Size(width, height);
      });
    });
  }
}
