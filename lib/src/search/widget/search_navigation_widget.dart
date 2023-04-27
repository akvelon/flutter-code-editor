import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../search_navigation_controller.dart';

const _iconSize = 24.0;

class SearchNavigationWidget extends StatefulWidget {
  final FocusNode focusNode;
  final FocusNode parentFocus;
  final SearchNavigationController searchNavigationController;

  const SearchNavigationWidget({
    super.key,
    required this.focusNode,
    required this.parentFocus,
    required this.searchNavigationController,
  });

  @override
  State<SearchNavigationWidget> createState() => _SearchNavigationWidgetState();
}

class _SearchNavigationWidgetState extends State<SearchNavigationWidget> {
  late final focusNode = widget.focusNode;
  late final parentFocus = widget.parentFocus;
  late final searchNavigationController = widget.searchNavigationController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          hoverColor: Colors.transparent,
          onTap: () {
            focusNode.unfocus();
            parentFocus.requestFocus();
            searchNavigationController.movePrevious();
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
            searchNavigationController.moveNext();
          },
          child: const Icon(
            Icons.arrow_downward,
            size: _iconSize,
          ),
        ),
      ],
    );
  }
}
