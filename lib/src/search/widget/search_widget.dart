import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controller.dart';
import '../search_navigation_controller.dart';
import '../settings_controller.dart';
import 'search_navigation_widget.dart';
import 'search_settings_widget.dart';

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
  late final patternFocusNode = FocusNode(onKeyEvent: _onkey);
  late final Timer timer;
  var _shouldDismissChangeCounter = 0;
  var _shouldDismiss = false;

  @override
  void initState() {
    widget.searchController.currentSearchPopupFocusNode = patternFocusNode;

    patternFocusNode.requestFocus();

    patternFocusNode.addListener(_onFocusChange);
    widget.codeFieldFocusNode.addListener(_onFocusChange);
    timer = Timer.periodic(const Duration(milliseconds: 300), _timerCallback);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: IntrinsicWidth(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 6,
              child: SearchSettingsWidget(
                onSubmitted: _onSubmitted,
                patternFocusNode: patternFocusNode,
                settingsController: widget.searchSettingsController,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: SearchNavigationWidget(
                patternFocusNode: patternFocusNode,
                codeFieldFocusNode: widget.codeFieldFocusNode,
                searchNavigationController: widget.searchNavigationController,
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
      ),
    );
  }

  void _dismiss() {
    widget.searchController.disableSearch();
    widget.codeFieldFocusNode.requestFocus();
  }

  KeyEventResult _onkey(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _dismiss();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _onSubmitted(String str) {
    widget.codeFieldFocusNode.requestFocus();
    widget.searchNavigationController.moveNext();
    patternFocusNode.requestFocus();
  }

  @override
  void dispose() {
    widget.searchController.currentSearchPopupFocusNode = null;
    widget.codeFieldFocusNode.removeListener(_onFocusChange);
    patternFocusNode.dispose();
    timer.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _shouldDismiss =
          !widget.codeFieldFocusNode.hasFocus && !patternFocusNode.hasFocus;
      _shouldDismissChangeCounter++;
    });
  }

  void _timerCallback(Timer timer) {
    if (_shouldDismissChangeCounter > 0) {
      _shouldDismissChangeCounter = 0;
      return;
    }

    if (_shouldDismiss) {
      _dismiss();
    }
  }
}
