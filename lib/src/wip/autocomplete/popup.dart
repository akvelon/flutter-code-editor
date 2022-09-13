import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../sizes.dart';
import 'popup_controller.dart';

/// Popup window displaying the list of possible completions
class Popup extends StatefulWidget {
  final Offset preferredOffset;
  final bool isPopupCropped;
  final Size editingWindowSize;
  final TextStyle style;
  final Color? backgroundColor;
  final PopupController controller;
  final FocusNode parentFocusNode;

  Popup({
    Key? key,
    required this.preferredOffset,
    required this.isPopupCropped,
    required this.controller,
    required this.editingWindowSize,
    required this.style,
    required this.parentFocusNode,
    this.backgroundColor,
  }) : super(key: key);

  @override
  PopupState createState() => PopupState();
}

class PopupState extends State<Popup> {
  static const double width = 300;
  static const double height = Sizes.autocompletePopupMaxHeight;

  @override
  void initState() {
    widget.controller.addListener(rebuild);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.removeListener(rebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.preferredOffset.dx,
      top: widget.preferredOffset.dy,
      child: Container(
        alignment: widget.isPopupCropped
            ? Alignment.bottomCenter
            : Alignment.topCenter,
        constraints: const BoxConstraints(
          maxHeight: height,
          maxWidth: width,
        ),
        // DecoratedBox is rendered differently.
        // ignore_for_file: use_decorated_box
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(
              color: widget.style.color!,
              width: 0.5,
            ),
          ),
          child: ScrollablePositionedList.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemScrollController: widget.controller.itemScrollController,
            itemPositionsListener: widget.controller.itemPositionsListener,
            itemCount: widget.controller.suggestions.length,
            itemBuilder: (context, index) {
              return _buildListItem(index);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Material(
      color: const Color(0xff2e312c),
      child: InkWell(
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
        child: ColoredBox(
          color: widget.controller.selectedIndex == index
              ? Colors.blueAccent.withOpacity(0.5)
              : Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.controller.suggestions[index],
              overflow: TextOverflow.ellipsis,
              style: widget.style,
            ),
          ),
        ),
      ),
    );
  }

  void rebuild() {
    setState(() {});
  }
}
