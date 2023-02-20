## 0.2.12

* Fix undo/redo bugs (Issues [132](https://github.com/akvelon/flutter-code-editor/issues/132), [186](https://github.com/akvelon/flutter-code-editor/issues/186), [193](https://github.com/akvelon/flutter-code-editor/issues/193)).
* Fix cursor jumping bug ([Issue 182](https://github.com/akvelon/flutter-code-editor/issues/182)).

## 0.2.10

* Added pluggable analyzers support ([Issue 139](https://github.com/akvelon/flutter-code-editor/issues/139)).
* Added `DartPadAnalyzer`.
* Fixed linter issues ([Issue 164](https://github.com/akvelon/flutter-code-editor/issues/164)).

## 0.2.9

* Hiding line numbers, errors, and folding handles ([Issue 159](https://github.com/akvelon/flutter-code-editor/issues/159)).
* Indent new line after `:` in Python ([Issue 135](https://github.com/akvelon/flutter-code-editor/issues/135)).
* Track the test coverage, add the codecov badge ([Issue 146](https://github.com/akvelon/flutter-code-editor/issues/146)).
* Do not pale the editor if a visible section is set ([Issue 153](https://github.com/akvelon/flutter-code-editor/pull/153)).
* Added GIFs to README ([Issue 148](https://github.com/akvelon/flutter-code-editor/issues/148)).
* Fixed 'Index out of range' exception with visible sections on the default factorial example ([Issue 152](https://github.com/akvelon/flutter-code-editor/issues/152)).
* Fixed linter issues ([Issue 147](https://github.com/akvelon/flutter-code-editor/issues/147)).

## 0.2.8

* Java fallback parser preserves foldable blocks if `highlight` fails ([Issue 48](https://github.com/akvelon/flutter-code-editor/issues/48)).

## 0.2.7

* Fix joining nested foldable blocks ([Issue 136](https://github.com/akvelon/flutter-code-editor/issues/136)).

## 0.2.6

* Comment out and uncomment code with Ctrl-/ ([Issue 117](https://github.com/akvelon/flutter-code-editor/issues/117)).

## 0.2.5

* Tab and Shift-Tab handling ([Issue 116](https://github.com/akvelon/flutter-code-editor/issues/116)).
* Selection does not reset redo history ([Issue 133](https://github.com/akvelon/flutter-code-editor/issues/133)).

## 0.2.4

* Exported `StringExtension`.
* Added an example with changing the language and the theme.

## 0.2.3

* Fixed removing listeners in `_CodeFieldState.dispose()`.

## 0.2.2

* Added `CodeController.lastTextSpan` field (visible for testing) to return the last `TextSpan`
produced by `buildTextSpan()`.

## 0.2.1

* Added the migration guide for 0.2 to README.

## 0.2.0

* **BREAKING:** Removed theme from `CodeController`. Use `CodeTheme` widget instead.
* **BREAKING:** Removed `webSpaceFix`, https://github.com/flutter/flutter/issues/77929
* **BREAKING:** Fixed typo `IntendModifier` → `IndentModifier`.
* **BREAKING:** `CodeFieldState` is now private.

## 0.1.15

* Added a missing code file.

## 0.1.14

* Python fallback parser preserves foldable blocks if `highlight` fails ([Issue 49](https://github.com/akvelon/flutter-code-editor/issues/49)).

## 0.1.13

* Remove an accidentally published temp file.

## 0.1.12

* Reformatted the license, updated README.

## 0.1.11

* Updated README.

## 0.1.10

* Fixed formatting.

## 0.1.9

* Read-only blocks are now pale ([Issue 103](https://github.com/akvelon/flutter-code-editor/issues/103)).

## 0.1.8

* Fixed linter issues.

## 0.1.7

* Fixed README errors.

## 0.1.6

* Improved README.

## 0.1.5

* Updated license formatting to match pub.dev requirements.

## 0.1.4
* Added `CodeController.readOnlySectionNames` getter and setter ([Issue 110](https://github.com/akvelon/flutter-code-editor/issues/110)).
* Added `CodeController.foldCommentAtLineZero`, `foldImports`, `foldOutsideSections` ([Issue 89](https://github.com/akvelon/flutter-code-editor/issues/89)).
* Added `CodeController.visibleSectionNames` ([Issue 27](https://github.com/akvelon/flutter-code-editor/issues/27)).
* Fixed folding Python blocks with multiline `if` conditions ([Issue 108](https://github.com/akvelon/flutter-code-editor/issues/108)).
* Fixed folding duplicate blocks like `[{...}]` etc ([Issue 99](https://github.com/akvelon/flutter-code-editor/issues/99)).
* Fixed `cutLineIndexIfVisible` bug ([Issue 112](https://github.com/akvelon/flutter-code-editor/issues/112)).

## 0.1.3

* Custom undo/redo implementation ([Issue 97](https://github.com/akvelon/flutter-code-editor/issues/97)).
* Remove `FoldableBlock` duplicates ([Issue 99](https://github.com/akvelon/flutter-code-editor/issues/99)).
* Copy folded text ([Issue 24](https://github.com/akvelon/flutter-code-editor/issues/24)).

## 0.1.2

* Preserve selection when folding and unfolding ([Issue 81](https://github.com/akvelon/flutter-code-editor/issues/81)).

## 0.1.1

* Added code folding.
* Fixed editing around hidden text ranges.
* Updated dependencies.

## 0.1.0

* Highlights unterminated blocks for Java and Python.

## 0.0.9

* Forked https://github.com/BertrandBev/code_field
* Re-license under the Apache license, mention the original author as the original license required.
* Added hidden service comment support.
* Added read-only blocks support.
* Added autocomplete for keywords, already-in-the-editor words, and external dictionary.
