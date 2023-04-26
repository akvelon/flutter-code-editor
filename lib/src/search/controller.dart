import 'package:flutter/foundation.dart';

import '../code/code.dart';
import 'result.dart';
import 'settings.dart';
import 'strategies/abstract.dart';
import 'strategies/plain_case_insensitive.dart';
import 'strategies/plain_case_sensitive.dart';
import 'strategies/regexp.dart';

class SearchController extends ChangeNotifier {
  SearchResult search(Code code, {required SearchSettings settings}) {
    if (!settings.isEnabled) {
      return SearchResult.empty;
    }

    if (settings.pattern.isEmpty) {
      return SearchResult.empty;
    }

    final strategy = getSearchStrategy(settings);

    return strategy.searchPlain(code.text, settings: settings);
  }

  @visibleForTesting
  SearchStrategy getSearchStrategy(SearchSettings settings) {
    if (settings.isRegExp) {
      return RegExpSearchStrategy();
    }

    if (settings.isCaseSensitive) {
      return PlainCaseSensitiveSearchStrategy();
    }

    return PlainCaseInsensitiveSearchStrategy();
  }
}
