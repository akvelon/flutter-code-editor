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
          [
            CodeHistoryRecord(
              code: controller.code,
              selection: const TextSelection.collapsed(offset: -1),
            ),
          ],
        );
      });

      testWidgets('Only selection change', (wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        // Right now cursor is not inside of a TextField,
        // but the focusNode has focus.

        // Stack has 1 record, new change is only selection change -> replace.
        await wt.moveCursor(-1); // +after
        expect(controller.historyController.stack.length, 1);
        expect(
          controller.historyController.stack.last.selection,
          TextSelection.collapsed(offset: controller.value.text.length),
        );

        controller.value = controller.value.copyWith();
        expect(controller.historyController.stack.length, 1);

        // Multiple selection changes preserves first and last change.
        // Removing inbetween ones.

        controller.value = controller.value.typed('a');

        // First selection change creates record before and after.
        await wt.moveCursor(-1); // +before +after
        expect(controller.historyController.stack.length, 3);

        // Selection change removes record inbetween.
        await wt.moveCursor(-1); // -before +after
        expect(controller.historyController.stack.length, 3);

        expect(
          controller.historyController.stack.last.selection,
          TextSelection.collapsed(offset: controller.value.text.length - 2),
        );

        final stack = controller.historyController.stack;
        final preLastRecord = stack[stack.length - 2];
        expect(
          preLastRecord.selection,
          TextSelection.collapsed(offset: controller.value.text.length),
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

        controller.value = controller.value.typed('a'); // Schedules.
        final code1 = controller.code;
        final selection1 = controller.selection;
        await wt.moveCursor(-1); // +before +after
        final code2 = controller.code;
        final selection2 = controller.selection;

        controller.value = controller.value.typed('b');
        final code3 = controller.code;
        final selection3 = controller.selection;
        await wt.moveCursor(-1); // +before +after
        final code4 = controller.code;
        final selection4 = controller.selection;

        expect(controller.historyController.stack.length, 5);

        expect(controller.historyController.stack[1].code, code1);
        expect(controller.historyController.stack[1].selection, selection1);

        expect(controller.historyController.stack[2].code, code2);
        expect(controller.historyController.stack[2].selection, selection2);

        expect(controller.historyController.stack[3].code, code3);
        expect(controller.historyController.stack[3].selection, selection3);

        expect(controller.historyController.stack[4].code, code4);
        expect(controller.historyController.stack[4].selection, selection4);
      });

      testWidgets('Line count change after text change',
          (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);

        final manualHistoryRecords = <CodeHistoryRecord>[];

        await wt.cursorEnd(); // Replaces.
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        controller.value = controller.value.typed('a'); // Schedules.

        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );
        controller.value = controller.value.typed('\n'); // +before +after
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        expect(controller.historyController.stack.length, 3);

        controller.value = controller.value.typed('a'); // Schedules.

        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );
        controller.value = controller.value.typed('\n'); // +before +after
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );
        expect(controller.historyController.stack.length, 5);

        await wt.sendKeyEvent(LogicalKeyboardKey.backspace); // +after
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        controller.value = controller.value.typed('\n'); // +after
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        controller.value = controller.value.typed('\n'); // +after
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        expect(
          controller.historyController.stack.length,
          manualHistoryRecords.length,
        );

        for (int i = 0; i < manualHistoryRecords.length; i++) {
          expect(
            manualHistoryRecords[i].code,
            controller.historyController.stack[i].code,
          );
          expect(
            manualHistoryRecords[i].selection,
            controller.historyController.stack[i].selection,
          );
        }
      });

      testWidgets('Typing + Timeout', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        Code? code1;
        int? recordCountAfterFirstIdle;
        await wt.cursorEnd();

        fakeAsync((async) {
          controller.value = controller.value.typed('a'); // Schedules.

          async.elapse(
            CodeHistoryController.idle - const Duration(microseconds: 1),
          );

          controller.value = controller.value.typed('b'); // Schedules.
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

        final manualHistoryRecords = <CodeHistoryRecord>[];
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        controller.value = controller.value.typed('a'); // Schedules.
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );
        await wt.moveCursor(-1); // +before +after
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        controller.value = controller.value.typed('b'); // Schedules.
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );
        await wt.moveCursor(-1); // +before +after
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        controller.value = controller.value.typed('c'); // Schedules.
        manualHistoryRecords.add(
          CodeHistoryRecord(
            code: controller.code,
            selection: controller.selection,
          ),
        );

        expect(controller.historyController.stack.length, 5);

        await wt.sendUndo(); // Creates.
        expect(controller.historyController.stack.length, 6);

        // Undo to bottom.

        for (int i = manualHistoryRecords.length - 2; i >= 0; i--) {
          expect(
            controller.value.text,
            manualHistoryRecords[i].code.visibleText,
          );
          await wt.sendUndo();
        }

        await wt.sendUndo(); // One too many.
        expect(
          controller.value.text,
          manualHistoryRecords.first.code.visibleText,
        );

        // Redo to top.

        for (int i = 0; i < manualHistoryRecords.length; i++) {
          expect(
            controller.value.text,
            manualHistoryRecords[i].code.visibleText,
          );
          await wt.sendRedo();
        }

        await wt.sendRedo(); // One too many.
        expect(
          controller.value.text,
          manualHistoryRecords.last.code.visibleText,
        );
      });

      testWidgets('Changing text disables redo', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);
        await wt.cursorEnd();

        controller.value = controller.value.typed('a'); // Schedules.
        await wt.moveCursor(-1); // +before +after
        final code2 = controller.code;
        final selection2 = controller.selection;

        controller.value = controller.value.typed('b'); // Schedules.

        await wt.sendUndo(); // Creates.

        expect(controller.code.text, code2.text);
        expect(controller.selection, selection2);

        expect(controller.historyController.stack.length, 4);

        controller.value = controller.value.typed('c'); // Deletes redo records.
        final code4 = controller.code;
        final selection4 = controller.selection;

        expect(controller.historyController.stack.length, 3);

        await wt.sendRedo(); // No effect.
        expect(controller.code.text, code4.text);
        expect(controller.selection, selection4);
        expect(controller.historyController.stack.last.code, code2);
        expect(controller.historyController.stack.last.selection, selection2);
      });

      testWidgets('Start typing -> Fold -> Continue -> Undo -> Still folded',
          (wt) async {
        const example = 'a\n// comment 1\n// comment2\n a';
        const visible = 'a\n// comment 1\n a';
        final controller = await pumpController(wt, example);
        await wt.cursorEnd();

        controller.value = controller.value.typed('b'); // Schedules.
        await wt.moveCursor(-1); // +before +after
        expect(controller.historyController.stack.length, 3);

        controller.foldAt(1);

        controller.value = controller.value.typed('a'); // Schedules.
        await wt.moveCursor(-1); // +before +after
        expect(controller.historyController.stack.length, 5);

        await wt.sendUndo();
        expect(controller.value.text, visible + 'ab'); // Keeps folding.
        //                                        \ selection
        expect(
          controller.value.selection,
          TextSelection.collapsed(offset: controller.value.text.length - 1),
        );
        await wt.sendUndo();
        expect(controller.value.text, visible + 'b');
        //                                       \ selection
        expect(
          controller.value.selection,
          TextSelection.collapsed(offset: controller.value.text.length - 1),
        );
        await wt.sendUndo();
        expect(controller.value.text, visible + 'b');
        //                                        \ selection
        expect(
          controller.value.selection,
          TextSelection.collapsed(offset: controller.value.text.length),
        );
        await wt.sendUndo();
        expect(controller.value.text, visible);
        //                                   \ selection
        expect(
          controller.value.selection.start,
          controller.value.text.length,
        );

        expect(controller.code.foldedBlocks.length, 1);

        await wt.sendRedo();
        await wt.sendRedo();
        await wt.sendRedo();
        await wt.sendRedo();

        expect(controller.code.foldedBlocks.length, 1);
      });

      testWidgets('Selection disables redo', (WidgetTester wt) async {
        final controller = await pumpController(wt, MethodSnippet.full);

        await wt.cursorEnd();
        controller.value = controller.value.typed('a'); // Schedules.
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

        Code? firstCode;
        TextSelection? firstSelection;

        for (int i = 0; i < CodeHistoryController.limit - 2; i++) {
          controller.value = controller.value.typed('ab'); // Creates.
          firstCode ??= controller.code;
          firstSelection ??= controller.selection;
        }

        expect(
          controller.historyController.stack.length,
          CodeHistoryController.limit - 1,
        );

        controller.value = controller.value.typed('ab'); // Creates.

        expect(
          controller.historyController.stack.length,
          CodeHistoryController.limit,
        );

        // 2. Overflow drops the oldest record.

        controller.value = controller.value.typed('ab'); // Creates.

        expect(
          controller.historyController.stack.length,
          CodeHistoryController.limit,
        );

        expect(
          controller.historyController.stack.first.code,
          firstCode,
        );
        expect(
          controller.historyController.stack.first.selection,
          firstSelection,
        );
      });
    });

    testWidgets('deleteHistory', (WidgetTester wt) async {
      final controller = await pumpController(wt, MethodSnippet.full);
      await wt.cursorEnd();

      controller.value = controller.value.typed('a'); // Schedules.
      await wt.moveCursor(-1); // +before +after

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
