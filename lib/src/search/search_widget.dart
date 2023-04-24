import 'package:flutter/material.dart';

import 'settings.dart';
import 'settings_controller.dart';

class SearchWidget extends StatefulWidget {
  final SearchSettingsController controller;
  const SearchWidget({
    super.key,
    required this.controller,
  });

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late final settingsController = widget.controller;
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    settingsController.patternController.addListener(
      () {
        settingsController.value = SearchSettings(
          isCaseSensitive: false,
          isRegExp: false,
          pattern: settingsController.patternController.text,
        );
      },
    );
    focusNode.requestFocus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // if (!controller.isEnabled) {
    //   return Container();
    // }

    return Container(
      color: Colors.amber,
      height: 50,
      width: 200,
      child: TextField(
        decoration: InputDecoration(
          suffix: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ),
        focusNode: focusNode,
        enabled: true,
        controller: settingsController.patternController,
      ),
    );
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
}
