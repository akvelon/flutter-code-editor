import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../code/code.dart';
import '../code/key_event.dart';
import '../code_field/code_controller.dart';
import 'result.dart';
import 'search_navigation_controller.dart';
import 'settings.dart';
import 'settings_controller.dart';
import 'strategies/abstract.dart';
import 'strategies/plain_case_insensitive.dart';
import 'strategies/plain_case_sensitive.dart';
import 'strategies/regexp.dart';

const _hidingCheckInterval = Duration(milliseconds: 1000);

/// Controller that is responsible for enabling the search
/// and generating search results when requested.
/// Notifies the listeners only when shown or hidden.
class CodeSearchController extends ChangeNotifier {
  bool get shouldShow => _shouldShow;
  bool _shouldShow = false;

  final SearchSettingsController settingsController =
      SearchSettingsController();
  final SearchNavigationController navigationController;

  FocusNode? get codeFieldFocusNode => _codeFieldFocusNode;
  FocusNode? _codeFieldFocusNode;
  set codeFieldFocusNode(FocusNode? newValue) {
    navigationController.codeFieldFocusNode = newValue;
    _codeFieldFocusNode?.removeListener(_onFocusChange);
    _codeFieldFocusNode = newValue;
    _codeFieldFocusNode?.addListener(_onFocusChange);
  }

  late final FocusNode patternFocusNode = FocusNode(onKeyEvent: _onkey);

  int _focusChangesWithinTimeFrame = 0;
  Timer? _hidingTimer;

  CodeSearchController({
    required CodeController codeController,
  }) : navigationController =
            SearchNavigationController(codeController: codeController) {
    patternFocusNode.addListener(_onFocusChange);
  }

  void showSearch() {
    patternFocusNode.requestFocus();
    if (_shouldShow) {
      return;
    }

    _hidingTimer?.cancel();
    _hidingTimer = Timer.periodic(
      _hidingCheckInterval,
      _hidingTimerCallback,
    );

    _shouldShow = true;
    notifyListeners();
  }

  @internal
  void hideSearch({
    required bool returnFocusToCodeField,
  }) {
    patternFocusNode.unfocus();
    _hidingTimer?.cancel();

    if (returnFocusToCodeField == true) {
      _codeFieldFocusNode?.requestFocus();
    }

    if (!_shouldShow) {
      return;
    }

    _shouldShow = false;
    notifyListeners();
  }

  /// Performs the search on the full text of the [code].
  ///
  /// The returned result does not contain collapsed matches and is sorted
  /// by the start position of the match.
  SearchResult search(Code code, {required SearchSettings settings}) {
    if (!_shouldShow) {
      return SearchResult.empty;
    }

    if (settings.pattern.isEmpty) {
      return SearchResult.empty;
    }

    final strategy = getSearchStrategy(settings);
    final result = strategy.searchPlain(code.text, settings: settings);

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
    if (event.isCtrlF(HardwareKeyboard.instance.logicalKeysPressed)) {
      return KeyEventResult.handled;
    }

    if ((event is KeyDownEvent || event is KeyRepeatEvent) &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      unawaited(_onEnterKeyPressed());
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      hideSearch(returnFocusToCodeField: true);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Future<void> _onEnterKeyPressed() async {
    _codeFieldFocusNode?.requestFocus();
    navigationController.moveNext();
    await Future.delayed(Duration.zero);
    patternFocusNode.requestFocus();
  }

  /// Called when pattern or code field is focused or de-focused.
  void _onFocusChange() {
    _focusChangesWithinTimeFrame++;
  }

  /// We should hide the search if focus is neither in the pattern field
  /// nor in the code field. But the focus could have left these fields
  /// for a short while on search navigation.
  ///
  /// So only hide the search if both nodes were de-focused for
  /// the whole last tick and did not fire events during it.
  void _hidingTimerCallback(Timer timer) {
    if (_focusChangesWithinTimeFrame > 0) {
      _focusChangesWithinTimeFrame = 0;
      return;
    }

    final shouldDismiss = patternFocusNode.hasFocus == false &&
        _codeFieldFocusNode?.hasFocus == false;

    if (shouldDismiss) {
      hideSearch(returnFocusToCodeField: false);
    }
  }

  @override
  void dispose() {
    _shouldShow = false;
    _codeFieldFocusNode?.removeListener(_onFocusChange);
    _codeFieldFocusNode = null;
    navigationController.dispose();
    settingsController.dispose();
    _hidingTimer?.cancel();
    patternFocusNode.dispose();
    super.dispose();
  }
}
