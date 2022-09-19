enum FoldableBlockType {
  /// { }
  braces,

  /// [ ]
  brackets,

  /// ( )
  parentheses,

  //just for python
  spaces,

  multilineComment,
  singleLineComment,
  imports,
}
