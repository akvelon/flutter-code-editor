enum KeywordSemantics {
  /// A keyword that can only be used in an import statement.
  import,

  /// A keyword that can be used in both import statement and a non-import
  /// statement.
  /// Ex.: 'as' in Dart can be used both in `import 'dart:ui' as ui;`
  /// and in `final n = value as int;`
  possibleImport,
}
