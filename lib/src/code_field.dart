import 'dart:async';
import 'dart:math';


import 'package:code_text_field/src/autocomplete/popup.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '/constants/constants.dart';
import '/language_syntax/brackets_counting.dart';
import '/language_syntax/golang_syntax.dart';
import '/language_syntax/java_dart_syntax.dart';
import '/language_syntax/python_syntax.dart';
import '/language_syntax/scala_syntax.dart';
import 'code_controller.dart';

const double LINE_NUMBER_WIDTH = 42;
const TextAlign LINE_NUMBER_ALIGN = TextAlign.right;
const double LINE_NUMBER_MARGIN = 5;
const double TEXT_FIELD_MARGIN = 16;
const double BOTTOM_PADDING = 200;

class TooltipTextSpan extends WidgetSpan {
  TooltipTextSpan({
    required String message,
    required String number,
    required TextStyle? style,
  }) : super(
          child: Tooltip(
            message: message,
            child: Container(
              padding: const EdgeInsets.only(right: LINE_NUMBER_MARGIN),
              decoration: const BoxDecoration(
<<<<<<< HEAD
                color: Colors.red,
                borderRadius: BorderRadius.all(Radius.circular(4))
              ),
=======
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
>>>>>>> ebab93d91dca3c601128e6729b4038dd6d5117f1
              width: LINE_NUMBER_WIDTH,
              child: Text(
                number,
                textAlign: LINE_NUMBER_ALIGN,
                style: style,
              ),
            ),
          ),
        );
}

Map<int, String> getErrorsMap(String text, String language) {
  Map<int, String> errors = <int, String>{};
  errors.addAll(countingBrackets(text));
  switch (language) {
    case java:
    case dart:
      {
        errors.addAll(findJavaDartErrors(text));
        break;
      }
    case go:
      {
        errors.addAll(findGolangErrors(text));
        break;
      }
    case python:
      {
        errors.addAll(findPythonErrorTabs(text));
        break;
      }
    case scala:
      {
        errors.addAll(findScalaErrors(text));
        break;
      }
  }
  return errors;
}

class LineNumberController extends TextEditingController {
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
  String language;
  String codeFieldText;

  LineNumberController(
      this.lineNumberBuilder, this.language, this.codeFieldText);

  @override
  TextSpan buildTextSpan(
      {required BuildContext context, TextStyle? style, bool? withComposing}) {
    final List<InlineSpan> children = <InlineSpan>[];
    final List<String> list = text.split('\n');
    Map<int, String> errors = getErrorsMap(codeFieldText, language);
    for (int k = 0; k < list.length; k++) {
      final String el = list[k];
      final int number = int.parse(el);
      TextSpan textSpan = TextSpan(text: el, style: style);

      if (lineNumberBuilder != null) {
        textSpan = lineNumberBuilder!(number, style);
      }

      if (errors.containsKey(number)) {
        children.add(TooltipTextSpan(
            message: errors[number]!, number: el, style: style));
      } else {
        children.add(textSpan);
        if (k < list.length - 1) children.add(const TextSpan(text: '\n'));
      }
    }
    children.add(const TextSpan(text: '\n '));
    return TextSpan(children: children);
  }
}

class LineNumberStyle {
  /// Style of the numbers
  final TextStyle? textStyle;

  /// Background of the line number column
  final Color? background;

  const LineNumberStyle({
    this.textStyle,
    this.background,
  });
}

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
  late TextStyle? textStyle;

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
  final bool spaceAfterLastLine;

  final double defaultFontSize = 16.0;

  CodeField({
    Key? key,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(),
    this.lineNumberStyle = const LineNumberStyle(),
    this.enabled,
    this.readOnly = false,
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,
    this.spaceAfterLastLine = true,
  }) : super(key: key);

  @override
  CodeFieldState createState() => CodeFieldState();
}

