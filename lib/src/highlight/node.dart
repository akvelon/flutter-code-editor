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
}
