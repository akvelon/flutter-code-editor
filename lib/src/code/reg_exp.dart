class RegExps {
  static final emptyLine = RegExp(r'^\s*$');
  static final whiteSpacesAfterStartOfLine = RegExp(r'^\s*');
  static final wordSplit = RegExp('[^_a-zA-Z0-9]+');

  static RegExp getSingleLineCommentRegExp(
    String commentType, {
    bool multiline = false,
  }) {
    return RegExp(
      r'^\s*' // starts with start of the line + any number of whitespaces
          +
          commentType // then goes single line comment symbol(s)
          +
          r'.*$', // ends with anything + end of the line
      multiLine: multiline,
    );
  }

  static RegExp getCommentPlusWhitespaceRegExp(String commentType) {
    return RegExp(commentType + r'\s?');
  }
}
