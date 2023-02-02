import '../../code/code.dart';

import '../api/analyzer.dart';
import '../api/models/analysis_result.dart';

class DefaultAnalyzer extends Analyzer {
  const DefaultAnalyzer();

  @override
  Future<AnalysisResult> analyze(Code code) async {
    final issues = code.invalidBlocks.map((e) => e.issue).toList(
          growable: false,
        );
    return AnalysisResult(issues: issues);
  }
}
