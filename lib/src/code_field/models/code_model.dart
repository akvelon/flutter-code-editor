import 'package:flutter/material.dart';

import 'code_line_model.dart';

class CodeModel {
  final String code;
  late final List<CodeLineModel> lines;
  late final List<CodeLineModel> readOnlyLines;

  static final _cache = {};

  factory CodeModel({required String code}) {
    return _cache.putIfAbsent(code, () => CodeModel._(code));
  }

  CodeModel._(this.code) {
    lines = splitTextToLines(code);
    readOnlyLines = getReadOnlyLines(lines);
  }

  List<CodeLineModel> splitTextToLines(String text) {
    int positionIndex = 0;
    int lineCounter = 0;
    List<String> codeLines = [];
    List<CodeLineModel> lines = [];

    if (text.isNotEmpty) {
      codeLines = text.split('\n');

      for (String line in codeLines) {
        lineCounter++;
        if (lines.isNotEmpty) {
          positionIndex++;
        }
        lines.add(
          CodeLineModel(
            text: line,
            lineNumber: lineCounter,
            startIndex: positionIndex,
            endIndex: positionIndex + line.length,
            isReadOnly: line.contains('//readonly'),
          ),
        );
        positionIndex += line.length;
      }
    }
    return lines;
  }

  List<CodeLineModel> getReadOnlyLines(List<CodeLineModel> lines) {
    List<CodeLineModel> readOnlyLines = [];

    for (var line in lines) {
      if (line.isReadOnly) {
        readOnlyLines.add(line);
      }
    }

    return readOnlyLines;
  }

  bool isSelectionHitReadOnlyLines(
    String text,
    TextSelection selection,
    List<CodeLineModel> readOnlyLines,
  ) {
    if (selection.isCollapsed) {
      for (var line in readOnlyLines) {
        if (line.startIndex <= selection.baseOffset &&
            selection.baseOffset <= line.endIndex) {
          return true;
        }
      }
      return false;
    } else {
      for (var line in readOnlyLines) {
        List<int> lineRange = [
          for (var i = line.startIndex; i <= line.endIndex; i++) i
        ];
        List<int> selectionRange = getSelectionRange(selection);

        for (int index in selectionRange) {
          if (lineRange.contains(index)) {
            return true;
          }
        }
      }
      return false;
    }
  }

  List<int> getSelectionRange(TextSelection selection) {
    if (selection.baseOffset < selection.extentOffset) {
      return [
        for (var i = selection.baseOffset; i <= selection.extentOffset; i++) i
      ];
    } else {
      return [
        for (var i = selection.extentOffset; i <= selection.baseOffset; i++) i
      ];
    }
  }
}
