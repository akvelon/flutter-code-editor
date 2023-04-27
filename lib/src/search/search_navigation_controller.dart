import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import 'match.dart';
import 'result.dart';
import 'search_navigation_state.dart';

class SearchNavigationController {
  final CodeController codeController;
  final SearchNavigationState state = SearchNavigationState();
  SearchResult searchResult = SearchResult.empty;

  SearchNavigationController({
    required this.codeController,
  }) {
    codeController.addListener(_updateState);
  }

  void moveNext() {
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
