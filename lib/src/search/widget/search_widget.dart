import 'package:flutter/material.dart';

import '../controller.dart';
import '../search_navigation_controller.dart';
import '../settings_controller.dart';
import 'search_navigation_widget.dart';
import 'search_settings_widget.dart';

const _iconSize = 24.0;

class SearchWidget extends StatelessWidget {
  final SearchSettingsController searchSettingsController;
  final SearchController searchController;
  final SearchNavigationController searchNavigationController;
  final FocusNode codeFieldFocusNode;

  const SearchWidget({
    super.key,
    required this.codeFieldFocusNode,
    required this.searchController,
    required this.searchNavigationController,
    required this.searchSettingsController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: searchController,
      builder: (context, child) => SizedBox(
        height: 50,
        child: IntrinsicWidth(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 6,
                child: SearchSettingsWidget(
                  patternFocusNode: searchController.patternFocusNode,
                  settingsController: searchSettingsController,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: SearchNavigationWidget(
                  patternFocusNode: searchController.patternFocusNode,
                  codeFieldFocusNode: codeFieldFocusNode,
                  searchNavigationController: searchNavigationController,
                ),
              ),
              Expanded(
                child: InkWell(
                  hoverColor: Colors.transparent,
                  onTap: () => searchController.disableSearch(
                    returnFocusToCodeField: true,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: _iconSize,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
