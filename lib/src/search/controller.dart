import 'package:flutter/foundation.dart';

import '../code/code.dart';
import 'result.dart';
import 'settings.dart';
import 'strategies/abstract.dart';
import 'strategies/plain_case_insensitive.dart';
import 'strategies/plain_case_sensitive.dart';
import 'strategies/regexp.dart';

class SearchController extends ChangeNotifier {
  bool get isEnabled => _isEnabled;
  bool _isEnabled = false;
  set isEnabled(bool value) {
    _isEnabled = value;
    notifyListeners();
  }

  SearchResult search(Code code, {required SearchSettings settings}) {
    if (!isEnabled) {
      return SearchResult.empty;
    }

    if (settings.pattern.isEmpty) {
      return SearchResult.empty;
    }

    final strategy = getSearchStrategy(settings);
    final result = strategy.searchPlain(code.text, settings: settings);
    return result;
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
