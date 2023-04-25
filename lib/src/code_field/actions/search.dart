import 'package:flutter/cupertino.dart';

import '../code_controller.dart';

class SearchIntent extends Intent {
  const SearchIntent();
}

class SearchAction extends Action<SearchIntent> {
  final CodeController controller;

  SearchAction({
    required this.controller,
  });

  @override
  Object? invoke(SearchIntent intent) {
    controller.searchController.isEnabled = true;

    return null;
  }
}
