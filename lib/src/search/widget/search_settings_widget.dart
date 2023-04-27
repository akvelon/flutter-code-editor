import 'package:flutter/material.dart';

import '../settings_controller.dart';

const _hintText = 'Search...';
const _iconSize = 24.0;

class SearchSettingsWidget extends StatelessWidget {
  final FocusNode patternFocusNode;
  final SearchSettingsController settingsController;

  const SearchSettingsWidget({
    super.key,
    required this.patternFocusNode,
    required this.settingsController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (context, child) {
        return Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: _hintText,
                    isCollapsed: true,
                    border: InputBorder.none,
                  ),
                  focusNode: patternFocusNode,
                  enabled: true,
                  controller: settingsController.patternController,
                ),
              ),
            ),
            ToggleButtons(
              onPressed: (index) {
                // TODO(yescorp): Use keyed_collection_widgets when this lands:
                //  https://github.com/alexeyinkin/flutter-keyed-collection-widgets/issues/2
                switch (index) {
                  case 0:
                    settingsController.toggleCaseSensitivity();
                    break;
                  case 1:
                    settingsController.toggleIsRegExp();
                    break;
                }
              },
              isSelected: [
                settingsController.value.isCaseSensitive,
                settingsController.value.isRegExp,
              ],
              children: const [
                Icon(
                  Icons.abc,
                  size: _iconSize,
                ),
                Icon(
                  Icons.r_mobiledata,
                  size: _iconSize,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
