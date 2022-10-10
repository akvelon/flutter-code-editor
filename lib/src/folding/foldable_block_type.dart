enum FoldableBlockType {
  /// { }
  braces,

  /// [ ]
  brackets,

  /// ( )
  parentheses,

  /// Spaces or tabs.
  indent,

  multilineComment,
  singleLineComment,
  imports,
  union,
}
