import 'package:flutter/services.dart';

extension KeyEventExtension on KeyEvent {
  bool isCtrlF(Set<LogicalKeyboardKey> logicalKeysPressed) {
    final isKeyFPressed = physicalKey == PhysicalKeyboardKey.keyF ||
        logicalKey == LogicalKeyboardKey.keyF;

    final isMetaOrControlPressed =
        logicalKeysPressed.contains(LogicalKeyboardKey.metaLeft) ||
            logicalKeysPressed.contains(LogicalKeyboardKey.metaRight) ||
            logicalKeysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            logicalKeysPressed.contains(LogicalKeyboardKey.controlRight);

    return isKeyFPressed && isMetaOrControlPressed;
  }
}
