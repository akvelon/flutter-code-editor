class SearchNavigationState {
  final int? currentMatchIndex;
  final int totalMatchesCount;

  const SearchNavigationState({
    this.currentMatchIndex,
    required this.totalMatchesCount,
  });

  static const noMatches = SearchNavigationState(totalMatchesCount: 0);

  SearchNavigationState copyWith({
    int? currentMatchIndex,
    int? totalMatchesCount,
  }) {
    return SearchNavigationState(
      currentMatchIndex: currentMatchIndex ?? this.currentMatchIndex,
      totalMatchesCount: totalMatchesCount ?? this.totalMatchesCount,
    );
  }

  SearchNavigationState resetCurrentMatchIndex() {
    return SearchNavigationState(totalMatchesCount: totalMatchesCount);
  }
}
