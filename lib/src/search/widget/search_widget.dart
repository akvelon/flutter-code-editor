import 'package:flutter/material.dart';

import '../controller.dart';
import 'search_navigation_widget.dart';
import 'search_settings_widget.dart';

const _iconSize = 24.0;

class SearchWidget extends StatelessWidget {
  final SearchController searchController;

  const SearchWidget({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: searchController,
      builder: (context, child) => InkWell(
        mouseCursor: MouseCursor.defer,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        onTap: () => searchController.patternFocusNode.requestFocus(),
        child: SizedBox(
          height: 50,
          child: IntrinsicWidth(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: SearchSettingsWidget(
                    patternFocusNode: searchController.patternFocusNode,
                    settingsController: searchController.settingsController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: SearchNavigationWidget(
                    codeFieldFocusNode: searchController.codeFieldFocusNode,
                    searchNavigationController:
                        searchController.navigationController,
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
      ),
    );
  }
}
