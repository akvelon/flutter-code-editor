import 'package:flutter/material.dart';

class CodelineChangeNotifier extends ChangeNotifier {
  TextSpan? get lineText => _lineText;
  TextSpan? _lineText;
  set lineText(TextSpan? value) {
    final shouldNotify = _lineText != value;

    _lineText = value;
    if (shouldNotify) {
      notifyListeners();
    }
  }

  CodelineChangeNotifier({
    TextSpan? lineText,
  }) : _lineText = lineText;
}
