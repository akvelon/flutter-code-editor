/* Search for syntax errors for scala : missing data type,
for loop errors. Including comments, strings. */

Map<int, String> findScalaErrors(String text) {
  List<String> lines = text.split("\n");
  Map<int, String> errors = {};

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim().isEmpty || lines[i].startsWith(RegExp("\\s*//"))) {
      continue;
    }
    if (lines[i].startsWith(RegExp("\\s*/\\*"))) {
      while (
          (!lines[i].contains(RegExp("\\*/\\s*"))) && (i < lines.length - 1)) {
        i++;
        lines[i] = lines[i];
      }
    }

    if (lines[i].contains(RegExp(":\\s*="))) {
      errors.addAll({(i + 1): "Missing type"});
    }

    // error in for construct
    if (lines[i].contains(RegExp("\\s*for\\s*\\(")) &&
        (!lines[i].contains(RegExp("[\"']\\s*for\\s*\\([\"']"))) &&
        (!lines[i].contains(RegExp("//\\s*for\\s*\\(")))) {
      String commandFor = "";
      while (!lines[i].contains(RegExp("\\)")) && (i < lines.length - 1)) {
        commandFor += lines[i];
        i++;
        lines[i] = lines[i];
      }
      commandFor += lines[i];
      if (!commandFor.contains(RegExp("for.*\\(.*<-.*\\)"))) {
        errors.addAll({(i + 1): "Missing '<-' in for statement"});
      }
    }
  }

  return errors;
}
