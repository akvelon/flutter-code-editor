import 'package:highlight/highlight_core.dart';

import 'node.dart';

extension MyResult on Result {
  void forEachNode(
    void Function(Node node, int lineIndex, int characterIndex) callback,
  ) {
    int lineIndex = 0;
    int characterIndex = 0;

    void walk(List<Node> nodes) {
      for (final node in nodes) {
        callback(node, lineIndex, characterIndex);

        lineIndex += node.getValueNewlineCount();
        characterIndex += node.value?.length ?? 0;

        if (node.children != null) {
          walk(node.children!);
        }
      }
    }

    if (nodes != null) {
      walk(nodes!);
    }
  }

  void forEachTopLevelNode(
    void Function(Node node, int lineIndex, int characterIndex) callback,
  ) {
    int lineIndex = 0;
    int characterIndex = 0;

    for (final node in nodes ?? const <Node>[]) {
      callback(node, lineIndex, characterIndex);

      lineIndex += node.getNewlineCount();
      characterIndex += node.getCharacterCount();
    }
  }

  Result splitLines() {
    return copyWith(
      nodes: nodes?.splitLines(),
    );
  }

  Result copyWith({
    int? relevance,
    List<Node>? nodes,
    String? language,
    Mode? top,
    Result? secondBest,
  }) {
    return Result(
      relevance: relevance ?? this.relevance,
      nodes: nodes ?? this.nodes,
      language: language ?? this.language,
      top: top ?? this.top,
      secondBest: secondBest ?? this.secondBest,
    );
  }
}