class CodeFieldState extends State<CodeField> {
// Add a controller
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  ScrollController? _horizontalCodeScroll;
  LineNumberController? _numberController;
  GlobalKey _editingFieldKey = GlobalKey();
  GlobalKey _popupKey = GlobalKey();
  ScrollController _generalScroll = ScrollController();
  PopupAlign _popupAlign = PopupAlign.top;

  double cursorX = 0.0;
  double cursorY = 0.0;
  double painterWidth = 0.0;
  double painterHeight = 0.0;

  StreamSubscription<bool>? _keyboardVisibilitySubscription;
  FocusNode? _focusNode;
  String? lines;
  String longestLine = '';
<<<<<<< HEAD
  late Size windowSize;
=======
>>>>>>> ebab93d91dca3c601128e6729b4038dd6d5117f1

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _numberScroll = _controllers?.addAndGet();
    _codeScroll = _controllers?.addAndGet();
    _numberController = LineNumberController(widget.lineNumberBuilder,
        widget.controller.language!.nameOfLanguage, widget.controller.text);
    widget.controller.addListener(_onTextChanged);
    widget.controller.addListener(() {
      _updateCursorOffset(widget.controller.text);
    });
    _horizontalCodeScroll = ScrollController(initialScrollOffset: 0.0);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.attach(context, onKey: _onKey);
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
    setState(() {});
  }

  void _onTextChanged() {
    // Rebuild line number
    final List<String> str = widget.controller.text.split('\n');
    final List<String> buf = <String>[];
    for (int k = 0; k < str.length; k++) {
      buf.add((k + 1).toString());
    }
    _numberController?.text = buf.join('\n');
    _numberController?.codeFieldText = widget.controller.text;
    // Find longest line
    longestLine = '';
    widget.controller.text.split('\n').forEach((String line) {
      if (line.length > longestLine.length) longestLine = line;
    });
    rebuild();
  }

