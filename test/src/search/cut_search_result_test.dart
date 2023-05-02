import 'package:flutter_code_editor/src/hidden_ranges/hidden_range.dart';
import 'package:flutter_code_editor/src/hidden_ranges/hidden_ranges.dart';
import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

void main() {
  test('cutSearchResult', () {
    final examples = [
      //
      _Example(
        'No hidden ranges',
        ranges: HiddenRanges(ranges: const [], textLength: 100),
        fullSearchResult: const SearchResult(
          matches: [
            SearchMatch(start: 20, end: 24),
          ],
        ),
        visibleSearchResult: const SearchResult(
          matches: [
            SearchMatch(start: 20, end: 24),
          ],
        ),
      ),

      _Example(
        'Hidden ranges before, after, and inbetween',
        ranges: HiddenRanges(
          ranges: const [
            HiddenRange(
              10,
              20,
              firstLine: 0,
              lastLine: 0,
              wholeFirstLine: false,
            ),
            HiddenRange(
              30,
              40,
              firstLine: 3,
              lastLine: 3,
              wholeFirstLine: false,
            ),
          ],
          textLength: 100,
        ),
        fullSearchResult: const SearchResult(
          matches: [
            SearchMatch(start: 0, end: 2),
            SearchMatch(start: 22, end: 24),
            SearchMatch(start: 42, end: 44),
          ],
        ),
        visibleSearchResult: const SearchResult(
          matches: [
            SearchMatch(start: 0, end: 2),
            SearchMatch(start: 22 - 10, end: 24 - 10),
            SearchMatch(start: 42 - 20, end: 44 - 20),
          ],
        ),
      ),
    ];

    for (final example in examples) {
      final result = example.ranges.cutSearchResult(example.fullSearchResult);

      expect(
        result,
        example.visibleSearchResult,
        reason: example.name,
      );
    }
  });
}

class _Example {
  final String name;
  final HiddenRanges ranges;
  final SearchResult fullSearchResult;
  final SearchResult visibleSearchResult;

  const _Example(
    this.name, {
    required this.ranges,
    required this.fullSearchResult,
    required this.visibleSearchResult,
  });
}
