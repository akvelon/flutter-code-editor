import 'package:flutter/widgets.dart';

import 'settings.dart';

/// Controller that is responsible for storing [SearchSettings]
/// and notifying the listeners whenever the [value] changes.
class SearchSettingsController extends ValueNotifier<SearchSettings> {
  SearchSettingsController() : super(SearchSettings.empty) {
    patternController.addListener(_onPatternControllerChanged);
  }

  final patternController = TextEditingController();

  void toggleCaseSensitivity() {
    value = value.copyWith(isCaseSensitive: !value.isCaseSensitive);
  }

  void toggleIsRegExp() {
    value = value.copyWith(isRegExp: !value.isRegExp);
  }

  void _onPatternControllerChanged() {
    value = value.copyWith(pattern: patternController.text);
  }

  @override
  void dispose() {
    patternController.dispose();
    super.dispose();
  }
}
