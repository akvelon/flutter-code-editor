import 'match.dart';
import 'result.dart';

extension KMP on String {
  /// Performs search on `this` by using Knuth-Morris-Pratt algorithm.
  /// https://en.wikipedia.org/wiki/Knuth%E2%80%93Morris%E2%80%93Pratt_algorithm
  SearchResult kmpSearch(
    String searchPattern, {
    required bool isCaseSensitive,
  }) {
    final str = isCaseSensitive ? this : toLowerCase();
    final pattern =
        isCaseSensitive ? searchPattern : searchPattern.toLowerCase();

    int strPos = 0;
    int ptrPos = 0;
    final matches = <SearchMatch>[];
    final table = _buildKmpTable(pattern);

    while (strPos < str.length) {
      if (pattern[ptrPos] == str[strPos]) {
        strPos++;
        ptrPos++;
        if (ptrPos == pattern.length) {
          matches.add(SearchMatch(start: strPos - ptrPos, end: strPos));
          // Reset the position to 0 to start searching the next match.
          ptrPos = 0;
        }
      } else {
        ptrPos = table[ptrPos];
        if (ptrPos < 0) {
          strPos++;
          ptrPos++;
        }
      }
    }

    return SearchResult(matches: matches);
  }
}

List<int> _buildKmpTable(String pattern) {
  final table = List<int>.generate(pattern.length + 1, (index) => -1);

  int pos = 1;
  int cnd = 0;

  while (pos < pattern.length) {
    if (pattern[pos] == pattern[cnd]) {
      table[pos] = table[cnd];
    } else {
      table[pos] = cnd;
      while (cnd >= 0 && pattern[pos] != pattern[cnd]) {
        cnd = table[cnd];
      }
    }
    pos++;
    cnd++;
  }

  table[pos] = cnd;

  return table;
}
