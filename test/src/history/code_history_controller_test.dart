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

        expect(controller.historyController.stack.length, 0);
      });

      testWidgets('Selection change creates 1 record after change', (wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);

        // The stack is empty -> Selection change creates.
        await wt.moveCursor(-1);
        expect(controller.historyController.stack.length, 1);
        expect(
          controller.historyController.stack.last.selection,
          TextSelection.collapsed(offset: controller.value.text.length),
        );

        // Stack has 1 record, new change is only selection change -> replace
        await wt.moveCursor(-1);
        expect(controller.historyController.stack.length, 1);
        expect(
          controller.historyController.stack.last.selection,
          TextSelection.collapsed(offset: controller.value.text.length - 1),
        );

        controller.value = controller.value.copyWith(
          selection:
              TextSelection.collapsed(offset: controller.value.text.length),
        );
        expect(controller.historyController.stack.length, 1);

        // Multiple selection changes preserves first and last change.
        // Removing inbetween ones.
        controller.value = controller.value.typed('a');

        // First selection change.
        await wt.moveCursor(-1);
        expect(controller.historyController.stack.length, 2);

        // Selection change inbetween.
        await wt.moveCursor(-1);
        expect(controller.historyController.stack.length, 3);

        // Last selection change.
        await wt.moveCursor(-1);
        expect(controller.historyController.stack.length, 3);

        expect(
          controller.historyController.stack.last.selection,
          TextSelection.collapsed(offset: controller.value.text.length - 3),
        );

        final stack = controller.historyController.stack;
        final preLastRecord = stack[stack.length - 2];
        expect(
          preLastRecord.selection,
          TextSelection.collapsed(offset: controller.value.text.length - 1),
        );
      });

      testWidgets(
        'Typing, Same value, Folding/Unfolding do not create',
        (WidgetTester wt) async {
          final controller = await pumpController(wt, MethodSnippet.full);
          await wt.cursorEnd();

          controller.value = controller.value;
          controller.value = controller.value.typed('a');
          controller.value = controller.value.typed('b');
          controller.value = controller.value;
          controller.foldAt(0);
          controller.unfoldAt(0);

          expect(controller.historyController.stack.length, 1);
        },
      );

      testWidgets('Typing + Selection change', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd();

        controller.value = controller.value.typed('a');
        final code1 = controller.code;
        await wt.moveCursor(-1); // Creates.

        controller.value = controller.value.typed('b');
        // final code2 = controller.code;
        await wt.moveCursor(1); // Creates.

        expect(controller.historyController.stack.length, 3);
        expect(
          controller.historyController.stack[1],
          CodeHistoryRecord(
            code: code1,
            selection: const TextSelection.collapsed(
              offset: MethodSnippet.visible.length,
            ),
          ),
        );

        // TODO(yescorp): uncomment when issue resolves.
        //  https://github.com/akvelon/flutter-code-editor/issues/179
        // expect(
        //   controller.historyController.stack[2],
        //   CodeHistoryRecord(
        //     code: code2,
        //     selection: const TextSelection.collapsed(
        //       offset: MethodSnippet.visible.length + 2,
        //     ),
        //   ),
        // );
      });

      testWidgets('Line count change after text change',
          (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd(); // Creates.
        expect(controller.historyController.stack.length, 1);

        controller.value = controller.value.typed('a');
        final code1 = controller.code;
        final selection1 = controller.selection;

        // Creates before and after.
        controller.value = controller.value.typed('\n');
        final code2 = controller.code;
        final selection2 = controller.selection;

        expect(controller.historyController.stack.length, 3);

        controller.value = controller.value.typed('a');
        final code3 = controller.code;
        final selection3 = controller.selection;

        // Creates before and after.
        controller.value = controller.value.typed('\n');
        final code4 = controller.code;
        final selection4 = controller.selection;
        expect(controller.historyController.stack.length, 5);

        // Creates before and after. Removes repetitions.
        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);
        final code5 = controller.code;
        final selection5 = controller.selection;

        expect(controller.historyController.stack.length, 6);
        expect(
          controller.historyController.stack[1],
          CodeHistoryRecord(code: code1, selection: selection1),
        );
        expect(
          controller.historyController.stack[2],
          CodeHistoryRecord(code: code2, selection: selection2),
        );
        expect(
          controller.historyController.stack[3],
          CodeHistoryRecord(code: code3, selection: selection3),
        );
        expect(
          controller.historyController.stack[4],
          CodeHistoryRecord(code: code4, selection: selection4),
        );
        expect(
          controller.historyController.stack[5],
          CodeHistoryRecord(code: code5, selection: selection5),
        );
      });

      testWidgets('Line count changes in a row', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd(); // Creates.
        expect(controller.historyController.stack.length, 1);

        // Creates before and after. Removes repetitions.
        controller.value = controller.value.typed('\n');
        expect(controller.historyController.stack.length, 2);
        final code1 = controller.code;

        // Creates before and after. Removes repetitions.
        controller.value = controller.value.typed('\n');
        expect(controller.historyController.stack.length, 3);

        final code2 = controller.code;
        // Creates before and after. Removes repetitions.
        await wt.sendKeyEvent(LogicalKeyboardKey.backspace);

        expect(controller.historyController.stack.length, 4);
        expect(
          controller.historyController.stack[1],
          CodeHistoryRecord(
            code: code1,
            selection: const TextSelection.collapsed(
              offset: MethodSnippet.visible.length + 1,
            ),
          ),
        );
        expect(
          controller.historyController.stack[2],
          CodeHistoryRecord(
            code: code2,
            selection: const TextSelection.collapsed(
              offset: MethodSnippet.visible.length + 2,
            ),
          ),
        );
      });

      testWidgets('Typing + Timeout', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        Code? code1;
        int? recordCountAfterFirstIdle;
        await wt.cursorEnd();

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
        await wt.cursorEnd();

        await wt.sendUndo(); // No effect.

        expect(controller.fullText, MethodSnippet.full);
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
            affinity: TextAffinity.upstream,
          ),
        );

        await wt.sendRedo(); // No effect.

        expect(controller.fullText, MethodSnippet.full);
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
            affinity: TextAffinity.upstream,
          ),
        );
      });

      testWidgets('Undo to bottom, then redo', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd();

        controller.value = controller.value.typed('a');
        await wt.moveCursor(-1); // Creates.

        controller.value = controller.value.typed('b');
        await wt.moveCursor(-1); // Creates.

        controller.value = controller.value.typed('c');

        await wt.sendUndo(); // Creates.

        expect(controller.historyController.stack.length, 4);
        expect(controller.fullText, MethodSnippet.full + 'ba');
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
          ),
        );

        await wt.sendUndo();

        expect(controller.fullText, MethodSnippet.full + 'a');

        await wt.sendUndo(); // To initial.

        expect(controller.fullText, MethodSnippet.full);

        // TODO(yescorp): uncomment when issue resolves.
        //  https://github.com/akvelon/flutter-code-editor/issues/179
        // expect(
        //   controller.selection,
        //   const TextSelection.collapsed(offset: 40),
        // );

        await wt.sendUndo(); // No effect.

        expect(controller.fullText, MethodSnippet.full);

        await wt.sendRedo();

        expect(controller.fullText, MethodSnippet.full + 'a');
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
          ),
        );

        await wt.sendRedo();

        expect(controller.fullText, MethodSnippet.full + 'ba');

        await wt.sendRedo();

        expect(controller.fullText, MethodSnippet.full + 'cba');

        await wt.sendRedo(); // No effect.

        expect(controller.fullText, MethodSnippet.full + 'cba');
      });

      testWidgets('Changing text disables redo', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd();

        controller.value = controller.value.typed('a');
        await wt.moveCursor(-1); // Creates.

        controller.value = controller.value.typed('b');

        await wt.sendUndo(); // Creates.

        expect(controller.fullText, MethodSnippet.full + 'a');
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
          ),
        );

        controller.value = controller.value.typed('b'); // Deletes redo records.

        expect(controller.historyController.stack.length, 2);

        await wt.sendRedo(); // No effect.

        expect(controller.historyController.stack.length, 2);

        await wt.moveCursor(-1); // Creates.

        expect(controller.fullText, MethodSnippet.full + 'ba');
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
          ),
        );

        await wt.sendUndo();
        await wt.sendUndo();

        expect(controller.fullText, MethodSnippet.full);

        await wt.sendRedo();
        await wt.sendRedo();

        expect(controller.fullText, MethodSnippet.full + 'ba');
      });

      testWidgets('Selection disables redo', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);

        await wt.cursorEnd();
        controller.value = controller.value.typed('a');
        await wt.sendUndo(); // Creates.
        expect(controller.historyController.stack.length, 2);
        await wt.pumpAndSettle();

        controller.value = controller.value.copyWith(
          selection: const TextSelection.collapsed(offset: 0),
        );
        expect(controller.historyController.stack.length, 1);
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
            offset: MethodSnippet.visible.length,
          ),
        );

        // 4. Can redo.

        // One too many.
        for (int i = 0; i < CodeHistoryController.limit; i++) {
          await wt.sendRedo();
        }

        expect(
          controller.fullText,
          MethodSnippet.full + 'a' * CodeHistoryController.limit,
        );
        expect(
          controller.selection,
          const TextSelection.collapsed(
            offset: MethodSnippet.visible.length,
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
