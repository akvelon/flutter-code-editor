const brackets = {'(': ')', '{': '}', '[': ']'};

Map<int, String> countingBrackets(String text) {
  int lineNumber = 1;
  String stackBrackets = "";
  Map<int, String> errors = {};
  List<int> errorsLocations = [];
  bool isCharInString = false;
  bool isShieldingInString = false;
  String openOneLineString = "";
  String openMultiLineString = "";

  for (int i = 0; i < text.length; i++) {
    String char = text[i];

    if (char == "\n") {
      lineNumber++;
      continue;
    } else if (char == "/" && i < text.length - 1 && text[i + 1] == char && !isCharInString) {
      while (char != "\n" && i < text.length - 1) {
        i++;
        char = text[i];
      }
      lineNumber++;
    } else if (char == "/" && i < text.length - 1 && text[i + 1] == "*" && !isCharInString) {
      while (char != "*" && i < text.length - 1 && text[i + 1] == "/") {
        i++;
        char = text[i];
      }
    } else if (((i + 2) < text.length) &&
        (char == "'" || char == "\"") &&
        (char == text[i + 1]) &&
        (text[i + 1] == text[i + 2])) {
      i = i + 2;
      if (openMultiLineString == "") {
        openMultiLineString = char;
      } else if ((openMultiLineString == char) && isCharInString) {
        openMultiLineString = "";
      } else {
        continue;
      }
      if (isCharInString) {
        isCharInString = false;
      } else {
        isCharInString = true;
      }
    } else if ((char == "'" || char == "\"") && openMultiLineString == "") {
      if (i - 1 >= 0 && (text[i - 1] == "\\")) {
        if ((i - 2 >= 0) && (text[i - 2] != "\\")) {
          continue;
        }
      }
      if (openOneLineString == "") {
        openOneLineString = char;
      } else if ((openOneLineString == char) && isCharInString) {
        openOneLineString = "";
      } else {
        continue;
      }
      if (isCharInString) {
        isCharInString = false;
      } else {
        isCharInString = true;
      }
    } else if ((char == "\$") &&
        ((i + 1) < text.length) &&
        (text[i + 1] == "{") &&
        isCharInString) {
      isShieldingInString = true;
      isCharInString = false;
      i++;
    } else if (isShieldingInString && (char == "}")) {
      isShieldingInString = false;
      isCharInString = true;
    } else if (isCharInString) {
      continue;
    } else if ((char == "(") | (char == "[") | (char == "{")) {
      stackBrackets = stackBrackets + char;
      errorsLocations.add(lineNumber);
    } else if ((char == ")") | (char == "]") | (char == "}")) {
      if (stackBrackets == "") {
        if (errors.containsKey(lineNumber)) {
          errors[lineNumber] = errors[lineNumber]! + "\n" + "Unexpected symbol";
        } else {
          errors.addAll({lineNumber: "Unexpected symbol"});
        }
      } else if (char != brackets[stackBrackets[stackBrackets.length - 1]]) {
        if (errors.containsKey(lineNumber)) {
          errors[lineNumber] = errors[lineNumber]! +
              "\n" +
              "Expected to find '${brackets[stackBrackets[stackBrackets.length - 1]]}', but founded $char";
        } else {
          errors.addAll({
            lineNumber:
                "Expected to find '${brackets[stackBrackets[stackBrackets.length - 1]]}', but founded $char"
          });
        }
      } else {
        stackBrackets = stackBrackets.substring(0, stackBrackets.length - 1);
        errorsLocations.removeLast();
      }
    }
  }

  if (stackBrackets.isNotEmpty) {
    if (errors.containsKey(errorsLocations[errorsLocations.length - 1])) {
      errors[errorsLocations[errorsLocations.length - 1]] =
          errors[errorsLocations[errorsLocations.length - 1]]! + "\n" + "Missing bracket";
    } else {
      errors.addAll({errorsLocations[errorsLocations.length - 1]: "Missing bracket"});
    }
  }

  return errors;
}
