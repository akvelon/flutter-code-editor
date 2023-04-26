import 'package:flutter/material.dart';

import '../search/result.dart';

const searchBackgroundColor = Color.fromARGB(141, 255, 235, 59);
const searchTextColor = Colors.black;

class SearchResultHighlightedBuilder {
  final SearchResult searchResult;
  final TextStyle? rootStyle;
  final TextSpan textSpan;

  SearchResultHighlightedBuilder({
    required this.searchResult,
    required this.rootStyle,
    required this.textSpan,
  }) {
    if (searchResult.matches.isEmpty) {
      return;
    }

    // searchResult.matches.sort((a, b) {
    //   return a.start - b.start;
    // });

    matchIndexes = searchResult.matches
        .expand<int>((e) => [e.start, e.end])
        .toList(growable: false);
  }

  /// List of spans to be added to the result.
  final _spans = <InlineSpan>[];

  /// Indexes of [searchResult] in ascending order.
  /// Every element under even index is the start,
  /// and every element under odd index is the end of the searchMatch.
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

  /// Overrides `TextStyle` of span to highlight search result.
  TextStyle get searchStyle =>
      _currentSpanStyle?.copyWith(
        backgroundColor: searchBackgroundColor,
        color: searchTextColor,
      ) ??
      const TextStyle(
        backgroundColor: searchBackgroundColor,
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
