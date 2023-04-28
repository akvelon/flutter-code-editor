import 'package:flutter_code_editor/src/code/code.dart';
import 'package:flutter_code_editor/src/search/controller.dart';
import 'package:flutter_code_editor/src/search/result.dart';
import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  test('SearchController enalbe/disable', () {
    final controller = SearchController();

    expect(controller.isEnabled, false);
    controller.enableSearch();
    expect(controller.isEnabled, true);
    controller.disableSearch();
    expect(controller.isEnabled, false);
  });

  test('Disabled SearchController returns empty result on search()', () {
    final controller = SearchController();

    final result = controller.search(
      Code(text: 'aaa'),
      settings: const SearchSettings(
        isCaseSensitive: false,
        isRegExp: false,
        pattern: 'a',
      ),
    );

    expect(result, SearchResult.empty);
  });
}
