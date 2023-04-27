import 'package:flutter/material.dart';

import '../search/match.dart';
import '../search/result.dart';
import '../search/search_navigation_state.dart';

const searchBackgroundColor = Color.fromARGB(141, 255, 235, 59);
const searchTextColor = Colors.black;
const currentMatchBackgroundColor = Colors.yellow;

class SearchResultHighlightedBuilder {
  final SearchResult searchResult;
  final TextStyle? rootStyle;
  final TextSpan textSpan;
  late final int highlightedMatchIndex;

  SearchResultHighlightedBuilder({
    required this.searchResult,
    required this.rootStyle,
    required this.textSpan,
    required SearchNavigationState searchNavigationState,
  }) : highlightedMatchIndex = searchNavigationState.currentMatchIndex * 2 + 1 {
    if (searchResult.matches.isEmpty) {
      return;
    }

    searchResult.matches.sort(_searchMatchStartAscendingComparator);

    matchIndexes = searchResult.matches
        .expand<int>((e) => [e.start, e.end])
        .toList(growable: false);
  }

  /// List of spans to be added to the result.
  final _spans = <InlineSpan>[];

  /// Indexes of [searchResult] in ascending order.
  /// Every element under even index is the start,
  /// and every element under odd index is the end of the searchMatch.
  ///
  /// SearchMatches are grouped this way and look like this: 0-1 2-3 4-5
  late final List<int> matchIndexes;

  /// Current index of [matchIndexes] that is being processed.
  int _currentMatchIndex = 0;

  /// Whether the text before [_currentMatchIndex]
  /// should have search or regular style.
  bool get _isCurrentMatchIndexSearch => _currentMatchIndex.isOdd;

  /// Whether we finished to process all of the search matches.
  bool get _isLastMatchProcessed => _currentMatchIndex >= matchIndexes.length;

  /// Number of characters that are already processed.
  /// Or the current position in the text that we are about to process.
  int _currentWindowStart = 0;

  /// `TextStyle` of current span that is being processed.
  TextStyle? _currentSpanStyle;

  /// Returns the background color either for regular match,
  /// or currently highlighted match.
  Color get searchMatchBackgroundColor =>
      highlightedMatchIndex == _currentMatchIndex
          ? currentMatchBackgroundColor
          : searchBackgroundColor;

  /// Overrides `TextStyle` of span to highlight search result.
  TextStyle get searchStyle =>
      _currentSpanStyle?.copyWith(
        backgroundColor: searchMatchBackgroundColor,
        color: searchTextColor,
      ) ??
      TextStyle(
        backgroundColor: searchMatchBackgroundColor,
        color: searchTextColor,
      );

  /// Get actual style based on
  /// whether the current processing index is inside search or not.
  TextStyle? get _actualStyle =>
      _isCurrentMatchIndexSearch ? searchStyle : _currentSpanStyle;

  TextSpan build() {
    if (searchResult.matches.isEmpty) {
      return textSpan;
    }

    textSpan.visitChildren((span) {
      final currentText = (span as TextSpan).text;
      if (currentText == null || currentText.isEmpty) {
        return true;
      }
      _currentSpanStyle = span.style;

      _processText(currentText);

      return true;
    });

    return TextSpan(
      children: _spans,
      style: rootStyle,
    );
  }

  /// Recursively processes the text and adds TextSpans
  /// with proper styling to the [_spans]
  ///
  /// Slices the text according to the [_currentMatchIndex] and applies styling.
  /// Then advances the [_currentWindowStart] and [_currentMatchIndex].
  ///
  /// If all of the matches are prcoessed,
  /// adds the whole text to the [_spans] with regular styling.
  void _processText(String text) {
    if (_isLastMatchProcessed) {
      _spans.add(
        TextSpan(
          text: text,
          style: _currentSpanStyle,
        ),
      );
      return;
    }

    final sliceIndex = matchIndexes[_currentMatchIndex] - _currentWindowStart;

    if (sliceIndex >= 0 && sliceIndex <= text.length) {
      _spans.add(
        TextSpan(
          text: text.substring(0, sliceIndex),
          style: _actualStyle,
        ),
      );
      _currentWindowStart = matchIndexes[_currentMatchIndex];
      _currentMatchIndex++;
      if (sliceIndex == text.length) {
        return;
      }

      final textAfter = text.substring(sliceIndex, text.length);
      if (textAfter.isNotEmpty) {
        _processText(textAfter);
      }
    } else {
      _spans.add(
        TextSpan(
          text: text,
          style: _actualStyle,
        ),
      );
      _currentWindowStart += text.length;
    }
  }
}

int _searchMatchStartAscendingComparator(
    SearchMatch first, SearchMatch second) {
  return first.start - second.start;
}
