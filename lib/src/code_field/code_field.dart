import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../code_theme/code_theme.dart';
import '../line_numbers/line_number_controller.dart';
import '../line_numbers/line_number_style.dart';
import '../wip/autocomplete/popup.dart';
import 'code_controller.dart';

const double _lineNumberWidth = 42;
const TextAlign _lineNumberAlign = TextAlign.right;
const double _lineNumberMargin = 5;

class CodeField extends StatefulWidget {
  /// {@macro flutter.widgets.textField.minLines}
  final int? minLines;

  /// {@macro flutter.widgets.textField.maxLInes}
  final int? maxLines;

  /// {@macro flutter.widgets.textField.expands}
  final bool expands;

  /// Whether overflowing lines should wrap around or make the field scrollable horizontally
  final bool wrap;

  /// A CodeController instance to apply language highlight, themeing and modifiers
  final CodeController controller;

  /// A LineNumberStyle instance to tweak the line number column styling
  final LineNumberStyle lineNumberStyle;

  /// {@macro flutter.widgets.textField.cursorColor}
  final Color? cursorColor;

  /// {@macro flutter.widgets.textField.textStyle}
  final TextStyle? textStyle;

  /// A way to replace specific line numbers by a custom TextSpan
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;

  /// {@macro flutter.widgets.textField.enabled}
  final bool? enabled;

  /// {@macro flutter.widgets.editableText.onChanged}
  final void Function(String)? onChanged;

  /// {@macro flutter.widgets.editableText.readOnly}
  final bool readOnly;

  final Color? background;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextSelectionThemeData? textSelectionTheme;
  final FocusNode? focusNode;

  final double defaultFontSize = 16;

  const CodeField({
    Key? key,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    this.lineNumberStyle = const LineNumberStyle(),
    this.enabled,
    this.readOnly = false,
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,
  }) : super(key: key);

  @override
  CodeFieldState createState() => CodeFieldState();
}

// TODO: Make private in next breaking release.
class CodeFieldState extends State<CodeField> {
  // Add a controller
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  ScrollController? _horizontalCodeScroll;
  LineNumberController? _numberController;
  final _codeFieldKey = GlobalKey();

  double cursorX = 0;
  double cursorY = 0;
  double painterWidth = 0;
  double painterHeight = 0;

  //
  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  FocusNode? _focusNode;
  String? lines;
  String longestLine = '';
  late Size windowSize;
  late TextStyle textStyle;

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _numberScroll = _controllers?.addAndGet();
    _codeScroll = _controllers?.addAndGet();
    _numberController = LineNumberController(
      widget.lineNumberBuilder,
      widget.controller.language,
      widget.controller.text,
    );
    widget.controller.addListener(_onTextChanged);
    widget.controller.addListener(() {
      _updateCursorOffset(widget.controller.text);
    });
    _horizontalCodeScroll = ScrollController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.attach(context, onKey: _onKey);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      double width = _codeFieldKey.currentContext!.size!.width;
      double height = _codeFieldKey.currentContext!.size!.height;
      windowSize = Size(width - _lineNumberWidth, height);
    });
    _onTextChanged();
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    return widget.controller.onKey(event);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.controller.removeListener(() {
      _updateCursorOffset(widget.controller.text);
    });
    _numberScroll?.dispose();
    _codeScroll?.dispose();
    _horizontalCodeScroll?.dispose();
    _numberController?.dispose();
    _keyboardVisibilitySubscription?.cancel();
    super.dispose();
  }

  void rebuild() {
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        double width = _codeFieldKey.currentContext!.size!.width;
        double height = _codeFieldKey.currentContext!.size!.height;
        windowSize = Size(width - _lineNumberWidth, height);
      });
    });
  }

  void _onTextChanged() {
    // Rebuild line number
    final str = widget.controller.text.split('\n');
    final buf = <String>[];

    for (var k = 0; k < str.length; k++) {
      buf.add((k + 1).toString());
    }

    _numberController?.text = buf.join('\n');
    _numberController?.codeFieldText = widget.controller.text;

    // Find longest line
    longestLine = '';
    widget.controller.text.split('\n').forEach((line) {
      if (line.length > longestLine.length) longestLine = line;
    });

    rebuild();
  }

