import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../sizes.dart';
import 'popup_controller.dart';

/// Popup window displaying the list of possible completions
class Popup extends StatefulWidget {
  final Offset normalOffset;
  final Offset flippedOffset;
  final Size editingWindowSize;
  final TextStyle style;
  final Color? backgroundColor;
  final PopupController controller;
  final FocusNode parentFocusNode;
  final Offset? offset;

  const Popup({
    super.key,
    required this.normalOffset,
    required this.flippedOffset,
    required this.controller,
    required this.editingWindowSize,
    required this.style,
    required this.parentFocusNode,
    required this.offset,
    this.backgroundColor,
  });

  @override
  PopupState createState() => PopupState();
}

class PopupState extends State<Popup> {
  final pageStorageBucket = PageStorageBucket();
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
    final isPopupShorterThanWindow =
        Sizes.autocompletePopupMaxHeight < widget.editingWindowSize.height;
    final isPopupOverflowingHeight = widget.normalOffset.dy +
            Sizes.autocompletePopupMaxHeight -
            (widget.offset?.dy ?? 0) >
        widget.editingWindowSize.height;
      
    final bool verticalFlipRequired =
        isPopupOverflowingHeight && isPopupShorterThanWindow;
    final bool horizontalOverflow =
        widget.normalOffset.dx + Sizes.autocompletePopupMaxWidth >
            widget.editingWindowSize.width;
    final double leftOffsetLimit =
        // TODO(nausharipov): find where 100 comes from
        widget.editingWindowSize.width - Sizes.autocompletePopupMaxWidth - 100;

    return PageStorage(
      bucket: pageStorageBucket,
      child: Positioned(
        left: horizontalOverflow ? leftOffsetLimit : widget.normalOffset.dx,
        top:
            verticalFlipRequired ? widget.flippedOffset.dy : widget.normalOffset.dy,
        child: Container(
          alignment:
              verticalFlipRequired ? Alignment.bottomCenter : Alignment.topCenter,
          constraints: const BoxConstraints(
            maxHeight: Sizes.autocompletePopupMaxHeight,
            maxWidth: Sizes.autocompletePopupMaxWidth,
          ),
          // Container is used because the vertical borders
          // in DecoratedBox are hidden under scroll.
          // ignore: use_decorated_box
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
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Material(
      color: Colors.grey.withOpacity(0.1),
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
