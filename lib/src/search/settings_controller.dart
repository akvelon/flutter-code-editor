import 'package:flutter/widgets.dart';

import 'settings.dart';

class SearchSettingsController extends ValueNotifier<SearchSettings> {
  SearchSettingsController() : super(SearchSettings.empty);

  final patternController = TextEditingController();

  @override
  void dispose() {
    patternController.dispose();
    super.dispose();
  }
}
