import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import 'match.dart';
import 'result.dart';
import 'search_navigation_state.dart';

/// Controller that navigates through the [SearchResult].
///
/// Listens to the [CodeController] and
/// gets the actual [SearchResult] from there.
///
/// When [SearchResult] changes,
/// advances the [value] to the nearest match index.
/// Changes selection of [CodeController] along with [value]
/// to scroll the CodeField to the currentMatch.
///
/// When the text of a [CodeController] is changed with non-empty [SearchResult]
/// enters the editing mode where it doesn't advance the [value] to currentMatch
/// nor change the selection of the [CodeController].
class SearchNavigationController extends ValueNotifier<SearchNavigationState> {
  final CodeController codeController;

  SearchResult searchResult = SearchResult.empty;
  String lastText = '';
  bool _isEditing = false;

  SearchNavigationController({
    required this.codeController,
    SearchNavigationState? state,
  }) : super(state ?? SearchNavigationState()) {
    codeController.addListener(_updateState);
    lastText = codeController.code.text;
  }

  void moveNext() {
    _isEditing = false;
    if (searchResult.matches.isEmpty) {
      return;
    }

    if (value.currentMatchIndex == searchResult.matches.length - 1) {
      value = value.copyWith(currentMatchIndex: 0);
    } else {
      value = value.copyWith(currentMatchIndex: value.currentMatchIndex + 1);
    }

    moveSelectionToMatch(value.currentMatchIndex);
  }

  void movePrevious() {
    _isEditing = false;
    if (searchResult.matches.isEmpty) {
      return;
    }

    if (value.currentMatchIndex == 0) {
      value = value.copyWith(
        currentMatchIndex: searchResult.matches.length - 1,
      );
    } else {
      value = value.copyWith(currentMatchIndex: value.currentMatchIndex - 1);
    }

    moveSelectionToMatch(value.currentMatchIndex);
  }

  void _updateState() {
    if (codeController.code.text != lastText) {
      _isEditing = true;
      lastText = codeController.code.text;
    }

    if (_isEditing) {
      value = value.copyWith(currentMatchIndex: -1);
      return;
    }

    if (codeController.fullSearchResult.matches.isEmpty) {
      value = value.copyWith(currentMatchIndex: -1, totalMatchesCount: 0);
      return;
    }

    if (codeController.fullSearchResult == searchResult) {
      return;
    }

    searchResult = codeController.fullSearchResult;

    final visibleSelectionEnd = codeController.selection.end;
    final fullSelectionEnd = codeController.code.hiddenRanges.recoverPosition(
      visibleSelectionEnd,
      placeHiddenRanges: TextAffinity.downstream,
    );

    var closestMatchIndex = searchResult.matches.indexWhere(
      (element) => element.start >= fullSelectionEnd,
    );

    if (closestMatchIndex == -1) {
      closestMatchIndex = searchResult.matches.length - 1;
    }

    moveSelectionToMatch(closestMatchIndex);
  }

  void moveSelectionToMatch(int matchIndex) {
    final match = searchResult.matches[matchIndex];

    expandFoldedBlockIfNeeded(match);

    codeController.selection = matchToSelection(match);
    value = value.copyWith(
      currentMatchIndex: matchIndex,
      totalMatchesCount: searchResult.matches.length,
    );
  }

  void expandFoldedBlockIfNeeded(SearchMatch match) {
    final firstLine = codeController.code.lines.characterIndexToLineIndex(
      match.start,
    );
    final lastLine = codeController.code.lines.characterIndexToLineIndex(
      match.end,
    );

    final foldedBlock = codeController.code.foldedBlocks.firstWhereOrNull(
      (element) =>
          (firstLine <= element.firstLine && element.firstLine <= lastLine) ||
          (firstLine <= element.lastLine && element.lastLine <= lastLine) ||
          (element.firstLine <= firstLine && firstLine <= element.lastLine) ||
          (element.firstLine <= lastLine && lastLine <= element.lastLine),
    );

    if (foldedBlock != null) {
      codeController.unfoldAt(foldedBlock.firstLine);
    }
  }

  TextSelection matchToSelection(SearchMatch match) {
    return codeController.code.hiddenRanges.cutSelection(
      TextSelection(
        baseOffset: match.start,
        extentOffset: match.end,
      ),
    );
  }
}
