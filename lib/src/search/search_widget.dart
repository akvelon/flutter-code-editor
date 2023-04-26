import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'controller.dart';
import 'settings_controller.dart';

const _selectedColor = Colors.black;
const _unselectedColor = Color.fromARGB(88, 0, 0, 0);
const _hintText = 'Search...';
const _iconSize = 24.0;

class SearchWidget extends StatefulWidget {
  final SearchSettingsController controller;
  final SearchController searchController;
  final FocusNode focusNode;
  const SearchWidget({
    super.key,
    required this.controller,
    required this.searchController,
    required this.focusNode,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late final settingsController = widget.controller;
  late final searchController = widget.searchController;
  late final focusNode = FocusNode(onKeyEvent: _onkey);
  late final parentFocus = widget.focusNode;

  bool _isCaseSensitive = false;
  bool _isRegex = false;

  @override
  void initState() {
    settingsController.patternController.addListener(
      () {
        settingsController.value = settingsController.value.copyWith(
          isCaseSensitive: _isCaseSensitive,
          isRegExp: _isRegex,
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
      width: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
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
                focusNode: focusNode,
                enabled: true,
                controller: settingsController.patternController,
              ),
            ),
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              setState(() {
                _isCaseSensitive = !_isCaseSensitive;
                settingsController.value = settingsController.value.copyWith(
                  isCaseSensitive: _isCaseSensitive,
                );
              });
            },
            child: Icon(
              Icons.abc,
              color: _isCaseSensitive ? _selectedColor : _unselectedColor,
              size: _iconSize,
            ),
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              setState(() {
                _isRegex = !_isRegex;
                settingsController.value = settingsController.value.copyWith(
                  isRegExp: _isRegex,
                );
              });
            },
            child: Icon(
              Icons.r_mobiledata,
              color: _isRegex ? _selectedColor : _unselectedColor,
              size: _iconSize,
            ),
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              focusNode.unfocus();
              parentFocus.requestFocus();
              searchController.movePreviousMatch();
            },
            child: const Icon(
              Icons.arrow_upward,
              size: _iconSize,
            ),
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: () {
              focusNode.unfocus();
              parentFocus.requestFocus();
              searchController.moveNextMatch();
            },
            child: const Icon(
              Icons.arrow_downward,
              size: _iconSize,
            ),
          ),
          InkWell(
            hoverColor: Colors.transparent,
            onTap: _dismiss,
            child: const Icon(
              Icons.close,
              size: _iconSize,
            ),
          ),
        ],
      ),
    );
  }

  void _dismiss() {
    settingsController.value = settingsController.value.copyWith(
      isEnabled: false,
    );
    parentFocus.requestFocus();
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
