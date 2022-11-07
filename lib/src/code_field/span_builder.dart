import 'package:flutter/widgets.dart';
import 'package:highlight/highlight_core.dart';

import '../code/code.dart';
import '../code_theme/code_theme_data.dart';

class SpanBuilder {
  final Code code;
  final CodeThemeData? theme;
  final TextStyle? textStyle;

  int _lineIndex = 0;
  int _characterIndex = 0;

  SpanBuilder({
    required this.code,
    required this.theme,
    this.textStyle,
  });

  TextSpan build() {
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
    required TextStyle? parentStyle,
  }) {
    final baseStyle = theme?.styles[node.className];

    final fixedStyle = _applyStyleChanges(node, baseStyle, parentStyle);

    return TextSpan(
      text: node.value,
      children: _buildList(
        nodes: node.children,
        theme: theme,
        parentStyle: baseStyle,
      ),
      style: fixedStyle,
    );
  }

  TextStyle? _applyStyleChanges(
    Node node,
    TextStyle? style,
    TextStyle? parentStyle,
  ) {
    int getNodeIndex() => code.lines.lines[_lineIndex].text
        .indexOf(node.value!.trim(), _characterIndex);

    bool isLineIndexInRange() => _lineIndex < code.lines.lines.length;

    if (node.value != null && node.value != '' && isLineIndexInRange()) {
      final nodeIndex = getNodeIndex();
      if (nodeIndex >= 0) {
        _characterIndex = nodeIndex;
        return _applyReadonlyIfRequired(style, parentStyle);
      } else {
        _characterIndex = 0;
        var nodeIndex = -1;
        while (nodeIndex < 0) {
          _lineIndex++;
          if (!isLineIndexInRange()) {
            break;
          }
          nodeIndex = getNodeIndex();
          if (nodeIndex >= 0) {
            _characterIndex = nodeIndex;
            return _applyReadonlyIfRequired(style, parentStyle);
          }
        }
      }
    }

    return style;
  }

  TextStyle? _applyReadonlyIfRequired(
    TextStyle? style,
    TextStyle? parentStyle,
  ) {
    TextStyle? result;
    if (code.lines.lines[_lineIndex].isReadOnly) {
      if (style == null) {
        if (parentStyle == null) {
          result = textStyle?.paled();
        } else {
          result = parentStyle.paled();
        }
      } else {
        result = style.paled();
      }
    }
    return result;
  }
}

extension TextStyleExtension on TextStyle {
  TextStyle paled() {
    return copyWith(
      color: Color.fromARGB(
        color!.alpha ~/ 2,
        color!.red,
        color!.green,
        color!.blue,
      ),
    );
  }
}
