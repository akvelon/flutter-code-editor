import 'dart:async';

import '../../code/code.dart';
import '../../code_field/code_controller.dart';
import '../../code_field/code_field.dart';
import 'models/analysis_result.dart';

/// Service for analyzing the code inside [CodeField].
///
/// Inherit and implement [analyze] method to use in [CodeController].
abstract class Analyzer {
  const Analyzer();

  /// Analyzes the code and generates new list of issues.
  Future<AnalysisResult> analyze(Code code);

  void dispose() {}
}
