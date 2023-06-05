import 'package:flutter/material.dart';

import '../code_field/code_controller.dart';
import '../folding/foldable_block.dart';
import '../folding/foldable_block_type.dart';
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

  SearchResult _lastFullSearchResult = SearchResult.empty;
  String _lastText;
  bool _wasEdited = false;

  FocusNode? codeFieldFocusNode;

  SearchNavigationController({
    required this.codeController,
  })  : _lastText = '',
        super(SearchNavigationState.noMatches) {
    codeController.addListener(_updateState);
    _lastText = codeController.code.text;
  }

  void moveNext() {
    _moveToResult(1);
  }

  void movePrevious() {
    _moveToResult(-1);
  }

  void _moveToResult(int delta) {
    codeFieldFocusNode?.requestFocus();
    _wasEdited = false;
    if (_lastFullSearchResult.matches.isEmpty) {
      return;
    }

    final currentIndex = value.currentMatchIndex ??
        _getNextOrFirstMatchIndex() ??
        (throw Exception('Empty result must have been checked above.'));

    value = value.copyWith(
      currentMatchIndex: (currentIndex + delta) % value.totalMatchCount,
    );

    _moveSelectionToCurrentMatch();
  }

  void _updateState() {
    _wasEdited = codeController.code.text != _lastText;
    _lastText = codeController.code.text;

    if (codeController.fullSearchResult == _lastFullSearchResult) {
      return;
    }

    _lastFullSearchResult = codeController.fullSearchResult;

    value = _createValue();
    _moveSelectionToCurrentMatch();
  }

  SearchNavigationState _createValue() {
    if (_wasEdited) {
      return value.resetCurrentMatchIndex(
        codeController.fullSearchResult.matches.length,
      );
    }

    if (_lastFullSearchResult.matches.isEmpty) {
      return SearchNavigationState.noMatches;
    }

    final closestMatch = _getNextOrFirstMatchIndex();

    return value.copyWith(
      currentMatchIndex: closestMatch,
      totalMatchCount: _lastFullSearchResult.matches.length,
    );
  }

  int? _getNextOrFirstMatchIndex() {
    if (_lastFullSearchResult.matches.isEmpty) {
      return null;
    }

    final visibleSelectionStart = codeController.selection.start;
    final fullSelectionStart = codeController.code.hiddenRanges.recoverPosition(
      visibleSelectionStart,
      placeHiddenRanges: TextAffinity.downstream,
    );

    var closestMatchIndex = _lastFullSearchResult.matches.indexWhere(
      (element) {
        return element.start >= fullSelectionStart;
      },
    );

    if (closestMatchIndex == -1) {
      closestMatchIndex = _lastFullSearchResult.matches.length - 1;
    }

    return closestMatchIndex;
  }

  void _moveSelectionToCurrentMatch() {
    if (value.currentMatchIndex == null) {
      return;
    }

    final match = _lastFullSearchResult.matches[value.currentMatchIndex!];

    _expandFoldedBlocksIfNeed(match);

    codeController.selection = _matchToSelection(match);
  }

  void _expandFoldedBlocksIfNeed(SearchMatch match) {
    final firstLine = codeController.code.lines.characterIndexToLineIndex(
      match.start,
    );
    final lastLine = codeController.code.lines.characterIndexToLineIndex(
      match.end,
    );

    final matchRange = FoldableBlock(
      firstLine: firstLine,
      lastLine: lastLine,
      type: FoldableBlockType.union,
    );

    final foldedBlocks = codeController.code.foldedBlocks.where(
      (block) => block.overlaps(matchRange),
    );

    for (final foldedBlock in foldedBlocks) {
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

  @override
  void dispose() {
    codeController.removeListener(_updateState);
    super.dispose();
  }
}
