import 'package:flutter/widgets.dart';

import '../code/code.dart';
import '../code/code_edit_result.dart';
import '../code/reg_exp.dart';
import '../code/string.dart';
import '../code/text_range.dart';
import '../hidden_ranges/hidden_range.dart';
import 'text_selection.dart';

const _readonlyString = '//readonly ';
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

  TextEditingValue replacedSelection(String value) {
    return replaced(selection, value);
  }

  TextEditingValue replacedText(
    Code code,
    Code oldCode,
    CodeEditResult editResult,
  ) {
    final areVisibleTextsEqual = code.visibleText == oldCode.visibleText;
    final areHiddenRangesEqual = _areHiddenRangesEqual(
      code.hiddenRanges.ranges,
      oldCode.hiddenRanges.ranges,
    );

    if (areHiddenRangesEqual) {
      return this;
    }

    int? offset;
    if (areVisibleTextsEqual) {
      final rangeAfter = code.visibleText.getChangedRange(
        text,
        attributeChangeTo: TextAffinity.upstream,
      );

      offset = rangeAfter.start;
    } else {
      var insertedHiddenRangesLength = text.length - code.visibleText.length;
      if (text.contains(_readonlyString)) {
        insertedHiddenRangesLength -= _getCharacterCountAfterReadonlyString(text);
      }
      offset = selection.end - insertedHiddenRangesLength;
    }
    return TextEditingValue(
        text: code.visibleText,
        selection: TextSelection.collapsed(
          offset: offset,
        ),
      );
  }

  bool _areHiddenRangesEqual(
    Iterable<HiddenRange> hiddenRanges,
    Iterable<HiddenRange> oldHiddenRanges,
  ) {
    if (hiddenRanges.length != oldHiddenRanges.length) {
      return false;
    }

    final list = hiddenRanges.toList();
    final oldList = oldHiddenRanges.toList();

    for (int i = 0; i < hiddenRanges.length; i++) {
      if (list[i] != oldList[i]) {
        return false;
      }
    }

    return true;
  }

  int _getCharacterCountAfterReadonlyString(String text) {
    var result = 0;
    final readonlyString = _readonlyString.allMatches(text);
    for (final match in readonlyString) {
      var index = match.end;
      while(text[index] != '\n') {
        result++;
        index++;
      }
    }
    return result;
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
}
