import '../../../code/code.dart';
import 'issue.dart';

class AnalysisResult {
  final List<Issue> issues;
  final Code analyzedCode;

  const AnalysisResult({
    required this.issues,
    required this.analyzedCode,
  });
}