// Wrap the codeField in a horizontal scrollView
  Widget _wrapInScrollView(
    Widget codeField,
    TextStyle textStyle,
    double minWidth,
  ) {
    const leftPad = _lineNumberWidth;
    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0,
              minWidth: max(minWidth - leftPad, 0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(longestLine, style: textStyle),
            ), // Add extra padding
          ),
          widget.expands ? Expanded(child: codeField) : codeField,
        ],
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: leftPad,
        right: widget.padding.right,
      ),
      scrollDirection: Axis.horizontal,
      controller: _horizontalCodeScroll,
      child: intrinsic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default color scheme
    const rootKey = 'root';
    final defaultBg = Colors.grey.shade900;
    final defaultText = Colors.grey.shade200;

    final styles = CodeTheme.of(context)?.styles;
    Color? backgroundCol =
        widget.background ?? styles?[rootKey]?.backgroundColor ?? defaultBg;

    if (widget.decoration != null) {
      backgroundCol = null;
    }

    textStyle = widget.textStyle ?? const TextStyle();
    textStyle = textStyle.copyWith(
      color: textStyle.color ?? styles?[rootKey]?.color ?? defaultText,
      fontSize: textStyle.fontSize ?? widget.defaultFontSize,
    );

    TextStyle numberTextStyle =
        widget.lineNumberStyle.textStyle ?? const TextStyle();
    final numberColor =
        (styles?[rootKey]?.color ?? defaultText).withOpacity(0.7);

    // Copy important attributes
    numberTextStyle = numberTextStyle.copyWith(
      color: numberTextStyle.color ?? numberColor,
      fontSize: textStyle.fontSize,
      fontFamily: textStyle.fontFamily,
    );

    final cursorColor =
        widget.cursorColor ?? styles?[rootKey]?.color ?? defaultText;

    final lineNumberCol = TextField(
      scrollPadding: widget.padding,
      style: numberTextStyle,
      controller: _numberController,
      readOnly: true,
      enableInteractiveSelection: false,
      mouseCursor: SystemMouseCursors.basic,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      expands: widget.expands,
      scrollController: _numberScroll,
      decoration: const InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
        disabledBorder: InputBorder.none,
      ),
      textAlign: _lineNumberAlign,
    );

    final numberCol = Container(
      width: _lineNumberWidth,
      padding: EdgeInsets.only(
        left: widget.padding.left,
        right: _lineNumberMargin,
      ),
      color: widget.lineNumberStyle.background,
      child: lineNumberCol,
    );

    final codeField = TextField(
      focusNode: _focusNode,
      scrollPadding: widget.padding,
      style: textStyle,
      controller: widget.controller,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      expands: widget.expands,
      scrollController: _codeScroll,
      decoration: const InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
        disabledBorder: InputBorder.none,
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
      cursorColor: cursorColor,
      autocorrect: false,
      enableSuggestions: false,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      readOnly: widget.readOnly,
    );

    final editingField = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: widget.textSelectionTheme,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Control horizontal scrolling
          return _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
        },
      ),
    );

    return Container(
      decoration: widget.decoration,
      color: backgroundCol,
      key: _codeFieldKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          numberCol,
          Expanded(
            child: Stack(
              children: [
                editingField,
                widget.controller.popupController.isPopupShown
                    ? Popup(
                        row: cursorY,
                        column: cursorX,
                        controller: widget.controller.popupController,
                        editingWindowSize: windowSize,
                        style: textStyle,
                        backgroundColor: backgroundCol,
                        parentFocusNode: _focusNode!,
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateCursorOffset(String text) {
    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text, style: textStyle),
    )..layout();
    TextPosition cursorTextPosition = widget.controller.selection.base;
    Rect caretPrototype = Rect.zero;
    Offset caretOffset =
        painter.getOffsetForCaret(cursorTextPosition, caretPrototype);
    double caretHeight = (widget.controller.selection.base.offset > 0)
        ? painter.getFullHeightForCaret(cursorTextPosition, caretPrototype)!
        : 0;

    setState(() {
      cursorX = max(
          caretOffset.dx +
              widget.padding.left +
              _lineNumberMargin / 2 -
              _horizontalCodeScroll!.offset,
          0);
      cursorY = max(
          caretOffset.dy +
              caretHeight +
              16 +
              widget.padding.top -
              _codeScroll!.offset,
          0);
      painterWidth = painter.width;
      painterHeight = painter.height;
    });
  }
}
