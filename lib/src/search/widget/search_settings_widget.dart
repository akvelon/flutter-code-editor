import 'package:flutter/material.dart';

import '../settings_controller.dart';

const _selectedColor = Colors.black;
const _unselectedColor = Color.fromARGB(88, 0, 0, 0);
const _hintText = 'Search...';
const _iconSize = 24.0;

class SearchSettingsWidget extends StatefulWidget {
  final FocusNode focusNode;
  final SearchSettingsController settingsController;

  const SearchSettingsWidget({
    super.key,
    required this.focusNode,
    required this.settingsController,
  });

  @override
  State<SearchSettingsWidget> createState() => _SearchSettingsWidgetState();
}

class _SearchSettingsWidgetState extends State<SearchSettingsWidget> {
  late final focusNode = widget.focusNode;
  late final settingsController = widget.settingsController;
  bool _isCaseSensitive = false;
  bool _isRegex = false;

  @override
  Widget build(BuildContext context) {
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
      ],
    );
  }
}
