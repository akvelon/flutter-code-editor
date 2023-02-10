import '../code/code.dart';

import 'abstract.dart';
import 'models/analysis_result.dart';

class DefaultLocalAnalyzer extends AbstractAnalyzer {
  const DefaultLocalAnalyzer();

  @override
  Future<AnalysisResult> analyze(Code code) async {
    final issues = code.invalidBlocks.map((e) => e.issue).toList(
          growable: false,
        );
    return AnalysisResult(issues: issues);
  }
}
