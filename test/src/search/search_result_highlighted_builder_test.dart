import 'package:flutter/material.dart';
import 'package:flutter_code_editor/src/code_field/search_result_highlighted_builder.dart';
import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/search_navigation_state.dart';
import 'package:flutter_test/flutter_test.dart';

const _default = TextStyle(color: Color(0xFF000000));
const _keyword = TextStyle(color: Color(0xFF000002));

void main() {
  group('SearchResultHighlightedBuilder', () {
    group('Without highlighted match', () {
      final examples = [
        //
        const _Example(
          'Empty search result',
          visibleSearchResult: SearchResult.empty,
          navigationState: SearchNavigationState.noMatches,
          visibleTextSpan: TextSpan(
            children: [
              TextSpan(text: 'Aa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
          expectedResult: TextSpan(
            children: [
              TextSpan(text: 'Aa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
        ),

        _Example(
          'Within 1 textSpan',
          visibleSearchResult: const SearchResult(
            matches: [
              SearchMatch(start: 0, end: 1),
            ],
          ),
          navigationState: const SearchNavigationState(totalMatchCount: 1),
          visibleTextSpan: const TextSpan(
            children: [
              TextSpan(text: 'Aa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
          expectedResult: TextSpan(
            style: _default,
            children: [
              TextSpan(
                text: 'A',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              const TextSpan(text: 'a', style: _default),
              const TextSpan(text: 'Bb', style: _keyword),
              const TextSpan(text: 'Cc', style: _keyword),
            ],
          ),
        ),

        _Example(
          '1 whole textSpan',
          visibleSearchResult: const SearchResult(
            matches: [
              SearchMatch(start: 0, end: 2),
            ],
          ),
          navigationState: const SearchNavigationState(totalMatchCount: 1),
          visibleTextSpan: const TextSpan(
            children: [
              TextSpan(text: 'Aa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
          expectedResult: TextSpan(
            style: _default,
            children: [
              TextSpan(
                text: 'Aa',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              const TextSpan(text: 'Bb', style: _keyword),
              const TextSpan(text: 'Cc', style: _keyword),
            ],
          ),
        ),

        _Example(
          'Within 2 textSpans',
          visibleSearchResult: const SearchResult(
            matches: [
              SearchMatch(start: 1, end: 3),
            ],
          ),
          navigationState: const SearchNavigationState(totalMatchCount: 1),
          visibleTextSpan: const TextSpan(
            children: [
              TextSpan(text: 'Aa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
          expectedResult: TextSpan(
            style: _default,
            children: [
              const TextSpan(
                text: 'A',
                style: _default,
              ),
              TextSpan(
                text: 'a',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              TextSpan(
                text: 'B',
                style: _keyword.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              const TextSpan(text: 'b', style: _keyword),
              const TextSpan(text: 'Cc', style: _keyword),
            ],
          ),
        ),

        _Example(
          '2 whole textSpans',
          visibleSearchResult: const SearchResult(
            matches: [
              SearchMatch(start: 0, end: 4),
            ],
          ),
          navigationState: const SearchNavigationState(totalMatchCount: 1),
          visibleTextSpan: const TextSpan(
            children: [
              TextSpan(text: 'Aa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
          expectedResult: TextSpan(
            style: _default,
            children: [
              TextSpan(
                text: 'Aa',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              TextSpan(
                text: 'Bb',
                style: _keyword.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              const TextSpan(text: 'Cc', style: _keyword),
            ],
          ),
        ),

        _Example(
          'Through 3 texpans',
          visibleSearchResult: const SearchResult(
            matches: [
              SearchMatch(start: 1, end: 5),
            ],
          ),
          navigationState: const SearchNavigationState(totalMatchCount: 1),
          visibleTextSpan: const TextSpan(
            children: [
              TextSpan(text: 'Aa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
          expectedResult: TextSpan(
            style: _default,
            children: [
              const TextSpan(
                text: 'A',
                style: _default,
              ),
              TextSpan(
                text: 'a',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              TextSpan(
                text: 'Bb',
                style: _keyword.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              TextSpan(
                text: 'C',
                style: _keyword.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              const TextSpan(text: 'c', style: _keyword),
            ],
          ),
        ),

        _Example(
          'Inside a textSpan',
          visibleSearchResult: const SearchResult(
            matches: [
              SearchMatch(start: 1, end: 2),
            ],
          ),
          navigationState: const SearchNavigationState(totalMatchCount: 1),
          visibleTextSpan: const TextSpan(
            children: [
              TextSpan(text: 'Aaa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
          expectedResult: TextSpan(
            style: _default,
            children: [
              const TextSpan(
                text: 'A',
                style: _default,
              ),
              TextSpan(
                text: 'a',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              const TextSpan(
                text: 'a',
                style: _default,
              ),
              const TextSpan(
                text: 'Bb',
                style: _keyword,
              ),
              const TextSpan(
                text: 'Cc',
                style: _keyword,
              ),
            ],
          ),
        ),

        _Example(
          'Several matches inside 1 text span',
          visibleSearchResult: const SearchResult(
            matches: [
              SearchMatch(start: 0, end: 1),
              SearchMatch(start: 1, end: 2),
              SearchMatch(start: 2, end: 3),
            ],
          ),
          navigationState: const SearchNavigationState(totalMatchCount: 3),
          visibleTextSpan: const TextSpan(
            children: [
              TextSpan(text: 'Aaaaa', style: _default),
            ],
          ),
          expectedResult: TextSpan(
            style: _default,
            children: [
              TextSpan(
                text: 'A',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              TextSpan(
                text: 'a',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              TextSpan(
                text: 'a',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              const TextSpan(text: 'aa', style: _default),
            ],
          ),
        ),
      ];

      for (final example in examples) {
        test(example.name, () {
          final result = SearchResultHighlightedBuilder(
            searchResult: example.visibleSearchResult,
            rootStyle: _default,
            textSpan: example.visibleTextSpan,
            searchNavigationState: example.navigationState,
          ).build();

          expect(result, example.expectedResult);
        });
      }
    });

    group('With highlighted result', () {
      final examples = [
        //
        _Example(
          'Highlighted match has brighter background',
          visibleSearchResult: const SearchResult(
            matches: [
              SearchMatch(start: 0, end: 1),
              SearchMatch(start: 1, end: 2),
            ],
          ),
          navigationState: const SearchNavigationState(
            currentMatchIndex: 1,
            totalMatchCount: 2,
          ),
          visibleTextSpan: const TextSpan(
            children: [
              TextSpan(text: 'Aa', style: _default),
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Bb',
                    style: _keyword,
                  ),
                  TextSpan(
                    text: 'Cc',
                    style: _keyword,
                  ),
                ],
              ),
            ],
          ),
          expectedResult: TextSpan(
            style: _default,
            children: [
              TextSpan(
                text: 'A',
                style: _default.copyWith(
                  backgroundColor: matchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              TextSpan(
                text: 'a',
                style: _default.copyWith(
                  backgroundColor: currentMatchBackgroundColor,
                  color: searchTextColor,
                ),
              ),
              const TextSpan(text: 'Bb', style: _keyword),
              const TextSpan(text: 'Cc', style: _keyword),
            ],
          ),
        ),
      ];

      for (final example in examples) {
        test(example.name, () {
          final result = SearchResultHighlightedBuilder(
            searchResult: example.visibleSearchResult,
            rootStyle: _default,
            textSpan: example.visibleTextSpan,
            searchNavigationState: example.navigationState,
          ).build();

          expect(result, example.expectedResult);
        });
      }
    });
  });
}

class _Example {
  final String name;
  final TextSpan visibleTextSpan;
  final SearchResult visibleSearchResult;
  final TextSpan expectedResult;
  final SearchNavigationState navigationState;

  const _Example(
    this.name, {
    required this.expectedResult,
    required this.visibleSearchResult,
    required this.visibleTextSpan,
    required this.navigationState,
  });
}
