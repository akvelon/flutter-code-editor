import 'package:collection/collection.dart';
import 'package:highlight/highlight_core.dart';

import 'keyword_semantics.dart';
import 'node_classes.dart';

extension MyNode on Node {
  int getValueNewlineCount() => '\n'.allMatches(value ?? '').length;

  /// The number of newline characters in this node's [value] and its
  /// descendants.
  int getNewlineCount() {
    int result = '\n'.allMatches(value ?? '').length;

    for (final child in children ?? const <Node>[]) {
      result += child.getNewlineCount();
    }

    return result;
  }

  /// The number of characters in this node's [value] ad its descendants.
  int getCharacterCount() {
    int result = value?.length ?? 0;

    for (final child in children ?? const <Node>[]) {
      result += child.getCharacterCount();
    }

    return result;
  }

  /// The [KeywordSemantics] for nodes with
  /// [className] == [NodeClasses.keyword], null for other nodes.
  ///
  /// There is no language information here, so this only works for
  /// selected languages. This is currently valid for:
  /// - Java
  ///
  /// It may give false positive or negative for other languages.
  KeywordSemantics? get keywordSemantics {
    if (className != NodeClasses.keyword) {
      return null;
    }

    switch (children?.firstOrNull?.value) {
      case 'import':
      case 'package':
        return KeywordSemantics.import;
    }

    return null;
  }

  List<Node> splitLines() {
    final splitValue = value?.split('\n');
    if (splitValue == null || (splitValue.length) <= 1) {
      return [copyWith(children: children?.splitLines())];
    }
    final result = <Node>[];
    for (int i = 0; i < splitValue.length; i++) {
      result.add(
        copyWith(
          value: splitValue[i] + (i == splitValue.length - 1 ? '' : '\n'),
          children: i == 0 ? children?.splitLines() : null,
        ),
      );
    }
    return result;
  }

  String toStringRecursive([int indent = 0]) {
    final sb = StringBuffer();
    sb.writeln(' ' * 2 * indent + toMapString());
    for (final child in children ?? const <Node>[]) {
      sb.write(child.toStringRecursive(indent + 1));
    }
    return sb.toString();
  }

  String toMapString() {
    final map = {
      'value': value == null ? null : '\'$value\'',
      'className': className,
      'children': children == null ? 'empty' : null,
    }..removeWhere((key, value) => value == null);
    return map.toString();
  }

  Node copyWith({
    String? className,
    String? value,
    bool? noPrefix,
    List<Node>? children,
  }) =>
      Node(
        className: className ?? this.className,
        value: value ?? this.value,
        noPrefix: noPrefix ?? this.noPrefix,
      )..children = children ?? this.children;
}

extension NodeListExtension on List<Node> {
  List<Node> splitLines() {
    return map((n) => n.splitLines()).expand((e) => e).toList(growable: false);
  }
}
