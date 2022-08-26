import 'package:flutter/widgets.dart';
import 'package:highlight/highlight_core.dart';

import '../code/code.dart';
import '../code_theme/code_theme_data.dart';

class SpanBuilder {
  const SpanBuilder();

  TextSpan build({
    required Code code,
    required CodeThemeData? theme,
    TextStyle? textStyle,
  }) {
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
    return TextSpan(
      text: node.value,
      children: _buildList(nodes: node.children, theme: theme),
      style: theme?.styles[node.className],
    );
  }
}
