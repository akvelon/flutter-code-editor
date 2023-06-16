import 'dart:math';

import 'package:flutter/widgets.dart';

import '../code_field/text_editing_value.dart';
import 'edit_type.dart';

extension StringExtension on String {
  /// Returns a [TextRange] around selection in [oldValue]
  /// that is different from this.
  ///
  /// This is useful if the ordinary diff with [getChangedRange]
  /// may be ambiguous. This method tests for the most common changes
  /// and snaps the changed range to the old selection.
  ///
  /// Handles these special cases:
  /// - Selected text is replaced / deleted / inserted, outside is unchanged.
  /// - Deleted at a collapsed selection.
  ///
  /// Returns null if neither of the above cases apply.
  TextRange? getChangedRangeAroundSelection(TextEditingValue oldValue) {
    final oldBefore = oldValue.beforeSelection;
    final oldAfter = oldValue.afterSelection;
    final oldLength = oldBefore.length + oldAfter.length;

    final editType = _getEditType(
      oldBefore: oldBefore,
      oldAfter: oldAfter,
      oldLength: oldLength,
    );
    switch (editType) {
      case EditType.backspaceBeforeCollapsedSelection:
        final start = oldBefore.length - (oldLength - length);
        final end = oldBefore.length;
        return TextRange(
          start: 0,
          end: 1,
        );
      case EditType.deleteAfterCollapsedSelection:
        return TextRange(
          start: oldBefore.length,
          end: length,
        );
      case EditType.replacedSelection:
        return TextRange(
          start: oldBefore.length,
          end: length - oldAfter.length,
        );
      case null:
        return null;
    }
  }

  EditType? _getEditType({
    required String oldBefore,
    required String oldAfter,
    required int oldLength,
  }) {
    if (length < oldLength) {
      if (startsWith(oldBefore)) {
        return EditType.deleteAfterCollapsedSelection;
      }
      if (endsWith(oldAfter)) {
        return EditType.backspaceBeforeCollapsedSelection;
      }
    }

    final newBefore = substring(0, oldBefore.length);
    final newAfter = substring(length - oldAfter.length - 1);
    if (newBefore + newAfter != this &&
        oldBefore == newBefore &&
        oldAfter == newAfter) {
      return EditType.replacedSelection;
    }

    return null;
  }

  /// Returns the widest [TextRange] of this that is different from [old].
  ///
  /// `start` refers to the common prefix. It is the first character of this
  /// that is different from the corresponding character of [old].
  ///
  /// `end` refers to the common suffix. It is the first character of this
  /// after the diff that matches the corresponding character of [old].
  ///
  /// `null` is returned for equal strings.
  ///
  /// [attributeChangeTo] affects where the change is attributed in ambiguous
  /// cases:
  ///  - Inserting a duplicate: aBc -> aBBc
  ///  - Deletion of a duplicate: aBBc -> aBc
  ///
  /// This method should be used if [getChangedRangeAroundSelection] failed.
  TextRange getChangedRange(
    String old, {
    required TextAffinity attributeChangeTo,
  }) {
    if (this == old) {
      return TextRange.empty;
    }

    switch (attributeChangeTo) {
      case TextAffinity.upstream:
        return _getChangedRangeAttributeChangeUpstream(old);
      case TextAffinity.downstream:
        return _getChangedRangeAttributeChangeDownstream(old);
    }
  }

  TextRange _getChangedRangeAttributeChangeUpstream(String old) {
    final minLast = max(0, length - old.length) - 1;
    int start = 0;
    int last = length - 1;
    int oldLast = old.length - 1;

    while (last > minLast && this[last] == old[oldLast]) {
      last--;
      oldLast--;
    }

    final maxStart = min(last, oldLast) + 1;
    while (start < maxStart && this[start] == old[start]) {
      start++;
    }

    return TextRange(start: start, end: last + 1);
  }

  TextRange _getChangedRangeAttributeChangeDownstream(String old) {
    final minLength = min(length, old.length);
    int start = 0;
    int last = length - 1;
    int oldLast = old.length - 1;

    while (start < minLength && this[start] == old[start]) {
      start++;
    }

    final minLast = start + max(0, length - old.length) - 1;
    while (last > minLast && this[last] == old[oldLast]) {
      last--;
      oldLast--;
    }

    return TextRange(start: start, end: last + 1);
  }

  String tabsToSpaces(int spaceCount) {
    return replaceAll('\t', ' ' * spaceCount);
  }

  bool hasOnlyWhitespaces() => trim() == '';
}
