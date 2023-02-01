import 'dart:async';

import '../../../flutter_code_editor.dart';

/// Service for analzying the code inside CodeField.
///
/// Uses streams to connect incoming new code and outgoing list of issues.
/// Retrieves code from `CodeController` every second
/// and adds to the stream for analysis.
///
/// Inherit and implement [analyze] method to use in [CodeController].
abstract class Analyzer {
  const Analyzer();

  /// Analyzes the code and generates new list of issues.
  Future<List<Issue>> analyze(Code code);

  void dispose() {}
}
