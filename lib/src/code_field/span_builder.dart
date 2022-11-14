import 'package:flutter/widgets.dart';
import 'package:highlight/highlight_core.dart';

import '../../src/highlight/node.dart';
import '../code/code.dart';
import '../code_theme/code_theme_data.dart';

class SpanBuilder {
  final Code code;
  final CodeThemeData? theme;
  final TextStyle? textStyle;

  int _visibleLineIndex = 0;

  SpanBuilder({
    required this.code,
    required this.theme,
    this.textStyle,
  });

  TextSpan build() {
    _visibleLineIndex = 0;
    return TextSpan(
      style: textStyle,
      children: _buildList(
        nodes: code.visibleHighlighted?.nodes ?? [],
        theme: theme,
      ),
    );
  }

  List<TextSpan>? _buildList({
    required List<Node>? nodes,
    required CodeThemeData? theme,
  }) {
    if (nodes == null) {
      return null;
    }

    return nodes
        .map((node) => _buildNode(node: node, theme: theme))
        .toList(growable: false);
  }

  TextSpan _buildNode({
    required Node node,
    required CodeThemeData? theme,
  }) {
    _updateLineIndex(node);

    final style = theme?.styles[node.className];

    return TextSpan(
      text: node.value,
      children: _buildList(
        nodes: node.children,
        theme: theme,
      ),
      style: _paleIfRequired(style),
    );
  }

  void _updateLineIndex(Node node) {
    _visibleLineIndex += node.getNewlineCount();

    if (_visibleLineIndex >= code.lines.length) {
      _visibleLineIndex = code.lines.length - 1;
    }
  }

  TextStyle? _paleIfRequired(TextStyle? style) {
    final fullLineIndex =
        code.hiddenLineRanges.recoverLineIndex(_visibleLineIndex);
    if (code.lines[fullLineIndex].isReadOnly) {
      return (style ?? textStyle)?.paled();
    }
    return style;
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle paled() {
    final clr = color;

    if (clr == null) {
      return this;
    }

    return copyWith(
      color: Color.fromARGB(
        clr.alpha ~/ 2,
        clr.red,
        clr.green,
        clr.blue,
      ),
    );
  }
}
