import 'package:flutter/widgets.dart';

import 'settings.dart';

/// Controller that is responsible for storing [SearchSettings]
/// and notifying the listeners whenever the [value] changes.
class SearchSettingsController extends ValueNotifier<SearchSettings> {
  SearchSettingsController() : super(SearchSettings.empty);

  final patternController = TextEditingController();

  @override
  void dispose() {
    patternController.dispose();
    super.dispose();
  }
}
