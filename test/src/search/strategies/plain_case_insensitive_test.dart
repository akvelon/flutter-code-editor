import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_code_editor/src/search/strategies/plain_case_insensitive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlainCaseInsensitiveSearchStrategy', () {
    test('PlainCaseInsensitiveSearchStrategy', () {
      const text = 'Aa';
      const pattern = 'a';
      const expectedResult = SearchResult(
        matches: [
          SearchMatch(start: 0, end: 1),
          SearchMatch(start: 1, end: 2),
        ],
      );

      final result = PlainCaseInsensitiveSearchStrategy().searchPlain(
        text,
        settings: const SearchSettings(
          isCaseSensitive: false,
          isRegExp: false,
          pattern: pattern,
        ),
      );

      expect(result, expectedResult);
    });
  });
}
