import 'package:flutter/material.dart';

class SearchNavigationState {
  final int currentMatchIndex;
  final int totalMatchesCount;

  SearchNavigationState({
    this.currentMatchIndex = -1,
    this.totalMatchesCount = 0,
  });

  SearchNavigationState copyWith({
    int? currentMatchIndex,
    int? totalMatchesCount,
  }) {
    return SearchNavigationState(
      currentMatchIndex: currentMatchIndex ?? this.currentMatchIndex,
      totalMatchesCount: totalMatchesCount ?? this.totalMatchesCount,
    );
  }
}
