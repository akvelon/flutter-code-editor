import 'package:flutter/material.dart';

const double LINE_NUMBER_WIDTH = 42;
const TextAlign LINE_NUMBER_ALIGN = TextAlign.right;
const double LINE_NUMBER_MARGIN = 5;

class TooltipTextSpan extends WidgetSpan {
  TooltipTextSpan({
    required String message,
    required String number,
    required TextStyle? style,
  }) : super(
          child: Tooltip(
            message: message,
            child: Container(
              child: Text(
                number,
                textAlign: LINE_NUMBER_ALIGN,
                style: style,
              ),
              padding: EdgeInsets.only(right: LINE_NUMBER_MARGIN),
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(4))),
              width: LINE_NUMBER_WIDTH,
            ),
          ),
        );
}
