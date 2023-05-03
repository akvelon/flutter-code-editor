import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';

void main() {
  testWidgets('CTRL + F or META + F enables search', (wt) async {
    const text = 'AaAa';
    final controller = await pumpController(wt, text);

    expect(controller.searchController.shouldShow, false);

    await wt.sendKeyDownEvent(LogicalKeyboardKey.control);
    await wt.sendKeyEvent(LogicalKeyboardKey.keyF);
    await wt.sendKeyUpEvent(LogicalKeyboardKey.control);

    expect(controller.searchController.shouldShow, true);
  });

  testWidgets('ESCAPE disables search', (wt) async {
    const text = 'AaAa';
    final controller = await pumpController(wt, text);

    await wt.sendKeyDownEvent(LogicalKeyboardKey.control);
    await wt.sendKeyEvent(LogicalKeyboardKey.keyF);
    await wt.sendKeyUpEvent(LogicalKeyboardKey.control);

    await wt.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(controller.searchController.shouldShow, false);
  });
}
