import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import 'match.dart';
import 'result.dart';
import 'search_navigation_state.dart';
import 'widget/search_navigation_widget.dart';

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
///
/// Also used to manage the state of [SearchNavigationWidget].
class SearchNavigationController extends ValueNotifier<SearchNavigationState> {
  final CodeController codeController;

  SearchResult _searchResult = SearchResult.empty;
  String _lastText = '';
  bool _wasEdited = false;

  SearchNavigationController({
    required this.codeController,
    SearchNavigationState? state,
  }) : super(state ?? SearchNavigationState.noMatches) {
    codeController.addListener(_updateState);
    _lastText = codeController.code.text;
  }

  void moveNext() {
    _wasEdited = false;
    if (_searchResult.matches.isEmpty) {
      return;
    }

    value = value.copyWith(
      currentMatchIndex:
          ((value.currentMatchIndex ?? 0) + 1) % value.totalMatchesCount,
    );

    _moveSelectionToMatch(value.currentMatchIndex!);
  }

  void movePrevious() {
    _wasEdited = false;
    if (_searchResult.matches.isEmpty) {
      return;
    }

    value = value.copyWith(
      currentMatchIndex:
          ((value.currentMatchIndex ?? 0) - 1) % value.totalMatchesCount,
    );

    _moveSelectionToMatch(value.currentMatchIndex!);
  }

  void _updateState() {
    if (codeController.fullSearchResult == _searchResult) {
      return;
    }

    _searchResult = codeController.fullSearchResult;

    value = value.copyWith(totalMatchesCount: _searchResult.matches.length);

    if (codeController.code.text != _lastText) {
      _wasEdited = true;
      _lastText = codeController.code.text;
    }

    if (_wasEdited) {
      value = value.resetCurrentMatchIndex();
      return;
    }

    if (_searchResult.matches.isEmpty) {
      value = SearchNavigationState.noMatches;
      return;
    }

    final visibleSelectionEnd = codeController.selection.end;
    final fullSelectionEnd = codeController.code.hiddenRanges.recoverPosition(
      visibleSelectionEnd,
      placeHiddenRanges: TextAffinity.downstream,
    );

    var closestMatchIndex = _searchResult.matches.indexWhere(
      (element) => element.start >= fullSelectionEnd,
    );

    if (closestMatchIndex == -1) {
      closestMatchIndex = _searchResult.matches.length - 1;
    }

    _moveSelectionToMatch(closestMatchIndex);
  }

  void _moveSelectionToMatch(int matchIndex) {
    final match = _searchResult.matches[matchIndex];

    _expandFoldedBlockIfNeed(match);

    codeController.selection = _matchToSelection(match);
    value = value.copyWith(
      currentMatchIndex: matchIndex,
      totalMatchesCount: _searchResult.matches.length,
    );
  }

  void _expandFoldedBlockIfNeed(SearchMatch match) {
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

  TextSelection _matchToSelection(SearchMatch match) {
    return codeController.code.hiddenRanges.cutSelection(
      TextSelection(
        baseOffset: match.start,
        extentOffset: match.end,
      ),
    );
  }
}
