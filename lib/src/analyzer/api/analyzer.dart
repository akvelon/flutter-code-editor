import 'dart:async';

import '../../code/code.dart';
import 'models/analysis_result.dart';

/// Service for analzying the code inside CodeField.
///
/// Inherit and implement [analyze] method to use in `CodeController`.
abstract class Analyzer {
  const Analyzer();

  /// Analyzes the code and generates new list of issues.
  Future<AnalysisResult> analyze(Code code);

  void dispose() {}
}
