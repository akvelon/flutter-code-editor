import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// ignore_for_file: parameter_assignments

extension WidgetTesterExtension on WidgetTester {
  /// Moves the cursor to [base] from the beginning of the document,
  /// then selects [offset] characters from there to the left (negative)
  /// or to the right (positive).
  Future<void> selectFromHome(int base, {int offset = 0}) async {
    await cursorHome();
    await moveCursor(base);

    await sendKeyDownEvent(LogicalKeyboardKey.shift);
    await moveCursor(offset);
    await sendKeyUpEvent(LogicalKeyboardKey.shift);
  }

  Future<void> cursorHome() async {
    await sendKeyDownEvent(LogicalKeyboardKey.alt);
    await sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await sendKeyUpEvent(LogicalKeyboardKey.alt);
  }

  Future<void> cursorEnd() async {
    await sendKeyDownEvent(LogicalKeyboardKey.alt);
    await sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await sendKeyUpEvent(LogicalKeyboardKey.alt);
  }

  Future<void> moveCursor(int steps) async {
    if (steps > 0) {
      while (steps-- > 0) {
        await sendKeyEvent(LogicalKeyboardKey.arrowRight);
      }
    } else {
      while (steps++ < 0) {
        await sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      }
    }
  }

  Future<void> sendUndo() async {
    await sendKeyDownEvent(LogicalKeyboardKey.control);
    await sendKeyEvent(LogicalKeyboardKey.keyZ);
    await sendKeyUpEvent(LogicalKeyboardKey.control);
  }

  Future<void> sendRedo() async {
    await sendKeyDownEvent(LogicalKeyboardKey.shift);
    await sendKeyDownEvent(LogicalKeyboardKey.control);
    await sendKeyEvent(LogicalKeyboardKey.keyZ);
    await sendKeyUpEvent(LogicalKeyboardKey.control);
    await sendKeyUpEvent(LogicalKeyboardKey.shift);
  }
}
