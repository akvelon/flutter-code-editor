import 'package:flutter_code_editor/src/search/settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  group('SearchNavigationController', () {
    testWidgets(
        'Navigation to a match that is inside of a folded block '
        'unfolds the block', (wt) async {
      const text = '''
{
{
{
{
c
}
}
}
}''';
      final controller = await pumpController(wt, text);
      controller.foldAt(0);
      controller.foldAt(1);
      controller.foldAt(2);
      controller.foldAt(3);

      expect(controller.text, '{');

      controller.showSearch();

      controller.searchController.settingsController.value =
          const SearchSettings(
        isCaseSensitive: false,
        isRegExp: false,
        pattern: 'c',
      );

      expect(controller.text, text);
    });
  });
}
