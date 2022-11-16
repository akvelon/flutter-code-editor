import 'package:flutter/widgets.dart';
import 'package:highlight/highlight_core.dart';
import '/src/code/text_style.dart';

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
    TextStyle? parentStyle,
  }) {
    if (nodes == null) {
      return null;
    }

    return nodes
        .map(
          (node) => _buildNode(
            node: node,
            theme: theme,
            parentStyle: parentStyle,
          ),
        )
        .toList(growable: false);
  }

  TextSpan _buildNode({
    required Node node,
    required CodeThemeData? theme,
    TextStyle? parentStyle,
  }) {
    final style = theme?.styles[node.className];
    final paledStyle = _paleIfRequired(style, parentStyle);

    _updateLineIndex(node);

    return TextSpan(
      text: node.value,
      children: _buildList(
        nodes: node.children,
        theme: theme,
        parentStyle: style ?? parentStyle,
      ),
      style: paledStyle,
    );
  }

  void _updateLineIndex(Node node) {
    _visibleLineIndex += '\n'.allMatches(node.value ?? '').length;

    if (_visibleLineIndex >= code.lines.length) {
      _visibleLineIndex = code.lines.length - 1;
    }
  }

  TextStyle? _paleIfRequired(TextStyle? style, TextStyle? parentStyle) {
    final fullLineIndex =
        code.hiddenLineRanges.recoverLineIndex(_visibleLineIndex);
    if (code.lines[fullLineIndex].isReadOnly) {
      return (style ?? parentStyle ?? textStyle)?.paled();
    }
    return style;
  }
}
