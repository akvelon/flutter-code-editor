import 'package:flutter/foundation.dart';

import '../code/code.dart';
import 'result.dart';
import 'settings.dart';
import 'strategies/abstract.dart';

class SearchController extends ChangeNotifier {
  bool _isEnabled = false;

  SearchResult search(Code code, {required SearchSettings settings}) {
    if (!_isEnabled) {
      return SearchResult.empty;
    }

    final strategy = getSearchStrategy(settings);
    final result = strategy.searchPlain(code.text, settings: settings);
    return _filterResult(result);
  }

  @visibleForTesting
  SearchStrategy getSearchStrategy(SearchSettings settings) {

  }
}
