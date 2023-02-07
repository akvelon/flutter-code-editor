import '../../../code/code.dart';
import 'issue.dart';

class AnalysisResult {
  final Code analyzedCode;
  final List<Issue> issues;

  const AnalysisResult({
    required this.analyzedCode,
    required this.issues,
  });
}
