/* Search for syntax errors for python : indentation errors.
 Including comments, strings. */

Map<int, String> findPythonErrorTabs(String text) {
  List<String> lines = text.split("\n");
  Map<int, String> errors = {};
  bool isPreviousLineContainsColon = false;
  int previousCountOfSpace = 0;

  for (int i = 0; i < lines.length; i++) {
    int countOfSpace = 0;

    if (lines[i].trim().isEmpty || lines[i].startsWith(RegExp("\\s*#"))) {
      continue;
    }

    // ignore multiline String var
    if (lines[i].contains(RegExp("'''")) && (!lines[i].contains(RegExp("[\"'].*'''.*[\"']")))) {
      do {
        if (lines[i].contains(RegExp("'''.*'''"))) break;
        i++;
      } while ((!lines[i].contains(RegExp("'''"))) && (i < lines.length - 1));
    } else if (lines[i].contains(RegExp("\"\"\"")) &&
        (!lines[i].contains(RegExp("[\"'].*\"\"\".*[\"']")))) {
      do {
        if (lines[i].contains(RegExp("\"\"\".*\"\"\""))) break;
        i++;
      } while ((!lines[i].contains(RegExp("\"\"\""))) && (i < lines.length - 1));
    }

    int lineLength = lines[i].length;
    while (lines[i][countOfSpace] == " " && (countOfSpace < lineLength)) {
      countOfSpace++;
    }

    if (isPreviousLineContainsColon == true && (previousCountOfSpace + 4) != countOfSpace) {
      errors.addAll({(i + 1): "error in indents"});
    }

    previousCountOfSpace = countOfSpace;

    if ((lineLength > 2) &&
        ((lines[i][lineLength - 1] == ":") || (lines[i].contains(RegExp(":\\s*#"))))) {
      isPreviousLineContainsColon = true;
    } else {
      isPreviousLineContainsColon = false;
    }
  }

  return errors;
}
