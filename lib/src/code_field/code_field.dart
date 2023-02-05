import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../code_theme/code_theme.dart';
import '../gutter/gutter.dart';
import '../line_numbers/gutter_style.dart';
import '../sizes.dart';
import '../wip/autocomplete/popup.dart';
import 'actions/comment_uncomment.dart';
import 'actions/indent.dart';
import 'actions/outdent.dart';
import 'code_controller.dart';
import 'default_styles.dart';

final _shortcuts = <ShortcutActivator, Intent>{
  // Copy
  LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyC,
  ): CopySelectionTextIntent.copy,
  const SingleActivator(
    LogicalKeyboardKey.keyC,
    meta: true,
  ): CopySelectionTextIntent.copy,
  LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.insert,
  ): CopySelectionTextIntent.copy,

  // Cut
  LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyX,
  ): const CopySelectionTextIntent.cut(SelectionChangedCause.keyboard),
  const SingleActivator(
    LogicalKeyboardKey.keyX,
    meta: true,
  ): const CopySelectionTextIntent.cut(SelectionChangedCause.keyboard),
  LogicalKeySet(
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.delete,
  ): const CopySelectionTextIntent.cut(SelectionChangedCause.keyboard),

  // Undo
  LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyZ,
  ): const UndoTextIntent(SelectionChangedCause.keyboard),
  const SingleActivator(
    LogicalKeyboardKey.keyZ,
    meta: true,
  ): const UndoTextIntent(SelectionChangedCause.keyboard),

  // Redo
  LogicalKeySet(
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.keyZ,
  ): const RedoTextIntent(SelectionChangedCause.keyboard),
  LogicalKeySet(
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.keyZ,
  ): const RedoTextIntent(SelectionChangedCause.keyboard),

  // Indent
  LogicalKeySet(
    LogicalKeyboardKey.tab,
  ): const IndentIntent(),

  // Outdent
  LogicalKeySet(
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.tab,
  ): const OutdentIntent(),

  // Comment Uncomment
  LogicalKeySet(
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.slash,
  ): const CommentUncommentIntent(),
  const SingleActivator(
    LogicalKeyboardKey.slash,
    meta: true,
  ): const CommentUncommentIntent(),
};

class CodeField extends StatefulWidget {
  /// {@macro flutter.widgets.textField.minLines}
  final int? minLines;

  /// {@macro flutter.widgets.textField.maxLInes}
  final int? maxLines;

  /// {@macro flutter.widgets.textField.expands}
  final bool expands;

  /// Whether overflowing lines should wrap around
  /// or make the field scrollable horizontally.
  final bool wrap;

  /// A CodeController instance to apply
  /// language highlight, themeing and modifiers.
  final CodeController controller;

  @Deprecated('Use gutterStyle instead')
  final GutterStyle lineNumberStyle;

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

  @Deprecated('Use gutterStyle instead')
  final bool? lineNumbers;

  final GutterStyle gutterStyle;

  const CodeField({
    super.key,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    GutterStyle? gutterStyle,
    this.enabled,
    this.readOnly = false,
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,
    @Deprecated('Use gutterStyle instead') this.lineNumbers,
    @Deprecated('Use gutterStyle instead')
        this.lineNumberStyle = const GutterStyle(),
  })  : assert(
            gutterStyle == null || lineNumbers == null,
            'Can not provide gutterStyle and lineNumbers at the same time. '
            'Please use gutterStyle and provide necessary columns to show/hide'),
        gutterStyle = gutterStyle ??
            ((lineNumbers == false) ? GutterStyle.none : lineNumberStyle);

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  // Add a controller
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  ScrollController? _horizontalCodeScroll;
  final _codeFieldKey = GlobalKey();

  Offset _normalPopupOffset = Offset.zero;
  Offset _flippedPopupOffset = Offset.zero;
  double painterWidth = 0;
  double painterHeight = 0;

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

