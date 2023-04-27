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
/// advances the [state] to the nearest match index.
/// Changes selection of [CodeController] along with [state]
/// to scroll the CodeField to the currentMatch.
///
/// When the text of a [CodeController] is changed with non-empty [SearchResult]
/// enters the editing mode where it doesn't advance the [state] to currentMatch
/// nor change the selection of the [CodeController].
class SearchNavigationController {
  final CodeController codeController;
  final SearchNavigationState state = SearchNavigationState();
  SearchResult searchResult = SearchResult.empty;
  String lastText = '';
  bool _isEditing = false;

  SearchNavigationController({
    required this.codeController,
  }) {
    codeController.addListener(_updateState);
    lastText = codeController.code.text;
  }

  void moveNext() {
    _isEditing = false;
    if (searchResult.matches.isEmpty) {
      return;
    }

    if (state.value == searchResult.matches.length - 1) {
      state.value = 0;
    } else {
      state.value = state.value + 1;
    }

    moveSelectionToMatch(state.value);
  }

  void movePrevious() {
    _isEditing = false;
    if (searchResult.matches.isEmpty) {
      return;
    }

    if (state.value == 0) {
      state.value = searchResult.matches.length - 1;
    } else {
      state.value = state.value - 1;
    }

    moveSelectionToMatch(state.value);
  }

  void _updateState() {
    if (codeController.code.text != lastText) {
      _isEditing = true;
      lastText = codeController.code.text;
    }

    if (_isEditing) {
      state.value = -1;
      return;
    }

    if (codeController.searchResult.matches.isEmpty) {
      state.value = -1;
      return;
    }

    if (codeController.searchResult == searchResult) {
      return;
    }

    searchResult = codeController.searchResult;

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
    state.value = matchIndex;
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
