import 'package:flutter_code_editor/src/search/match.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_code_editor/src/search/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  group('SearchSettingsController', () {
    testWidgets('Notification changes search result on CodeController',
        (wt) async {
      const text = 'AaBb';
      const examples = [
        //
        _Example(
          'Case Sensitive',
          settings: SearchSettings(
            isCaseSensitive: true,
            isRegExp: false,
            pattern: 'a',
          ),
          expectedResult: SearchResult(
            matches: [
              SearchMatch(start: 1, end: 2),
            ],
          ),
        ),

        _Example(
          'Case Insensitive',
          settings: SearchSettings(
            isCaseSensitive: false,
            isRegExp: false,
            pattern: 'a',
          ),
          expectedResult: SearchResult(
            matches: [
              SearchMatch(start: 0, end: 1),
              SearchMatch(start: 1, end: 2),
            ],
          ),
        ),
      ];

      final controller = await pumpController(wt, text);
      controller.showSearch();

      for (final example in examples) {
        controller.searchController.settingsController.value = example.settings;

        expect(
          controller.fullSearchResult,
          example.expectedResult,
          reason: example.name,
        );
      }
    });

    test('patternController change causes value to change', () {
      final settingsController = SearchSettingsController();

      expect(settingsController.value, SearchSettings.empty);

      settingsController.patternController.value = const TextEditingValue(
        text: 'a',
      );

      expect(
        settingsController.value,
        SearchSettings.empty.copyWith(pattern: 'a'),
      );
    });

    test('toggleCaseSensitivity()', () {
      final settingsController = SearchSettingsController();

      expect(settingsController.value.isCaseSensitive, false);
      expect(settingsController.value.pattern, '');
      expect(settingsController.value.isRegExp, false);

      settingsController.toggleCaseSensitivity();

      expect(settingsController.value.isCaseSensitive, true);
      expect(settingsController.value.pattern, '');
      expect(settingsController.value.isRegExp, false);

      settingsController.toggleCaseSensitivity();

      expect(settingsController.value.isCaseSensitive, false);
      expect(settingsController.value.pattern, '');
      expect(settingsController.value.isRegExp, false);
    });

    test('toggleIsRegExp()', () {
      final settingsController = SearchSettingsController();

      expect(settingsController.value.isRegExp, false);
      expect(settingsController.value.pattern, '');
      expect(settingsController.value.isCaseSensitive, false);

      settingsController.toggleIsRegExp();

      expect(settingsController.value.isRegExp, true);
      expect(settingsController.value.pattern, '');
      expect(settingsController.value.isCaseSensitive, false);

      settingsController.toggleIsRegExp();

      expect(settingsController.value.isRegExp, false);
      expect(settingsController.value.pattern, '');
      expect(settingsController.value.isCaseSensitive, false);
    });
  });
}

class _Example {
  final String name;
  final SearchSettings settings;
  final SearchResult expectedResult;

  const _Example(
    this.name, {
    required this.settings,
    required this.expectedResult,
  });
}
