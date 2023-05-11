class SearchNavigationState {
  final int? currentMatchIndex;
  final int totalMatchCount;

  const SearchNavigationState({
    required this.totalMatchCount,
    this.currentMatchIndex,
  });

  static const noMatches = SearchNavigationState(totalMatchCount: 0);

  SearchNavigationState copyWith({
    int? currentMatchIndex,
    int? totalMatchCount,
  }) {
    return SearchNavigationState(
      currentMatchIndex: currentMatchIndex ?? this.currentMatchIndex,
      totalMatchCount: totalMatchCount ?? this.totalMatchCount,
    );
  }

  SearchNavigationState resetCurrentMatchIndex(int? totalMatchCount) {
    return SearchNavigationState(
      totalMatchCount: totalMatchCount ?? this.totalMatchCount,
    );
  }
}
