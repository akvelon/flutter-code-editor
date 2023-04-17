import 'package:flutter/widgets.dart';

import '../code/reg_exp.dart';
import '../code/string.dart';
import '../code/text_range.dart';
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

  /// Checks if the newValue is most likely
  /// to be caused by the `delete` button.
  bool isDelete(TextEditingValue newValue) {
    return _isCollapsedAndOneCharShort(newValue) &&
        selection.start == newValue.selection.start &&
        beforeSelection == newValue.beforeSelection &&
        (afterSelection.isEmpty ? '' : afterSelection.substring(1)) ==
            newValue.afterSelection;
  }

  /// Checks if the newValue is most likely
  /// to be caused by the `backspace` button.
  bool isBackspace(TextEditingValue newValue) {
    return _isCollapsedAndOneCharShort(newValue) &&
        selection.start == newValue.selection.start + 1 &&
        beforeSelection.substring(0, selection.start - 1) ==
            newValue.beforeSelection &&
        afterSelection == newValue.afterSelection;
  }

  bool _isCollapsedAndOneCharShort(TextEditingValue newValue) {
    return newValue.selection.isCollapsed &&
        selection.isCollapsed &&
        text.length == newValue.text.length + 1;
  }
}
