import 'dart:async';

import 'package:flutter/widgets.dart';

import '../code/code.dart';
import '../code_field/code_controller.dart';
import '../code_field/text_selection.dart';
import 'code_history_record.dart';

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
  bool _isTextChanged = false;
  Timer? _debounceTimer;

  @visibleForTesting
  final stack = <CodeHistoryRecord>[];

  static const idle = Duration(seconds: 5);
  static const limit = 100;

  CodeHistoryController({
    required this.codeController,
  })  : lastCode = codeController.code,
        lastSelection = codeController.value.selection {
    _push();
  }

  void beforeChanged(Code code, TextSelection selection) {
    _dropRedoIfNeed();
    bool save = false;

    if (_isTextChanged) {
      save = code.lines.lines.length != lastCode.lines.lines.length;
    }

    if (!save) {
      if (lastCode.text != code.text) {
        _isTextChanged = true;
      }

      final isTextOneCharLonger = code.text.length == lastCode.text.length + 1;
      final isSelectionChangeImportant = !isTextOneCharLonger ||
          !selection.hasMovedOneCharacterRight(lastSelection);

      if (_isTextChanged) {
        if (isSelectionChangeImportant) {
          save = true;
        } else {
          _setTimer();
        }
      }
    }

    if (save) {
      _push();
    }

    lastCode = code;
    lastSelection = selection;
  }

  void _dropRedoIfNeed() {
    stack.removeRange(_currentRecordIndex + 1, stack.length);
  }

  void undo() {
    if (_isTextChanged) {
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
    _debounceTimer?.cancel();
    _pushRecord(_createRecord());
    _isTextChanged = false;
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
    stack.add(record);
    _currentRecordIndex = stack.length - 1;

    if (stack.length > limit) {
      stack.removeRange(0, stack.length - limit);
      _currentRecordIndex = limit - 1;
    }
  }

  void deleteHistory() {
    stack.clear();
    _push();
    _currentRecordIndex = 0;
  }
}
