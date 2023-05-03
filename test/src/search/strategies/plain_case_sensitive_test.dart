import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_code_editor/src/search/strategies/plain_case_sensitive.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlainCaseSensitiveSearchStrategy', () {
    test('PlainCaseSensitiveSearchStrategy', () {
      const text = 'Aa';
      const pattern = 'a';
      const expectedResult = SearchResult(
        matches: [
          SearchMatch(start: 1, end: 2),
        ],
      );

      final result = PlainCaseSensitiveSearchStrategy().searchPlain(
        text,
        settings: const SearchSettings(
          isCaseSensitive: true,
          isRegExp: false,
          pattern: pattern,
        ),
      );

      expect(result, expectedResult);
    });
  });
}
