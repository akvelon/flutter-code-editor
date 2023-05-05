import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../code_field/actions/ignore.dart';
import '../controller.dart';
import 'focus_rediretor.dart';
import 'search_navigation_widget.dart';
import 'search_settings_widget.dart';

const _iconSize = 24.0;

class SearchWidget extends StatelessWidget {
  final CodeSearchController searchController;

  const SearchWidget({
    super.key,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      actions: {
        IgnoreIntent: IgnoreAction(),
      },
      shortcuts: {
        LogicalKeySet(
          LogicalKeyboardKey.keyF,
          LogicalKeyboardKey.control,
        ): const IgnoreIntent(),
        LogicalKeySet(
          LogicalKeyboardKey.keyF,
          LogicalKeyboardKey.meta,
        ): const IgnoreIntent(),
      },
      child: AnimatedBuilder(
        animation: searchController,
        builder: (context, child) => FocusRedirector(
          redirectTo: searchController.patternFocusNode,
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
                      searchNavigationController:
                          searchController.navigationController,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      hoverColor: Colors.transparent,
                      onTap: () => searchController.hideSearch(
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
      ),
    );
  }
}
