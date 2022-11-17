import 'package:flutter/widgets.dart';
import 'package:highlight/highlight_core.dart';

import '../code/code.dart';
import '../code/text_style.dart';
import '../code_theme/code_theme_data.dart';
import '../highlight/node.dart';

class SpanBuilder {
  final Code code;
  final CodeThemeData? theme;
  final TextStyle? rootStyle;

  int _visibleLineIndex = 0;

  SpanBuilder({
    required this.code,
    required this.theme,
    this.rootStyle,
  });

  TextSpan build() {
    _visibleLineIndex = 0;
    return TextSpan(
      style: rootStyle,
      children: _buildList(
        nodes: code.visibleHighlighted?.nodes ?? [],
        theme: theme,
        ancestorStyle: rootStyle
      ),
    );
  }

  List<TextSpan>? _buildList({
    required List<Node>? nodes,
    required CodeThemeData? theme,
    TextStyle? ancestorStyle,
  }) {
    if (nodes == null) {
      return null;
    }

    return nodes
        .map(
          (node) => _buildNode(
            node: node,
            theme: theme,
            ancestorStyle: ancestorStyle,
          ),
        )
        .toList(growable: false);
  }

  TextSpan _buildNode({
    required Node node,
    required CodeThemeData? theme,
    TextStyle? ancestorStyle,
  }) {
    final style = theme?.styles[node.className] ?? ancestorStyle;
    final processedStyle = _paleIfRequired(style);

    _updateLineIndex(node);

    return TextSpan(
      text: node.value,
      children: _buildList(
        nodes: node.children,
        theme: theme,
        ancestorStyle: style,
      ),
      style: processedStyle,
    );
  }

  void _updateLineIndex(Node node) {
    _visibleLineIndex += node.getValueNewlineCount();

    if (_visibleLineIndex >= code.lines.length) {
      _visibleLineIndex = code.lines.length - 1;
    }
  }

  TextStyle? _paleIfRequired(TextStyle? style) {
    final fullLineIndex =
        code.hiddenLineRanges.recoverLineIndex(_visibleLineIndex);
    if (code.lines[fullLineIndex].isReadOnly) {
      return style?.paled();
    }
    return style;
  }
}
