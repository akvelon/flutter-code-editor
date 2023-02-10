import 'package:flutter/cupertino.dart';

class PaintedTextNotifier extends ChangeNotifier {
  TextSpan get textSpan => _textSpan;
  TextSpan _textSpan = TextSpan();
  set textSpan(TextSpan value) {
    _textSpan = value;
    notifyListeners();
  }

  int _linesCount = 0;
  int get linesCount => _linesCount;
  set linesCount(int value) {
    _linesCount = value;
    notifyListeners();
  }

  bool get showCursor => _showCursor;
  bool _showCursor = false;
  set showCursor(bool value) {
    _showCursor = value;
    notifyListeners();
  }

  void setEverything({
    TextSpan? text,
    int? linesCount,
    bool? showCursor,
  }) {
    if (text != null) {
      _textSpan = text;
    }
    if (linesCount != null) {
      _linesCount = linesCount;
    }
    if (showCursor != null) {
      _showCursor = showCursor;
    }

    notifyListeners();
  }
}