// Wrap the codeField in a horizontal scrollView
  Widget _wrapInScrollView(
      Widget codeField, TextStyle textStyle, double minWidth) {
    final double leftPad = LINE_NUMBER_MARGIN;
    final IntrinsicWidth intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0.0,
              minWidth: max(minWidth - leftPad, 0.0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
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
    const String ROOT_KEY = 'root';
    final Color defaultBg = Colors.grey.shade900;
    final Color defaultText = Colors.grey.shade200;

    final Map<String, TextStyle>? theme = widget.controller.theme;
    Color? backgroundCol =
        widget.background ?? theme?[ROOT_KEY]?.backgroundColor ?? defaultBg;
    if (widget.decoration != null) {
      backgroundCol = null;
    }
    TextStyle textStyle = widget.textStyle ?? const TextStyle();
    textStyle = textStyle.copyWith(
      color: textStyle.color ?? theme?[ROOT_KEY]?.color ?? defaultText,
      fontSize: textStyle.fontSize ?? this.widget.defaultFontSize,
    );
    this.widget.textStyle = textStyle;
<<<<<<< HEAD
    TextStyle numberTextStyle = widget.lineNumberStyle.textStyle ?? const TextStyle();
=======
    TextStyle numberTextStyle =
        widget.lineNumberStyle.textStyle ?? const TextStyle();
>>>>>>> ebab93d91dca3c601128e6729b4038dd6d5117f1
    final Color numberColor =
        (theme?[ROOT_KEY]?.color ?? defaultText).withOpacity(0.7);
    // Copy important attributes
    numberTextStyle = numberTextStyle.copyWith(
      color: numberTextStyle.color ?? numberColor,
      fontSize: textStyle.fontSize,
      fontFamily: textStyle.fontFamily,
    );
    final Color cursorColor =
        widget.cursorColor ?? theme?[ROOT_KEY]?.color ?? defaultText;

    final TextField lineNumberCol = TextField(
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
        contentPadding: EdgeInsets.symmetric(vertical: TEXT_FIELD_MARGIN),
        disabledBorder: InputBorder.none,
      ),
      textAlign: LINE_NUMBER_ALIGN,
    );

    final Container numberCol = Container(
      width: LINE_NUMBER_WIDTH,
      padding: EdgeInsets.only(
        left: widget.padding.left,
        right: LINE_NUMBER_MARGIN,
      ),
      color: widget.lineNumberStyle.background,
      child: lineNumberCol,
    );

    final TextField codeField = TextField(
<<<<<<< HEAD
=======
      key: _editingFieldKey,
>>>>>>> ebab93d91dca3c601128e6729b4038dd6d5117f1
      focusNode: _focusNode,
      scrollPadding: widget.padding,
      style: textStyle,
      controller: widget.controller,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      scrollController: _codeScroll,
      expands: widget.expands,
      decoration: const InputDecoration(
        isCollapsed: true,
        contentPadding: EdgeInsets.symmetric(vertical: TEXT_FIELD_MARGIN),
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

    final Theme editingField = Theme(
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
<<<<<<< HEAD
    return Container(
      decoration: widget.decoration,
      color: backgroundCol,
      key: _codeFieldKey,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          numberCol,
          Expanded(
            child: Stack(
              children: <Widget>[
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
=======

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        child: SingleChildScrollView(
          controller: _generalScroll,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    bottom: widget.spaceAfterLastLine ? BOTTOM_PADDING : 0.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    numberCol,
                    Expanded(
                      child: editingField,
                    ),
                  ],
                ),
              ),
              widget.controller.popupController.isPopupShown
                  ? Popup(
                      key: _popupKey,
                      verticalIndent: cursorY,
                      align: _popupAlign,
                      leftIndent: cursorX,
                      controller: widget.controller.popupController,
                      editingWindowSize: Size(
                          constraints.maxWidth - LINE_NUMBER_WIDTH,
                          _generalScroll.position.viewportDimension),
                      style: textStyle,
                      backgroundColor: backgroundCol,
                      parentFocusNode: _focusNode!,
                    )
                  : Container(),
            ],
>>>>>>> ebab93d91dca3c601128e6729b4038dd6d5117f1
          ),
        ),
      );
    });
  }

  void _updateCursorOffset(String text) {
    TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text, style: widget.textStyle),
    );
    painter.layout();
    TextPosition cursorTextPosition = widget.controller.selection.base;
    Rect caretPrototype = const Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);
    Offset caretOffset =
        painter.getOffsetForCaret(cursorTextPosition, caretPrototype);
    double caretHeight = (widget.controller.selection.base.offset > 0)
        ? painter.getFullHeightForCaret(cursorTextPosition, caretPrototype)!
        : 0;

    setState(() {
      cursorX = max(
          caretOffset.dx +
              LINE_NUMBER_WIDTH +
              widget.padding.left +
              LINE_NUMBER_MARGIN / 2 -
              _horizontalCodeScroll!.offset,
          0);
      cursorY =
          max(calculateVerticalPopupOffset(caretOffset.dy, caretHeight), 0);
      painterWidth = painter.width;
      painterHeight = painter.height;
    });
  }

  double calculateVerticalPopupOffset(double caretOffset, double caretHeight) {
    double popupHeight = _popupKey.currentContext?.size?.height ?? 100;
    double? windowHeight = _generalScroll.position.viewportDimension;
    double? editingFieldHeight = _editingFieldKey.currentContext!.size!.height;
    double rawOffset = caretOffset +
        TEXT_FIELD_MARGIN +
        widget.padding.top -
        _codeScroll!.offset;
    if (rawOffset - _generalScroll.offset + popupHeight + caretHeight >
        windowHeight) {
      _popupAlign = PopupAlign.bottom;
      return editingFieldHeight -
          rawOffset +
          TEXT_FIELD_MARGIN +
          BOTTOM_PADDING;
    }
    _popupAlign = PopupAlign.top;
    return rawOffset + caretHeight;
  }
}