    widget.controller.addListener(_onTextChanged);
    widget.controller.addListener(_updatePopupOffset);
    _horizontalCodeScroll = ScrollController();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.attach(context, onKeyEvent: _onKeyEvent);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final double width = _codeFieldKey.currentContext!.size!.width;
      final double height = _codeFieldKey.currentContext!.size!.height;
      windowSize = Size(width, height);
    });
    _onTextChanged();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    return widget.controller.onKey(event);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.controller.removeListener(_updatePopupOffset);
    _numberScroll?.dispose();
    _codeScroll?.dispose();
    _horizontalCodeScroll?.dispose();
    unawaited(_keyboardVisibilitySubscription?.cancel());
    super.dispose();
  }

  void rebuild() {
    setState(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // For some reason _codeFieldKey.currentContext is null in tests
        // so check first.
        final context = _codeFieldKey.currentContext;
        if (context != null) {
          final double width = context.size!.width;
          final double height = context.size!.height;
          windowSize = Size(width, height);
        }
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
    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0,
              minWidth: minWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(longestLine, style: textStyle),
            ), // Add extra padding
          ),
          // ignore: prefer_if_elements_to_conditional_expressions
          widget.expands ? Expanded(child: codeField) : codeField,
        ],
      ),
    );

    return SingleChildScrollView(
      padding: EdgeInsets.only(
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

    final themeData = Theme.of(context);
    final styles = CodeTheme.of(context)?.styles;
    Color? backgroundCol = widget.background ??
        styles?[rootKey]?.backgroundColor ??
        DefaultStyles.backgroundColor;

    if (widget.decoration != null) {
      backgroundCol = null;
    }

    const paddingLeft = 8.0;

    final defaultTextStyle = TextStyle(
      color: styles?[rootKey]?.color ?? DefaultStyles.textColor,
      fontSize: themeData.textTheme.subtitle1?.fontSize,
    );

    textStyle = defaultTextStyle.merge(widget.textStyle);

    final lineNumberSize = textStyle.fontSize;
    final lineNumberColor =
        widget.gutterStyle.textStyle?.color ?? textStyle.color?.withOpacity(.5);

    final lineNumberTextStyle =
        (widget.gutterStyle.textStyle ?? textStyle).copyWith(
      color: lineNumberColor,
      fontFamily: textStyle.fontFamily,
      fontSize: lineNumberSize,
    );

    final gutterStyle = widget.gutterStyle.copyWith(
      textStyle: lineNumberTextStyle,
      errorPopupTextStyle: widget.gutterStyle.errorPopupTextStyle ??
          textStyle.copyWith(
            fontSize: DefaultStyles.errorPopupTextSize,
            backgroundColor: DefaultStyles.backgroundColor,
            fontStyle: DefaultStyles.fontStyle,
          ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {

        Widget? gutter;
        if (gutterStyle.showGutter) {
          final List<int> linesInParagraps;
          final codeLines = widget.controller.code.lines.lines;
          if (widget.wrap) {
            // get wrapped line count in each paragraph
            const textFieldPadding =
                paddingLeft + 3; // TODO(emuell): not sure why the 3 is needed!
            final codeFieldWidth = constraints.maxWidth.floorToDouble() -
                gutterStyle.totalWidth() -
                textFieldPadding;
            linesInParagraps = [];
            for (var i = 0; i < codeLines.length; ++i) {
              final codeLine = codeLines[i];
              // codelines contain an extra newline, except for the last line
              final text = (i == codeLines.length - 1)
                  ? codeLine.text
                  : codeLine.text.replaceAll('\n', '');
              // create painter with max width
              final TextPainter paragraphPainter =
                  _getTextPainter(text, codeFieldWidth);
              // compute paragraph's metrics to get number of line wraps
              final lineMetrics = paragraphPainter.computeLineMetrics();
              linesInParagraps.add(max(1, lineMetrics.length));
            }
          } else {
            // unrwapped editor's show one line per paragraph
            linesInParagraps = codeLines.map((_) => 1).toList();
          }
          gutter = GutterWidget(
            codeController: widget.controller,
            style: gutterStyle,
            linesInParagraps: linesInParagraps,
          );
        }

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
          cursorColor: widget.cursorColor ?? defaultTextStyle.color,
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
              // Control horizontal scrolling when not wrapping
              if (widget.wrap) {
                return codeField;
              } else {
                return _wrapInScrollView(
                      codeField,
                      textStyle,
                      constraints.maxWidth,
                    );
              }
            },
          ),
        );

        return FocusableActionDetector(
          actions: widget.controller.actions,
          shortcuts: _shortcuts,
          child: Container(
            decoration: widget.decoration,
            color: backgroundCol,
            key: _codeFieldKey,
            padding: const EdgeInsets.only(left: paddingLeft),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (gutter != null) gutter,
                Expanded(
                  child: Stack(
                    children: [
                      editingField,
                      if (widget.controller.popupController.isPopupShown)
                        Popup(
                          normalOffset: _normalPopupOffset,
                          flippedOffset: _flippedPopupOffset,
                          controller: widget.controller.popupController,
                          editingWindowSize: windowSize,
                          style: textStyle,
                          backgroundColor: backgroundCol,
                          parentFocusNode: _focusNode!,
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
  }

  void _updatePopupOffset() {
    final TextPainter textPainter =
        _getTextPainter(widget.controller.text, double.infinity);
    final caretHeight = _getCaretHeight(textPainter);

    final double leftOffset = _getPopupLeftOffset(textPainter);
    final double normalTopOffset = _getPopupTopOffset(textPainter, caretHeight);
    final double flippedTopOffset = normalTopOffset -
        (Sizes.autocompletePopupMaxHeight + caretHeight + Sizes.caretPadding);

    setState(() {
      _normalPopupOffset = Offset(leftOffset, normalTopOffset);
      _flippedPopupOffset = Offset(leftOffset, flippedTopOffset);
    });
  }

  TextPainter _getTextPainter(String text, double maxWidth) {
    return TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(text: text, style: textStyle),
    )..layout(maxWidth: maxWidth);
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
          widget.padding.left -
          (widget.wrap ? 0.0 : _horizontalCodeScroll!.offset),
      0,
    );
  }

  double _getPopupTopOffset(TextPainter textPainter, double caretHeight) {
    return max(
      _getCaretOffset(textPainter).dy +
          caretHeight +
          16 +
          widget.padding.top -
          _codeScroll!.offset,
      0,
    );
  }
}
