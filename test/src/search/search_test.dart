import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('SearchController.search', () {
    final examples = <_Example>[
      //
      _Example(
        'Case Sensitive Search',
        settings: const SearchSettings(
          isCaseSensitive: true,
          isRegExp: false,
          pattern: 'A',
        ),
        code: Code(text: 'AaAa'),
        expected: const SearchResult(
          matches: [
            SearchMatch(start: 0, end: 1),
            SearchMatch(start: 2, end: 3),
          ],
        ),
      ),
    ];

    for (final example in examples) {
      final codeController = CodeController();
      codeController.searchController.showSearch();
      final result = codeController.searchController.search(
        example.code,
        settings: example.settings,
      );

      expect(
        result,
        example.expected,
        reason: example.name,
      );
    }
  });
}

class _Example {
  final String name;
  final SearchSettings settings;
  final Code code;
  final SearchResult expected;

  const _Example(
    this.name, {
    required this.settings,
    required this.code,
    required this.expected,
  });
}
