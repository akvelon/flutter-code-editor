class SearchSettings {
  const SearchSettings({
    required this.isCaseSensitive,
    required this.isRegExp,
    required this.pattern,
  });

  final bool isCaseSensitive;
  final bool isRegExp;
  final String pattern;

  static const empty = SearchSettings(
    isCaseSensitive: false,
    isRegExp: false,
    pattern: '',
  );
}
