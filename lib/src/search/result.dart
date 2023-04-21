import 'match.dart';

class SearchResult {
  const SearchResult({
    required this.matches,
  });

  final List<SearchMatch> matches;

  static const empty = SearchResult(
    matches: [],
  );
}
