import 'package:flutter/painting.dart';

extension TextStyleExtension on TextStyle {
  String toMapString() {
    final result = {
      'color': color,
      //add another fields if required
    };
    result.removeWhere((key, value) => value == null);
    return result.toString();
  }

  TextStyle paled() {
    final clr = color;

    if (clr == null) {
      return this;
    }

    return copyWith(
      color: Color.fromARGB(
        clr.alpha ~/ 2,
        clr.red,
        clr.green,
        clr.blue,
      ),
    );
  }
}
