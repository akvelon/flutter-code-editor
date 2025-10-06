import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'popup_controller.dart';

/// Popup window displaying the list of possible completions
class Popup extends StatefulWidget {
  final PopupController controller;
  final Size editingWindowSize;

  /// The window coordinates of the top-left corner of the editor widget.
  final Offset? editorOffset;

  /// The window coordinates of the highest allowed top-left corner
  /// of the popup if shown above the caret.
  ///
  /// Since the popup is pushed to the bottom of the allowed rectangle
  /// the actual position may be lower.
  final Offset flippedOffset;

  /// The window coordinates of the top-left corner of the popup
  /// if shown below the caret.
  final Offset normalOffset;

  final FocusNode parentFocusNode;
  final TextStyle style;
  final Color? backgroundColor;

  final double maxHeight;
  final double maxWidth;
  final Widget Function(BuildContext context)? listBuilder;

  const Popup({
    super.key,
    required this.controller,
    required this.editingWindowSize,
    required this.editorOffset,
    required this.flippedOffset,
    required this.normalOffset,
    required this.parentFocusNode,
    required this.style,
    this.backgroundColor,
    required this.maxHeight,
    required this.maxWidth,
    this.listBuilder,
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
    final verticalFlipRequired = _isVerticalFlipRequired();
    final bool isHorizontalOverflowed = _isHorizontallyOverflowed();
    final double leftOffsetLimit =
        // TODO(nausharipov): find where 100 comes from
        widget.editingWindowSize.width - widget.maxWidth +
            (widget.editorOffset?.dx ?? 0) -
            100;

    // Fixes assertion error when ISC isn't attached but _attach method
    // of ISC instance are being called
    ItemScrollController? isc;
    if (widget.controller.itemScrollController.isAttached) {
      isc = widget.controller.itemScrollController;
    }

    return PageStorage(
      bucket: pageStorageBucket,
      child: Positioned(
        left: isHorizontalOverflowed ? leftOffsetLimit : widget.normalOffset.dx,
        top: verticalFlipRequired
            ? widget.flippedOffset.dy
            : widget.normalOffset.dy,
        child: Container(
          alignment: verticalFlipRequired
              ? Alignment.bottomCenter
              : Alignment.topCenter,
          constraints: BoxConstraints(
            maxHeight: widget.maxHeight,
            maxWidth: widget.maxWidth,
          ),
          // Container is used because the vertical borders
          // in DecoratedBox are hidden under scroll.
          // ignore: use_decorated_box
          child: widget.listBuilder?.call(context) ?? Container(
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
              itemScrollController: isc,
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

  bool _isVerticalFlipRequired() {
    final isPopupShorterThanWindow =
        widget.maxHeight < widget.editingWindowSize.height;
    final isPopupOverflowingHeight = widget.normalOffset.dy +
            widget.maxHeight -
            (widget.editorOffset?.dy ?? 0) >
        widget.editingWindowSize.height;

    return isPopupOverflowingHeight && isPopupShorterThanWindow;
  }

  bool _isHorizontallyOverflowed() {
    return widget.normalOffset.dx -
            (widget.editorOffset?.dx ?? 0) +
            widget.maxWidth >
        widget.editingWindowSize.width;
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
              widget.controller.suggestions[index].displayText,
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
