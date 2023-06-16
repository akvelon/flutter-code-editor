import 'package:flutter/widgets.dart';

import '../code/reg_exp.dart';
import '../code/string.dart';
import '../code/text_range.dart';
import '../code_field/code_controller.dart';
import '../util/edit_type.dart';
import 'text_selection.dart';

extension TextEditingValueExtension on TextEditingValue {
  /// The position where the word at the cursor starts.
  /// `null` for a non-collapsed selection.
  int? get wordAtCursorStart {
    final startEnd = _getWordAtCursorStartEnd();
    if (startEnd == null) {
      return null;
    }

    final start = startEnd[0];
    final end = startEnd[1];

    return end > start ? start : null;
  }

  /// The word at the cursor, including if it is on either side of the cursor.
  /// `null` for a non-collapsed selection.
  String? get wordAtCursor {
    final startEnd = _getWordAtCursorStartEnd();
    if (startEnd == null) {
      return null;
    }

    final start = startEnd[0];
    final end = startEnd[1];

    return end > start ? text.substring(start, end) : null;
  }

  List<int>? _getWordAtCursorStartEnd() {
    if (!selection.isCollapsed) {
      return null;
    }

    final cursorPosition = selection.normalized.start;
    if (cursorPosition < 0) {
      return null;
    }

    final text = this.text;
    final start = cursorPosition > 0
        ? text.lastIndexOf(RegExps.wordSplit, cursorPosition - 1) + 1
        : 0;
    final firstNonWord = text.indexOf(RegExps.wordSplit, cursorPosition);
    final end = firstNonWord == -1 ? text.length : firstNonWord;

    return [start, end];
  }

  /// The part of the word at the cursor from start to the cursor.
  /// `null` for a non-collapsed selection.
  String? get wordToCursor {
    final startEnd = _getWordAtCursorStartEnd();
    if (startEnd == null) {
      return null;
    }

    final cursorPosition = selection.normalized.start;
    final start = startEnd[0];

    return cursorPosition > start
        ? text.substring(start, cursorPosition)
        : null;
  }

  TextEditingValue deleteSelection() {
    return replaced(selection, '');
  }

  TextEditingValue replacedText(String newText) {
    if (newText == text) {
      return this;
    }

    final rangeAfter = newText.getChangedRange(
      text,
      attributeChangeTo: TextAffinity.upstream,
    );

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: rangeAfter.start),
    );
  }

  TextEditingValue tabsToSpaces(int spaceCount) {
    final replacedBefore = beforeSelection.tabsToSpaces(spaceCount);
    final replacedSelected = selected.tabsToSpaces(spaceCount);
    final replacedAfter = afterSelection.tabsToSpaces(spaceCount);

    final finalText = replacedBefore + replacedSelected + replacedAfter;

    return TextEditingValue(
      text: finalText,
      selection: _getSelectionFromSubstrings(
        replacedBefore,
        replacedSelected,
        replacedAfter,
      ),
      composing: composing,
    );
  }

  TextSelection _getSelectionFromSubstrings(
    String beforeSelection,
    String inSelection,
    String afterSelection,
  ) {
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      return const TextSelection.collapsed(offset: -1);
    }

    final baseOffset = beforeSelection.length;
    final extentOffset = baseOffset + inSelection.length;

    final result = selection.copyWith(
      baseOffset: baseOffset,
      extentOffset: extentOffset,
    );

    return selection.isSelectionNormalized ? result : result.reversed;
  }

  String get beforeSelection {
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      return '';
    }
    return text.substring(0, selection.start);
  }

  String get selected {
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      return '';
    }
    final selectionSubstring = text.substring(
      selection.start,
      selection.end,
    );
    return selectionSubstring;
  }

  String get afterSelection {
    if (selection.baseOffset == -1 || selection.extentOffset == -1) {
      return text;
    }
    return text.substring(selection.end);
  }

  TextEditingValue typed(String text) {
    final lengthDiff = text.length - selected.length;

    return replaced(selection, text).copyWith(
      selection: TextSelection.collapsed(offset: selection.end + lengthDiff),
    );
  }

  TextEditingValue? select(Pattern pattern, [int start = 0]) {
    if (pattern == '') {
      throw AssertionError('Cannot search for an empty pattern');
    }

    final position = text.indexOf(pattern, start);
    if (position == -1) {
      return null;
    }

    final match = pattern.matchAsPrefix(text, position);
    if (match == null) {
      throw AssertionError('');
    }

    return TextEditingValue(
      composing: composing,
      selection: TextSelection(
        baseOffset: position,
        extentOffset: match.end,
      ),
      text: text,
    );
  }

  /// Returns the widest [TextRange] of this that is different from [oldValue]
  /// if it can be produced by any of common edits allowed for user input.
  /// These are all edits that go through [CodeController.value] setter
  /// and do not include undo/redo.
  ///
  /// Returns null if the change cannot be produced by such user edits.
  TextRange? getChangedRange(TextEditingValue oldValue) {
    switch (getEditType(oldValue)) {
      case EditType.backspaceBeforeCollapsedSelection:
        return TextRange.collapsed(
          text.length - oldValue.afterSelection.length,
        );

      case EditType.deleteSelection:
      case EditType.deleteAfterCollapsedSelection:
        return TextRange.collapsed(oldValue.beforeSelection.length);

      case EditType.replaceSelection:
      case EditType.insertAtCollapsedSelection:
        return TextRange(
          start: oldValue.beforeSelection.length,
          end: text.length - oldValue.afterSelection.length,
        );

      case EditType.unchanged:
      case EditType.other:
        return null;
    }
  }

  EditType getEditType(TextEditingValue oldValue) {
    if (oldValue.text == text) {
      return EditType.unchanged;
    }

    final oldBefore = oldValue.beforeSelection;
    final oldAfter = oldValue.afterSelection;
    final oldUnselectedLength = oldBefore.length + oldAfter.length;

    if (text.length < oldUnselectedLength) {
      if (text.startsWith(oldBefore) && selection == oldValue.selection) {
        return EditType.deleteAfterCollapsedSelection;
      }

      if (text.endsWith(oldAfter) &&
          selection.isCollapsed &&
          selection.start ==
              text.length - oldValue.text.length + oldValue.selection.start) {
        return EditType.backspaceBeforeCollapsedSelection;
      }

      return EditType.other;
    }

    if (text.startsWith(oldBefore) && text.endsWith(oldAfter)) {
      if (oldValue.selection.isCollapsed) {
        return EditType.insertAtCollapsedSelection;
      }

      if (text.length == oldUnselectedLength) {
        return EditType.deleteSelection;
      }

      return EditType.replaceSelection;
    }

    return EditType.other;
  }
}
