import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller.dart';
import '../search_navigation_controller.dart';
import '../settings_controller.dart';
import 'search_navigation_widget.dart';
import 'search_settings_widget.dart';

const _selectedColor = Colors.black;
const _unselectedColor = Color.fromARGB(88, 0, 0, 0);
const _hintText = 'Search...';
const _iconSize = 24.0;

class SearchWidget extends StatefulWidget {
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
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late final settingsController = widget.searchSettingsController;
  late final searchController = widget.searchController;
  late final searchNavigationController = widget.searchNavigationController;
  late final focusNode = FocusNode(onKeyEvent: _onkey);
  late final codeFieldFocusNode = widget.codeFieldFocusNode;

  bool _isCaseSensitive = false;
  bool _isRegex = false;

  @override
  void initState() {
    settingsController.patternController.addListener(
      () {
        settingsController.value = settingsController.value.copyWith(
          pattern: settingsController.patternController.text,
        );
      },
    );
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 6,
            child: SearchSettingsWidget(
              patternFocusNode: focusNode,
              settingsController: settingsController,
            ),
          ),
          Expanded(
            flex: 2,
            child: SearchNavigationWidget(
              patternFocusNode: focusNode,
              codeFieldFocusNode: codeFieldFocusNode,
              searchNavigationController: searchNavigationController,
            ),
          ),
          Expanded(
            child: InkWell(
              hoverColor: Colors.transparent,
              onTap: _dismiss,
              child: const Icon(
                Icons.close,
                size: _iconSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _dismiss() {
    searchController.disableSearch();
    codeFieldFocusNode.requestFocus();
  }

  KeyEventResult _onkey(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _dismiss();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
