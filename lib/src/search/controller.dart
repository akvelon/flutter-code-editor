import 'package:flutter/foundation.dart';

import '../code/code.dart';
import 'result.dart';
import 'settings.dart';
import 'strategies/abstract.dart';
import 'strategies/plain_case_insensitive.dart';
import 'strategies/plain_case_sensitive.dart';
import 'strategies/regexp.dart';

/// Controller that is responsible for enabling the search
/// and generating search results when requested.
/// Notifies the listeners only when enabled / disabled.
class SearchController extends ChangeNotifier {
  // TODO(yescorp): Move this to a better place.
  //  https://github.com/akvelon/flutter-code-editor/issues/234
  bool get isEnabled => _isEnabled;
  bool _isEnabled = false;

  void enableSearch() {
    if (isEnabled == true) {
      return;
    }

    _isEnabled = true;
    notifyListeners();
  }

  void disableSearch() {
    if (isEnabled == false) {
      return;
    }

    _isEnabled = false;
    notifyListeners();
  }

  SearchResult search(Code code, {required SearchSettings settings}) {
    if (!_isEnabled) {
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
