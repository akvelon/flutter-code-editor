import 'package:flutter/material.dart';

/// Exposes notifyListeners that was protected in the superclass.
///
/// Use this object when you need to fire callbacks that for some
/// reason cannot listen to the object you write your code in.
class PublicNotifier extends ChangeNotifier {
  void notifyPublic() => notifyListeners();
}
