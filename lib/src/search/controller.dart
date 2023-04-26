import 'package:flutter/foundation.dart';

import '../code/code.dart';
import 'match.dart';
import 'result.dart';
import 'settings.dart';
import 'strategies/abstract.dart';
import 'strategies/plain_case_insensitive.dart';
import 'strategies/plain_case_sensitive.dart';
import 'strategies/regexp.dart';

class SearchController extends ChangeNotifier {
  SearchResult get result => _result;
  SearchResult _result = SearchResult.empty;
  set result(SearchResult value) {
    if (_result == value) {
      return;
    }

    _result = value;
    notifyListeners();
  }

  String lastSearchedText = '';
  SearchSettings? lastSearchSettings;

  void moveNextMatch() {
    if (result.matches.isEmpty) {
      return;
    }

    if (result.currentMatchIndex == result.matches.length - 1) {
      result = result.copyWith(currentMatchIndex: 0);
      return;
    }

    result = result.copyWith(currentMatchIndex: result.currentMatchIndex + 1);
  }

  void movePreviousMatch() {
    if (result.matches.isEmpty) {
      return;
    }

    if (result.currentMatchIndex == 0) {
      result = result.copyWith(currentMatchIndex: result.matches.length - 1);
      return;
    }

    result = result.copyWith(currentMatchIndex: result.currentMatchIndex - 1);
  }

  SearchResult search(Code code, {required SearchSettings settings}) {
    if (lastSearchedText == code.text &&
        lastSearchSettings == settings &&
        result.matches.isNotEmpty) {
      return result;
    }

    if (!settings.isEnabled) {
      return result = SearchResult.empty;
    }

    if (settings.pattern.isEmpty) {
      return result = SearchResult.empty;
    }

    lastSearchedText = code.text;
    lastSearchSettings = settings;
    final strategy = getSearchStrategy(settings);

    return result = strategy.searchPlain(code.text, settings: settings);
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
