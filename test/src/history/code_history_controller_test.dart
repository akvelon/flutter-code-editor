// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:fake_async/fake_async.dart';
import 'package:flutter/services.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_code_editor/src/history/code_history_controller.dart';
import 'package:flutter_code_editor/src/history/code_history_record.dart';
import 'package:flutter_test/flutter_test.dart';

import '../common/create_app.dart';
import '../common/snippets.dart';
import '../common/widget_tester.dart';

void main() {
  group('CodeHistoryController.', () {
    group('Creating records.', () {
      testWidgets('Initial record', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);

        expect(
          controller.historyController.stack,
          [],
        );
      });

      testWidgets(
        'Typing, Same value, Folding/Unfolding do not create',
        (WidgetTester wt) async {
          final controller = await pumpController(wt, MethodSnippet.full);
          controller.value = controller.value.copyWith(
            selection: TextSelection.collapsed(
              offset: controller.value.text.length,
            ),
          );

          expect(controller.historyController.stack.length, 1);

          controller.value = controller.value;
          controller.value = controller.value.typed('a');
          controller.value = controller.value.typed('b');
          controller.value = controller.value;
          controller.foldAt(0);
          controller.unfoldAt(0);

          expect(controller.historyController.stack.length, 1);
        },
      );

      testWidgets('Empty stack -> any change creates record',
          (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        expect(controller.historyController.stack.length, 0);

        await wt.moveCursor(-1);
        expect(controller.historyController.stack.length, 1);
      });

      testWidgets('Only selection change -> does not create',
          (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        expect(controller.historyController.stack.length, 0);

        await wt.moveCursor(-1); // Creates because empty stack
        expect(controller.historyController.stack.length, 1);

        await wt.moveCursor(-5);
        expect(controller.historyController.stack.length, 1);
      });

      testWidgets('Typing + Selection change', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        expect(controller.historyController.stack.length, 0);

        await wt.cursorEnd(); // Creates because stack is empty.

        expect(controller.historyController.stack.length, 1);

        controller.value = controller.value.typed('a');
        final code1 = controller.code;
        await wt.moveCursor(-1); // Creates.
        expect(controller.historyController.stack.length, 2);

        controller.value = controller.value.typed('b');
        final code2 = controller.code;
        await wt.moveCursor(1); // Creates.
        expect(controller.historyController.stack.length, 3);

        expect(controller.historyController.stack[1].code, code1);
        expect(controller.historyController.stack[2].code, code2);
      });

      testWidgets('Line count change', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);

        await wt.cursorEnd(); // Creates.

        expect(controller.historyController.stack.length, 1);

        controller.value = controller.value.typed('\n'); // Creates.
        final code1 = controller.code;

        controller.value = controller.value.typed('\n'); // Creates.
        final code2 = controller.code;

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace); // Creates.

        expect(controller.historyController.stack.length, 4);
        expect(controller.historyController.stack[1].code, code1);
        expect(controller.historyController.stack[2].code, code2);
      });

      testWidgets('Typing + Timeout', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        Code? code1;
        int? recordCountAfterFirstIdle;
        await wt.cursorEnd();

        expect(controller.historyController.stack.length, 1);

        fakeAsync((async) {
          controller.value = controller.value.typed('a');

          async.elapse(
            CodeHistoryController.idle - const Duration(microseconds: 1),
          );

          controller.value = controller.value.typed('b');
          code1 = controller.code;

          async.elapse(CodeHistoryController.idle); // Creates.
          recordCountAfterFirstIdle = controller.historyController.stack.length;

          async.elapse(CodeHistoryController.idle * 2);
        });

        expect(recordCountAfterFirstIdle, 2);
        expect(controller.historyController.stack.length, 2);
        expect(
          controller.historyController.stack[1],
          CodeHistoryRecord(
            code: code1!,
            selection: const TextSelection.collapsed(
              offset: MethodSnippet.visible.length + 2,
            ),
          ),
        );
      });
    });

    group('Undo/Redo.', () {
      testWidgets('Cannot initially', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        expect(controller.historyController.stack.length, 0);

        await wt.sendUndo(); // No effect.

        expect(controller.fullText, MethodSnippet.full);
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
          ),
        );

        await wt.sendRedo(); // No effect.

        expect(controller.fullText, MethodSnippet.full);
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
          ),
        );
      });

      testWidgets('Undo to bottom, then redo', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd();

        expect(controller.historyController.stack.length, 1);

        controller.value = controller.value.typed('a');
        await wt.moveCursor(-1); // Creates.

        expect(controller.historyController.stack.length, 2);

        controller.value = controller.value.typed('b');
        await wt.moveCursor(-1); // Creates.

        expect(controller.historyController.stack.length, 3);

        controller.value = controller.value.typed('c');

        await wt.sendUndo(); // Creates.

        expect(controller.historyController.stack.length, 4);
        expect(controller.fullText, MethodSnippet.full + 'ba');
        //                                                 \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );

        await wt.sendUndo();

        expect(controller.fullText, MethodSnippet.full + 'a');
        //                                                 \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );

        await wt.sendUndo();

        expect(controller.fullText, MethodSnippet.full);
        //                                            \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
          ),
        );

        expect(controller.fullText, MethodSnippet.full);

        await wt.sendRedo();

        expect(controller.fullText, MethodSnippet.full + 'a');
        //                                                 \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );

        await wt.sendRedo();

        expect(controller.fullText, MethodSnippet.full + 'ba');
        //                                                 \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );

        await wt.sendRedo();

        expect(controller.fullText, MethodSnippet.full + 'cba');
        //                                                 \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );

        await wt.sendRedo(); // does nothing

        expect(controller.fullText, MethodSnippet.full + 'cba');
        //                                                 \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );
      });

      testWidgets('Changing text disables redo', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd();

        expect(controller.historyController.stack.length, 1);

        controller.value = controller.value.typed('a');
        await wt.moveCursor(-1); // Creates.
        expect(controller.historyController.stack.length, 2);

        controller.value = controller.value.typed('b');
        expect(controller.historyController.stack.length, 2);

        await wt.sendUndo(); // Creates.
        expect(controller.historyController.stack.length, 3);

        expect(controller.fullText, MethodSnippet.full + 'a');
        //                                                 \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );

        controller.value = controller.value.typed('b'); // Deletes redo records.
        expect(controller.fullText, MethodSnippet.full + 'ab');
        //                                                  \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 2,
          ),
        );

        expect(controller.historyController.stack.length, 2);

        await wt.sendRedo(); // No effect.
        expect(controller.fullText, MethodSnippet.full + 'ab');
        //                                                  \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 2,
          ),
        );

        expect(controller.historyController.stack.length, 2);

        await wt.moveCursor(-1); // Creates.
        expect(controller.historyController.stack.length, 3);

        expect(controller.fullText, MethodSnippet.full + 'ab');
        //                                                 \ selection
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );

        await wt.sendUndo();
        await wt.sendUndo();

        expect(controller.fullText, MethodSnippet.full);

        await wt.sendRedo();
        await wt.sendRedo();

        expect(controller.fullText, MethodSnippet.full + 'ab');
      });

      testWidgets('Selection disables redo', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);

        await wt.cursorEnd();
        controller.historyController.deleteHistory();

        controller.value = controller.value.typed('a');
        await wt.sendUndo(); // Creates.
        await wt.pumpAndSettle();

        controller.value = controller.value.copyWith(
          selection: const TextSelection.collapsed(offset: 0),
        );
        expect(controller.historyController.stack.length, 2);
      });

      testWidgets('Limit depth', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd();

        // 1. Fill the limit.

        for (int i = 0; i < CodeHistoryController.limit - 1; i++) {
          controller.value = controller.value.typed('a');
          await wt.moveCursor(-1); // Creates.
        }

        expect(
          controller.historyController.stack.length,
          CodeHistoryController.limit,
        );

        // 2. Overflow drops the oldest record.

        controller.value = controller.value.typed('a');
        await wt.moveCursor(-1); // Creates, drops the oldest.

        expect(
          controller.historyController.stack.length,
          CodeHistoryController.limit,
        );

        // 3. Can undo to bottom.

        // One too many.
        for (int i = 0; i < CodeHistoryController.limit; i++) {
          await wt.sendUndo();
        }

        expect(controller.fullText, MethodSnippet.full + 'a'); //Last not undone
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );

        // 4. Can redo.

        // One too many.
        for (int i = 0; i < CodeHistoryController.limit; i++) {
          await wt.sendRedo();
        }

        expect(controller.fullText, MethodSnippet.full + 'a' * 100);
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length + 1,
          ),
        );
      });
    });

    testWidgets('deleteHistory', (WidgetTester wt) async {
      final controller = await pumpController(wt, MethodSnippet.full);
      await wt.cursorEnd();

      controller.value = controller.value.typed('a');
      await wt.moveCursor(-1); // Creates.

      controller.historyController.deleteHistory();

      expect(controller.historyController.stack.length, 1);
      expect(
        controller.historyController.stack[0].code.text,
        MethodSnippet.full + 'a',
      );
      expect(
        controller.historyController.stack[0].selection,
        const TextSelection.collapsed(
          offset: MethodSnippet.visible.length,
        ),
      );
    });
  });
}
