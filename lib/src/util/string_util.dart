class StringUtil {
  static bool isDigit(String char) {
    if (char.isEmpty || char.length > 1) return false;
    final codeUnit = char.codeUnitAt(0);
    return codeUnit >= 48 && codeUnit <= 57; // Unicode range for '0' to '9'
  }

  static bool isLetterEng(String char) {
    if (char.isEmpty || char.length > 1) return false;
    final codeUnit = char.codeUnitAt(0);
    return (codeUnit >= 65 && codeUnit <= 90) || // A-Z
        (codeUnit >= 97 && codeUnit <= 122); // a-z
  }
}
