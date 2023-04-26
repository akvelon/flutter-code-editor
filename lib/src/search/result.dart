import 'package:equatable/equatable.dart';

import 'match.dart';

class SearchResult extends Equatable {
  const SearchResult({
    required this.matches,
    this.currentMatchIndex = -1,
  });

  final List<SearchMatch> matches;
  final int currentMatchIndex;

  SearchMatch? get currentMatch =>
      currentMatchIndex >= 0 && currentMatchIndex < matches.length
          ? matches[currentMatchIndex]
          : null;

  static const empty = SearchResult(
    matches: [],
  );

  SearchResult copyWith({
    List<SearchMatch>? matches,
    int? currentMatchIndex,
  }) {
    return SearchResult(
      matches: matches ?? this.matches,
      currentMatchIndex: currentMatchIndex ?? this.currentMatchIndex,
    );
  }

  @override
  List<Object?> get props => [matches, currentMatchIndex];
}
