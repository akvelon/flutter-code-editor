import 'package:equatable/equatable.dart';

import 'match.dart';

class SearchResult extends Equatable {
  const SearchResult({
    required this.matches,
  });

  final List<SearchMatch> matches;

  static const empty = SearchResult(
    matches: [],
  );

  @override
  List<Object?> get props => [matches];
}
