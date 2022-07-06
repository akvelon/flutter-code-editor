import 'dart:math';

import 'package:code_text_field/src/autocomplete/popup_controller.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Popup window displaying the list of possible completions
class Popup extends StatefulWidget {
  final double row;
  final double column;
  final Size editingWindowSize;
  final TextStyle style;
  final Color? backgroundColor;
  final PopupController controller;
  final FocusNode parentFocusNode;

  Popup({
    Key? key,
    required this.row,
    required this.column,
    required this.controller,
    required this.editingWindowSize,
    required this.style,
    required this.parentFocusNode,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _PopupState createState() => _PopupState();
}

class _PopupState extends State<Popup> {
  late double width;
  late double height;

  @override
  void initState() {
    widget.controller.addListener(rebuild);
    this.width = 300;
    this.height = 100;
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: min(widget.column, widget.editingWindowSize.width - width),
        top: widget.row,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height, maxWidth: width),
        child: Container(
          child: ScrollablePositionedList.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            itemScrollController: widget.controller.itemScrollController,
            itemPositionsListener: widget.controller.itemPositionsListener,
            itemCount: widget.controller.suggestions.length,
            itemBuilder: (context, index) {
              return _buildListItem(index);
            },
          ),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(
              color: widget.style.color!,
              width: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Material(
      color: Colors.grey.withOpacity(0.1),
      child: InkWell(
        child: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0),
            child: Text(
              widget.controller.suggestions[index].word,
              overflow: TextOverflow.ellipsis,
              style: widget.style,
            ),
          ),
          color: widget.controller.selectedIndex == index
              ? Colors.blueAccent.withOpacity(0.5)
              : Colors.transparent,
        ),
        onTap: () {
          widget.controller.selectedIndex = index;
          widget.parentFocusNode.requestFocus();
        },
        onDoubleTap: () {
          widget.controller.selectedIndex = index;
          widget.parentFocusNode.requestFocus();
          widget.controller.onCompletionSelected();
        },
        hoverColor: Colors.grey.withOpacity(0.1),
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
    );
  }

  void rebuild() {
    setState(() {});
  }
}
