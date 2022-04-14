/* Search for syntax errors for java and dart : missing parts of identifier,
for loop errors, missing semicolons. Including comments, strings. */

Map<int, String> findJavaDartErrors(String text) {
  List<String> lines = text.split("\n");
  Map<int, String> errors = {};

  for (int i = 0; i < lines.length; i++) {
    // ignore comments
    if (lines[i].trim().startsWith("//")) {
      continue;
    }
    if (lines[i].startsWith(RegExp("\\s*/\\*"))) {
      while ((!lines[i].contains(RegExp("\\*/\\s*"))) && (i < lines.length - 1)) {
        i++;
      }
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

    // errors with identifier and missing semicolon
    if (lines[i].contains(RegExp("[^<>!=]=[^<>!=]*")) &&
        !lines[i].contains(RegExp("[\"'].*=.*[\"']")) &&
        !lines[i].contains(";")) {
      String command = lines[i];
      while (!lines[i].trim().endsWith(";") && (i < lines.length - 1)) {
        i++;
        command += lines[i];
      }
      if (command.contains(RegExp("=\\s*;"))) {
        errors.addAll({(i + 1): "Missing identifier"});
      }
    } else if (lines[i].contains(RegExp("=\\s*;"))) {
      errors.addAll({(i + 1): "Missing identifier"});
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
      if (!commandFor.contains(RegExp("for.*\\(.*[;].*[;].*\\)"))) {
        errors.addAll({(i + 1): "Missing ';' in for statement"});
      }
    }
  }
  return errors;
}
