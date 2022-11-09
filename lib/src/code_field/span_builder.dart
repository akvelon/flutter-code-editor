import 'package:flutter/widgets.dart';
import 'package:highlight/highlight_core.dart';

import '../../src/highlight/node.dart';
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
        nodes: code.visibleHighlighted?.nodes?.splitNewLines() ?? [],
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
        .map(
          (node) => _buildNode(
            node: node,
            theme: theme,
          ),
        )
        .toList(growable: false);
  }

  TextSpan _buildNode({
    required Node node,
    required CodeThemeData? theme,
  }) {
    final style = theme?.styles[node.className];

    _updatePositionIndexes(node);

    return TextSpan(
      text: node.value,
      children: _buildList(
        nodes: node.children,
        theme: theme,
      ),
      style: _applyReadonlyIfRequired(style),
    );
  }

  void _updatePositionIndexes(Node node) {
    int getNodeIndex() => code.lines.lines[_lineIndex].text
        .indexOf(node.value!.trim(), _characterIndex);

    bool isLineIndexInRange() => _lineIndex < code.lines.lines.length;

    if (node.value != null && node.value != '' && isLineIndexInRange()) {
      final nodeIndex = getNodeIndex();
      if (nodeIndex >= 0) {
        _characterIndex = nodeIndex;
      } else {
        _characterIndex = 0;
        var nodeIndex = -1;
        while (nodeIndex < 0) {
          if (_lineIndex < code.lines.lines.length - 1) {
            _lineIndex++;
          }
          nodeIndex = getNodeIndex();
          if (nodeIndex >= 0) {
            _characterIndex = nodeIndex;
          }
        }
      }
    }
  }

  TextStyle? _applyReadonlyIfRequired(TextStyle? style) {
    if (code.lines.lines[_lineIndex].isReadOnly) {
      if (style == null) {
        return textStyle?.paled();
      } else {
        return style.paled();
      }
    }
    return style;
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
