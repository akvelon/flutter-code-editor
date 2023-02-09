import 'package:flutter/cupertino.dart';

class PaintedTextNotifier extends ChangeNotifier {
  TextSpan get textSpan => _textSpan;
  TextSpan _textSpan = TextSpan();
  set textSpan(TextSpan value) {
    _textSpan = value;
    notifyListeners();
  }

  bool get showCursor => _showCursor;
  bool _showCursor = false;
  set showCursor(bool value) {
    _showCursor = value;
    notifyListeners();
  }
}
