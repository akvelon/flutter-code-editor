import 'dart:async';

import 'package:flutter/widgets.dart';

import '../code/code.dart';
import '../code_field/code_controller.dart';
import '../code_field/text_selection.dart';
import 'code_history_record.dart';
import 'limit_stack.dart';

enum HistoryControllerAction {
  newEntryAfterEdit,
  newEntriesBeforeAndAfterEdit,
  setTimer,
}

/// A custom undo/redo implementation for [CodeController].
///
/// This is needed because the built-in implementation listens to the
/// visible text changes in [TextEditingController] and sets that on undo/redo.
/// This would delete hidden ranges and folded blocks.
///
/// With this controller, new records are created:
/// - If the line count has changed.
/// - After the [idle] duration if the text has changed since the last record.
/// - On any selection change other than that of inserting a single
///   character, if the text has changed since the last record.
class CodeHistoryController {
  final CodeController codeController;
  Code lastCode;
  TextSelection lastSelection;
  int _currentRecordIndex = 0;
  bool _wasTextChanged = false;
  Timer? _debounceTimer;

  @visibleForTesting
  final stack = LimitStack<CodeHistoryRecord>(maxLength: limit);

  static const idle = Duration(seconds: 5);
  static const limit = 100;

  CodeHistoryController({
    required this.codeController,
  })  : lastCode = codeController.code,
        lastSelection = codeController.value.selection {
    _push();
  }

  void beforeChanged({
    required Code code,
    required TextSelection selection,
    required bool isTextChanging,
  }) {
    if (isTextChanging) {
      _wasTextChanged = true;
      _dropRedoIfAny();
    }

    final action = _getAction(
      code: code,
      selection: selection,
      isTextChanging: isTextChanging,
    );

    switch (action) {
      case HistoryControllerAction.newEntriesBeforeAndAfterEdit:
        _push();
        lastCode = code;
        lastSelection = selection;
        _push();
        break;

      case HistoryControllerAction.newEntryAfterEdit:
        lastCode = code;
        lastSelection = selection;
        _push();
        break;

      case HistoryControllerAction.setTimer:
        _setTimer();
        break;
    }

    lastCode = code;
    lastSelection = selection;

    _removeLastRedundantSelectionOnlyChanges();
  }

  HistoryControllerAction _getAction({
    required Code code,
    required TextSelection selection,
    required bool isTextChanging,
  }) {
    {
      // If the line count is changed, we add record before and after edit.
      if (code.lines.length != lastCode.lines.length) {
        return HistoryControllerAction.newEntriesBeforeAndAfterEdit;
      }
    }

    {
      // If change is caused by casual typing, we re-set the timer.
      final isText1CharLonger = code.text.length == lastCode.text.length + 1;
      final isTypingContinuous = isText1CharLonger &&
          selection.hasMovedOneCharacterRight(lastSelection);
      if (isTypingContinuous) {
        return HistoryControllerAction.setTimer;
      }
    }

    // Any other change will create record after edit.
    return HistoryControllerAction.newEntryAfterEdit;
  }

  void _removeLastRedundantSelectionOnlyChanges() {
    switch (stack.length) {
      case 0:
      case 1:
        return;

      case 2:
        // Drop the first one if only selection has changed.
        if (_isFullTextSame([stack[0], stack[1]])) {
          stack.removeAt(0);
        }
        break;

      default:
        // Check last, last-1, last-2. Drop last-1.
        final last = stack.last;
        final lastMinus1 = stack[stack.length - 2];
        final lastMinus2 = stack[stack.length - 3];

        if (_isFullTextSame([last, lastMinus1, lastMinus2])) {
          stack.removeAt(stack.length - 2);
        }
    }
  }

  bool _isFullTextSame(List<CodeHistoryRecord> records) {
    final first = records.first;

    for (int i = 1; i < records.length; i++) {
      if (records[i].code.text != first.code.text) {
        return false;
      }
    }

    return true;
  }

  void _dropRedoIfAny() {
    final startIndexToRemove = _currentRecordIndex + 1;
    if (startIndexToRemove < stack.length) {
      stack.removeStartingAt(startIndexToRemove);
    }
  }

  void undo() {
    if (_wasTextChanged) {
      _push();
    }

    if (_currentRecordIndex == 0) {
      return;
    }

    _applyHistoryRecord(stack[--_currentRecordIndex]);
  }

  void redo() {
    if (_currentRecordIndex == stack.length - 1) {
      return;
    }

    _applyHistoryRecord(stack[++_currentRecordIndex]);
  }

  void _applyHistoryRecord(CodeHistoryRecord record) {
    lastCode = record.code;
    lastSelection = record.selection;

    codeController.applyHistoryRecord(record);
  }

  void _push() {
    if (!lastSelection.isValid) {
      // Do not create record for invalid selection
      // as it is not considered to be standart user input.
      return;
    }

    if (stack.isNotEmpty &&
        stack.last.code.text == lastCode.text &&
        stack.last.selection == lastSelection) {
      // Do not create record if the last record is the same as the new one.
      return;
    }
    _dropRedoIfAny();

    _debounceTimer?.cancel();
    _pushRecord(_createRecord());
    _wasTextChanged = false;
  }

  void _setTimer() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(idle, _push);
  }

  CodeHistoryRecord _createRecord() {
    return CodeHistoryRecord(
      code: lastCode,
      selection: lastSelection,
    );
  }

  void _pushRecord(CodeHistoryRecord record) {
    stack.push(record);
    _currentRecordIndex = stack.length - 1;
  }

  void deleteHistory() {
    stack.clear();
    _push();
    _currentRecordIndex = 0;
  }

  void dispose() {
    _debounceTimer?.cancel();
  }
}
