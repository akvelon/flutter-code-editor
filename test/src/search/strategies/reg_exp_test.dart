import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_code_editor/src/search/strategies/regexp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegExpSearchStrategy', () {
    test('Case sensitive', () {
      const text = 'AaAa';
      const pattern = 'A+';
      const expectedResult = SearchResult(
        matches: [
          SearchMatch(start: 0, end: 1),
          SearchMatch(start: 2, end: 3),
        ],
      );

      final result = RegExpSearchStrategy().searchPlain(
        text,
        settings: const SearchSettings(
          isCaseSensitive: true,
          isRegExp: true,
          pattern: pattern,
        ),
      );

      expect(result, expectedResult);
    });

    test('Case insensitive', () {
      const text = 'AaAa';
      const pattern = 'A+';
      const expectedResult = SearchResult(
        matches: [
          SearchMatch(start: 0, end: 4),
        ],
      );

      final result = RegExpSearchStrategy().searchPlain(
        text,
        settings: const SearchSettings(
          isCaseSensitive: false,
          isRegExp: true,
          pattern: pattern,
        ),
      );

      expect(result, expectedResult);
    });

    test('Line start and end expressions work', () {
      const text = '__a^__\$a__\n__abc_\n';
      const pattern = r'^_+|_+$';
      const expectedResult = SearchResult(
        matches: [
          SearchMatch(start: 0, end: 2),
          SearchMatch(start: 8, end: 10),
          SearchMatch(start: 11, end: 13),
          SearchMatch(start: 16, end: 17),
        ],
      );

      final result = RegExpSearchStrategy().searchPlain(
        text,
        settings: const SearchSettings(
          isCaseSensitive: false,
          isRegExp: true,
          pattern: pattern,
        ),
      );

      expect(result, expectedResult);
    });

    test('Invalid RegExp -> empty result', () {
      const text = '[]';
      const pattern = '[';
      const expectedResult = SearchResult.empty;

      final result = RegExpSearchStrategy().searchPlain(
        text,
        settings: const SearchSettings(
          isCaseSensitive: false,
          isRegExp: true,
          pattern: pattern,
        ),
      );

      expect(result, expectedResult);
    });
  });
}
