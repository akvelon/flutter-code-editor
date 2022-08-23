import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:highlight/highlight_core.dart';

import '../code/text_range.dart';
import 'hidden_range.dart';

@immutable
class HiddenRanges {
  /// How many hidden characters are there before this range.
  /// Has the length of [ranges] + 1. The last element shows how many
  /// hidden characters are there in total.
  final List<int> hiddenCharactersBeforeRanges;

  final List<HiddenRange> ranges;
  final int textLength;

  factory HiddenRanges({
    required List<HiddenRange> ranges,
    required int textLength,
  }) {
    assert(
      _areSortedAndNotOverlapping(ranges),
      'Texts must be sorted and not overlap',
    );

    final nonEmptyRanges =
        ranges.where((r) => r.text != '').toList(growable: false);

    return HiddenRanges._(
      hiddenCharactersBeforeRanges: _getHiddenCharactersBeforeRanges(
        nonEmptyRanges,
      ),
      ranges: nonEmptyRanges,
      textLength: textLength,
    );
  }

  const HiddenRanges._({
    required this.hiddenCharactersBeforeRanges,
    required this.ranges,
    required this.textLength,
  });

  static const empty = HiddenRanges._(
    hiddenCharactersBeforeRanges: [0],
    ranges: [],
    textLength: 0,
  );

  static bool _areSortedAndNotOverlapping(List<HiddenRange> texts) {
    for (int i = texts.length; --i >= 1;) {
      if (!texts[i].isAfter(texts[i - 1])) {
        return false;
      }
    }

    return true;
  }

  static List<int> _getHiddenCharactersBeforeRanges(List<HiddenRange> ranges) {
    int sum = 0;
    final result = List.filled(ranges.length + 1, 0);

    for (int i = 1; i <= ranges.length; i++) {
      sum += ranges[i - 1].text.length;
      result[i] = sum;
    }

    return result;
  }

  /// Cuts the hidden ranges from [str].
  ///
  /// [str] is considered a substring of a full text, starting at [start].
  String cutString(String str, {required int start}) {
    if (ranges.isEmpty || str == '') {
      return str;
    }

    final end = start + str.length;
    final buffer = StringBuffer();

    // Skip the ranges that are too early.
    int rangeIndex = _getFirstRangeIndexThatCanOverlapWith(start);

    // The current position in a virtual full string we are cutting.
    int position = start;

    // In this loop, for each range add the content before its start.
    // Break in 2 cases:
    // 1. No more ranges.
    // 2. `str` has ended, all further ranges are after it.
    while (rangeIndex < ranges.length && position < end) {
      final range = ranges[rangeIndex];

      final substringEnd = min(range.start - start, str.length);
      if (substringEnd > 0) {
        buffer.write(str.substring(position - start, substringEnd));
      }
      position = range.end;
      rangeIndex++;
    }

    // Add the remainder of `str` after all the ranges were processed.
    if (position < end) {
      buffer.write(str.substring(position - start));
    }

    return buffer.toString();
  }

  /// Returns the index of the first range that can potentially overlap
  /// with a string that starts at [start]. It just skips ranges that end
  /// before [start].
  int _getFirstRangeIndexThatCanOverlapWith(int start) {
    int i = 0;

    for (; i < ranges.length; i++) {
      if (ranges[i].end > start) {
        return i;
      }
    }

    return i;
  }

  /// Cuts hidden ranges from [highlighted].
  Result cutHighlighted(Result highlighted) {
    int fullChar = 0;

    String? _cutString(String? nodeValue) {
      if (nodeValue == null) {
        return null;
      }

      final result = cutString(nodeValue, start: fullChar);
      fullChar += nodeValue.length;
      return result;
    }

    Node _cutHighlightedNode(Node node) {
      final value = _cutString(node.value);
      final children =
          node.children?.map(_cutHighlightedNode).toList(growable: false);

      return Node(
        className: node.className,
        value: value,
        children: children,
        noPrefix: node.noPrefix,
      );
    }

    final nodes =
        highlighted.nodes?.map(_cutHighlightedNode).toList(growable: false) ??
            const <Node>[];

    return Result(
      relevance: highlighted.relevance,
      nodes: nodes,
      language: highlighted.language,
      top: highlighted.top,
    );
  }

  /// Translates the [position] in the visible text to the position in
  /// the full text.
  ///
  /// If any hidden ranges are collapsed at this [position],
  /// [placeHiddenRanges] determines whether to put them before or after
  /// the cursor. Putting them after effectively ignores them.
  int recoverPosition(int position, {required TextAffinity placeHiddenRanges}) {
    if (ranges.isEmpty || position < ranges.first.start) {
      return position;
    }

    if (position > ranges.last.end - hiddenCharactersBeforeRanges.last) {
      return position + hiddenCharactersBeforeRanges.last;
    }

    int lowerRange = 0;
    int upperRange = ranges.length - 1;

    while (upperRange > lowerRange) {
      // Visible characters if the range collapse positions.
      final lowerChar =
          ranges[lowerRange].end - hiddenCharactersBeforeRanges[lowerRange + 1];
      final upperChar =
          ranges[upperRange].end - hiddenCharactersBeforeRanges[upperRange + 1];

      int rangeIndex = lowerRange +
          ((position - lowerChar) /
                  (upperChar - lowerChar) *
                  (upperRange - lowerRange))
              .floor();
      final range = ranges[rangeIndex];

      final collapsePosition =
          range.end - hiddenCharactersBeforeRanges[rangeIndex + 1];

      switch ((collapsePosition - position).sign) {
        case 0: // position is at the range collapse.
          switch (placeHiddenRanges) {
            case TextAffinity.downstream:
              // Find the first range collapsed at this point.
              while (rangeIndex > 0 &&
                  ranges[rangeIndex - 1].end == ranges[rangeIndex].start) {
                rangeIndex--;
              }
              return ranges[rangeIndex].start;
            case TextAffinity.upstream:
              // Find the last range collapsed at this point.
              while (rangeIndex < ranges.length - 1 &&
                  ranges[rangeIndex].end == ranges[rangeIndex + 1].start) {
                rangeIndex++;
              }
              return ranges[rangeIndex].end;
          }

        case -1: // position is after the range collapse
          lowerRange = rangeIndex + 1;
          final range = ranges[lowerRange];
          final collapsePosition =
              range.end - hiddenCharactersBeforeRanges[lowerRange + 1];
          if (collapsePosition > position) {
            return position + hiddenCharactersBeforeRanges[lowerRange];
          }
          break;

        case 1: // position is before the range
          upperRange = rangeIndex - 1;
          final range = ranges[upperRange];
          final collapsePosition =
              range.end - hiddenCharactersBeforeRanges[upperRange + 1];
          if (collapsePosition < position) {
            return position + hiddenCharactersBeforeRanges[upperRange + 1];
          }
          break;
      }
    }

    // There is only one range, and position is at its collapse.
    switch (placeHiddenRanges) {
      case TextAffinity.downstream:
        return ranges[0].start;
      case TextAffinity.upstream:
        return ranges[0].end;
    }
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(ranges),
        textLength,
      );

  @override
  bool operator ==(Object other) {
    return other is HiddenRanges &&
        textLength == other.textLength &&
        const ListEquality().equals(ranges, other.ranges);
  }
}
