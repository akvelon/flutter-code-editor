import 'package:flutter_code_editor/src/code_field/code_controller.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_code_editor/src/search/strategies/plain_case_insensitive.dart';
import 'package:flutter_code_editor/src/search/strategies/plain_case_sensitive.dart';
import 'package:flutter_code_editor/src/search/strategies/regexp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Get search strategy', () {
    const examples = <_Example>[
      //
      _Example(
        'PlainCaseInsensitiveSearchStrategy',
        // ignore: use_named_constants
        settings: SearchSettings(
          isCaseSensitive: false,
          isRegExp: false,
          pattern: '',
        ),
        strategyType: PlainCaseInsensitiveSearchStrategy,
      ),

      _Example(
        'PlainCaseInsensitiveSearchStrategy',
        settings: SearchSettings(
          isCaseSensitive: true,
          isRegExp: false,
          pattern: '',
        ),
        strategyType: PlainCaseSensitiveSearchStrategy,
      ),

      _Example(
        'PlainCaseInsensitiveSearchStrategy',
        settings: SearchSettings(
          isCaseSensitive: false,
          isRegExp: true,
          pattern: '',
        ),
        strategyType: RegExpSearchStrategy,
      ),
    ];

    for (final example in examples) {
      final codeController = CodeController();

      final result = codeController.searchController.getSearchStrategy(
        example.settings,
      );

      expect(
        result.runtimeType,
        example.strategyType,
        reason: example.name,
      );
    }
  });
}

class _Example {
  final String name;
  final SearchSettings settings;
  final Type strategyType;

  const _Example(
    this.name, {
    required this.settings,
    required this.strategyType,
  });
}
