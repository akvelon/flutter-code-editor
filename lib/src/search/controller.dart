import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../code/code.dart';
import '../code_field/code_controller.dart';
import 'match.dart';
import 'result.dart';
import 'search_navigation_controller.dart';
import 'settings.dart';
import 'settings_controller.dart';
import 'strategies/abstract.dart';
import 'strategies/plain_case_insensitive.dart';
import 'strategies/plain_case_sensitive.dart';
import 'strategies/regexp.dart';

/// Controller that is responsible for enabling the search
/// and generating search results when requested.
/// Notifies the listeners only when enabled / disabled.
class SearchController extends ChangeNotifier {
  // TODO(yescorp): Move this to a better place.
  //  https://github.com/akvelon/flutter-code-editor/issues/234
  bool get isEnabled => _isEnabled;
  bool _isEnabled = false;

  late final SearchSettingsController settingsController;
  late final SearchNavigationController navigationController;

  FocusNode? get codeFieldFocusNode => _codeFieldFocusNode;
  FocusNode? _codeFieldFocusNode;
  set codeFieldFocusNode(FocusNode? newValue) {
    _codeFieldFocusNode?.removeListener(_onFocusChange);
    _codeFieldFocusNode = newValue;
    _codeFieldFocusNode?.addListener(_onFocusChange);
    navigationController.codeFieldFocusNode = newValue;
  }

  late FocusNode patternFocusNode = FocusNode(onKeyEvent: _onkey);

  int focusChangesWithinTimeFrame = 0;
  bool shouldDismiss = false;

  Timer? _dismissTimer;

  SearchController({
    required CodeController codeController,
  }) {
    settingsController = SearchSettingsController();
    navigationController = SearchNavigationController(
      codeController: codeController,
    );

    patternFocusNode.addListener(_onFocusChange);
  }

  void enableSearch() {
    patternFocusNode.requestFocus();
    if (isEnabled == true) {
      return;
    }

    _dismissTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      _dismissTimerCallback,
    );

    _isEnabled = true;
    notifyListeners();
  }

  void disableSearch({
    required bool returnFocusToCodeField,
  }) {
    patternFocusNode.unfocus();
    _dismissTimer?.cancel();

    if (returnFocusToCodeField == true) {
      _codeFieldFocusNode?.requestFocus();
    }

    if (isEnabled == false) {
      return;
    }

    _isEnabled = false;
    notifyListeners();
  }

  /// Performs the search on the full text of a code.
  ///
  /// The returned result does not contain collapsed matches and is sorted
  /// by the start position of the match.
  SearchResult search(Code code, {required SearchSettings settings}) {
    if (!_isEnabled) {
      return SearchResult.empty;
    }

    if (settings.pattern.isEmpty) {
      return SearchResult.empty;
    }

    final strategy = getSearchStrategy(settings);

    final result = strategy.searchPlain(code.text, settings: settings);
    result.matches.sort(_searchMatchStartAscendingComparator);

    return result;
  }

  @visibleForTesting
  SearchStrategy getSearchStrategy(SearchSettings settings) {
    if (settings.isRegExp) {
      return RegExpSearchStrategy();
    }

    if (settings.isCaseSensitive) {
      return PlainCaseSensitiveSearchStrategy();
    }

    return PlainCaseInsensitiveSearchStrategy();
  }

  KeyEventResult _onkey(FocusNode node, KeyEvent event) {
    if ((event is KeyDownEvent || event is KeyRepeatEvent) &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      unawaited(_onEnterKeyPressed());
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      disableSearch(returnFocusToCodeField: true);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Future<void> _onEnterKeyPressed() async {
    _codeFieldFocusNode?.requestFocus();
    navigationController.moveNext();
    await Future.delayed(const Duration(milliseconds: 1));
    patternFocusNode.requestFocus();
  }

  void _onFocusChange() {
    focusChangesWithinTimeFrame++;

    shouldDismiss = patternFocusNode.hasFocus == false &&
        _codeFieldFocusNode?.hasFocus == false;
  }

  void _dismissTimerCallback(Timer timer) {
    if (focusChangesWithinTimeFrame > 0) {
      focusChangesWithinTimeFrame = 0;
      return;
    }

    if (shouldDismiss) {
      disableSearch(returnFocusToCodeField: false);
    }
  }

  @override
  void dispose() {
    navigationController.dispose();
    patternFocusNode.dispose();
    settingsController.dispose();
    _dismissTimer?.cancel();
    super.dispose();
  }
}

int _searchMatchStartAscendingComparator(
  SearchMatch first,
  SearchMatch second,
) {
  return first.start - second.start;
}
